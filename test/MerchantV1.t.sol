// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/merchant/MerchantV1.sol";
import "../src/contracts/InventoryV1155.sol";

// Event definitions for testing
event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
event InventoryUpdated(address indexed oldInventory, address indexed newInventory);
event MerchandiseAdded(uint256 indexed merchandiseId, uint256 indexed tokenId, uint256 unitPrice, uint256 quantity);
event MerchandisePurchased(uint256 indexed merchandiseId, address indexed buyer, uint256 quantity, uint256 totalPrice);
event MerchandiseBatchPurchased(address indexed buyer, uint256[] merchandiseIds, uint256[] quantities, uint256 totalPrice);
event MerchandiseRestocked(uint256 indexed merchandiseId, uint256 addedQuantity, uint256 newTotalQuantity);
event MerchandiseStatusChanged(uint256 indexed merchandiseId, bool isActive);
event MerchandisePriceUpdated(uint256 indexed merchandiseId, uint256 oldPrice, uint256 newPrice);
event Withdrawal(address indexed to, uint256 amount);

contract MerchantV1Test is Test {
    MerchantV1 private merchant;
    InventoryV1155 private inventory;
    address private admin;
    address private shop;
    address private buyer;
    address private treasury;

    function setUp() public {
        admin = address(this);
        shop = vm.addr(1);
        buyer = vm.addr(2);
        treasury = vm.addr(3);

        // Deploy contracts
        merchant = new MerchantV1();
        inventory = new InventoryV1155("https://example.com/");

        // Setup roles
        merchant.grantRole(merchant.SHOP_ROLE(), shop);
        merchant.setTreasury(treasury);
        merchant.setInventory1155(address(inventory));

        // Setup inventory
        inventory.grantRole(inventory.MINTER_ROLE(), address(merchant));
        inventory.grantRole(inventory.ADMIN_ROLE(), admin);

        // Add test items to inventory
        uint256[] memory attributeData = new uint256[](1);
        uint256[] memory attributeId = new uint256[](1);
        attributeData[0] = 10;
        attributeId[0] = 1;

        InventoryV1155.Item memory item1 = InventoryV1155.Item(
            attributeData,
            attributeId,
            "https://token-uri.com/item1",
            1
        );

        InventoryV1155.Item memory item2 = InventoryV1155.Item(
            attributeData,
            attributeId,
            "https://token-uri.com/item2",
            2
        );

        inventory.addItem(item1);
        inventory.addItem(item2);
    }

    function testSetup() public view {
        assertTrue(merchant.hasRole(merchant.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(merchant.hasRole(merchant.SHOP_ROLE(), shop));
        assertEq(merchant.treasury(), treasury);
        assertEq(merchant.inventory1155(), address(inventory));
    }

    function testAddMerchandise() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        (uint256 unitPrice, bool isActive) = merchant.getUnitPrice(1);
        assertEq(unitPrice, 1 ether);
        assertTrue(isActive);
        assertEq(merchant.getMerchandiseCount(), 2); // 2 because count starts at 1
    }

    function testAddMerchandiseOnlyShop() public {
        vm.prank(buyer);
        vm.expectRevert();
        merchant.addMerchandise(1, 1 ether, 10);
    }

    function testBuyMerchandise() public {
        // Add merchandise
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        // Buy merchandise
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        merchant.buyMerchandise{value: 2 ether}(1, 2);

        // Check balances
        assertEq(inventory.balanceOf(buyer, 1), 2);
        assertEq(treasury.balance, 2 ether);
    }

    function testBuyMerchandiseInsufficientPayment() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        vm.expectRevert(bytes("Insufficient balance"));
        merchant.buyMerchandise{value: 0.5 ether}(1, 1);
    }

    function testBuyMerchandiseBatch() public {
        // Add multiple merchandise items
        vm.startPrank(shop);
        merchant.addMerchandise(1, 1 ether, 10);
        merchant.addMerchandise(2, 2 ether, 5);
        vm.stopPrank();

        // Buy multiple items
        vm.deal(buyer, 10 ether);
        vm.prank(buyer);
        uint256[] memory ids = new uint256[](2);
        uint256[] memory quantities = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        quantities[0] = 2;
        quantities[1] = 1;
        merchant.buyMerchandiseBatch{value: 4 ether}(ids, quantities);

        // Check balances
        assertEq(inventory.balanceOf(buyer, 1), 2);
        assertEq(inventory.balanceOf(buyer, 2), 1);
        assertEq(treasury.balance, 4 ether);
    }

    function testSetMerchandiseActive() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.prank(shop);
        merchant.setMerchandiseActive(1, false);

        (, bool isActive) = merchant.getUnitPrice(1);
        assertFalse(isActive);
    }

    function testSetMerchandiseUnitPrice() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.prank(shop);
        merchant.setMerchandiseUnitPrice(1, 2 ether);

        (uint256 unitPrice, ) = merchant.getUnitPrice(1);
        assertEq(unitPrice, 2 ether);
    }

    function testRestockMerchandise() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.prank(shop);
        merchant.restockMerchandise(1, 5);

        MerchantV1.Merchandise memory item = merchant.getMerchandise(1);
        assertEq(item.quantity, 15);
        assertFalse(item.isSoldOut);
    }

    function testWithdraw() public {
        // Add some ETH to the contract
        vm.deal(address(merchant), 1 ether);

        merchant.withdraw();
        assertEq(treasury.balance, 1 ether);
        assertEq(address(merchant).balance, 0);
    }

    function testBuyMerchandiseSoldOut() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 1);

        // First purchase
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        merchant.buyMerchandise{value: 1 ether}(1, 1);

        // Try to buy again
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        vm.expectRevert(bytes("Merchandise is sold out"));
        merchant.buyMerchandise{value: 1 ether}(1, 1);
    }

    function testBuyMerchandiseInactive() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.prank(shop);
        merchant.setMerchandiseActive(1, false);

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        vm.expectRevert(bytes("Merchandise is not active"));
        merchant.buyMerchandise{value: 1 ether}(1, 1);
    }

    function testBuyMerchandiseExcessQuantity() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.deal(buyer, 20 ether);
        vm.prank(buyer);
        vm.expectRevert(
            bytes("Quantity is greater than the available quantity")
        );
        merchant.buyMerchandise{value: 20 ether}(1, 20);
    }

    function testDuplicateTokenId() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.prank(shop);
        vm.expectRevert();
        merchant.addMerchandise(1, 2 ether, 5);
    }

    function testBuyMerchandiseBatchEmptyArrays() public {
        uint256[] memory merchandiseIds = new uint256[](0);
        uint256[] memory quantities = new uint256[](0);

        vm.expectRevert();
        merchant.buyMerchandiseBatch(merchandiseIds, quantities);
    }

    function testBuyMerchandiseBatchMismatchedArrays() public {
        uint256[] memory merchandiseIds = new uint256[](2);
        uint256[] memory quantities = new uint256[](1);

        vm.expectRevert();
        merchant.buyMerchandiseBatch(merchandiseIds, quantities);
    }

    function testBuyMerchandiseBatchMultipleItems() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);
        vm.prank(shop);
        merchant.addMerchandise(2, 2 ether, 5);

        uint256[] memory merchandiseIds = new uint256[](2);
        uint256[] memory quantities = new uint256[](2);
        merchandiseIds[0] = 1;
        merchandiseIds[1] = 2;
        quantities[0] = 2;
        quantities[1] = 1;

        vm.deal(buyer, 4 ether);
        vm.prank(buyer);
        merchant.buyMerchandiseBatch{value: 4 ether}(merchandiseIds, quantities);

        assertEq(inventory.balanceOf(buyer, 1), 2);
        assertEq(inventory.balanceOf(buyer, 2), 1);
    }

    function testGrantShopRole() public {
        address newShop = address(0x789);
        vm.prank(admin);
        merchant.grantRole(merchant.SHOP_ROLE(), newShop);
        assertTrue(merchant.hasRole(merchant.SHOP_ROLE(), newShop));
    }

    function testRevokeShopRole() public {
        vm.prank(admin);
        merchant.revokeRole(merchant.SHOP_ROLE(), shop);
        assertFalse(merchant.hasRole(merchant.SHOP_ROLE(), shop));

        vm.prank(shop);
        vm.expectRevert();
        merchant.addMerchandise(1, 1 ether, 10);
    }

    function testBuyMerchandiseExactPayment() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        merchant.buyMerchandise{value: 1 ether}(1, 1);
        assertEq(inventory.balanceOf(buyer, 1), 1);
    }

    function testBuyMerchandiseExcessPayment() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        merchant.buyMerchandise{value: 2 ether}(1, 1);
        assertEq(inventory.balanceOf(buyer, 1), 1);
        assertEq(address(merchant).balance, 0);
    }

    function testBuyMerchandiseZeroPayment() public {
        vm.prank(shop);
        merchant.addMerchandise(1, 1 ether, 10);

        vm.deal(buyer, 0);
        vm.prank(buyer);
        vm.expectRevert(bytes("Insufficient balance"));
        merchant.buyMerchandise{value: 0}(1, 1);
    }

    function testTreasuryBalance() public {
        vm.deal(address(merchant), 1 ether);
        uint256 initialBalance = treasury.balance;
        
        vm.prank(admin);
        merchant.withdraw();
        
        assertEq(treasury.balance, initialBalance + 1 ether);
        assertEq(address(merchant).balance, 0);
    }
}
