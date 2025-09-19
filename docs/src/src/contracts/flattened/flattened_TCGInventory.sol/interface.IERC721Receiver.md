# IERC721Receiver
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/587f423f64ab56a242c28dfa0c3602ff1cc24292/src/contracts/flattened/flattened_TCGInventory.sol)

*Interface for any contract that wants to support safeTransfers
from ERC-721 asset contracts.*


## Functions
### onERC721Received

*Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called.
It must return its Solidity selector to confirm the token transfer.
If any other value is returned or the interface is not implemented by the recipient, the transfer will be
reverted.
The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.*


```solidity
function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external
    returns (bytes4);
```

