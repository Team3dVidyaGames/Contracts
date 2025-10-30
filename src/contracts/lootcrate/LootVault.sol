// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/access/Ownable.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../../../lib/openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../interfaces/ILootVault.sol";

contract LootVault is ILootVault, Ownable, ReentrancyGuard, ERC1155Holder, ERC721Holder {
    using SafeERC20 for IERC20;

    uint256 public constant NATIVEID = 0;
    uint256 public constant ERC20ID = 20;
    uint256 public constant ERC1155ID = 1155;
    uint256 public constant ERC721ID = 721;

    constructor(address _owner) Ownable(_owner) {}

    function onERC1155Received(address, address, uint256, uint256, bytes memory)
        public
        virtual
        override
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _validateAddresses(address lootToken, address to, uint256 ercID) internal pure {
        if (to == address(0)) {
            revert InvalidAddresses(lootToken, to);
        }
        // For non-native transfers, lootToken should not be zero
        if (ercID != NATIVEID && lootToken == address(0)) {
            revert InvalidAddresses(lootToken, to);
        }
    }

    function claimLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, address to)
        external
        onlyOwner
        nonReentrant
    {
        _validateAddresses(lootToken, to, ercID);

        if (ercID == NATIVEID) {
            if (address(this).balance < amount) {
                revert InsufficientBalance(address(this).balance, amount);
            }
            payable(to).transfer(amount);
        } else if (ercID == ERC20ID) {
            if (IERC20(lootToken).balanceOf(address(this)) < amount) {
                revert InsufficientBalance(IERC20(lootToken).balanceOf(address(this)), amount);
            }
            IERC20(lootToken).safeTransfer(to, amount);
        } else if (ercID == ERC1155ID) {
            if (IERC1155(lootToken).balanceOf(address(this), tokenId) < amount) {
                revert InsufficientBalance(IERC1155(lootToken).balanceOf(address(this), tokenId), amount);
            }
            IERC1155(lootToken).safeTransferFrom(address(this), to, tokenId, amount, "");
        } else if (ercID == ERC721ID) {
            if (IERC721(lootToken).ownerOf(tokenId) != address(this)) {
                revert InsufficientBalance(0, 1);
            }
            IERC721(lootToken).safeTransferFrom(address(this), to, tokenId);
        } else {
            revert InvalidErcID(ercID);
        }

        emit LootClaimed(lootToken, ercID, tokenId, amount, to);
    }

    receive() external payable {}
}
