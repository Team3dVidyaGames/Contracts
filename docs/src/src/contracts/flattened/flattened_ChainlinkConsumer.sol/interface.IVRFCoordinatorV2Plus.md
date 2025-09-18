# IVRFCoordinatorV2Plus
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/31e6a3daee14ffbd0b191978eeefd42265f32d78/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

**Inherits:**
[IVRFSubscriptionV2Plus](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/interface.IVRFSubscriptionV2Plus.md)


## Functions
### requestRandomWords

Request a set of random words.


```solidity
function requestRandomWords(VRFV2PlusClient.RandomWordsRequest calldata req) external returns (uint256 requestId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`req`|`VRFV2PlusClient.RandomWordsRequest`|- a struct containing following fields for randomness request: keyHash - Corresponds to a particular oracle job which uses that key for generating the VRF proof. Different keyHash's have different gas price ceilings, so you can select a specific one to bound your maximum per request cost. subId  - The ID of the VRF subscription. Must be funded with the minimum subscription balance required for the selected keyHash. requestConfirmations - How many blocks you'd like the oracle to wait before responding to the request. See SECURITY CONSIDERATIONS for why you may want to request more. The acceptable range is [minimumRequestBlockConfirmations, 200]. callbackGasLimit - How much gas you'd like to receive in your fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords may be slightly less than this amount because of gas used calling the function (argument decoding etc.), so you may need to request slightly more than you expect to have inside fulfillRandomWords. The acceptable range is [0, maxGasLimit] numWords - The number of uint256 random values you'd like to receive in your fulfillRandomWords callback. Note these numbers are expanded in a secure way by the VRFCoordinator from a single random value supplied by the oracle. extraArgs - abi-encoded extra args|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`requestId`|`uint256`|- A unique identifier of the request. Can be used to match a request to a response in fulfillRandomWords.|


