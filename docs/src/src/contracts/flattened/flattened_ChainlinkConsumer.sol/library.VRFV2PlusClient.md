# VRFV2PlusClient
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e7abd099c8ff67c53a32c1d0c029bd31930c8a9c/src/contracts/flattened/flattened_ChainlinkConsumer.sol)


## State Variables
### EXTRA_ARGS_V1_TAG

```solidity
bytes4 public constant EXTRA_ARGS_V1_TAG = bytes4(keccak256("VRF ExtraArgsV1"));
```


## Functions
### _argsToBytes


```solidity
function _argsToBytes(ExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts);
```

## Structs
### ExtraArgsV1

```solidity
struct ExtraArgsV1 {
    bool nativePayment;
}
```

### RandomWordsRequest

```solidity
struct RandomWordsRequest {
    bytes32 keyHash;
    uint256 subId;
    uint16 requestConfirmations;
    uint32 callbackGasLimit;
    uint32 numWords;
    bytes extraArgs;
}
```

