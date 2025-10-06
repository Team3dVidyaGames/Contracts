# SplitterAccessControl
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/3f338936af54058cad79e79f965686603f483c22/src/contracts/flattened/flattened_SplitterAccessControl.sol)

**Inherits:**
[AccessControl](/src/contracts/flattened/flattened_SplitterAccessControl.sol/abstract.AccessControl.md), [ReentrancyGuard](/src/contracts/flattened/flattened_SplitterAccessControl.sol/abstract.ReentrancyGuard.md)


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### SPLITTER_ROLE

```solidity
bytes32 public constant SPLITTER_ROLE = keccak256("SPLITTER_ROLE");
```


### userPosition

```solidity
mapping(address => uint256) public userPosition;
```


### positionToUser

```solidity
mapping(uint256 => address) public positionToUser;
```


### memberCount

```solidity
uint256 public memberCount;
```


## Functions
### constructor


```solidity
constructor();
```

### addMemberToSplitter


```solidity
function addMemberToSplitter(address user) external onlyRole(ADMIN_ROLE);
```

### removeMemberFromSplitter


```solidity
function removeMemberFromSplitter(address user) external onlyRole(ADMIN_ROLE);
```

### changePositionAddress


```solidity
function changePositionAddress(address user) external onlyRole(SPLITTER_ROLE);
```

### distributeFunds


```solidity
function distributeFunds(address erc20, bool ethAsWell) external nonReentrant;
```

## Events
### MemberAdded

```solidity
event MemberAdded(address indexed user, uint256 indexed position);
```

### MemberRemoved

```solidity
event MemberRemoved(address indexed user, uint256 indexed position);
```

### PositionAddressChanged

```solidity
event PositionAddressChanged(address indexed oldUser, address indexed newUser, uint256 indexed position);
```

### FundsDistributed

```solidity
event FundsDistributed(address indexed erc20, bool indexed ethAsWell);
```

