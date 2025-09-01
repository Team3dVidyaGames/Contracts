# IVRFConsumer
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/8a9ab064a51b9ac58b16f10ebc77025047982a5b/src/contracts/interfaces/IVRFConsumer.sol)


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

