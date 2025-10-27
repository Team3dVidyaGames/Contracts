# TemplateCounter
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/b5bfef754acfacd78150cf855fef6e8434ab19d9/src/contracts/agnosia/templateCounter.sol)


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

