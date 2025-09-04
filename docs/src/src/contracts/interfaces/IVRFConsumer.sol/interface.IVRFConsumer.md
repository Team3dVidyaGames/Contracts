# IVRFConsumer
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/89b178e6ffa791443426be90fc6b186536acbc57/src/contracts/interfaces/IVRFConsumer.sol)


## Functions
### getRandomness


```solidity
function getRandomness(uint256) external view returns (uint256[] memory);
```

### requestRandomness


```solidity
function requestRandomness(uint32 numWords) external payable returns (uint256);
```

### getRandomnessPosition


```solidity
function getRandomnessPosition(uint256[] memory randomnessPosition) external payable returns (uint256[] memory);
```

