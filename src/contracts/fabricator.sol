// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IInventoryV1155.sol";

contract Fabricator is ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => Recipe) public recipes;
    uint256 public recipeCount;

    struct Recipe {
        MintItem mintItem;
        address creator;
        Item1155[] items1155;
        uint256 item1155Index;
        Item20[] items20;
        uint256 item20Index;
    }

    struct MintItem {
        address contractAddress;
        uint256 id;
        uint256 amount;
    }

    struct Item1155 {
        address contractAddress;
        uint256 id;
        uint256 amount;
        bool burn;
    }

    struct Item20 {
        address contractAddress;
        uint256 amount;
        bool native;
    }

    constructor() {}

    modifier onlyRole(bytes32 role, address contractAddress) {
        require(
            IAccessControl(contractAddress).hasRole(role, msg.sender),
            "Caller is not a role"
        );
        _;
    }

    function addRecipe(
        Recipe memory _recipe
    ) external onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress) {
        require(isMinter(_recipe.mintItem.contractAddress), "Is not Minter");
        _recipeAdjustment(recipeCount, _recipe);
        recipeCount++;
    }

    function _recipeAdjustment(
        uint256 _recipeId,
        Recipe memory _recipe
    ) internal {
        Recipe storage r = recipes[_recipeId];
        if (_recipe.items1155.length > 0) {
            for (uint256 i = 0; i < _recipe.items1155.length; i++) {
                r.items1155.push(_recipe.items1155[i]);
            }
            r.item1155Index = r.items1155.length - 1;
        }
        if (_recipe.items20.length > 0) {
            for (uint256 i = 0; i < _recipe.items20.length; i++) {
                r.items20.push(_recipe.items20[i]);
            }
            r.item20Index = r.items20.length - 1;
        }
        require(_recipe.creator != address(0), "Creator not set");
        r.creator = _recipe.creator;
        r.mintItem = _recipe.mintItem;
    }

    function removeRecipe(
        uint256 _recipeId
    )
        external
        onlyRole(ADMIN_ROLE, recipes[_recipeId].mintItem.contractAddress)
    {
        require(recipeCount > _recipeId, "Recipe does not exist");
        recipes[_recipeId] = recipes[recipeCount - 1];
        recipeCount--;
    }

    function adjustRecipe(
        uint256 _recipeId,
        Recipe memory _recipe
    ) external onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress) {
        require(recipeCount > _recipeId, "Recipe does not exist");
        require(
            isMinter(_recipe.mintItem.contractAddress),
            "Minter does not exist"
        );
        _recipeAdjustment(_recipeId, _recipe);
    }

    function isMinter(address _contractAddress) public view returns (bool) {
        return
            IAccessControl(_contractAddress).hasRole(
                MINTER_ROLE,
                address(this)
            );
    }

    function fabricate(uint256 _recipeId) external payable nonReentrant {
        Recipe memory recipe = recipes[_recipeId];
        require(
            isMinter(recipe.mintItem.contractAddress),
            "Minter does not exist"
        );

        //burn/transfer items1155
        for (uint256 i = 0; i < recipe.items1155.length; i++) {
            uint256 balanceOf = IInventoryV1155(
                recipe.items1155[i].contractAddress
            ).balanceOf(msg.sender, recipe.items1155[i].id);
            require(
                balanceOf >= recipe.items1155[i].amount,
                "Insufficient balance"
            );
            recipe.items1155[i].burn
                ? IInventoryV1155(recipe.items1155[i].contractAddress).burn(
                    msg.sender,
                    recipe.items1155[i].id,
                    recipe.items1155[i].amount
                )
                : IInventoryV1155(recipe.items1155[i].contractAddress)
                    .safeTransferFrom(
                        msg.sender,
                        recipe.creator,
                        recipe.items1155[i].id,
                        recipe.items1155[i].amount,
                        ""
                    );
            require(
                balanceOf - recipe.items1155[i].amount ==
                    IInventoryV1155(recipe.items1155[i].contractAddress)
                        .balanceOf(recipe.creator, recipe.items1155[i].id),
                "Did not burn/transfer all items"
            );
        }

        for (uint256 i = 0; i < recipe.items20.length; i++) {
            if (recipe.items20[i].native) {
                require(
                    msg.value == recipe.items20[i].amount,
                    "Insufficient ETH sent"
                );
                payable(recipe.creator).transfer(recipe.items20[i].amount);
            } else {
                IERC20(recipe.items20[i].contractAddress).safeTransferFrom(
                    msg.sender,
                    recipe.creator,
                    recipe.items20[i].amount
                );
            }
        }
        require(
            isMinter(recipe.mintItem.contractAddress),
            "Minter does not exist"
        );
        //mint item
        IInventoryV1155(recipe.mintItem.contractAddress).mint(
            msg.sender,
            recipe.mintItem.id,
            recipe.mintItem.amount
        );
    }
}

//Todo:
//Generate InventoryInterface
//Create Recipe struct(s)
//Recipe(s) should handle native/erc20/Inventory
//Recipe(s) should only be able to be made by ADMINs of the erc1155
//Recipe(s) should only be able to be made if fabicator is minter
//Recipe(s) should designate where to send native/erc20
//Recipe(s) does not need an owner or access control directly
