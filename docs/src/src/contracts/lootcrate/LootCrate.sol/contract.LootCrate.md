# LootCrate
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e59a3c26fbd24f4aff21370c713588eae3cb43b1/src/contracts/lootcrate/LootCrate.sol)

**Inherits:**
AccessControl, ReentrancyGuard


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### REWARD_ADDER_ROLE

```solidity
bytes32 public constant REWARD_ADDER_ROLE = keccak256("REWARD_ADDER_ROLE");
```


## Functions
### constructor


```solidity
constructor() AccessControl();
```

### addRewardAdder


```solidity
function addRewardAdder(address _reward) external onlyRole(ADMIN_ROLE);
```

### removeRewardAdder


```solidity
function removeRewardAdder(address _reward) external onlyRole(ADMIN_ROLE);
```

