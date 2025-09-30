# IERC721Enumerable
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/cb1733471b1d4daa24a16e671f78159e22669528/src/contracts/flattened/flattened_TCGInventory.sol)

**Inherits:**
[IERC721](/src/contracts/flattened/flattened_PackSeller.sol/interface.IERC721.md)

*See https://eips.ethereum.org/EIPS/eip-721*


## Functions
### totalSupply

*Returns the total amount of tokens stored by the contract.*


```solidity
function totalSupply() external view returns (uint256);
```

### tokenOfOwnerByIndex

*Returns a token ID owned by `owner` at a given `index` of its token list.
Use along with {balanceOf} to enumerate all of ``owner``'s tokens.*


```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
```

### tokenByIndex

*Returns a token ID at a given `index` of all the tokens stored by the contract.
Use along with [totalSupply](/src/contracts/flattened/flattened_TCGInventory.sol/interface.IERC721Enumerable.md#totalsupply) to enumerate all tokens.*


```solidity
function tokenByIndex(uint256 index) external view returns (uint256);
```

