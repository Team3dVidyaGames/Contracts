# MerchantV1
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/26c5f16de2d551ed5bfcade59d4625fc493725cf/src/contracts/merchant/MerchantV1.sol)

**Inherits:**
[IMerchantV1](/src/contracts/interfaces/IMerchantV1.sol/interface.IMerchantV1.md), AccessControl, ReentrancyGuard

*A contract for managing the sale of ERC1155 tokens with role-based access control
and reentrancy protection. Allows adding merchandise, purchasing items, and managing inventory.*


## State Variables
### SHOP_ROLE

```solidity
bytes32 public SHOP_ROLE = "SHOP_ROLE";
```


### treasury

```solidity
address public treasury;
```


### inventory1155

```solidity
address public inventory1155;
```


### merchandise

```solidity
mapping(uint256 => Merchandise) private merchandise;
```


### tokenIdsUsed

```solidity
mapping(uint256 => bool) private tokenIdsUsed;
```


### merchandiseCount

```solidity
uint256 private merchandiseCount;
```


## Functions
### constructor

*Constructor initializes the contract with admin and shop roles
Grants DEFAULT_ADMIN_ROLE and SHOP_ROLE to the deployer*


```solidity
constructor();
```

### setTreasury

Only callable by admin role

*Sets the treasury address where payments will be sent*


```solidity
function setTreasury(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasury`|`address`|The new treasury address|


### setInventory1155

Only callable by admin role

*Sets the ERC1155 inventory contract address*


```solidity
function setInventory1155(address _inventory1155) public onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_inventory1155`|`address`|The new inventory contract address|


### setMerchandiseActive

Only callable by shop role

*Sets the active status of a merchandise item*


```solidity
function setMerchandiseActive(uint256 merchandiseId, bool isActive) external onlyRole(SHOP_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise|
|`isActive`|`bool`|The new active status|


### setMerchandiseUnitPrice

Only callable by shop role

*Updates the unit price of a merchandise item*


```solidity
function setMerchandiseUnitPrice(uint256 merchandiseId, uint256 unitPrice) external onlyRole(SHOP_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise|
|`unitPrice`|`uint256`|The new unit price in wei|


### addMerchandise

Only callable by shop role

*Adds new merchandise to the shop*


```solidity
function addMerchandise(uint256 tokenId, uint256 unitPrice, uint256 quantity) public onlyRole(SHOP_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ERC1155 token ID|
|`unitPrice`|`uint256`|Price per unit in wei|
|`quantity`|`uint256`|Initial quantity available|


### buyMerchandise

Requires exact payment amount in wei

Protected against reentrancy attacks

*Allows users to purchase a single merchandise item*


```solidity
function buyMerchandise(uint256 merchandiseId, uint256 quantity) public payable nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise to purchase|
|`quantity`|`uint256`|The quantity to purchase|


### buyMerchandiseBatch

Requires exact payment amount in wei

Protected against reentrancy attacks

*Allows users to purchase multiple merchandise items in a single transaction*


```solidity
function buyMerchandiseBatch(uint256[] memory merchandiseIds, uint256[] memory quantities)
    public
    payable
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseIds`|`uint256[]`|Array of merchandise IDs to purchase|
|`quantities`|`uint256[]`|Array of quantities to purchase for each merchandise|


### _buyMerchandise

*Internal function to handle merchandise purchase logic*


```solidity
function _buyMerchandise(uint256 merchandiseId, uint256 quantity, uint256 value)
    internal
    returns (uint256 remainingValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise to purchase|
|`quantity`|`uint256`|The quantity to purchase|
|`value`|`uint256`|The payment amount in wei|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`remainingValue`|`uint256`|The remaining value after purchase|


### getMerchandise

*Returns the merchandise information for a given ID*


```solidity
function getMerchandise(uint256 merchandiseId) external view returns (Merchandise memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Merchandise`|Merchandise struct containing all merchandise details|


### getMerchandiseCount

*Returns the total number of merchandise items*


```solidity
function getMerchandiseCount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total count of merchandise items|


### getTokenIdsUsed

*Returns an array of all token IDs used in merchandise*


```solidity
function getTokenIdsUsed() external view returns (uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|Array of token IDs|


### getUnitPrice

*Returns the unit price and active status of a merchandise item*


```solidity
function getUnitPrice(uint256 merchandiseId) external view returns (uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|unitPrice The unit price in wei|
|`<none>`|`bool`|isActive The active status of the merchandise|


### getTokenIdUsed

*Checks if a token ID has been used in any merchandise*


```solidity
function getTokenIdUsed(uint256 merchandiseId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Boolean indicating if the token ID is used|


### restockMerchandise

Only callable by shop role

*Restocks a merchandise item with additional quantity*


```solidity
function restockMerchandise(uint256 merchandiseId, uint256 quantity) public onlyRole(SHOP_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`merchandiseId`|`uint256`|The ID of the merchandise to restock|
|`quantity`|`uint256`|The quantity to add|


### withdraw

Only callable by admin role

*Withdraws all contract balance to the treasury address*


```solidity
function withdraw() external;
```

### receive

*Allows the contract to receive ETH*


```solidity
receive() external payable;
```

