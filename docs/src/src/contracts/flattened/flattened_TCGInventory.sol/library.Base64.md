# Base64
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/flattened/flattened_TCGInventory.sol)

*Provides a set of functions to operate with Base64 strings.*


## State Variables
### _TABLE
*Base64 Encoding/Decoding Table
See sections 4 and 5 of https://datatracker.ietf.org/doc/html/rfc4648*


```solidity
string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
```


### _TABLE_URL

```solidity
string internal constant _TABLE_URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
```


## Functions
### encode

*Converts a `bytes` to its Bytes64 `string` representation.*


```solidity
function encode(bytes memory data) internal pure returns (string memory);
```

### encodeURL

*Converts a `bytes` to its Bytes64Url `string` representation.
Output is not padded with `=` as specified in https://www.rfc-editor.org/rfc/rfc4648[rfc4648].*


```solidity
function encodeURL(bytes memory data) internal pure returns (string memory);
```

### _encode

*Internal table-agnostic conversion*


```solidity
function _encode(bytes memory data, string memory table, bool withPadding) private pure returns (string memory);
```

