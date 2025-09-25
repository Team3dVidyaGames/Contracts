# Strings
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/cb1733471b1d4daa24a16e671f78159e22669528/src/contracts/flattened/flattened_TCGInventory.sol)

*String operations.*


## State Variables
### HEX_DIGITS

```solidity
bytes16 private constant HEX_DIGITS = "0123456789abcdef";
```


### ADDRESS_LENGTH

```solidity
uint8 private constant ADDRESS_LENGTH = 20;
```


### ABS_MIN_INT256

```solidity
uint256 private constant ABS_MIN_INT256 = 2 ** 255;
```


## Functions
### toString

*Converts a `uint256` to its ASCII `string` decimal representation.*


```solidity
function toString(uint256 value) internal pure returns (string memory);
```

### toStringSigned

*Converts a `int256` to its ASCII `string` decimal representation.*


```solidity
function toStringSigned(int256 value) internal pure returns (string memory);
```

### toHexString

*Converts a `uint256` to its ASCII `string` hexadecimal representation.*


```solidity
function toHexString(uint256 value) internal pure returns (string memory);
```

### toHexString

*Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.*


```solidity
function toHexString(uint256 value, uint256 length) internal pure returns (string memory);
```

### toHexString

*Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
representation.*


```solidity
function toHexString(address addr) internal pure returns (string memory);
```

### toChecksumHexString

*Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
representation, according to EIP-55.*


```solidity
function toChecksumHexString(address addr) internal pure returns (string memory);
```

### equal

*Returns true if the two strings are equal.*


```solidity
function equal(string memory a, string memory b) internal pure returns (bool);
```

### parseUint

*Parse a decimal string and returns the value as a `uint256`.
Requirements:
- The string must be formatted as `[0-9]*`
- The result must fit into an `uint256` type*


```solidity
function parseUint(string memory input) internal pure returns (uint256);
```

### parseUint

*Variant of {parseUint-string} that parses a substring of `input` located between position `begin` (included) and
`end` (excluded).
Requirements:
- The substring must be formatted as `[0-9]*`
- The result must fit into an `uint256` type*


```solidity
function parseUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256);
```

### tryParseUint

*Variant of {parseUint-string} that returns false if the parsing fails because of an invalid character.
NOTE: This function will revert if the result does not fit in a `uint256`.*


```solidity
function tryParseUint(string memory input) internal pure returns (bool success, uint256 value);
```

### tryParseUint

*Variant of {parseUint-string-uint256-uint256} that returns false if the parsing fails because of an invalid
character.
NOTE: This function will revert if the result does not fit in a `uint256`.*


```solidity
function tryParseUint(string memory input, uint256 begin, uint256 end)
    internal
    pure
    returns (bool success, uint256 value);
```

### _tryParseUintUncheckedBounds

*Implementation of {tryParseUint-string-uint256-uint256} that does not check bounds. Caller should make sure that
`begin <= end <= input.length`. Other inputs would result in undefined behavior.*


```solidity
function _tryParseUintUncheckedBounds(string memory input, uint256 begin, uint256 end)
    private
    pure
    returns (bool success, uint256 value);
```

### parseInt

*Parse a decimal string and returns the value as a `int256`.
Requirements:
- The string must be formatted as `[-+]?[0-9]*`
- The result must fit in an `int256` type.*


```solidity
function parseInt(string memory input) internal pure returns (int256);
```

### parseInt

*Variant of {parseInt-string} that parses a substring of `input` located between position `begin` (included) and
`end` (excluded).
Requirements:
- The substring must be formatted as `[-+]?[0-9]*`
- The result must fit in an `int256` type.*


```solidity
function parseInt(string memory input, uint256 begin, uint256 end) internal pure returns (int256);
```

### tryParseInt

*Variant of {parseInt-string} that returns false if the parsing fails because of an invalid character or if
the result does not fit in a `int256`.
NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.*


```solidity
function tryParseInt(string memory input) internal pure returns (bool success, int256 value);
```

### tryParseInt

*Variant of {parseInt-string-uint256-uint256} that returns false if the parsing fails because of an invalid
character or if the result does not fit in a `int256`.
NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.*


```solidity
function tryParseInt(string memory input, uint256 begin, uint256 end)
    internal
    pure
    returns (bool success, int256 value);
```

