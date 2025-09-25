# UniswapV3Integration
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/cc124d509378b286cf5b28729406af3750bf09dd/src/contracts/agnosia/UniswapV3Integration.sol)


## State Variables
### Weth9

```solidity
address public immutable Weth9;
```


### uniswapV3Router

```solidity
ISwapRouter immutable uniswapV3Router;
```


## Functions
### constructor


```solidity
constructor(address _uniswapV3Router);
```

### _buyTokenETH

*function to buy primary token and send to the contract*


```solidity
function _buyTokenETH(address token, uint256 amount, address to, uint24 poolFee) internal;
```

### buyTokenETH


```solidity
function buyTokenETH(address token, uint24 poolFee) public payable;
```

