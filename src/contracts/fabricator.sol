// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IInventoryV1155.sol";

contract Fabricator is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Custom Errors with parameters for better gas efficiency
    error NotAuthorized(address caller, bytes32 role);
    error NotMinter(address contractAddress);
    error RecipeDoesNotExist(uint256 recipeId);
    error TooManyItems(uint256 count, uint256 max);
    error CreatorNotSet();
    error InsufficientBalance(address token, uint256 required, uint256 available);
    error InsufficientEth(uint256 required, uint256 sent);
    error TransferFailed(address token, uint256 amount);
    error InvalidRecipe(uint256 recipeId);

    // Events
    event RecipeAdded(uint256 indexed recipeId, address indexed creator, MintItem mintItem);
    event RecipeRemoved(uint256 indexed recipeId);
    event RecipeAdjusted(uint256 indexed recipeId, address indexed creator, MintItem mintItem);
    event ItemFabricated(uint256 indexed recipeId, address indexed user, MintItem mintItem);
    event ItemBurned(address indexed user, address indexed contractAddress, uint256 id, uint256 amount);
    event ItemTransferred(
        address indexed from, address indexed to, address indexed contractAddress, uint256 id, uint256 amount
    );
    event NativeTokenTransferred(address indexed from, address indexed to, uint256 amount);
    event ERC20Transferred(address indexed from, address indexed to, address indexed token, uint256 amount);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => Recipe) public recipes;
    uint256 public recipeCount;

    struct Recipe {
        MintItem mintItem;
        address creator;
        Item1155[] items1155;
        Item20[] items20;
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
        if (!IAccessControl(contractAddress).hasRole(role, msg.sender)) {
            revert NotAuthorized(msg.sender, role);
        }
        _;
    }

    function addRecipe(Recipe memory _recipe) external onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress) {
        if (!isMinter(_recipe.mintItem.contractAddress)) {
            revert NotMinter(_recipe.mintItem.contractAddress);
        }
        _recipeAdjustment(recipeCount, _recipe);
        emit RecipeAdded(recipeCount, _recipe.creator, _recipe.mintItem);
        unchecked {
            recipeCount++;
        }
    }

    function _recipeAdjustment(uint256 _recipeId, Recipe memory _recipe) internal {
        Recipe storage r = recipes[_recipeId];
        if (_recipe.items1155.length >= 21) {
            revert TooManyItems(_recipe.items1155.length, 20);
        }
        if (_recipe.items20.length >= 21) {
            revert TooManyItems(_recipe.items20.length, 20);
        }
        if (_recipe.creator == address(0)) {
            revert CreatorNotSet();
        }

        if (_recipe.items1155.length > 0) {
            for (uint256 i = 0; i < _recipe.items1155.length;) {
                r.items1155.push(_recipe.items1155[i]);
                unchecked {
                    i++;
                }
            }
        }
        if (_recipe.items20.length > 0) {
            for (uint256 i = 0; i < _recipe.items20.length;) {
                r.items20.push(_recipe.items20[i]);
                unchecked {
                    i++;
                }
            }
        }
        r.creator = _recipe.creator;
        r.mintItem = _recipe.mintItem;
    }

    function removeRecipe(uint256 _recipeId)
        external
        onlyRole(ADMIN_ROLE, recipes[_recipeId].mintItem.contractAddress)
    {
        if (recipeCount <= _recipeId) {
            revert RecipeDoesNotExist(_recipeId);
        }
        recipes[_recipeId] = recipes[recipeCount - 1];
        emit RecipeRemoved(_recipeId);
        unchecked {
            recipeCount--;
        }
    }

    function adjustRecipe(uint256 _recipeId, Recipe memory _recipe)
        external
        onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress)
    {
        if (recipeCount <= _recipeId) {
            revert RecipeDoesNotExist(_recipeId);
        }
        if (!isMinter(_recipe.mintItem.contractAddress)) {
            revert NotMinter(_recipe.mintItem.contractAddress);
        }
        _recipeAdjustment(_recipeId, _recipe);
        emit RecipeAdjusted(_recipeId, _recipe.creator, _recipe.mintItem);
    }

    function isMinter(address _contractAddress) public view returns (bool) {
        return IAccessControl(_contractAddress).hasRole(MINTER_ROLE, address(this));
    }

    function fabricate(uint256 _recipeId) external payable nonReentrant {
        Recipe memory recipe = recipes[_recipeId];
        if (!isMinter(recipe.mintItem.contractAddress)) {
            revert NotMinter(recipe.mintItem.contractAddress);
        }

        //burn/transfer items1155
        for (uint256 i = 0; i < recipe.items1155.length;) {
            uint256 balanceOf =
                IInventoryV1155(recipe.items1155[i].contractAddress).balanceOf(msg.sender, recipe.items1155[i].id);
            if (balanceOf < recipe.items1155[i].amount) {
                revert InsufficientBalance(recipe.items1155[i].contractAddress, recipe.items1155[i].amount, balanceOf);
            }

            if (recipe.items1155[i].burn) {
                IInventoryV1155(recipe.items1155[i].contractAddress).burn(
                    msg.sender, recipe.items1155[i].id, recipe.items1155[i].amount
                );
                emit ItemBurned(
                    msg.sender, recipe.items1155[i].contractAddress, recipe.items1155[i].id, recipe.items1155[i].amount
                );
            } else {
                IInventoryV1155(recipe.items1155[i].contractAddress).safeTransferFrom(
                    msg.sender, recipe.creator, recipe.items1155[i].id, recipe.items1155[i].amount, ""
                );
                emit ItemTransferred(
                    msg.sender,
                    recipe.creator,
                    recipe.items1155[i].contractAddress,
                    recipe.items1155[i].id,
                    recipe.items1155[i].amount
                );
            }
            if (
                balanceOf - recipe.items1155[i].amount
                    != IInventoryV1155(recipe.items1155[i].contractAddress).balanceOf(
                        recipe.creator, recipe.items1155[i].id
                    )
            ) {
                revert TransferFailed(recipe.items1155[i].contractAddress, recipe.items1155[i].amount);
            }
            unchecked {
                i++;
            }
        }

        for (uint256 i = 0; i < recipe.items20.length;) {
            if (recipe.items20[i].native) {
                if (msg.value != recipe.items20[i].amount) {
                    revert InsufficientEth(recipe.items20[i].amount, msg.value);
                }
                payable(recipe.creator).transfer(recipe.items20[i].amount);
                emit NativeTokenTransferred(msg.sender, recipe.creator, recipe.items20[i].amount);
            } else {
                IERC20(recipe.items20[i].contractAddress).safeTransferFrom(
                    msg.sender, recipe.creator, recipe.items20[i].amount
                );
                emit ERC20Transferred(
                    msg.sender, recipe.creator, recipe.items20[i].contractAddress, recipe.items20[i].amount
                );
            }
            unchecked {
                i++;
            }
        }
        if (!isMinter(recipe.mintItem.contractAddress)) {
            revert NotMinter(recipe.mintItem.contractAddress);
        }
        //mint item
        IInventoryV1155(recipe.mintItem.contractAddress).mint(msg.sender, recipe.mintItem.id, recipe.mintItem.amount);
        emit ItemFabricated(_recipeId, msg.sender, recipe.mintItem);
    }
}

//Todo:
//Write tests
//Check for reentrancy
//Check for overflows
//Check for underflows
//Check for zero address
//Check for zero amount
//Check for zero id
//Add events for minting, burning, transferring, and fabricating
//Add events for adding, removing, and adjusting recipes
//Recipe(s) should only be able to be made by ADMINs of the erc1155
//Recipe(s) should only be able to be made if fabicator is minter
//Recipe(s) should handle native/erc20/Inventory
//Recipe(s) should handle burn/transfer
