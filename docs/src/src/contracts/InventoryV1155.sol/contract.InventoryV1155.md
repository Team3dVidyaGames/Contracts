# InventoryV1155
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/31e6a3daee14ffbd0b191978eeefd42265f32d78/src/contracts/InventoryV1155.sol)

**Inherits:**
[AccessControl](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/abstract.AccessControl.md), ERC1155


## State Variables
### tokenID

```solidity
uint256 public tokenID = 1;
```


### itemData

```solidity
mapping(uint256 => Item) private itemData;
```


### itemAttributeInfo

```solidity
mapping(uint256 => mapping(uint256 => uint256)) public itemAttributeInfo;
```


### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


## Functions
### constructor


```solidity
constructor(string memory baseUri) ERC1155(baseUri);
```

### addItem


```solidity
function addItem(Item memory newItem) external onlyRole(ADMIN_ROLE);
```

### updateItemData


```solidity
function updateItemData(Item memory updateItem, uint256 tokenId) external onlyRole(ADMIN_ROLE);
```

### uri


```solidity
function uri(uint256 tokenId) public view override returns (string memory);
```

### mint


```solidity
function mint(address to, uint256 tokenId, uint256 amount) external onlyRole(MINTER_ROLE);
```

### mintBatch


```solidity
function mintBatch(address to, uint256[] memory ids, uint256[] memory values) external onlyRole(MINTER_ROLE);
```

### burn


```solidity
function burn(address from, uint256 id, uint256 value) external;
```

### burnBatch


```solidity
function burnBatch(address from, uint256[] memory ids, uint256[] memory values) external;
```

### fullBalanceOf


```solidity
function fullBalanceOf(address account) external view returns (uint256[] memory);
```

### tokenExist


```solidity
function tokenExist(uint256 tokenId) public view returns (bool);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC1155) returns (bool);
```

### getCharacterSlot


```solidity
function getCharacterSlot(uint256 tokenId) external view returns (uint256);
```

### itemAttributeIdDetail


```solidity
function itemAttributeIdDetail(uint256 tokenId, uint256 attributeId) external view returns (uint256);
```

### getItemAttributes


```solidity
function getItemAttributes(uint256 tokenId) external view returns (uint256[] memory, uint256[] memory);
```

## Events
### ItemAdded

```solidity
event ItemAdded(uint256 indexed tokenId, address admin);
```

### ItemUpdated

```solidity
event ItemUpdated(uint256 indexed tokenId, address admin);
```

## Errors
### ItemDataAndIDMisMatch

```solidity
error ItemDataAndIDMisMatch(address admin, uint256 length);
```

### TokenDoesNotExist

```solidity
error TokenDoesNotExist(uint256 tokenId);
```

## Structs
### Item

```solidity
struct Item {
    uint256[] attributeData;
    uint256[] attributeId;
    string tokenURI;
    uint256 characterSlot;
}
```

