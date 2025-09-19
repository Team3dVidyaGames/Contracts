# StarterPackSeller
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/agnosia/PackSeller.sol)

**Inherits:**
[ReentrancyGuard](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/abstract.ReentrancyGuard.md), [AccessControl](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/abstract.AccessControl.md), [UniswapV3Integration](/src/contracts/agnosia/UniswapV3Integration.sol/contract.UniswapV3Integration.md)


## State Variables
### packCost

```solidity
uint256 public packCost = 0.005 ether;
```


### nft

```solidity
address public nft;
```


### splitter

```solidity
address public splitter = 0x26f8d863819210A81D3CA079720e71056F0f1823;
```


### vault

```solidity
address public vault = 0x26f8d863819210A81D3CA079720e71056F0f1823;
```


### split

```solidity
uint256 public split = 50;
```


### referralSplit

```solidity
uint256 public referralSplit = 10;
```


### vaultSplit

```solidity
uint256 public vaultSplit = 25;
```


### totalSplit

```solidity
uint256 public totalSplit = 85;
```


### primaryToken

```solidity
address public primaryToken = 0x46c8651dDedD50CBDF71de85D3de9AaC80247B62;
```


### consumer

```solidity
address public consumer;
```


### cardsInPack

```solidity
uint8 public constant cardsInPack = 7;
```


### levelToTemplateIds

```solidity
mapping(uint8 => uint256[]) public levelToTemplateIds;
```


### requestData

```solidity
mapping(uint256 => RequestInfo) public requestData;
```


### userToRequestID

```solidity
mapping(address => uint256) public userToRequestID;
```


### userHasPendingRequest

```solidity
mapping(address => bool) public userHasPendingRequest;
```


### referralToClaim

```solidity
mapping(address => uint256) public referralToClaim;
```


### userPoints

```solidity
mapping(address => uint256) public userPoints;
```


### userReferrals

```solidity
mapping(address => mapping(address => bool)) public userReferrals;
```


### referralCount

```solidity
mapping(address => uint256) public referralCount;
```


### ascensionCount

```solidity
mapping(address => uint256) public ascensionCount;
```


### packsOpened

```solidity
mapping(address => uint256) public packsOpened;
```


## Functions
### constructor


```solidity
constructor(address _uniswapV3Router) UniswapV3Integration(_uniswapV3Router);
```

### changeVault


```solidity
function changeVault(address newVault) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### changeConsumer


```solidity
function changeConsumer(address newConsumer) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### changeSplitter


```solidity
function changeSplitter(address newSplitter) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### changeCost


```solidity
function changeCost(uint256 newCost) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### userPoint


```solidity
function userPoint(address user) external view returns (uint256);
```

### changeNFT


```solidity
function changeNFT(address newNFT) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### addTemplateId


```solidity
function addTemplateId(uint256[] memory templates) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### removeTemplateIds


```solidity
function removeTemplateIds(uint8 level, uint256 position) external onlyRole(DEFAULT_ADMIN_ROLE);
```

### storedTemplates


```solidity
function storedTemplates(uint8 level) external view returns (uint256[] memory templatesDisplay);
```

### setSplits

*function to set Splits between the entities*


```solidity
function setSplits(uint256 _newDev, uint256 _newVault, uint256 _newReferral) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newDev`|`uint256`|DevSplit goes to splitter|
|`_newVault`|`uint256`|Vault Split goes to vault|
|`_newReferral`|`uint256`|goes to referer|


### requestRandomWords

*function called to request randomness from smart contracts*


```solidity
function requestRandomWords(uint8 cardsToMint, address user, uint8 level) internal returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 requestId|


### handleRequest

*function to handle the requestData to mint tokens*


```solidity
function handleRequest(address user, uint8 cards, uint256 requestId, uint8 level) internal;
```

### buyStarterPack

*external function that is used to buy a StarterPack*


```solidity
function buyStarterPack(address referral) external payable nonReentrant returns (uint256 requestId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`referral`|`address`|is the address referring the user for a split|


### ascendToNextLevel

*Function to upgrade a set of tokens to the next level.*


```solidity
function ascendToNextLevel(uint256[11] memory tokenIds) external nonReentrant returns (uint256 requestId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[11]`|An array of 11 token IDs to upgrade.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`requestId`|`uint256`|The ID of the request for the new upgraded token.|


### splitFunds

*splits the Funds from buying the pack*


```solidity
function splitFunds(uint256 amount, address referral) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|the amount for the referrer and vault|
|`referral`|`address`||


### tokenPart

*function to split between referrer and vault*


```solidity
function tokenPart(address location, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`location`|`address`|the referrer|
|`amount`|`uint256`|eth to spend WARNING if location is not able to claim erc20 from contract tokens will be lost in contract|


### _retrieveRandomWords

*function to retrieve the random words from the consumer*


```solidity
function _retrieveRandomWords(uint256 requestId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestId`|`uint256`|the request id|


### canClaimRewards

*function to see if user can claim from contract*


```solidity
function canClaimRewards(address user) public view returns (bool claimable);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|the address to claim|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`claimable`|`bool`|can claim|


### claimRewards

This function allows a user to claim their referral rewards.


```solidity
function claimRewards() external nonReentrant;
```

### _claim

*the internal claim function*


```solidity
function _claim(address user) internal returns (uint256[] memory results);
```

### _mint

*function to mint NFT tokens if the User has a current position to claim from
will only claim from one starter pack at a time*


```solidity
function _mint(address user) internal returns (uint256[] memory);
```

### _tokenClaim

*function to send any referral tokens to user*


```solidity
function _tokenClaim(address user) internal;
```

### receive


```solidity
receive() external payable;
```

### canOpenStarterPack

This function checks if a user can open a starter pack.


```solidity
function canOpenStarterPack(address user) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user can open a starter pack, false otherwise.|


### openStarterPack

*This function allows a user to open a starter pack.*


```solidity
function openStarterPack() external nonReentrant returns (uint256[] memory results);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`results`|`uint256[]`|The IDs of the minted tokens.|


## Events
### CostUpdate

```solidity
event CostUpdate(uint256 cost);
```

### NftUpdate

```solidity
event NftUpdate(address indexed NFT);
```

### Success

```solidity
event Success(bool success, address location);
```

### TemplateAdded

```solidity
event TemplateAdded(uint256 templateId);
```

### ChangeSubscriptionId

```solidity
event ChangeSubscriptionId(uint64 indexed newId);
```

## Structs
### RequestInfo

```solidity
struct RequestInfo {
    address user;
    uint8 requestCount;
    uint8 level;
    uint256[] templateIdToMint;
}
```

