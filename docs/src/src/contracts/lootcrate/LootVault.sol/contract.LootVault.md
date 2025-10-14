# LootVault
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/c2c2953897142b895776d58e8b608d1002e4b685/src/contracts/lootcrate/LootVault.sol)

**Inherits:**
Ownable, ReentrancyGuard, ERC1155Holder, ERC721Holder


## State Variables
### NATIVEID

```solidity
uint256 public constant NATIVEID = 0;
```


### ERC20ID

```solidity
uint256 public constant ERC20ID = 20;
```


### ERC1155ID

```solidity
uint256 public constant ERC1155ID = 1155;
```


### ERC721ID

```solidity
uint256 public constant ERC721ID = 721;
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
function claimLoot(address lootToken, uint256 tokenId, uint256 amount, address to) external onlyOwner nonReentrant;
```

### receive


```solidity
receive() external payable;
```

