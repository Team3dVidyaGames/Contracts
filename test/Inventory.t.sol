// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/InventoryV1155.sol";
import "../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../lib/openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {IERC1155Errors} from "../lib/openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract InventoryV1155Test is Test {
    InventoryV1155 private inventory;
    address private admin;
    address private minter;
    address private user;

    function setUp() public {
        admin = address(this);
        minter = vm.addr(1);
        user = vm.addr(2);

        inventory = new InventoryV1155("https://example.com/");
        inventory.grantRole(inventory.ADMIN_ROLE(), admin);
        inventory.grantRole(inventory.MINTER_ROLE(), minter);
    }

    function testAddItem() public {
        uint256[] memory attributeData = new uint256[](2);
        uint256[] memory attributeId = new uint256[](2);
        attributeData[0] = 10;
        attributeData[1] = 20;
        attributeId[0] = 1;
        attributeId[1] = 2;

        InventoryV1155.Item memory item =
            InventoryV1155.Item(attributeData, attributeId, "https://token-uri.com/item1", 1);

        inventory.addItem(item);
        assertEq(inventory.tokenExist(1), true);
    }

    function testUpdateItem() public {
        testAddItem();

        uint256[] memory updatedAttributeData = new uint256[](1);
        uint256[] memory updatedAttributeId = new uint256[](1);
        updatedAttributeData[0] = 50;
        updatedAttributeId[0] = 1;

        InventoryV1155.Item memory updatedItem =
            InventoryV1155.Item(updatedAttributeData, updatedAttributeId, "https://token-uri.com/item1-updated", 1);

        inventory.updateItemData(updatedItem, 1);
        assertEq(inventory.uri(1), "https://token-uri.com/item1-updated");
    }

    function testMint() public {
        testAddItem();

        vm.prank(minter);
        inventory.mint(user, 1, 5);
        assertEq(inventory.balanceOf(user, 1), 5);
    }

    function testMintBatch() public {
        testAddItem();

        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 10;

        vm.prank(minter);
        inventory.mintBatch(user, ids, amounts);
        assertEq(inventory.balanceOf(user, 1), 10);
    }

    function testBurn() public {
        testMint();

        vm.prank(user);
        inventory.burn(user, 1, 2);
        assertEq(inventory.balanceOf(user, 1), 3);
    }

    function testBurnBatch() public {
        testMintBatch();

        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 5;

        vm.prank(user);
        inventory.burnBatch(user, ids, amounts);
        assertEq(inventory.balanceOf(user, 1), 5);
    }

    function testFullBalanceOf() public {
        testMint();

        uint256[] memory balances = inventory.fullBalanceOf(user);
        assertEq(balances[1], 5);
    }

    function testGetCharacterSlot() public {
        testAddItem();
        assertEq(inventory.getCharacterSlot(1), 1);
    }

    function testItemAttributeIdDetail() public {
        testAddItem();
        assertEq(inventory.itemAttributeIdDetail(1, 1), 10);
        assertEq(inventory.itemAttributeIdDetail(1, 2), 20);
    }

    function testGetItemAttributes() public {
        testAddItem();
        (uint256[] memory attributeIds, uint256[] memory attributeData) = inventory.getItemAttributes(1);
        assertEq(attributeIds[0], 1);
        assertEq(attributeIds[1], 2);
        assertEq(attributeData[0], 10);
        assertEq(attributeData[1], 20);
    }

    function testUri() public {
        testAddItem();
        assertEq(inventory.uri(1), "https://token-uri.com/item1");
    }

    function testSupportsInterface() public view {
        // Test ERC1155 interface
        assertTrue(inventory.supportsInterface(0xd9b67a26));
        // Test AccessControl interface
        assertTrue(inventory.supportsInterface(0x7965db0b));
    }

    function testAddItemWithMismatchedArrays() public {
        uint256[] memory attributeData = new uint256[](2);
        uint256[] memory attributeId = new uint256[](1); // Mismatched length
        attributeData[0] = 10;
        attributeData[1] = 20;
        attributeId[0] = 1;

        InventoryV1155.Item memory item =
            InventoryV1155.Item(attributeData, attributeId, "https://token-uri.com/item1", 1);

        vm.expectRevert(abi.encodeWithSelector(InventoryV1155.ItemDataAndIDMisMatch.selector, admin, 2));
        inventory.addItem(item);
    }

    function testUpdateNonExistentItem() public {
        uint256[] memory attributeData = new uint256[](1);
        uint256[] memory attributeId = new uint256[](1);
        attributeData[0] = 50;
        attributeId[0] = 1;

        InventoryV1155.Item memory updatedItem =
            InventoryV1155.Item(attributeData, attributeId, "https://token-uri.com/item1-updated", 1);

        vm.expectRevert(abi.encodeWithSelector(InventoryV1155.TokenDoesNotExist.selector, 999));
        inventory.updateItemData(updatedItem, 999);
    }

    function testMintNonExistentToken() public {
        vm.prank(minter);
        vm.expectRevert(abi.encodeWithSelector(InventoryV1155.TokenDoesNotExist.selector, 999));
        inventory.mint(user, 999, 1);
    }

    function testMintBatchWithNonExistentToken() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        ids[1] = 999; // Non-existent token
        amounts[0] = 1;
        amounts[1] = 1;

        testAddItem(); // Add token 1 first

        vm.prank(minter);
        vm.expectRevert(abi.encodeWithSelector(InventoryV1155.TokenDoesNotExist.selector, 999));
        inventory.mintBatch(user, ids, amounts);
    }

    function testBurnWithoutApproval() public {
        testMint();

        address unauthorized = vm.addr(3);
        vm.prank(unauthorized);
        vm.expectRevert(
            abi.encodeWithSelector(IERC1155Errors.ERC1155MissingApprovalForAll.selector, unauthorized, user)
        );
        inventory.burn(user, 1, 1);
    }

    function testBurnBatchWithoutApproval() public {
        testMintBatch();

        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 5;

        address unauthorized = vm.addr(3);
        vm.prank(unauthorized);
        vm.expectRevert(
            abi.encodeWithSelector(IERC1155Errors.ERC1155MissingApprovalForAll.selector, unauthorized, user)
        );
        inventory.burnBatch(user, ids, amounts);
    }

    function testUriForNonExistentToken() public view {
        assertEq(inventory.uri(999), "https://example.com/");
    }

    function testMintZeroAmount() public {
        testAddItem();
        vm.prank(minter);
        inventory.mint(user, 1, 0);
        assertEq(inventory.balanceOf(user, 1), 0);
    }

    function testMintBatchEmptyArrays() public {
        testAddItem();
        uint256[] memory ids = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);

        vm.prank(minter);
        inventory.mintBatch(user, ids, amounts);
        assertEq(inventory.balanceOf(user, 1), 0);
    }
}
