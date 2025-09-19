# ERC721Utils
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/flattened/flattened_TCGInventory.sol)

*Library that provide common ERC-721 utility functions.
See https://eips.ethereum.org/EIPS/eip-721[ERC-721].
_Available since v5.1._*


## Functions
### checkOnERC721Received

*Performs an acceptance check for the provided `operator` by calling [IERC721Receiver-onERC721Received](/lib/chainlink/contracts/src/v0.8/vendor/forge-std/src/interfaces/IERC721.sol/interface.IERC721TokenReceiver.md#onerc721received)
on the `to` address. The `operator` is generally the address that initiated the token transfer (i.e. `msg.sender`).
The acceptance call is not executed and treated as a no-op if the target address doesn't contain code (i.e. an EOA).
Otherwise, the recipient must implement {IERC721Receiver-onERC721Received} and return the acceptance magic value to accept
the transfer.*


```solidity
function checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory data)
    internal;
```

