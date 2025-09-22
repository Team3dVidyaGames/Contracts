# IERC165
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e7abd099c8ff67c53a32c1d0c029bd31930c8a9c/src/contracts/flattened/flattened_TCGInventory.sol)

*Interface of the ERC-165 standard, as defined in the
https://eips.ethereum.org/EIPS/eip-165[ERC].
Implementers can declare support of contract interfaces, which can then be
queried by others ({ERC165Checker}).
For an implementation, see {ERC165}.*


## Functions
### supportsInterface

*Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.*


```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

