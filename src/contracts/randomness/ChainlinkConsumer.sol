// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import {VRFConsumerBaseV2Plus} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFConsumer} from "../interfaces/IVRFConsumer.sol";
import {IVRFCoordinatorV2Plus} from
    "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {AccessControl} from "../../../lib/openzeppelin/contracts/access/AccessControl.sol";

contract ChainlinkConsumer is VRFConsumerBaseV2Plus, IVRFConsumer, AccessControl {
    mapping(uint256 => uint256[]) public requestIdToRandomness;
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => bool) public requestIdToFulfilled;

    mapping(uint256 => uint256) public everyRandomnessRequested;
    uint256 public randomnessCounter;

    address public vrfCoordinator;
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint16 public requestConfirmations;
    uint32 public callbackGasLimit;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REQUESTER_ROLE = keccak256("REQUESTER_ROLE");
    bytes32 public constant RANDOMNESS_VIEWER = keccak256("RANDOMNESS_VIEWER");

    constructor(address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(RANDOMNESS_VIEWER, msg.sender);
    }

    function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external onlyRole(ADMIN_ROLE) {
        requestConfirmations = _requestConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external onlyRole(ADMIN_ROLE) {
        require(_vrfCoordinator != address(0), "Invalid VRF coordinator address");
        require(_subscriptionId != 0, "Invalid subscription ID");
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
    }

    function setKeyHash(bytes32 _keyHash) external onlyRole(ADMIN_ROLE) {
        keyHash = _keyHash;
    }

    function _requestRandomWords(uint32 numWords) internal returns (uint256 requestId) {
        requestId = IVRFCoordinatorV2Plus(vrfCoordinator).requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
        requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords)
        internal
        override
        onlyRole(RANDOMNESS_VIEWER)
    {
        for (uint256 i = 0; i < randomWords.length; i++) {
            requestIdToRandomness[requestId].push(randomWords[i]);
            everyRandomnessRequested[randomWords[i]];
            randomnessCounter++;
        }
        requestIdToFulfilled[requestId] = true;
    }

    function requestRandomness(uint32 numWords) external payable override onlyRole(REQUESTER_ROLE) returns (uint256) {
        return _requestRandomWords(numWords);
    }

    function getRandomness(uint256 requestId) external view onlyRole(REQUESTER_ROLE) returns (uint256[] memory) {
        return requestIdToRandomness[requestId];
    }

    function getRandomnessCounter() external view onlyRole(RANDOMNESS_VIEWER) returns (uint256) {
        return randomnessCounter;
    }

    function getRandomnessPosition(uint256 randomnessPosition)
        external
        view
        onlyRole(RANDOMNESS_VIEWER)
        returns (uint256)
    {
        return everyRandomnessRequested[randomnessPosition];
    }
}
