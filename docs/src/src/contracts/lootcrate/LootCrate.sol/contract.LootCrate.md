# LootCrate
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/fe1c37ad96fd8edc607fe8fc9fe164908c2347f3/src/contracts/lootcrate/LootCrate.sol)

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


### lootVault

```solidity
ILootVault public lootVault;
```


### contractToTokenIdToAmount

```solidity
mapping(address => mapping(uint256 => uint256)) internal contractToTokenIdToAmount;
```


### rarityToLootCrateItems

```solidity
mapping(uint256 => LootCrateItem[]) public rarityToLootCrateItems;
```


## Functions
### constructor


```solidity
constructor() AccessControl();
```

### setLootVault


```solidity
function setLootVault(address _lootVault) external onlyRole(ADMIN_ROLE);
```

### addLoot


```solidity
function addLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, uint256 rarity)
    external
    payable
    onlyRole(REWARD_ADDER_ROLE);
```

### _claimLoot


```solidity
function _claimLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, address to)
    internal
    onlyRole(REWARD_ADDER_ROLE)
    nonReentrant;
```

### _addLootCrateItem


```solidity
function _addLootCrateItem(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, uint256 rarity)
    internal;
```

### _transferLootToVault


```solidity
function _transferLootToVault(address from, address lootToken, uint256 ercID, uint256 tokenId, uint256 amount)
    internal;
```

### addRewarder


```solidity
function addRewarder(address _reward) external onlyRole(ADMIN_ROLE);
```

### removeRewardAdder


```solidity
function removeRewardAdder(address _reward) external onlyRole(ADMIN_ROLE);
```

### receive


```solidity
receive() external payable;
```

## Errors
### InvalidLootVaultOwner

```solidity
error InvalidLootVaultOwner();
```

## Structs
### LootCrateItem

```solidity
struct LootCrateItem {
    address lootToken;
    uint256 ercID;
    uint256 tokenId;
    uint256 amount;
    uint256 rarity;
}
```

