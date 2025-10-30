// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/ILootVault.sol";

contract LootCrate is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for address payable;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REWARD_ADDER_ROLE = keccak256("REWARD_ADDER_ROLE");

    ILootVault public lootVault;

    error InvalidLootVaultOwner();

    struct LootCrateItem {
        address lootToken;
        uint256 ercID;
        uint256 tokenId;
        uint256 amount;
        uint256 rarity;
    }

    mapping(address => mapping(uint256 => uint256)) internal contractToTokenIdToAmount;
    mapping(uint256 => LootCrateItem[]) public rarityToLootCrateItems;

    constructor() AccessControl() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(REWARD_ADDER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(REWARD_ADDER_ROLE, msg.sender);
    }

    function setLootVault(address _lootVault) external onlyRole(ADMIN_ROLE) {
        if (IOwnable(_lootVault).owner() != address(this)) {
            revert InvalidLootVaultOwner();
        }
        lootVault = ILootVault(payable(_lootVault));
    }

    function addLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, uint256 rarity)
        external
        payable
        onlyRole(REWARD_ADDER_ROLE)
    {
        _transferLootToVault(msg.sender, lootToken, ercID, tokenId, amount);
        _addLootCrateItem(lootToken, ercID, tokenId, amount, rarity);
    }

    // INTERNAL FUNCTIONS ------------------------------------------------------------

    function _claimLoot(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, address to)
        internal
        onlyRole(REWARD_ADDER_ROLE)
        nonReentrant
    {
        lootVault.claimLoot(lootToken, ercID, tokenId, amount, to);
    }

    function _addLootCrateItem(address lootToken, uint256 ercID, uint256 tokenId, uint256 amount, uint256 rarity)
        internal
    {
        LootCrateItem memory lootCrateItem =
            LootCrateItem({lootToken: lootToken, ercID: ercID, tokenId: tokenId, amount: amount, rarity: rarity});
        rarityToLootCrateItems[rarity].push(lootCrateItem);
        contractToTokenIdToAmount[lootToken][tokenId] += amount;
    }

    function _transferLootToVault(address from, address lootToken, uint256 ercID, uint256 tokenId, uint256 amount)
        internal
    {
        if (ercID == lootVault.NATIVEID()) {
            if (address(this).balance < amount) {
                revert ILootVault.InsufficientBalance(address(this).balance, amount);
            }
            payable(address(lootVault)).transfer(amount);
        } else if (ercID == lootVault.ERC20ID()) {
            IERC20(lootToken).safeTransfer(address(lootVault), amount);
        } else if (ercID == lootVault.ERC1155ID()) {
            IERC1155(lootToken).safeTransferFrom(from, address(lootVault), tokenId, amount, "");
        } else if (ercID == lootVault.ERC721ID()) {
            IERC721(lootToken).safeTransferFrom(from, address(lootVault), tokenId);
        } else {
            revert ILootVault.InvalidErcID(ercID);
        }
    }

    // ROLES FUNCTIONS ------------------------------------------------------------

    function addRewarder(address _reward) external onlyRole(ADMIN_ROLE) {
        _grantRole(REWARD_ADDER_ROLE, _reward);
    }

    function removeRewardAdder(address _reward) external onlyRole(ADMIN_ROLE) {
        _revokeRole(REWARD_ADDER_ROLE, _reward);
    }

    receive() external payable {}
}
