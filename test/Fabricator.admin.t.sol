// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
import "../src/contracts/Fabricator.sol";
import "../src/contracts/InventoryV1155.sol";
import "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin/contracts/access/AccessControl.sol";

contract FabricatorTest is Test {
    Fabricator private fabricator;
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
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        fabricator = new Fabricator();
    }

    // Flexible recipe builder for tests
    function _makeRecipe(
        Fabricator.MintItem memory mintItem,
        address creator,
        Fabricator.Item1155[] memory items1155,
        Fabricator.Item20[] memory items20
    ) internal pure returns (Fabricator.Recipe memory) {
        return
            Fabricator.Recipe({
                mintItem: mintItem,
                creator: creator,
                items1155: items1155,
                items20: items20
            });
    }

    function testAddRecipe_Success() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);

        // Grant Fabricator MINTER_ROLE on inventory
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create a recipe with at least one ERC1155 item
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);
        assertEq(fabricator.recipeCount(), 1);
        (Fabricator.MintItem memory mintItemOut, , , ) = fabricator
            .getRecipeDetails(0);
        assertEq(mintItemOut.contractAddress, address(inventory));
        assertEq(mintItemOut.id, 1);
        assertEq(mintItemOut.amount, 1);
    }

    function testAddRecipe_FailsIfNotAdmin() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        Fabricator.Recipe memory recipe = _makeRecipe(
            Fabricator.MintItem({
                contractAddress: address(inventory),
                id: 1,
                amount: 1
            }),
            admin,
            new Fabricator.Item1155[](0),
            new Fabricator.Item20[](0)
        );
        vm.prank(user); // user is not admin
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testAddRecipe_FailsIfNotMinter() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        // Do NOT grant MINTER_ROLE to Fabricator
        Fabricator.Recipe memory recipe = _makeRecipe(
            Fabricator.MintItem({
                contractAddress: address(inventory),
                id: 1,
                amount: 1
            }),
            admin,
            new Fabricator.Item1155[](0),
            new Fabricator.Item20[](0)
        );
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testAddRecipe_FailsIfTooManyItems() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Too many items1155
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](21);
        for (uint256 i = 0; i < 21; i++) {
            items1155[i] = Fabricator.Item1155(address(inventory), 1, 1, false);
        }
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = Fabricator.Recipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testAddRecipe_FailsIfZeroCreator() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        Fabricator.Recipe memory recipe = _makeRecipe(
            Fabricator.MintItem({
                contractAddress: address(inventory),
                id: 1,
                amount: 1
            }),
            address(0),
            new Fabricator.Item1155[](0),
            new Fabricator.Item20[](0)
        );
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testAddRecipe_FailsIfTooMany1155sAnd20s() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Too many items1155 and items20
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](21);
        for (uint256 i = 0; i < 21; i++) {
            items1155[i] = Fabricator.Item1155(address(inventory), 1, 1, false);
        }
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](21);
        for (uint256 i = 0; i < 21; i++) {
            items20[i] = Fabricator.Item20(address(0), 1, false);
        }
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testAddRecipe_FailsIfNoItemsListed() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create a recipe with no items
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](0);
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        vm.expectRevert();
        fabricator.addRecipe(recipe);
    }

    function testRemoveRecipe_Success() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add multiple recipes with different inventory contracts
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem1 = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe1 = _makeRecipe(
            mintItem1,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe1);

        // Create a second inventory contract
        InventoryV1155 inventory2 = new InventoryV1155("https://example2.com/");
        inventory2.grantRole(inventory2.ADMIN_ROLE(), admin);
        inventory2.grantRole(inventory2.MINTER_ROLE(), address(fabricator));
        inventory2.addItem(item);
        Fabricator.MintItem memory mintItem2 = Fabricator.MintItem(
            address(inventory2),
            1,
            1
        );
        Fabricator.Recipe memory recipe2 = _makeRecipe(
            mintItem2,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe2);

        // Create a third inventory contract
        InventoryV1155 inventory3 = new InventoryV1155("https://example3.com/");
        inventory3.grantRole(inventory3.ADMIN_ROLE(), admin);
        inventory3.grantRole(inventory3.MINTER_ROLE(), address(fabricator));
        inventory3.addItem(item);
        Fabricator.MintItem memory mintItem3 = Fabricator.MintItem(
            address(inventory3),
            1,
            1
        );
        Fabricator.Recipe memory recipe3 = _makeRecipe(
            mintItem3,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe3);
        assertEq(fabricator.recipeCount(), 3);

        // Remove the middle recipe (recipe2)
        fabricator.removeRecipe(1);
        assertEq(fabricator.recipeCount(), 2);

        // Verify the remaining recipes
        (Fabricator.MintItem memory mintItemOut1, , , ) = fabricator
            .getRecipeDetails(0);
        (Fabricator.MintItem memory mintItemOut2, , , ) = fabricator
            .getRecipeDetails(1);
        assertEq(mintItemOut1.contractAddress, address(inventory));
        assertEq(mintItemOut1.id, 1);
        assertEq(mintItemOut1.amount, 1);
        assertEq(mintItemOut2.contractAddress, address(inventory3));
        assertEq(mintItemOut2.id, 1);
        assertEq(mintItemOut2.amount, 1);
    }

    function testRemoveRecipe_FailsIfNotAdmin() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add a recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);
        assertEq(fabricator.recipeCount(), 1);

        // Try to remove the recipe as a non-admin
        vm.prank(user);
        vm.expectRevert();
        fabricator.removeRecipe(0);
    }

    function testRemoveRecipe_FailsIfRecipeDoesNotExist() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);

        // Grant MINTER_ROLE to Fabricator BEFORE adding recipe
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add a recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);
        assertEq(fabricator.recipeCount(), 1);

        // Try to remove a non-existent recipe (index 1)
        vm.expectRevert();
        fabricator.removeRecipe(1);
    }

    function testRemoveRecipe_FailsIfNoRecipes() public {
        vm.expectRevert();
        fabricator.removeRecipe(0);
    }

    function testRemoveRecipe_FailsIfInvalidIndex() public {
        // Add a recipe first
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Try to remove with invalid index
        vm.expectRevert();
        fabricator.removeRecipe(1); // Only recipe at index 0 exists
    }

    function testRemoveRecipe_FirstRecipe() public {
        // Add an item to inventory
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add multiple recipes
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);

        // First recipe
        Fabricator.MintItem memory mintItem1 = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe1 = _makeRecipe(
            mintItem1,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe1);

        // Second recipe
        InventoryV1155 inventory2 = new InventoryV1155("https://example2.com/");
        inventory2.grantRole(inventory2.ADMIN_ROLE(), admin);
        inventory2.grantRole(inventory2.MINTER_ROLE(), address(fabricator));
        inventory2.addItem(item);
        Fabricator.MintItem memory mintItem2 = Fabricator.MintItem(
            address(inventory2),
            1,
            1
        );
        Fabricator.Recipe memory recipe2 = _makeRecipe(
            mintItem2,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe2);

        assertEq(fabricator.recipeCount(), 2);

        // Remove the first recipe
        fabricator.removeRecipe(0);
        assertEq(fabricator.recipeCount(), 1);

        // Verify the remaining recipe
        (Fabricator.MintItem memory mintItemOut, , , ) = fabricator
            .getRecipeDetails(0);
        assertEq(mintItemOut.contractAddress, address(inventory2));
        assertEq(mintItemOut.id, 1);
        assertEq(mintItemOut.amount, 1);
    }

    function testRemoveRecipe_LastRecipe() public {
        // Add an item to inventory
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add multiple recipes
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);

        // First recipe
        Fabricator.MintItem memory mintItem1 = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe1 = _makeRecipe(
            mintItem1,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe1);

        // Second recipe
        InventoryV1155 inventory2 = new InventoryV1155("https://example2.com/");
        inventory2.grantRole(inventory2.ADMIN_ROLE(), admin);
        inventory2.grantRole(inventory2.MINTER_ROLE(), address(fabricator));
        inventory2.addItem(item);
        Fabricator.MintItem memory mintItem2 = Fabricator.MintItem(
            address(inventory2),
            1,
            1
        );
        Fabricator.Recipe memory recipe2 = _makeRecipe(
            mintItem2,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe2);

        assertEq(fabricator.recipeCount(), 2);

        // Remove the last recipe
        fabricator.removeRecipe(1);
        assertEq(fabricator.recipeCount(), 1);

        // Verify the remaining recipe
        (Fabricator.MintItem memory mintItemOut, , , ) = fabricator
            .getRecipeDetails(0);
        assertEq(mintItemOut.contractAddress, address(inventory));
        assertEq(mintItemOut.id, 1);
        assertEq(mintItemOut.amount, 1);
    }

    function testAdjustRecipe_Success() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);
        assertEq(
            fabricator.recipeCount(),
            1,
            "Should have exactly one recipe after adding"
        );

        // Create adjusted recipe with different values
        Fabricator.Item1155[] memory newItems1155 = new Fabricator.Item1155[](
            1
        );
        newItems1155[0] = Fabricator.Item1155(address(inventory), 1, 2, true); // Changed amount and burn flag
        Fabricator.MintItem memory newMintItem = Fabricator.MintItem(
            address(inventory),
            1,
            2
        ); // Changed amount
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            newMintItem,
            admin,
            newItems1155,
            items20
        );

        // Adjust the recipe
        fabricator.adjustRecipe(0, adjustedRecipe);

        // Verify the adjusted recipe
        (
            Fabricator.MintItem memory mintItemOut,
            address creator,
            Fabricator.Item1155[] memory items1155Out,
            Fabricator.Item20[] memory items20Out
        ) = fabricator.getRecipeDetails(0);

        // Verify mintItem
        assertEq(
            mintItemOut.contractAddress,
            address(inventory),
            "MintItem contract address should match inventory"
        );
        assertEq(mintItemOut.id, 1, "MintItem token ID should be 1");
        assertEq(
            mintItemOut.amount,
            2,
            "MintItem amount should be updated to 2"
        );

        // Verify items1155
        assertEq(
            items1155Out.length,
            1,
            "Should have exactly one ERC1155 item"
        );
        assertEq(
            items1155Out[0].contractAddress,
            address(inventory),
            "ERC1155 item contract address should match inventory"
        );
        assertEq(items1155Out[0].id, 1, "ERC1155 item token ID should be 1");
        assertEq(
            items1155Out[0].amount,
            2,
            "ERC1155 item amount should be updated to 2"
        );
        assertEq(
            items1155Out[0].burn,
            true,
            "ERC1155 item burn flag should be set to true"
        );

        // Verify items20
        assertEq(items20Out.length, 0, "Should have no ERC20 items");
    }

    function testAdjustRecipe_FailsIfTooManyItems() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe with too many items
        Fabricator.Item1155[] memory tooManyItems = new Fabricator.Item1155[](
            21
        );
        for (uint256 i = 0; i < 21; i++) {
            tooManyItems[i] = Fabricator.Item1155(
                address(inventory),
                1,
                1,
                false
            );
        }
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            admin,
            tooManyItems,
            items20
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfZeroCreator() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe with zero address creator
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            address(0),
            items1155,
            items20
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfNoItems() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe with items
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe with no items
        Fabricator.Item1155[] memory emptyItems1155 = new Fabricator.Item1155[](
            0
        );
        Fabricator.Item20[] memory emptyItems20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            admin,
            emptyItems1155,
            emptyItems20
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfTooManyERC1155Items() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe with too many ERC1155 items
        Fabricator.Item1155[] memory tooManyItems = new Fabricator.Item1155[](
            21
        );
        for (uint256 i = 0; i < 21; i++) {
            tooManyItems[i] = Fabricator.Item1155(
                address(inventory),
                1,
                1,
                false
            );
        }
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            admin,
            tooManyItems,
            items20
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfTooManyERC20Items() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe with too many ERC20 items
        Fabricator.Item20[] memory tooManyItems = new Fabricator.Item20[](21);
        for (uint256 i = 0; i < 21; i++) {
            tooManyItems[i] = Fabricator.Item20(address(0), 1, false);
        }
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            tooManyItems
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfNotAdmin() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create adjusted recipe
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );

        // Try to adjust recipe as non-admin
        vm.prank(user);
        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfNotMinter() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create and add initial recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );
        fabricator.addRecipe(recipe);

        // Create a new inventory contract that Fabricator is not minter for
        InventoryV1155 inventory2 = new InventoryV1155("uri");
        inventory2.addItem(item);

        // Create adjusted recipe with new inventory that Fabricator is not minter for
        Fabricator.MintItem memory newMintItem = Fabricator.MintItem(
            address(inventory2),
            1,
            1
        );
        Fabricator.Recipe memory adjustedRecipe = _makeRecipe(
            newMintItem,
            admin,
            items1155,
            items20
        );

        vm.expectRevert();
        fabricator.adjustRecipe(0, adjustedRecipe);
    }

    function testAdjustRecipe_FailsIfRecipeDoesNotExist() public {
        // Add an item to inventory so tokenId 1 exists
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(
            attrData,
            attrId,
            "uri",
            1
        );
        inventory.addItem(item);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Create recipe to try to adjust non-existent recipe
        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155(address(inventory), 1, 1, false);
        Fabricator.MintItem memory mintItem = Fabricator.MintItem(
            address(inventory),
            1,
            1
        );
        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](0);
        Fabricator.Recipe memory recipe = _makeRecipe(
            mintItem,
            admin,
            items1155,
            items20
        );

        // Try to adjust non-existent recipe
        vm.expectRevert();
        fabricator.adjustRecipe(0, recipe);
    }

    function testFabricatorHasMinterRole() public {
        // Check that Fabricator has MINTER_ROLE on inventory
        assertFalse(
            fabricator.isMinter(address(inventory)),
            "Fabricator Should not have minter role on inventory"
        );
        vm.prank(admin);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));
        assertTrue(
            fabricator.isMinter(address(inventory)),
            "Fabricator Should have minter role on inventory"
        );
    }
}
