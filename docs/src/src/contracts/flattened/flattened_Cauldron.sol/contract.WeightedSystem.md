# WeightedSystem
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e7abd099c8ff67c53a32c1d0c029bd31930c8a9c/src/contracts/flattened/flattened_Cauldron.sol)

**Author:**
Team3d.R&D


## State Variables
### totalWeight

```solidity
uint256 public totalWeight;
```


### userWeights

```solidity
mapping(address => uint256) public userWeights;
```


### users

```solidity
address[] public users;
```


## Functions
### _addWeight


```solidity
function _addWeight(address user, uint256 weightToAdd) internal virtual;
```

### weights


```solidity
function weights(address user) public view returns (uint256 userW, uint256 totalW);
```

### usersList


```solidity
function usersList() public view returns (address[] memory _users);
```

## Events
### weightUpdated

```solidity
event weightUpdated(uint256 _totalWeight, address indexed user, uint256 _userWeight);
```

