# IUniswapV3SwapCallback
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/9e546b382c23d2b0e19e283e91910f7ca89a14f9/src/contracts/agnosia/UniRouterDataV3.sol)

Any contract that calls IUniswapV3PoolActions#swap must implement this interface


## Functions
### uniswapV3SwapCallback

Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.

*In the implementation you must pay the pool tokens owed for the swap.
The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
amount0Delta and amount1Delta can both be 0 if no tokens were swapped.*


```solidity
function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount0Delta`|`int256`|The amount of token0 that was sent (negative) or must be received (positive) by the pool by the end of the swap. If positive, the callback must send that amount of token0 to the pool.|
|`amount1Delta`|`int256`|The amount of token1 that was sent (negative) or must be received (positive) by the pool by the end of the swap. If positive, the callback must send that amount of token1 to the pool.|
|`data`|`bytes`|Any data passed through by the caller via the IUniswapV3PoolActions#swap call|


