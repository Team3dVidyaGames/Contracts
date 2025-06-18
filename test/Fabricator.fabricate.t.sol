// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/contracts/Fabricator.sol";
import "../src/contracts/InventoryV1155.sol";
import "./mocks/MockERC20.sol";

contract FabricatorFabricateTest is Test {
    Fabricator public fabricator;
    InventoryV1155 public inventory;
    MockERC20 public erc20Token;
    address public user1;
    address public user2;
    address public admin;

    function setUp() public {
        admin = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        // Deploy contracts
        inventory = new InventoryV1155("https://example.com/");
        fabricator = new Fabricator();
        erc20Token = new MockERC20("Test Token", "TEST");

        // Setup roles - need to use vm.startPrank with the deployer address
        vm.startPrank(admin);
        inventory.grantRole(inventory.ADMIN_ROLE(), admin);
        inventory.grantRole(inventory.MINTER_ROLE(), address(fabricator));

        // Setup initial item
        uint256[] memory attrData = new uint256[](1);
        uint256[] memory attrId = new uint256[](1);
        attrData[0] = 10;
        attrId[0] = 1;
        InventoryV1155.Item memory item = InventoryV1155.Item(attrData, attrId, "uri", 1);
        inventory.addItem(item);

        // Setup recipe
        Fabricator.Recipe memory recipe = _makeRecipe();
        fabricator.addRecipe(recipe);
        vm.stopPrank();

        // Setup approvals
        vm.startPrank(user1);
        inventory.setApprovalForAll(address(fabricator), true);
        erc20Token.approve(address(fabricator), type(uint256).max);
        vm.stopPrank();
    }

    function _mintInitialBalances() internal {
        vm.startPrank(admin);
        inventory.mint(user1, 1, 1);
        erc20Token.mint(user1, 100 ether);
        vm.stopPrank();
    }

    function _makeRecipe() private view returns (Fabricator.Recipe memory) {
        Fabricator.MintItem memory mintItem =
            Fabricator.MintItem({contractAddress: address(inventory), id: 1, amount: 1});

        Fabricator.Item1155[] memory items1155 = new Fabricator.Item1155[](1);
        items1155[0] = Fabricator.Item1155({contractAddress: address(inventory), id: 1, amount: 1, burn: true});

        Fabricator.Item20[] memory items20 = new Fabricator.Item20[](1);
        items20[0] = Fabricator.Item20({contractAddress: address(erc20Token), amount: 10 ether, native: false});

        return Fabricator.Recipe({mintItem: mintItem, creator: admin, items1155: items1155, items20: items20});
    }

    function testFabricate_Success() public {
        _mintInitialBalances();

        vm.startPrank(user1);
        fabricator.fabricate(0);
        vm.stopPrank();

        // Verify user1 received the minted item
        assertEq(inventory.balanceOf(user1, 1), 1, "User1 should have received the minted item");

        // Verify ERC20 tokens were transferred
        assertEq(erc20Token.balanceOf(user1), 90 ether, "User1 should have spent 10 ether worth of tokens");
        assertEq(erc20Token.balanceOf(admin), 10 ether, "Admin should have received 10 ether worth of tokens");
    }

    function testFabricate_FailsIfNotEnoughItems() public {
        vm.startPrank(user2);
        vm.expectRevert(abi.encodeWithSelector(Fabricator.InsufficientBalance.selector, address(inventory), 1, 0));
        fabricator.fabricate(0);
        vm.stopPrank();
    }

    function testFabricate_FailsIfNotApproved() public {
        vm.startPrank(user2);
        vm.expectRevert("ERC1155: caller is not token owner or approved");
        fabricator.fabricate(0);
        vm.stopPrank();
    }

    function testFabricate_FailsIfRecipeDoesNotExist() public {
        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSelector(Fabricator.RecipeDoesNotExist.selector, 1));
        fabricator.fabricate(1);
        vm.stopPrank();
    }
}
