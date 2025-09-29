// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SplitterAccessControl is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event MemberAdded(address indexed user, uint256 indexed position);
    event MemberRemoved(address indexed user, uint256 indexed position);
    event PositionAddressChanged(address indexed oldUser, address indexed newUser, uint256 indexed position);
    event FundsDistributed(address indexed erc20, bool indexed ethAsWell);

    bytes32 public constant SPLITTER_ROLE = keccak256("SPLITTER_ROLE");
    mapping(address => uint256) public userPosition;
    mapping(uint256 => address) public positionToUser;
    uint256 public memberCount;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function addMemberToSplitter(address user) external onlyRole(ADMIN_ROLE) {
        _grantRole(SPLITTER_ROLE, user);
        memberCount++;
        userPosition[user] = memberCount;
        positionToUser[memberCount] = user;
        emit MemberAdded(user, memberCount);
    }

    function removeMemberFromSplitter(address user) external onlyRole(ADMIN_ROLE) {
        _revokeRole(SPLITTER_ROLE, user);
        uint256 position = userPosition[user];
        positionToUser[position] = positionToUser[memberCount];
        userPosition[positionToUser[memberCount]] = position;
        memberCount--;
        delete userPosition[user];
        delete positionToUser[position];
        emit MemberRemoved(user, position);
    }

    function changePositionAddress(address user) external onlyRole(SPLITTER_ROLE) {
        address oldUser = msg.sender;
        uint256 position = userPosition[user];
        userPosition[oldUser] = 0;
        positionToUser[position] = user;
        userPosition[user] = position;
        emit PositionAddressChanged(oldUser, user, position);
        emit MemberRemoved(oldUser, position);
        emit MemberAdded(user, position);
    }

    function distributeFunds(address erc20, bool ethAsWell) external nonReentrant {
        uint256 balance = address(this).balance / memberCount;
        uint256 erc20Balance = IERC20(erc20).balanceOf(address(this)) / memberCount;
        for (uint256 i = 1; i <= memberCount; i++) {
            address user = positionToUser[i];
            if (ethAsWell) {
                if (address(this).balance < balance) {
                    payable(user).transfer(address(this).balance);
                } else {
                    payable(user).transfer(balance);
                }
            }
            if (erc20 != address(0)) {
                if (IERC20(erc20).balanceOf(address(this)) < erc20Balance) {
                    IERC20(erc20).transfer(user, IERC20(erc20).balanceOf(address(this)));
                } else {
                    IERC20(erc20).transfer(user, erc20Balance);
                }
            }
        }
        emit FundsDistributed(erc20, ethAsWell);
    }
}
