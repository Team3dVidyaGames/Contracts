// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./IOwnable.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../../lib/openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../../lib/openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILootVault {
    // Constants
    function NATIVEID() external pure returns (uint256);

    function ERC20ID() external pure returns (uint256);

    function ERC1155ID() external pure returns (uint256);

    function ERC721ID() external pure returns (uint256);

    // Events
    event LootClaimed(
        address indexed lootToken, uint256 ercID, uint256 indexed tokenId, uint256 amount, address indexed to
    );

    // Errors
    error InvalidErcID(uint256 _ercID);
    error InvalidAddresses(address _lootToken, address _to);
    error InsufficientBalance(uint256 _available, uint256 _required);

    // Main function
    function claimLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, address to) external;

    // Receive function for ETH
    receive() external payable;
}
