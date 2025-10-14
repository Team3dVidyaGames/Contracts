# LootVault
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e59a3c26fbd24f4aff21370c713588eae3cb43b1/src/contracts/lootcrate/LootVault.sol)

**Inherits:**
Ownable, ReentrancyGuard, ERC1155Holder, ERC721Holder


## State Variables
### ETHID

```solidity
uint256 public ETHID = 0;
```


### ERC20ID

```solidity
uint256 public ERC20ID = 20;
```


### ERC1155ID

```solidity
uint256 public ERC1155ID = 1155;
```


### ERC721ID

```solidity
uint256 public ERC721ID = 721;
```


## Functions
### constructor


```solidity
constructor(address _owner) Ownable(_owner);
```

### onERC1155Received


```solidity
function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4);
```

### onERC721Received


```solidity
function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4);
```

### claimLoot


```solidity
function claimLoot(address lootToken, uint256 tokenId, uint256 amount, address to) external onlyOwner;
```

### receive


```solidity
receive() external payable;
```

