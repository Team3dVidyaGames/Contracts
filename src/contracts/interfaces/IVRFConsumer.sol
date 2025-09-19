// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

interface IVRFConsumer {
    // Core VRF Functions
    function requestRandomness(uint32 numWords) external payable returns (uint256);

    function getRandomness(uint256 requestId) external view returns (uint256[] memory);

    function getRandomnessPosition(uint256[] memory randomnessPosition) external payable returns (uint256[] memory);

    // Role Management Functions
    function setRequesterRole(address _requester, bool _grant, bool _free) external;

    function setRandomnessViewerRole(address _randomnessViewer, bool _grant) external;

    // Configuration Functions
    function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external;

    function setEthOverfundAddress(address _ethOverfundAddress) external;

    function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external;

    function setFees(uint256 _requestFee, uint256 _viewerFee, uint256 _holdingFeesAmount) external;

    function setKeyHash(bytes32 _keyHash) external;

    function setMaxNumWords(uint256 _maxNumWords) external;

    // View Functions
    function requestIdToSender(uint256 requestId) external view returns (address);

    function requestIdToFullfilled(uint256 requestId) external view returns (bool);

    function randomnessCounter() external view returns (uint256);

    function vrfCoordinator() external view returns (address);

    function subscriptionId() external view returns (uint256);

    function keyHash() external view returns (bytes32);

    function requestConfirmations() external view returns (uint16);

    function callbackGasLimit() external view returns (uint32);

    function requestFee() external view returns (uint256);

    function viewerFee() external view returns (uint256);

    function holdingFeesAmount() external view returns (uint256);

    function openWordRequest() external view returns (uint256);

    function maxNumWords() external view returns (uint256);

    function ethOverfundAddress() external view returns (address);

    // Role Constants
    function ADMIN_ROLE() external view returns (bytes32);

    function REQUESTER_ROLE() external view returns (bytes32);

    function RANDOMNESS_VIEWER() external view returns (bytes32);

    function FREE_ROLE() external view returns (bytes32);
}
