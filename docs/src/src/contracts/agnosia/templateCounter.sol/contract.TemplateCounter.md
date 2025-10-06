# TemplateCounter
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/c23d2f00a078c0b63e567bcd930645e3fd252715/src/contracts/agnosia/templateCounter.sol)


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

