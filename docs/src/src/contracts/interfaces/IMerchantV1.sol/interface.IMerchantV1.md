# IMerchantV1
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/b785bda044a71d2e5bb90a7d47ee33be048c0937/src/contracts/interfaces/IMerchantV1.sol)

*Interface for the MerchantV1 contract*


## Functions
### SHOP_ROLE


```solidity
function SHOP_ROLE() external view returns (bytes32);
```

### treasury


```solidity
function treasury() external view returns (address);
```

### inventory1155


```solidity
function inventory1155() external view returns (address);
```

### getUnitPrice


```solidity
function getUnitPrice(uint256 merchandiseId) external view returns (uint256 unitPrice, bool isActive);
```

### getMerchandise


```solidity
function getMerchandise(uint256 merchandiseId) external view returns (Merchandise memory);
```

### getMerchandiseCount


```solidity
function getMerchandiseCount() external view returns (uint256);
```

### setTreasury


```solidity
function setTreasury(address _treasury) external;
```

### setInventory1155


```solidity
function setInventory1155(address _inventory1155) external;
```

### setMerchandiseActive


```solidity
function setMerchandiseActive(uint256 merchandiseId, bool isActive) external;
```

### setMerchandiseUnitPrice


```solidity
function setMerchandiseUnitPrice(uint256 merchandiseId, uint256 unitPrice) external;
```

### addMerchandise


```solidity
function addMerchandise(uint256 tokenId, uint256 unitPrice, uint256 quantity) external;
```

### buyMerchandise


```solidity
function buyMerchandise(uint256 merchandiseId, uint256 quantity) external payable;
```

### buyMerchandiseBatch


```solidity
function buyMerchandiseBatch(uint256[] memory merchandiseIds, uint256[] memory quantities) external payable;
```

### restockMerchandise


```solidity
function restockMerchandise(uint256 merchandiseId, uint256 quantity) external;
```

### withdraw


```solidity
function withdraw() external;
```

## Events
### TreasuryUpdated

```solidity
event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
```

### InventoryUpdated

```solidity
event InventoryUpdated(address indexed oldInventory, address indexed newInventory);
```

### MerchandiseAdded

```solidity
event MerchandiseAdded(uint256 indexed merchandiseId, uint256 indexed tokenId, uint256 unitPrice, uint256 quantity);
```

### MerchandisePurchased

```solidity
event MerchandisePurchased(uint256 indexed merchandiseId, address indexed buyer, uint256 quantity, uint256 totalPrice);
```

### MerchandiseBatchPurchased

```solidity
event MerchandiseBatchPurchased(
    address indexed buyer, uint256[] merchandiseIds, uint256[] quantities, uint256 totalPrice
);
```

### MerchandiseRestocked

```solidity
event MerchandiseRestocked(uint256 indexed merchandiseId, uint256 addedQuantity, uint256 newTotalQuantity);
```

### MerchandiseStatusChanged

```solidity
event MerchandiseStatusChanged(uint256 indexed merchandiseId, bool isActive);
```

### MerchandisePriceUpdated

```solidity
event MerchandisePriceUpdated(uint256 indexed merchandiseId, uint256 oldPrice, uint256 newPrice);
```

### Withdrawal

```solidity
event Withdrawal(address indexed to, uint256 amount);
```

## Structs
### Merchandise

```solidity
struct Merchandise {
    uint256 tokenId;
    uint256 unitPrice;
    uint256 quantity;
    uint256 sold;
    bool isActive;
    bool isSoldOut;
}
```

