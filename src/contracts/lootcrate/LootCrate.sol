// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../lib/openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../../lib/openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LootCrate is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REWARD_ADDER_ROLE = keccak256("REWARD_ADDER_ROLE");

    constructor() AccessControl() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(REWARD_ADDER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(REWARD_ADDER_ROLE, msg.sender);
    }

    function addRewardAdder(address _reward) external onlyRole(ADMIN_ROLE) {
        _grantRole(REWARD_ADDER_ROLE, _reward);
    }

    function removeRewardAdder(address _reward) external onlyRole(ADMIN_ROLE) {
        _revokeRole(REWARD_ADDER_ROLE, _reward);
    }
}
