# TemplateCounter
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/fe1c37ad96fd8edc607fe8fc9fe164908c2347f3/src/contracts/agnosia/templateCounter.sol)


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

