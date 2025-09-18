# IVRFSubscriptionV2Plus
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/31e6a3daee14ffbd0b191978eeefd42265f32d78/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

The IVRFSubscriptionV2Plus interface defines the subscription

related methods implemented by the V2Plus coordinator.


## Functions
### addConsumer

Add a consumer to a VRF subscription.


```solidity
function addConsumer(uint256 subId, address consumer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|
|`consumer`|`address`|- New consumer which can use the subscription|


### removeConsumer

Remove a consumer from a VRF subscription.


```solidity
function removeConsumer(uint256 subId, address consumer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|
|`consumer`|`address`|- Consumer to remove from the subscription|


### cancelSubscription

Cancel a subscription


```solidity
function cancelSubscription(uint256 subId, address to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|
|`to`|`address`|- Where to send the remaining LINK to|


### acceptSubscriptionOwnerTransfer

Accept subscription owner transfer.

*will revert if original owner of subId has
not requested that msg.sender become the new owner.*


```solidity
function acceptSubscriptionOwnerTransfer(uint256 subId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|


### requestSubscriptionOwnerTransfer

Request subscription owner transfer.


```solidity
function requestSubscriptionOwnerTransfer(uint256 subId, address newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|
|`newOwner`|`address`|- proposed new owner of the subscription|


### createSubscription

Create a VRF subscription.

*You can manage the consumer set dynamically with addConsumer/removeConsumer.*

*Note to fund the subscription with LINK, use transferAndCall. For example*

*LINKTOKEN.transferAndCall(*

*address(COORDINATOR),*

*amount,*

*abi.encode(subId));*

*Note to fund the subscription with Native, use fundSubscriptionWithNative. Be sure*

*to send Native with the call, for example:*

*COORDINATOR.fundSubscriptionWithNative{value: amount}(subId);*


```solidity
function createSubscription() external returns (uint256 subId);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- A unique subscription id.|


### getSubscription

Get a VRF subscription.


```solidity
function getSubscription(uint256 subId)
    external
    view
    returns (uint96 balance, uint96 nativeBalance, uint64 reqCount, address owner, address[] memory consumers);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balance`|`uint96`|- LINK balance of the subscription in juels.|
|`nativeBalance`|`uint96`|- native balance of the subscription in wei.|
|`reqCount`|`uint64`|- Requests count of subscription.|
|`owner`|`address`|- owner of the subscription.|
|`consumers`|`address[]`|- list of consumer address which are able to use this subscription.|


### pendingRequestExists


```solidity
function pendingRequestExists(uint256 subId) external view returns (bool);
```

### getActiveSubscriptionIds

Paginate through all active VRF subscriptions.

*the order of IDs in the list is **not guaranteed**, therefore, if making successive calls, one*

*should consider keeping the blockheight constant to ensure a holistic picture of the contract state*


```solidity
function getActiveSubscriptionIds(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startIndex`|`uint256`|index of the subscription to start from|
|`maxCount`|`uint256`|maximum number of subscriptions to return, 0 to return all|


### fundSubscriptionWithNative

Fund a subscription with native.

This method expects msg.value to be greater than or equal to 0.


```solidity
function fundSubscriptionWithNative(uint256 subId) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`subId`|`uint256`|- ID of the subscription|