### _tryParseIntUncheckedBounds

*Implementation of {tryParseInt-string-uint256-uint256} that does not check bounds. Caller should make sure that
`begin <= end <= input.length`. Other inputs would result in undefined behavior.*


```solidity
function _tryParseIntUncheckedBounds(string memory input, uint256 begin, uint256 end)
    private
    pure
    returns (bool success, int256 value);
```

### parseHexUint

*Parse a hexadecimal string (with or without "0x" prefix), and returns the value as a `uint256`.
Requirements:
- The string must be formatted as `(0x)?[0-9a-fA-F]*`
- The result must fit in an `uint256` type.*


```solidity
function parseHexUint(string memory input) internal pure returns (uint256);
```

### parseHexUint

*Variant of {parseHexUint-string} that parses a substring of `input` located between position `begin` (included) and
`end` (excluded).
Requirements:
- The substring must be formatted as `(0x)?[0-9a-fA-F]*`
- The result must fit in an `uint256` type.*


```solidity
function parseHexUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256);
```

### tryParseHexUint

*Variant of {parseHexUint-string} that returns false if the parsing fails because of an invalid character.
NOTE: This function will revert if the result does not fit in a `uint256`.*


```solidity
function tryParseHexUint(string memory input) internal pure returns (bool success, uint256 value);
```

### tryParseHexUint

*Variant of {parseHexUint-string-uint256-uint256} that returns false if the parsing fails because of an
invalid character.
NOTE: This function will revert if the result does not fit in a `uint256`.*


```solidity
function tryParseHexUint(string memory input, uint256 begin, uint256 end)
    internal
    pure
    returns (bool success, uint256 value);
```

### _tryParseHexUintUncheckedBounds

*Implementation of {tryParseHexUint-string-uint256-uint256} that does not check bounds. Caller should make sure that
`begin <= end <= input.length`. Other inputs would result in undefined behavior.*


```solidity
function _tryParseHexUintUncheckedBounds(string memory input, uint256 begin, uint256 end)
    private
    pure
    returns (bool success, uint256 value);
```

### parseAddress

*Parse a hexadecimal string (with or without "0x" prefix), and returns the value as an `address`.
Requirements:
- The string must be formatted as `(0x)?[0-9a-fA-F]{40}`*


```solidity
function parseAddress(string memory input) internal pure returns (address);
```

### parseAddress

*Variant of {parseAddress-string} that parses a substring of `input` located between position `begin` (included) and
`end` (excluded).
Requirements:
- The substring must be formatted as `(0x)?[0-9a-fA-F]{40}`*


```solidity
function parseAddress(string memory input, uint256 begin, uint256 end) internal pure returns (address);
```

### tryParseAddress

*Variant of {parseAddress-string} that returns false if the parsing fails because the input is not a properly
formatted address. See {parseAddress-string} requirements.*


```solidity
function tryParseAddress(string memory input) internal pure returns (bool success, address value);
```

### tryParseAddress

*Variant of {parseAddress-string-uint256-uint256} that returns false if the parsing fails because input is not a properly
formatted address. See {parseAddress-string-uint256-uint256} requirements.*


```solidity
function tryParseAddress(string memory input, uint256 begin, uint256 end)
    internal
    pure
    returns (bool success, address value);
```

### _tryParseChr


```solidity
function _tryParseChr(bytes1 chr) private pure returns (uint8);
```

### _unsafeReadBytesOffset

*Reads a bytes32 from a bytes array without bounds checking.
NOTE: making this function internal would mean it could be used with memory unsafe offset, and marking the
assembly block as such would prevent some optimizations.*


```solidity
function _unsafeReadBytesOffset(bytes memory buffer, uint256 offset) private pure returns (bytes32 value);
```

## Errors
### StringsInsufficientHexLength
*The `value` string doesn't fit in the specified `length`.*


```solidity
error StringsInsufficientHexLength(uint256 value, uint256 length);
```

### StringsInvalidChar
*The string being parsed contains characters that are not in scope of the given base.*


```solidity
error StringsInvalidChar();
```

### StringsInvalidAddressFormat
*The string being parsed is not a properly formatted address.*


```solidity
error StringsInvalidAddressFormat();
```

