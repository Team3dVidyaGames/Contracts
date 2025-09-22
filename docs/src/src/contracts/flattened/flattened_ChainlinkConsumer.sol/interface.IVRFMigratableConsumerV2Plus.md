# IVRFMigratableConsumerV2Plus
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e7abd099c8ff67c53a32c1d0c029bd31930c8a9c/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

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

