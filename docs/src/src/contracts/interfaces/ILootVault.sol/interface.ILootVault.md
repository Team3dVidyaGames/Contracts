# ILootVault
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/fe1c37ad96fd8edc607fe8fc9fe164908c2347f3/src/contracts/interfaces/ILootVault.sol)


## Functions
### NATIVEID


```solidity
function NATIVEID() external pure returns (uint256);
```

### ERC20ID


```solidity
function ERC20ID() external pure returns (uint256);
```

### ERC1155ID


```solidity
function ERC1155ID() external pure returns (uint256);
```

### ERC721ID


```solidity
function ERC721ID() external pure returns (uint256);
```

### claimLoot


```solidity
function claimLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, address to) external;
```

### receive


```solidity
receive() external payable;
```

## Events
### LootClaimed

```solidity
event LootClaimed(
    address indexed lootToken, uint256 ercID, uint256 indexed tokenId, uint256 amount, address indexed to
);
```

## Errors
### InvalidErcID

```solidity
error InvalidErcID(uint256 _ercID);
```

### InvalidAddresses

```solidity
error InvalidAddresses(address _lootToken, address _to);
```

### InsufficientBalance

```solidity
error InsufficientBalance(uint256 _available, uint256 _required);
```

