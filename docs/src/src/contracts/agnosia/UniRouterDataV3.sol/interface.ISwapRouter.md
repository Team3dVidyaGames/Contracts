# ISwapRouter
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/agnosia/UniRouterDataV3.sol)

**Inherits:**
[IUniswapV3SwapCallback](/src/contracts/agnosia/UniRouterDataV3.sol/interface.IUniswapV3SwapCallback.md)

Functions for swapping tokens via Uniswap V3


## Functions
### exactInputSingle

Swaps `amountIn` of one token for as much as possible of another token


```solidity
function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`ExactInputSingleParams`|The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount of the received token|


### exactInput

Swaps `amountIn` of one token for as much as possible of another along the specified path


```solidity
function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`ExactInputParams`|The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount of the received token|


### exactOutputSingle

Swaps as little as possible of one token for `amountOut` of another token


```solidity
function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`ExactOutputSingleParams`|The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`uint256`|The amount of the input token|


### exactOutput

Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)


```solidity
function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`ExactOutputParams`|The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`uint256`|The amount of the input token|


### WETH9


```solidity
function WETH9() external view returns (address);
```

## Structs
### ExactInputSingleParams

```solidity
struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}
```

### ExactInputParams

```solidity
struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}
```

### ExactOutputSingleParams

```solidity
struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
    uint160 sqrtPriceLimitX96;
}
```

### ExactOutputParams

```solidity
struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
}
```

