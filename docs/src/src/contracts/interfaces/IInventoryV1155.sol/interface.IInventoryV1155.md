# IInventoryV1155
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/52288bdfdb36e7d411f3af7497ebd4d7a6c6f363/src/contracts/interfaces/IInventoryV1155.sol)

**Inherits:**
IERC1155, IAccessControl


## Functions
### tokenID


```solidity
function tokenID() external view returns (uint256);
```

### itemAttributeInfo


```solidity
function itemAttributeInfo(uint256, uint256) external view returns (uint256);
```

### uri


```solidity
function uri(uint256 tokenId) external view returns (string memory);
```

### tokenExist


```solidity
function tokenExist(uint256 tokenId) external view returns (bool);
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

### fullBalanceOf


```solidity
function fullBalanceOf(address account) external view returns (uint256[] memory);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

### addItem


```solidity
function addItem(Item memory newItem) external;
```

### updateItemData


```solidity
function updateItemData(Item memory updateItem, uint256 tokenId) external;
```

### mint


```solidity
function mint(address to, uint256 tokenId, uint256 amount) external;
```

### mintBatch


```solidity
function mintBatch(address to, uint256[] memory ids, uint256[] memory values) external;
```

### burn


```solidity
function burn(address from, uint256 id, uint256 value) external;
```

### burnBatch


```solidity
function burnBatch(address from, uint256[] memory ids, uint256[] memory values) external;
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

