# Cauldron
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/edd5b9280854f5d7be315ec63c3c3a058db024c0/src/contracts/agnosia/Cauldron.sol)

**Inherits:**
Ownable, [DistributionSystem](/src/contracts/agnosia/DistributionSystem.sol/contract.DistributionSystem.md)

**Author:**
Team3d.R&D


## State Variables
### nft

```solidity
ITCGInventory immutable nft;
```


### spillage

```solidity
uint256 public spillage;
```


### totalCardsBurned

```solidity
uint256 public totalCardsBurned;
```


### highestLevelBurned

```solidity
uint8 public highestLevelBurned;
```


### gateway

```solidity
address public gateway;
```


### pointPerLevel

```solidity
uint256[11] public pointPerLevel;
```


### levelToSlotToBurnCount

```solidity
mapping(uint8 => mapping(uint8 => uint256)) public levelToSlotToBurnCount;
```


### agnosia

```solidity
mapping(address => uint256) public agnosia;
```


### totalCardsBurnedPerUser

```solidity
mapping(address => uint256) public totalCardsBurnedPerUser;
```


### highestLevelBurnedPerUser

```solidity
mapping(address => uint256) public highestLevelBurnedPerUser;
```


## Functions
### constructor


```solidity
constructor(address _rewardToken, address _nft) DistributionSystem(_rewardToken);
```

### gatewaySet


```solidity
function gatewaySet() public view returns (bool);
```

### setGateway


```solidity
function setGateway(address _gateway) external onlyOwner;
```

### _processClaim


```solidity
function _processClaim(address user, uint256 tokensToClaim) internal override;
```

### rewardSupply


```solidity
function rewardSupply() public view override returns (uint256 supply);
```

### UIHelperForUser


```solidity
function UIHelperForUser(address user)
    external
    view
    returns (uint256 _tokensClaimable, uint256 userWeight, uint256 totalWeight, uint256 _rewardsClaimed);
```

### UIHelperForGeneralInformation


```solidity
function UIHelperForGeneralInformation() external view returns (uint256 _totalClaimed, uint256 _totalBurned);
```

### increaseCauldronPortion


```solidity
function increaseCauldronPortion(uint256[] memory tokenIds) external;
```

### initialize


```solidity
function initialize() external onlyOwner;
```

### bonusMultiplier


```solidity
function bonusMultiplier(uint256 _tokenId) public view returns (uint256 bonusMulti);
```

### getBatchBrewValueMulti


```solidity
function getBatchBrewValueMulti(uint256[] memory _tokenIds)
    public
    view
    returns (uint256[] memory cardsPointValue, uint256 sumOfCards, uint256 userPoints, uint256 contractPoints);
```

### changeTime


```solidity
function changeTime(uint256 newTime) external onlyOwner;
```

## Events
### GatewaySet

```solidity
event GatewaySet(address _gateway);
```

