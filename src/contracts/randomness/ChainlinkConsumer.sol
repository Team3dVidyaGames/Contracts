// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import {VRFConsumerBaseV2Plus} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFConsumer} from "../interfaces/IVRFConsumer.sol";
import {IVRFCoordinatorV2Plus} from
    "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {IVRFSubscriptionV2Plus} from
    "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFSubscriptionV2Plus.sol";
import {AccessControl} from "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IVRFSubscriptionV2Plus} from
    "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFSubscriptionV2Plus.sol";

contract ChainlinkConsumer is VRFConsumerBaseV2Plus, IVRFConsumer, AccessControl, ReentrancyGuard {
    event TransferFailed(address indexed ethOverfundAddress);
    event RandomWordsRequested(uint256 indexed requestId, uint256 numWords, address indexed requester);
    event RandomWordsFullfilled(uint256 indexed requestId, address indexed requester);
    event RandomWordsPositionRequested(address indexed requester, uint256[] randomNumbers);

    mapping(uint256 => uint256[]) private requestIdToRandomness;
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => bool) public requestIdToFullfilled;

    mapping(uint256 => uint256) private everyRandomnessRequested;
    uint256 public randomnessCounter;

    address public vrfCoordinator;
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint16 public requestConfirmations;
    uint32 public callbackGasLimit;
    uint256 public requestFee;
    uint256 public viewerFee;
    uint256 public holdingFeesAmount;
    uint256 public openWordRequest;
    uint256 public maxNumWords;

    address public ethOverfundAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REQUESTER_ROLE = keccak256("REQUESTER_ROLE");
    bytes32 public constant RANDOMNESS_VIEWER = keccak256("RANDOMNESS_VIEWER");
    bytes32 public constant FREE_ROLE = keccak256("FREE_ROLE");

    constructor(address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
        ethOverfundAddress = msg.sender;
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(RANDOMNESS_VIEWER, msg.sender);
        _grantRole(FREE_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(RANDOMNESS_VIEWER, ADMIN_ROLE);
        _setRoleAdmin(REQUESTER_ROLE, ADMIN_ROLE);
    }

    function setRequesterRole(address _requester, bool _grant, bool _free) external onlyRole(ADMIN_ROLE) {
        if (_grant) {
            _grantRole(REQUESTER_ROLE, _requester);
        } else {
            _revokeRole(REQUESTER_ROLE, _requester);
        }
        if (_free) {
            _grantRole(FREE_ROLE, _requester);
        } else {
            _revokeRole(FREE_ROLE, _requester);
        }
    }

    function setRandomnessViewerRole(address _randomnessViewer, bool _grant) external onlyRole(ADMIN_ROLE) {
        if (_grant) {
            _grantRole(RANDOMNESS_VIEWER, _randomnessViewer);
        } else {
            _revokeRole(RANDOMNESS_VIEWER, _randomnessViewer);
        }
    }

    function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external onlyRole(ADMIN_ROLE) {
        requestConfirmations = _requestConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    function setEthOverfundAddress(address _ethOverfundAddress) external onlyRole(ADMIN_ROLE) {
        ethOverfundAddress = _ethOverfundAddress;
    }

    function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external onlyRole(ADMIN_ROLE) {
        require(_vrfCoordinator != address(0), "Invalid VRF coordinator address");
        require(_subscriptionId != 0, "Invalid subscription ID");
        vrfCoordinator = _vrfCoordinator;
        subscriptionId = _subscriptionId;
    }

    function setFees(uint256 _requestFee, uint256 _viewerFee, uint256 _holdingFeesAmount)
        external
        onlyRole(ADMIN_ROLE)
    {
        requestFee = _requestFee;
        viewerFee = _viewerFee;
        holdingFeesAmount = _holdingFeesAmount;
    }

    function setKeyHash(bytes32 _keyHash) external onlyRole(ADMIN_ROLE) {
        keyHash = _keyHash;
    }

    function setMaxNumWords(uint256 _maxNumWords) external onlyRole(ADMIN_ROLE) {
        maxNumWords = _maxNumWords;
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
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
            })
        );
        requestIdToSender[requestId] = msg.sender;
        openWordRequest += uint256(numWords);
        emit RandomWordsRequested(requestId, numWords, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        for (uint256 i = 0; i < randomWords.length; i++) {
            requestIdToRandomness[requestId].push(randomWords[i]);
            everyRandomnessRequested[randomWords[i]];
            randomnessCounter++;
        }
        requestIdToFullfilled[requestId] = true;
        if (openWordRequest >= uint256(randomWords.length)) {
            openWordRequest -= uint256(randomWords.length);
        } else {
            openWordRequest = 0;
        }
        emit RandomWordsFullfilled(requestId, requestIdToSender[requestId]);
    }

    function requestRandomness(uint32 numWords)
        external
        payable
        override
        onlyRole(REQUESTER_ROLE)
        nonReentrant
        returns (uint256)
    {
        if (!hasRole(FREE_ROLE, msg.sender)) {
            require(msg.value >= requestFee, "Not enough ETH sent");
            _sendSubscriptionFees();
        }

        require(numWords <= maxNumWords, "Number of words exceeds max number of words");

        return _requestRandomWords(numWords);
    }

    function getRandomness(uint256 requestId) external view onlyRole(REQUESTER_ROLE) returns (uint256[] memory) {
        require(requestIdToFullfilled[requestId], "Request not fullfilled");
        require(requestIdToSender[requestId] == msg.sender, "Not the requester");
        return requestIdToRandomness[requestId];
    }

    function getRandomnessPosition(uint256[] memory randomnessPosition)
        external
        payable
        nonReentrant
        returns (uint256[] memory)
    {
        uint256 length = randomnessPosition.length;
        if (!hasRole(RANDOMNESS_VIEWER, msg.sender)) {
            require(msg.value >= viewerFee * length, "Not enough ETH sent");
            _sendSubscriptionFees();
        }
        uint256[] memory randomNumbers = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            randomNumbers[i] = everyRandomnessRequested[randomnessPosition[i]];
        }
        emit RandomWordsPositionRequested(msg.sender, randomNumbers);
        return randomNumbers;
    }

    function _sendSubscriptionFees() internal {
        (, uint96 nativeBalance,,,) = IVRFSubscriptionV2Plus(vrfCoordinator).getSubscription(subscriptionId);

        if (nativeBalance < holdingFeesAmount) {
            IVRFSubscriptionV2Plus(vrfCoordinator).fundSubscriptionWithNative{value: address(this).balance}(
                subscriptionId
            );
        } else {
            //transfer low level call the extra eth to the ethOverfundAddress
            (bool success,) = payable(ethOverfundAddress).call{value: address(this).balance}("");
            if (!success) {
                emit TransferFailed(ethOverfundAddress);
            }
        }
    }
}
