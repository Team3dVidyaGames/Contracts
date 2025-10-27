# TemplateCounter
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/b8947e8078c83c021a621910f8949582d5e5b7a1/src/contracts/agnosia/templateCounter.sol)


## State Variables
### inventoryContract

```solidity
ITCGInventory private inventoryContract;
```


### gameContract

```solidity
IGame private gameContract;
```


## Functions
### constructor


```solidity
constructor(address _tcgInventoryAddress, address _gameAddress);
```

### countTemplatesByOwner


```solidity
function countTemplatesByOwner(address owner) public view returns (TemplateCount[] memory);
```

## Structs
### TemplateCount

```solidity
struct TemplateCount {
    uint256 templateId;
    uint256 count;
}
```

