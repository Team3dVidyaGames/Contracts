# IVRFMigratableConsumerV2Plus
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/cb1733471b1d4daa24a16e671f78159e22669528/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

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

