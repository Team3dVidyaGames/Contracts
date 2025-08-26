// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import {VRFConsumerBaseV2Plus} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFConsumer} from "../interfaces/IVRFConsumer.sol";
import {IVRFCoordinatorV2Plus} from
    "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

contract ChainlinkConsumer is VRFConsumerBaseV2Plus, IVRFConsumer {
    mapping(uint256 => uint256[]) public requestIdToRandomness;
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => bool) public requestIdToFulfilled;

    address public vrfCoordinator;
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint16 public requestConfirmations;
    uint32 public callbackGasLimit;

    constructor(address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
    }

    function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external {
        requestConfirmations = _requestConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external {
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
    }

    function setKeyHash(bytes32 _keyHash) external {
        keyHash = _keyHash;
    }

    function requestRandomWords(uint32 numWords) internal returns (uint256) {
        return IVRFCoordinatorV2Plus(vrfCoordinator).requestRandomWords(
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
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        for (uint256 i = 0; i < randomWords.length; i++) {
            requestIdToRandomness[requestId].push(randomWords[i]);
        }
        requestIdToFulfilled[requestId] = true;
    }

    function requestRandomness(uint32 numWords) external payable override returns (uint256) {
        return requestRandomWords(numWords);
    }

    function getRandomness(uint256 requestId) external view returns (uint256[] memory) {
        return requestIdToRandomness[requestId];
    }
}
