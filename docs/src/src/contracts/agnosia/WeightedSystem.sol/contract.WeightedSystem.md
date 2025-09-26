# WeightedSystem
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/edd5b9280854f5d7be315ec63c3c3a058db024c0/src/contracts/agnosia/WeightedSystem.sol)

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

