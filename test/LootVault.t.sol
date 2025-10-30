// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/lootcrate/LootVault.sol";
import "../src/contracts/interfaces/ILootVault.sol";
import "../test/mocks/MockERC20.sol";
import "../test/mocks/MockERC721.sol";
import "../test/mocks/MockERC1155.sol";

contract LootVaultTest is Test {
    ILootVault private vault;
    MockERC20 private erc20Token;
    MockERC721 private erc721Token;
    MockERC1155 private erc1155Token;

    address private owner;
    address private user1;
    address private user2;

    uint256 private constant INITIAL_ETH_BALANCE = 10 ether;
    uint256 private constant INITIAL_ERC20_BALANCE = 1000000;
    uint256 private constant ERC1155_TOKEN_ID = 123;
    uint256 private constant ERC1155_AMOUNT = 50;
    uint256 private constant ERC721_TOKEN_ID = 456;

    function setUp() public {
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        // Deploy contracts
        vault = new LootVault(owner);
        erc20Token = new MockERC20("Test Token", "TEST");
        erc721Token = new MockERC721("Test NFT", "TNFT");
        erc1155Token = new MockERC1155();

        // Fund vault with ETH
        vm.deal(address(vault), INITIAL_ETH_BALANCE);

        // Mint ERC20 tokens to vault
        erc20Token.mint(address(vault), INITIAL_ERC20_BALANCE);

        // Mint ERC721 NFT to vault
        erc721Token.mint(address(vault));

        // Mint ERC1155 tokens to vault
        erc1155Token.mint(address(vault), ERC1155_TOKEN_ID, ERC1155_AMOUNT, "");

        // Verify initial balances
        assertEq(address(vault).balance, INITIAL_ETH_BALANCE);
        assertEq(erc20Token.balanceOf(address(vault)), INITIAL_ERC20_BALANCE);
        assertEq(erc721Token.ownerOf(0), address(vault));
        assertEq(erc1155Token.balanceOf(address(vault), ERC1155_TOKEN_ID), ERC1155_AMOUNT);
    }

    // Test Native ETH Transfers
    function testClaimNativeETH() public {
        uint256 claimAmount = 1 ether;
        uint256 initialBalance = user1.balance;

        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(0xdeadbeef), vault.NATIVEID(), 0, claimAmount, user1);

        vault.claimLoot(address(0xdeadbeef), vault.NATIVEID(), 0, claimAmount, user1);

        assertEq(user1.balance, initialBalance + claimAmount);
        assertEq(address(vault).balance, INITIAL_ETH_BALANCE - claimAmount);
    }

    function testClaimAllNativeETH() public {
        uint256 initialBalance = user1.balance;

        vault.claimLoot(address(0xdeadbeef), vault.NATIVEID(), 0, INITIAL_ETH_BALANCE, user1);

        assertEq(user1.balance, initialBalance + INITIAL_ETH_BALANCE);
        assertEq(address(vault).balance, 0);
    }

    // Test ERC20 Token Transfers
    function testClaimERC20Tokens() public {
        uint256 claimAmount = 1000;
        uint256 initialBalance = erc20Token.balanceOf(user1);

        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc20Token), vault.ERC20ID(), 0, claimAmount, user1);

        vault.claimLoot(address(erc20Token), vault.ERC20ID(), 0, claimAmount, user1);

        assertEq(erc20Token.balanceOf(user1), initialBalance + claimAmount);
        assertEq(erc20Token.balanceOf(address(vault)), INITIAL_ERC20_BALANCE - claimAmount);
    }

    function testClaimAllERC20Tokens() public {
        uint256 initialBalance = erc20Token.balanceOf(user1);

        vault.claimLoot(address(erc20Token), vault.ERC20ID(), 0, INITIAL_ERC20_BALANCE, user1);

        assertEq(erc20Token.balanceOf(user1), initialBalance + INITIAL_ERC20_BALANCE);
        assertEq(erc20Token.balanceOf(address(vault)), 0);
    }

    // Test ERC721 NFT Transfers
    function testClaimERC721NFT() public {
        uint256 tokenId = 0; // First minted NFT

        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc721Token), vault.ERC721ID(), tokenId, 0, user1);

        vault.claimLoot(address(erc721Token), vault.ERC721ID(), tokenId, 0, user1);

        assertEq(erc721Token.ownerOf(tokenId), user1);
    }

    function testClaimERC721NFTWithAmount() public {
        uint256 tokenId = 0;

        // Amount parameter should be ignored for ERC721
        vault.claimLoot(address(erc721Token), vault.ERC721ID(), tokenId, 999, user1);

        assertEq(erc721Token.ownerOf(tokenId), user1);
    }

    // Test ERC1155 Token Transfers
    function testClaimERC1155Tokens() public {
        uint256 claimAmount = 10;
        uint256 initialBalance = erc1155Token.balanceOf(user1, ERC1155_TOKEN_ID);

        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, claimAmount, user1);

        vault.claimLoot(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, claimAmount, user1);

        assertEq(erc1155Token.balanceOf(user1, ERC1155_TOKEN_ID), initialBalance + claimAmount);
        assertEq(erc1155Token.balanceOf(address(vault), ERC1155_TOKEN_ID), ERC1155_AMOUNT - claimAmount);
    }

    function testClaimAllERC1155Tokens() public {
        uint256 initialBalance = erc1155Token.balanceOf(user1, ERC1155_TOKEN_ID);

        vault.claimLoot(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, ERC1155_AMOUNT, user1);

        assertEq(erc1155Token.balanceOf(user1, ERC1155_TOKEN_ID), initialBalance + ERC1155_AMOUNT);
        assertEq(erc1155Token.balanceOf(address(vault), ERC1155_TOKEN_ID), 0);
    }

    // Test Multiple Claims
    function testMultipleClaims() public {
        // Claim ETH
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(0xdeadbeef), vault.NATIVEID(), 0, 1 ether, user1);
        vault.claimLoot(address(0xdeadbeef), vault.NATIVEID(), 0, 1 ether, user1);

        // Claim ERC20
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc20Token), vault.ERC20ID(), 0, 1000, user1);
        vault.claimLoot(address(erc20Token), vault.ERC20ID(), 0, 1000, user1);

        // Claim ERC721
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc721Token), vault.ERC721ID(), 0, 0, user1);
        vault.claimLoot(address(erc721Token), vault.ERC721ID(), 0, 0, user1);

        // Claim ERC1155
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, 10, user1);
        vault.claimLoot(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, 10, user1);

        // Verify all transfers
        assertEq(user1.balance, 1 ether);
        assertEq(erc20Token.balanceOf(user1), 1000);
        assertEq(erc721Token.ownerOf(0), user1);
        assertEq(erc1155Token.balanceOf(user1, ERC1155_TOKEN_ID), 10);
    }

    // Test Access Control
    function testOnlyOwnerCanClaim() public {
        // Test that non-owner cannot claim
        uint256 nativeId = vault.NATIVEID();
        vm.prank(user1);
        vm.expectRevert();
        vault.claimLoot(address(0xdeadbeef), nativeId, 0, 1 ether, user2);
    }

    function testOwnerCanClaim() public {
        // Test that owner can claim (this should work)
        vault.claimLoot(address(0xdeadbeef), vault.NATIVEID(), 0, 1 ether, user1);
        assertEq(user1.balance, 1 ether);
    }

    // Test onlyOwner modifier specifically
    function testOnlyOwnerModifier() public {
        // Reset balance for next test
        vm.deal(user2, INITIAL_ETH_BALANCE);
        vm.deal(address(vault), INITIAL_ETH_BALANCE);

        // This should fail as user2 is not the owner
        uint256 nativeId = vault.NATIVEID();
        vm.prank(user2);
        vm.expectRevert();
        vault.claimLoot(address(0xdeadbeef), nativeId, 0, 1 ether, user2);
    }

    function testNonOwnerCannotClaimERC20() public {
        uint256 erc20Id = vault.ERC20ID();
        vm.prank(user1);
        vm.expectRevert();
        vault.claimLoot(address(erc20Token), erc20Id, 0, 1000, user2);
    }

    function testNonOwnerCannotClaimERC721() public {
        uint256 erc721Id = vault.ERC721ID();
        vm.prank(user1);
        vm.expectRevert();
        vault.claimLoot(address(erc721Token), erc721Id, 0, 0, user2);
    }

    function testNonOwnerCannotClaimERC1155() public {
        uint256 erc1155Id = vault.ERC1155ID();
        vm.prank(user1);
        vm.expectRevert();
        vault.claimLoot(address(erc1155Token), erc1155Id, ERC1155_TOKEN_ID, 10, user2);
    }

    // Test Invalid Token ID
    function testInvalidTokenID() public {
        vm.expectRevert(abi.encodeWithSelector(ILootVault.InvalidErcID.selector, 999));
        vault.claimLoot(address(0xdeadbeef), 999, 0, 1 ether, user1);
    }

    // Test Insufficient Balance Scenarios
    function testInsufficientETHBalance() public {
        uint256 excessiveAmount = INITIAL_ETH_BALANCE + 100 ether;
        uint256 nativeId = vault.NATIVEID();

        // This will revert due to insufficient ETH balance in the vault
        vm.expectRevert(
            abi.encodeWithSelector(ILootVault.InsufficientBalance.selector, INITIAL_ETH_BALANCE, excessiveAmount)
        );
        vault.claimLoot(address(0xdeadbeef), nativeId, 0, excessiveAmount, user1);
    }

    function testInsufficientERC20Balance() public {
        uint256 excessiveAmount = INITIAL_ERC20_BALANCE + 1000;
        uint256 erc20Id = vault.ERC20ID();

        // This will revert due to insufficient ERC20 balance in the vault
        vm.expectRevert(
            abi.encodeWithSelector(ILootVault.InsufficientBalance.selector, INITIAL_ERC20_BALANCE, excessiveAmount)
        );
        vault.claimLoot(address(erc20Token), erc20Id, 0, excessiveAmount, user1);
    }

    function testInsufficientERC1155Balance() public {
        uint256 excessiveAmount = ERC1155_AMOUNT + 100;
        uint256 erc1155Id = vault.ERC1155ID();

        // This will revert due to insufficient ERC1155 balance in the vault
        vm.expectRevert(
            abi.encodeWithSelector(ILootVault.InsufficientBalance.selector, ERC1155_AMOUNT, excessiveAmount)
        );
        vault.claimLoot(address(erc1155Token), erc1155Id, ERC1155_TOKEN_ID, excessiveAmount, user1);
    }

    // Test Token Reception
    function testCanReceiveETH() public {
        uint256 sendAmount = 5 ether;
        uint256 initialBalance = address(vault).balance;

        vm.deal(user1, sendAmount);
        vm.prank(user1);
        (bool success,) = address(vault).call{value: sendAmount}("");

        assertTrue(success);
        assertEq(address(vault).balance, initialBalance + sendAmount);
    }

    function testCanReceiveERC20() public {
        uint256 mintAmount = 5000;
        uint256 initialBalance = erc20Token.balanceOf(address(vault));

        erc20Token.mint(address(vault), mintAmount);

        assertEq(erc20Token.balanceOf(address(vault)), initialBalance + mintAmount);
    }

    function testCanReceiveERC721() public {
        uint256 tokenId = erc721Token.mint(address(vault));

        assertEq(erc721Token.ownerOf(tokenId), address(vault));
    }

    function testCanReceiveERC1155() public {
        uint256 newTokenId = 999;
        uint256 amount = 25;

        erc1155Token.mint(address(vault), newTokenId, amount, "");

        assertEq(erc1155Token.balanceOf(address(vault), newTokenId), amount);
    }

    // Test Edge Cases
    function testClaimZeroAmount() public {
        uint256 initialBalance = user1.balance;

        vault.claimLoot(address(0xdeadbeef), vault.NATIVEID(), 0, 0, user1);

        assertEq(user1.balance, initialBalance);
        assertEq(address(vault).balance, INITIAL_ETH_BALANCE);
    }

    function testClaimToZeroAddress() public {
        uint256 nativeId = vault.NATIVEID();
        vm.expectRevert(abi.encodeWithSelector(ILootVault.InvalidAddresses.selector, address(0xdeadbeef), address(0)));
        vault.claimLoot(address(0xdeadbeef), nativeId, 0, 1 ether, address(0));
    }

    // Test Constants
    function testConstants() public view {
        assertEq(vault.NATIVEID(), 0);
        assertEq(vault.ERC20ID(), 20);
        assertEq(vault.ERC1155ID(), 1155);
        assertEq(vault.ERC721ID(), 721);
    }

    // Test Event Emission
    function testEventEmission() public {
        // Test ETH event
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(0), vault.NATIVEID(), 0, 1 ether, user1);
        vault.claimLoot(address(0), vault.NATIVEID(), 0, 1 ether, user1);

        // Test ERC20 event
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc20Token), vault.ERC20ID(), 0, 500, user2);
        vault.claimLoot(address(erc20Token), vault.ERC20ID(), 0, 500, user2);

        // Test ERC721 event
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc721Token), vault.ERC721ID(), 0, 0, user2);
        vault.claimLoot(address(erc721Token), vault.ERC721ID(), 0, 0, user2);

        // Test ERC1155 event
        vm.expectEmit(true, true, true, true);
        emit ILootVault.LootClaimed(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, 25, user2);
        vault.claimLoot(address(erc1155Token), vault.ERC1155ID(), ERC1155_TOKEN_ID, 25, user2);
    }
}
