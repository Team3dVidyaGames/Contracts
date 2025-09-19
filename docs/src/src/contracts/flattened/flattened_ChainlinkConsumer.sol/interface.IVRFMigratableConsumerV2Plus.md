# IVRFMigratableConsumerV2Plus
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

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

