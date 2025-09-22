# ERC721Enumerable
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e7abd099c8ff67c53a32c1d0c029bd31930c8a9c/src/contracts/flattened/flattened_TCGInventory.sol)

**Inherits:**
[ERC721](/src/contracts/flattened/flattened_TCGInventory.sol/abstract.ERC721.md), [IERC721Enumerable](/src/contracts/flattened/flattened_TCGInventory.sol/interface.IERC721Enumerable.md)

*This implements an optional extension of {ERC721} defined in the ERC that adds enumerability
of all the token ids in the contract as well as all token ids owned by each account.
CAUTION: {ERC721} extensions that implement custom `balanceOf` logic, such as {ERC721Consecutive},
interfere with enumerability and should not be used together with {ERC721Enumerable}.*


## State Variables
### _ownedTokens

```solidity
mapping(address owner => mapping(uint256 index => uint256)) private _ownedTokens;
```


### _ownedTokensIndex

```solidity
mapping(uint256 tokenId => uint256) private _ownedTokensIndex;
```


### _allTokens

```solidity
uint256[] private _allTokens;
```


### _allTokensIndex

```solidity
mapping(uint256 tokenId => uint256) private _allTokensIndex;
```


## Functions
### supportsInterface

*See [IERC165-supportsInterface](/src/contracts/flattened/flattened_TCGInventory.sol/contract.TCGInventory.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool);
```

### tokenOfOwnerByIndex

*See [IERC721Enumerable-tokenOfOwnerByIndex](/lib/chainlink/contracts/src/v0.8/vendor/forge-std/src/interfaces/IERC721.sol/interface.IERC721Enumerable.md#tokenofownerbyindex).*


```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256);
```

### totalSupply

*See [IERC721Enumerable-totalSupply](/lib/chainlink/contracts/src/v0.8/automation/test/WETH9.sol/contract.WETH9.md#totalsupply).*


```solidity
function totalSupply() public view virtual returns (uint256);
```

### tokenByIndex

*See [IERC721Enumerable-tokenByIndex](/lib/chainlink/contracts/src/v0.8/vendor/forge-std/src/interfaces/IERC721.sol/interface.IERC721Enumerable.md#tokenbyindex).*


```solidity
function tokenByIndex(uint256 index) public view virtual returns (uint256);
```

### _update

*See [ERC721-_update](/lib/chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/token/ERC20/ERC20.sol/abstract.ERC20.md#_update).*


```solidity
function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address);
```

### _addTokenToOwnerEnumeration

*Private function to add a token to this extension's ownership-tracking data structures.*


```solidity
function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|address representing the new owner of the given token ID|
|`tokenId`|`uint256`|uint256 ID of the token to be added to the tokens list of the given address|


### _addTokenToAllTokensEnumeration

*Private function to add a token to this extension's token tracking data structures.*


```solidity
function _addTokenToAllTokensEnumeration(uint256 tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|uint256 ID of the token to be added to the tokens list|


### _removeTokenFromOwnerEnumeration

*Private function to remove a token from this extension's ownership-tracking data structures. Note that
while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
gas optimizations e.g. when performing a transfer operation (avoiding double writes).
This has O(1) time complexity, but alters the order of the _ownedTokens array.*


```solidity
function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|address representing the previous owner of the given token ID|
|`tokenId`|`uint256`|uint256 ID of the token to be removed from the tokens list of the given address|


### _removeTokenFromAllTokensEnumeration

*Private function to remove a token from this extension's token tracking data structures.
This has O(1) time complexity, but alters the order of the _allTokens array.*


```solidity
function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|uint256 ID of the token to be removed from the tokens list|


### _increaseBalance

See [ERC721-_increaseBalance](/lib/openzeppelin/contracts/mocks/token/ERC721ConsecutiveEnumerableMock.sol/contract.ERC721ConsecutiveEnumerableMock.md#_increasebalance). We need that to account tokens that were minted in batch


```solidity
function _increaseBalance(address account, uint128 amount) internal virtual override;
```

## Errors
### ERC721OutOfBoundsIndex
*An `owner`'s token query was out of bounds for `index`.
NOTE: The owner being `address(0)` indicates a global out of bounds index.*


```solidity
error ERC721OutOfBoundsIndex(address owner, uint256 index);
```

### ERC721EnumerableForbiddenBatchMint
*Batch mint is not allowed.*


```solidity
error ERC721EnumerableForbiddenBatchMint();
```

