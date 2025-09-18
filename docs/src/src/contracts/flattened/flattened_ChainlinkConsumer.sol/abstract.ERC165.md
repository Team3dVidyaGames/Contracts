# ERC165
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/512679cdbe8ba50bfb5d75e26f1d9d30bbebcba4/src/contracts/flattened/flattened_ChainlinkConsumer.sol)

**Inherits:**
[IERC165](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/interface.IERC165.md)

*Implementation of the {IERC165} interface.
Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
for the additional interface id that will be supported. For example:
```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
}
```*


## Functions
### supportsInterface

*See [IERC165-supportsInterface](/src/contracts/flattened/flattened_ChainlinkConsumer.sol/abstract.AccessControl.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

