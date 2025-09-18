# IVRFMigratableConsumerV2Plus
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/31e6a3daee14ffbd0b191978eeefd42265f32d78/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

The IVRFMigratableConsumerV2Plus interface defines the

method required to be implemented by all V2Plus consumers.

*This interface is designed to be used in VRFConsumerBaseV2Plus.*


## Functions
### setCoordinator

Sets the VRF Coordinator address

This method should only be callable by the coordinator or contract owner


```solidity
function setCoordinator(address vrfCoordinator) external;
```

## Events
### CoordinatorSet

```solidity
event CoordinatorSet(address vrfCoordinator);
```

