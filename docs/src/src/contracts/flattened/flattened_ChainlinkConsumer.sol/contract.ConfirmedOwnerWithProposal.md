# ConfirmedOwnerWithProposal
[Git Source](https://github.com//Team3dVidyaGames/InventoryContractV3_erc1155/blob/31e6a3daee14ffbd0b191978eeefd42265f32d78/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

**Inherits:**
[IOwnable](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/interface.IOwnable.md)

A contract with helpers for basic contract ownership.


## State Variables
### s_owner

```solidity
address private s_owner;
```


### s_pendingOwner

```solidity
address private s_pendingOwner;
```


## Functions
### constructor


```solidity
constructor(address newOwner, address pendingOwner);
```

### transferOwnership

Allows an owner to begin transferring ownership to a new address.


```solidity
function transferOwnership(address to) public override onlyOwner;
```

### acceptOwnership

Allows an ownership transfer to be completed by the recipient.


```solidity
function acceptOwnership() external override;
```

### owner

Get the current owner


```solidity
function owner() public view override returns (address);
```

### _transferOwnership

validate, transfer ownership, and emit relevant events


```solidity
function _transferOwnership(address to) private;
```

### _validateOwnership

validate access


```solidity
function _validateOwnership() internal view;
```

### onlyOwner

Reverts if called by anyone other than the contract owner.


```solidity
modifier onlyOwner();
```

## Events
### OwnershipTransferRequested

```solidity
event OwnershipTransferRequested(address indexed from, address indexed to);
```

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed from, address indexed to);
```

