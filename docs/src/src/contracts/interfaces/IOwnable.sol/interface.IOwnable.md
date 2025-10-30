# IOwnable
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/fe1c37ad96fd8edc607fe8fc9fe164908c2347f3/src/contracts/interfaces/IOwnable.sol)


## Functions
### owner

*Returns the address of the current owner.*


```solidity
function owner() external view returns (address);
```

### renounceOwnership

*Leaves the contract without owner. It will not be possible to call
`onlyOwner` functions. Can only be called by the current owner.*


```solidity
function renounceOwnership() external;
```

### transferOwnership

*Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner.*


```solidity
function transferOwnership(address newOwner) external;
```

## Events
### OwnershipTransferred
*Emitted when ownership is transferred from one account to another.*


```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

## Errors
### OwnableUnauthorizedAccount
*The caller account is not authorized to perform an operation.*


```solidity
error OwnableUnauthorizedAccount(address account);
```

### OwnableInvalidOwner
*The owner is not a valid owner account. (eg. `address(0)`)*


```solidity
error OwnableInvalidOwner(address owner);
```

