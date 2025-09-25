# DistributionSystem
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/8cc4d72a909ca4f2a52b9bb1c21fb216d14debd4/src/contracts/agnosia/DistributionSystem.sol)

**Inherits:**
[WeightedSystem](/src/contracts/agnosia/WeightedSystem.sol/contract.WeightedSystem.md)

**Author:**
Team3d.R&D


## State Variables
### rewardToken

```solidity
IERC20 public immutable rewardToken;
```


### timeSet

```solidity
uint256 public timeSet = 180 days;
```


### totalRewardsClaimed

```solidity
uint256 public totalRewardsClaimed;
```


### lastClaim

```solidity
mapping(address => uint256) public lastClaim;
```


### rewardsClaimed

```solidity
mapping(address => uint256) public rewardsClaimed;
```


## Functions
### constructor


```solidity
constructor(address _rewardToken);
```

### claim


```solidity
function claim() external;
```

### _claim


```solidity
function _claim(address user) internal;
```

### _processClaim


```solidity
function _processClaim(address user, uint256 tokensToClaim) internal virtual;
```

### _transferClaim


```solidity
function _transferClaim(address user, uint256 amount) internal;
```

### _addWeight


```solidity
function _addWeight(address user, uint256 weightToAdd) internal override;
```

### tokensClaimable


```solidity
function tokensClaimable(address user)
    public
    view
    returns (uint256 tokensToClaim, uint256 userWeight, uint256 totalWeight);
```

### rewardSupply


```solidity
function rewardSupply() public view virtual returns (uint256 supply);
```

### calculateClaim


```solidity
function calculateClaim(address user, uint256 uw, uint256 tw) internal view returns (uint256 amount);
```

## Events
### Claimed

```solidity
event Claimed(address user, uint256 amount);
```

