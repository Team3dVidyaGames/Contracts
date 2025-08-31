# ChainlinkConsumer
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/fc90ad8d8725236ceebb9463d30d0b5cc0ef20b9/src/contracts/randomness/ChainlinkConsumer.sol)

**Inherits:**
VRFConsumerBaseV2Plus, [IVRFConsumer](/src/contracts/interfaces/IVRFConsumer.sol/interface.IVRFConsumer.md), AccessControl


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


### everyRandomnessRequested

```solidity
mapping(uint256 => uint256) public everyRandomnessRequested;
```


### randomnessCounter

```solidity
uint256 public randomnessCounter;
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


### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### REQUESTER_ROLE

```solidity
bytes32 public constant REQUESTER_ROLE = keccak256("REQUESTER_ROLE");
```


### RANDOMNESS_VIEWER

```solidity
bytes32 public constant RANDOMNESS_VIEWER = keccak256("RANDOMNESS_VIEWER");
```


## Functions
### constructor


```solidity
constructor(address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2Plus(_vrfCoordinator);
```

### setParams


```solidity
function setParams(uint16 _requestConfirmations, uint32 _callbackGasLimit) external onlyRole(ADMIN_ROLE);
```

### setVRF


```solidity
function setVRF(address _vrfCoordinator, uint256 _subscriptionId) external onlyRole(ADMIN_ROLE);
```

### setKeyHash


```solidity
function setKeyHash(bytes32 _keyHash) external onlyRole(ADMIN_ROLE);
```

### _requestRandomWords


```solidity
function _requestRandomWords(uint32 numWords) internal returns (uint256 requestId);
```

### fulfillRandomWords


```solidity
function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords)
    internal
    override
    onlyRole(RANDOMNESS_VIEWER);
```

### requestRandomness


```solidity
function requestRandomness(uint32 numWords) external payable override onlyRole(REQUESTER_ROLE) returns (uint256);
```

### getRandomness


```solidity
function getRandomness(uint256 requestId) external view onlyRole(REQUESTER_ROLE) returns (uint256[] memory);
```

### getRandomnessCounter


```solidity
function getRandomnessCounter() external view onlyRole(RANDOMNESS_VIEWER) returns (uint256);
```

### getRandomnessPosition


```solidity
function getRandomnessPosition(uint256 randomnessPosition)
    external
    view
    onlyRole(RANDOMNESS_VIEWER)
    returns (uint256);
```

