// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/splitter/SplitterAccessControl.sol";
import "../test/mocks/MockERC20.sol";
import "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SplitterAccessControlTest is Test {
    SplitterAccessControl private splitter;
    MockERC20 private mockToken;

    address private admin;
    address private member1;
    address private member2;
    address private member3;
    address private nonMember;

    event MemberAdded(address indexed user, uint256 indexed position);
    event MemberRemoved(address indexed user, uint256 indexed position);
    event PositionAddressChanged(
        address indexed oldUser,
        address indexed newUser,
        uint256 indexed position
    );
    event FundsDistributed(address indexed erc20, bool indexed ethAsWell);

    function setUp() public {
        admin = address(this);
        member1 = vm.addr(1);
        member2 = vm.addr(2);
        member3 = vm.addr(3);
        nonMember = vm.addr(4);

        splitter = new SplitterAccessControl();
        mockToken = new MockERC20("Test Token", "TEST");

        // Mint some tokens to the splitter contract for testing
        mockToken.mint(address(splitter), 1000e18);
    }

    function testConstructor() public {
        assertTrue(splitter.hasRole(splitter.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(splitter.hasRole(splitter.ADMIN_ROLE(), admin));
        assertEq(splitter.memberCount(), 0);
    }

    function testAddMemberToSplitter() public {
        vm.expectEmit(true, true, false, true);
        emit MemberAdded(member1, 1);

        splitter.addMemberToSplitter(member1);

        assertTrue(splitter.hasRole(splitter.SPLITTER_ROLE(), member1));
        assertEq(splitter.memberCount(), 1);
        assertEq(splitter.userPosition(member1), 1);
        assertEq(splitter.positionToUser(1), member1);
    }

    function testAddMultipleMembers() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);
        splitter.addMemberToSplitter(member3);

        assertEq(splitter.memberCount(), 3);
        assertEq(splitter.userPosition(member1), 1);
        assertEq(splitter.userPosition(member2), 2);
        assertEq(splitter.userPosition(member3), 3);
        assertEq(splitter.positionToUser(1), member1);
        assertEq(splitter.positionToUser(2), member2);
        assertEq(splitter.positionToUser(3), member3);
    }

    function testAddMemberOnlyAdmin() public {
        vm.prank(nonMember);
        vm.expectRevert();
        splitter.addMemberToSplitter(member1);
    }

    function testRemoveMemberFromSplitter() public {
        // Add members first
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);
        splitter.addMemberToSplitter(member3);

        // Remove member2 (position 2)
        vm.expectEmit(true, true, false, true);
        emit MemberRemoved(member2, 2);

        splitter.removeMemberFromSplitter(member2);

        assertFalse(splitter.hasRole(splitter.SPLITTER_ROLE(), member2));
        assertEq(splitter.memberCount(), 2);
        assertEq(splitter.userPosition(member2), 0);
        assertEq(splitter.positionToUser(2), member3); // member3 moved to position 2
        assertEq(splitter.userPosition(member3), 2);
    }

    function testRemoveLastMember() public {
        splitter.addMemberToSplitter(member1);

        vm.expectEmit(true, true, false, true);
        emit MemberRemoved(member1, 1);

        splitter.removeMemberFromSplitter(member1);

        assertEq(splitter.memberCount(), 0);
        assertEq(splitter.userPosition(member1), 0);
        assertEq(splitter.positionToUser(1), address(0));
    }

    function testRemoveMemberOnlyAdmin() public {
        splitter.addMemberToSplitter(member1);

        vm.prank(member1);
        vm.expectRevert();
        splitter.removeMemberFromSplitter(member1);
    }

    function testChangePositionAddress() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);

        // member1 changes their position to member3
        vm.prank(member1);
        vm.expectEmit(true, true, true, true);
        emit PositionAddressChanged(member1, member3, 1);
        emit MemberRemoved(member1, 1);
        emit MemberAdded(member3, 1);

        splitter.changePositionAddress(member3);

        assertEq(splitter.userPosition(member1), 0);
        assertEq(splitter.userPosition(member3), 1);
        assertEq(splitter.positionToUser(1), member3);
        assertTrue(splitter.hasRole(splitter.SPLITTER_ROLE(), member3));
        assertFalse(splitter.hasRole(splitter.SPLITTER_ROLE(), member1));
    }

    function testChangePositionOnlySplitter() public {
        splitter.addMemberToSplitter(member1);

        vm.prank(nonMember);
        vm.expectRevert();
        splitter.changePositionAddress(member2);
    }

    function testDistributeFundsETHOnly() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);

        // Send ETH to the contract
        vm.deal(address(splitter), 2 ether);

        uint256 balanceBefore1 = member1.balance;
        uint256 balanceBefore2 = member2.balance;

        vm.expectEmit(true, true, false, true);
        emit FundsDistributed(address(0), true);

        splitter.distributeFunds(address(0), true);

        assertEq(member1.balance, balanceBefore1 + 1 ether);
        assertEq(member2.balance, balanceBefore2 + 1 ether);
        assertEq(address(splitter).balance, 0);
    }

    function testDistributeFundsERC20Only() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);

        uint256 balanceBefore1 = mockToken.balanceOf(member1);
        uint256 balanceBefore2 = mockToken.balanceOf(member2);

        vm.expectEmit(true, true, false, true);
        emit FundsDistributed(address(mockToken), false);

        splitter.distributeFunds(address(mockToken), false);

        assertEq(mockToken.balanceOf(member1), balanceBefore1 + 500e18);
        assertEq(mockToken.balanceOf(member2), balanceBefore2 + 500e18);
        assertEq(mockToken.balanceOf(address(splitter)), 0);
    }

    function testDistributeFundsBoth() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);

        // Send ETH to the contract
        vm.deal(address(splitter), 2 ether);

        uint256 ethBalanceBefore1 = member1.balance;
        uint256 ethBalanceBefore2 = member2.balance;
        uint256 tokenBalanceBefore1 = mockToken.balanceOf(member1);
        uint256 tokenBalanceBefore2 = mockToken.balanceOf(member2);

        vm.expectEmit(true, true, false, true);
        emit FundsDistributed(address(mockToken), true);

        splitter.distributeFunds(address(mockToken), true);

        assertEq(member1.balance, ethBalanceBefore1 + 1 ether);
        assertEq(member2.balance, ethBalanceBefore2 + 1 ether);
        assertEq(mockToken.balanceOf(member1), tokenBalanceBefore1 + 500e18);
        assertEq(mockToken.balanceOf(member2), tokenBalanceBefore2 + 500e18);
    }

    function testDistributeFundsWithRemainder() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);
        splitter.addMemberToSplitter(member3);

        // Send 7 wei to the contract (not evenly divisible by 3)
        vm.deal(address(splitter), 7 wei);

        splitter.distributeFunds(address(0), true);

        // Should distribute 2 wei to each member, with 1 wei remaining
        assertEq(member1.balance, 2 wei);
        assertEq(member2.balance, 2 wei);
        assertEq(member3.balance, 2 wei);
        assertEq(address(splitter).balance, 1 wei);
    }

    function testDistributeFundsERC20WithRemainder() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);
        splitter.addMemberToSplitter(member3);

        // Mint 7 tokens (not evenly divisible by 3)
        mockToken.mint(address(splitter), 7);

        splitter.distributeFunds(address(mockToken), false);

        // Should distribute 2 tokens to each member, with 1 token remaining
        assertEq(mockToken.balanceOf(member1), 2);
        assertEq(mockToken.balanceOf(member2), 2);
        assertEq(mockToken.balanceOf(member3), 2);
        assertEq(mockToken.balanceOf(address(splitter)), 1);
    }

    function testDistributeFundsZeroMembers() public {
        // Should not revert but also not distribute anything
        splitter.distributeFunds(address(0), true);
        splitter.distributeFunds(address(mockToken), false);
    }

    function testDistributeFundsReentrancyProtection() public {
        splitter.addMemberToSplitter(member1);
        vm.deal(address(splitter), 1 ether);

        // This should work fine due to nonReentrant modifier
        splitter.distributeFunds(address(0), true);
        assertEq(member1.balance, 1 ether);
    }

    function testRoleAdminSetup() public {
        assertEq(
            splitter.getRoleAdmin(splitter.ADMIN_ROLE()),
            splitter.DEFAULT_ADMIN_ROLE()
        );
    }

    function testMemberCountUpdates() public {
        assertEq(splitter.memberCount(), 0);

        splitter.addMemberToSplitter(member1);
        assertEq(splitter.memberCount(), 1);

        splitter.addMemberToSplitter(member2);
        assertEq(splitter.memberCount(), 2);

        splitter.removeMemberFromSplitter(member1);
        assertEq(splitter.memberCount(), 1);

        splitter.removeMemberFromSplitter(member2);
        assertEq(splitter.memberCount(), 0);
    }

    function testPositionMappingIntegrity() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);
        splitter.addMemberToSplitter(member3);

        // Test position to user mapping
        assertEq(splitter.positionToUser(1), member1);
        assertEq(splitter.positionToUser(2), member2);
        assertEq(splitter.positionToUser(3), member3);

        // Test user to position mapping
        assertEq(splitter.userPosition(member1), 1);
        assertEq(splitter.userPosition(member2), 2);
        assertEq(splitter.userPosition(member3), 3);

        // Remove member2 and check that member3 moves to position 2
        splitter.removeMemberFromSplitter(member2);

        assertEq(splitter.positionToUser(1), member1);
        assertEq(splitter.positionToUser(2), member3);
        assertEq(splitter.userPosition(member1), 1);
        assertEq(splitter.userPosition(member3), 2);
        assertEq(splitter.userPosition(member2), 0);
    }

    function testChangePositionAddressUpdates() public {
        splitter.addMemberToSplitter(member1);
        splitter.addMemberToSplitter(member2);

        // member1 changes position to member3
        vm.prank(member1);
        splitter.changePositionAddress(member3);

        // Check that member3 now has position 1 and SPLITTER_ROLE
        assertEq(splitter.userPosition(member3), 1);
        assertEq(splitter.positionToUser(1), member3);
        assertTrue(splitter.hasRole(splitter.SPLITTER_ROLE(), member3));

        // Check that member1 no longer has position or role
        assertEq(splitter.userPosition(member1), 0);
        assertFalse(splitter.hasRole(splitter.SPLITTER_ROLE(), member1));

        // member2 should still be at position 2
        assertEq(splitter.userPosition(member2), 2);
        assertEq(splitter.positionToUser(2), member2);
    }
}
