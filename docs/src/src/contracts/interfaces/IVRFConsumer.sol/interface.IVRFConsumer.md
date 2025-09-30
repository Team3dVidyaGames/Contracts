# IVRFConsumer
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/597a494a06b3d5533e4bc67b2d1a7487539c85dc/src/contracts/interfaces/IVRFConsumer.sol)


## Functions
### requestRandomness


```solidity
function requestRandomness(uint32 numWords) external payable returns (uint256);
```

### getRandomness


```solidity
function getRandomness(uint256 requestId) external view returns (uint256[] memory);
```

### getRandomnessPosition


```solidity
function getRandomnessPosition(uint256[] memory randomnessPosition) external payable returns (uint256[] memory);
```

### setRequesterRole


```solidity
function setRequesterRole(address _requester, bool _grant, bool _free) external;
```

### setRandomnessViewerRole


```solidity
function setRandomnessViewerRole(address _randomnessViewer, bool _grant) external;
```

### setParams


```solidity
function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external;
```

### setEthOverfundAddress


```solidity
function setEthOverfundAddress(address _ethOverfundAddress) external;
```

### setVRF


```solidity
function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external;
```

### setFees


```solidity
function setFees(uint256 _requestFee, uint256 _viewerFee, uint256 _holdingFeesAmount) external;
```

### setKeyHash


```solidity
function setKeyHash(bytes32 _keyHash) external;
```

### setMaxNumWords


```solidity
function setMaxNumWords(uint256 _maxNumWords) external;
```

### requestIdToSender


```solidity
function requestIdToSender(uint256 requestId) external view returns (address);
```

### requestIdToFullfilled


```solidity
function requestIdToFullfilled(uint256 requestId) external view returns (bool);
```

### randomnessCounter


```solidity
function randomnessCounter() external view returns (uint256);
```

### vrfCoordinator


```solidity
function vrfCoordinator() external view returns (address);
```

### subscriptionId


```solidity
function subscriptionId() external view returns (uint256);
```

### keyHash


```solidity
function keyHash() external view returns (bytes32);
```

### requestConfirmations


```solidity
function requestConfirmations() external view returns (uint16);
```

### callbackGasLimit


```solidity
function callbackGasLimit() external view returns (uint32);
```

### requestFee


```solidity
function requestFee() external view returns (uint256);
```

### viewerFee


```solidity
function viewerFee() external view returns (uint256);
```

### holdingFeesAmount


```solidity
function holdingFeesAmount() external view returns (uint256);
```

### openWordRequest


```solidity
function openWordRequest() external view returns (uint256);
```

### maxNumWords


```solidity
function maxNumWords() external view returns (uint256);
```

### ethOverfundAddress


```solidity
function ethOverfundAddress() external view returns (address);
```

### ADMIN_ROLE


```solidity
function ADMIN_ROLE() external view returns (bytes32);
```

### REQUESTER_ROLE


```solidity
function REQUESTER_ROLE() external view returns (bytes32);
```

### RANDOMNESS_VIEWER


```solidity
function RANDOMNESS_VIEWER() external view returns (bytes32);
```

### FREE_ROLE


```solidity
function FREE_ROLE() external view returns (bytes32);
```

