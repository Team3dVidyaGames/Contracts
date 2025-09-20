# SignedMath
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/979b23aadc6ba57e24bde02cea0a160d5543b450/src/contracts/flattened/flattened_TCGInventory.sol)

*Standard signed math utilities missing in the Solidity language.*


## Functions
### ternary

*Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
one branch when needed, making this function more expensive.*


```solidity
function ternary(bool condition, int256 a, int256 b) internal pure returns (int256);
```

### max

*Returns the largest of two signed numbers.*


```solidity
function max(int256 a, int256 b) internal pure returns (int256);
```

### min

*Returns the smallest of two signed numbers.*


```solidity
function min(int256 a, int256 b) internal pure returns (int256);
```

### average

*Returns the average of two signed numbers without overflow.
The result is rounded towards zero.*


```solidity
function average(int256 a, int256 b) internal pure returns (int256);
```

### abs

*Returns the absolute unsigned value of a signed value.*


```solidity
function abs(int256 n) internal pure returns (uint256);
```

