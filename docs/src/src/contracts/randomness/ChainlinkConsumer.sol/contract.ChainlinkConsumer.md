# ChainlinkConsumer
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/b785bda044a71d2e5bb90a7d47ee33be048c0937/src/contracts/randomness/ChainlinkConsumer.sol)

**Inherits:**
VRFConsumerBaseV2Plus, [IVRFConsumer](/src/contracts/interfaces/IVRFConsumer.sol/interface.IVRFConsumer.md)


## State Variables
### requestIdToRandomness

```solidity
mapping(uint256 => uint256[]) public requestIdToRandomness;
```


### requestIdToSender

```solidity
mapping(uint256 => address) public requestIdToSender;
```


### requestIdToFulfilled

```solidity
mapping(uint256 => bool) public requestIdToFulfilled;
```


### vrfCoordinator

```solidity
address public vrfCoordinator;
```


### subscriptionId

```solidity
uint256 public subscriptionId;
```


### keyHash

```solidity
bytes32 public keyHash;
```


### requestConfirmations

```solidity
uint16 public requestConfirmations;
```


### callbackGasLimit

```solidity
uint32 public callbackGasLimit;
```


## Functions
### constructor


```solidity
constructor(address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2Plus(_vrfCoordinator);
```

### setParams


```solidity
function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external;
```

### setVRF


```solidity
function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external;
```

### setKeyHash


```solidity
function setKeyHash(bytes32 _keyHash) external;
```

### requestRandomWords


```solidity
function requestRandomWords(uint32 numWords) internal returns (uint256);
```

### fulfillRandomWords


```solidity
function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override;
```

### requestRandomness


```solidity
function requestRandomness(uint32 numWords) external payable override returns (uint256);
```

### getRandomness


```solidity
function getRandomness(uint256 requestId) external view returns (uint256[] memory);
```

