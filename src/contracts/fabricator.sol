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
    error BatchFabricationFailed(uint256 recipeId, string reason);
    error InvalidBatchLength();
    error DuplicateRecipeInBatch();
    error RecipeIdOutOfBounds(uint256 recipeId, uint256 maxRecipeId);
    error NoItemsListed();
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
    event BatchFabricationCompleted(uint256[] recipeIds, address indexed user);

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
        if (_recipe.items1155.length == 0 && _recipe.items20.length == 0) {
            revert NoItemsListed();
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
        delete recipes[_recipeId];
        _recipeAdjustment(_recipeId, _recipe);
        emit RecipeAdjusted(_recipeId, _recipe.creator, _recipe.mintItem);
    }

    function isMinter(address _contractAddress) public view returns (bool) {
        return IAccessControl(_contractAddress).hasRole(MINTER_ROLE, address(this));
    }

    function _fabricateRecipe(uint256 _recipeId, address _user, uint256 _ethAmount)
        internal
        returns (uint256 ethUsed)
    {
        Recipe storage recipe = recipes[_recipeId];
        if (!isMinter(recipe.mintItem.contractAddress)) {
            revert NotMinter(recipe.mintItem.contractAddress);
        }

        uint256 totalEthRequired;

        // Process ERC1155 items
        for (uint256 i = 0; i < recipe.items1155.length;) {
            uint256 balanceOf =
                IInventoryV1155(recipe.items1155[i].contractAddress).balanceOf(_user, recipe.items1155[i].id);
            if (balanceOf < recipe.items1155[i].amount) {
                revert InsufficientBalance(recipe.items1155[i].contractAddress, recipe.items1155[i].amount, balanceOf);
            }

            if (recipe.items1155[i].burn) {
                IInventoryV1155(recipe.items1155[i].contractAddress).burn(
                    _user, recipe.items1155[i].id, recipe.items1155[i].amount
                );
                emit ItemBurned(
                    _user, recipe.items1155[i].contractAddress, recipe.items1155[i].id, recipe.items1155[i].amount
                );
            } else {
                IInventoryV1155(recipe.items1155[i].contractAddress).safeTransferFrom(
                    _user, recipe.creator, recipe.items1155[i].id, recipe.items1155[i].amount, ""
                );
                emit ItemTransferred(
                    _user,
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

        // Process ERC20 and native token items
        for (uint256 i = 0; i < recipe.items20.length;) {
            if (recipe.items20[i].native) {
                totalEthRequired += recipe.items20[i].amount;
            } else {
                uint256 balance = IERC20(recipe.items20[i].contractAddress).balanceOf(_user);
                if (balance < recipe.items20[i].amount) {
                    revert InsufficientBalance(recipe.items20[i].contractAddress, recipe.items20[i].amount, balance);
                }
                IERC20(recipe.items20[i].contractAddress).safeTransferFrom(
                    _user, recipe.creator, recipe.items20[i].amount
                );
                emit ERC20Transferred(
                    _user, recipe.creator, recipe.items20[i].contractAddress, recipe.items20[i].amount
                );
            }
            unchecked {
                i++;
            }
        }

        // Validate ETH amount
        if (totalEthRequired > 0) {
            if (_ethAmount < totalEthRequired) {
                revert InsufficientEth(totalEthRequired, _ethAmount);
            }
            payable(recipe.creator).transfer(totalEthRequired);
            emit NativeTokenTransferred(_user, recipe.creator, totalEthRequired);
            ethUsed = totalEthRequired;
        }

        // Mint the output item
        IInventoryV1155(recipe.mintItem.contractAddress).mint(_user, recipe.mintItem.id, recipe.mintItem.amount);
        emit ItemFabricated(_recipeId, _user, recipe.mintItem);
    }

    function fabricate(uint256 _recipeId) external payable nonReentrant {
        if (_recipeId >= recipeCount) revert RecipeDoesNotExist(_recipeId);
        uint256 ethUsed = _fabricateRecipe(_recipeId, msg.sender, msg.value);

        // Refund excess ETH
        if (msg.value > ethUsed) {
            payable(msg.sender).transfer(msg.value - ethUsed);
        }
    }

    function hasDuplicateRecipeIds(uint256[] calldata _recipeIds) public view returns (bool) {
        if (_recipeIds.length == 0) return false;

        uint256 bitmap;
        for (uint256 i = 0; i < _recipeIds.length;) {
            uint256 recipeId = _recipeIds[i];

            // Check bounds and duplicates in one pass
            if (recipeId >= recipeCount) {
                revert RecipeIdOutOfBounds(recipeId, recipeCount - 1);
            }

            uint256 mask = 1 << recipeId;
            if ((bitmap & mask) != 0) {
                return true;
            }
            bitmap |= mask;

            unchecked {
                i++;
            }
        }
        return false;
    }

    function batchFabricate(uint256[] calldata _recipeIds) external payable nonReentrant {
        if (_recipeIds.length == 0) revert InvalidBatchLength();
        if (hasDuplicateRecipeIds(_recipeIds)) revert DuplicateRecipeInBatch();

        uint256 totalEthUsed;

        // Execute fabrications
        for (uint256 i = 0; i < _recipeIds.length;) {
            totalEthUsed += _fabricateRecipe(_recipeIds[i], msg.sender, msg.value - totalEthUsed);
            unchecked {
                i++;
            }
        }

        // Validate total ETH used
        if (msg.value < totalEthUsed) {
            revert InsufficientEth(totalEthUsed, msg.value);
        }

        // Refund excess ETH
        if (msg.value > totalEthUsed) {
            payable(msg.sender).transfer(msg.value - totalEthUsed);
        }

        emit BatchFabricationCompleted(_recipeIds, msg.sender);
    }

    // View Functions
    function getRecipeDetails(uint256 _recipeId)
        external
        view
        returns (MintItem memory mintItem, address creator, Item1155[] memory items1155, Item20[] memory items20)
    {
        if (_recipeId >= recipeCount) revert RecipeDoesNotExist(_recipeId);
        Recipe storage recipe = recipes[_recipeId];
        return (recipe.mintItem, recipe.creator, recipe.items1155, recipe.items20);
    }

    function getRecipeRequirements(uint256 _recipeId)
        external
        view
        returns (uint256 totalEthRequired, Item1155[] memory items1155, Item20[] memory items20)
    {
        if (_recipeId >= recipeCount) revert RecipeDoesNotExist(_recipeId);
        Recipe storage recipe = recipes[_recipeId];

        // Calculate total ETH required
        for (uint256 i = 0; i < recipe.items20.length;) {
            if (recipe.items20[i].native) {
                totalEthRequired += recipe.items20[i].amount;
            }
            unchecked {
                i++;
            }
        }

        return (totalEthRequired, recipe.items1155, recipe.items20);
    }

    function willFabricate(uint256 _recipeId, address _user)
        external
        view
        returns (bool canFabricate, string memory reason)
    {
        if (_recipeId >= recipeCount) {
            return (false, "Recipe does not exist");
        }

        Recipe memory recipe = recipes[_recipeId];

        // Check if contract is minter
        if (!isMinter(recipe.mintItem.contractAddress)) {
            return (false, "Contract is not minter");
        }

        // Check ERC1155 balances
        for (uint256 i = 0; i < recipe.items1155.length;) {
            uint256 balance =
                IInventoryV1155(recipe.items1155[i].contractAddress).balanceOf(_user, recipe.items1155[i].id);
            if (balance < recipe.items1155[i].amount) {
                return (false, "Insufficient ERC1155 balance");
            }
            unchecked {
                i++;
            }
        }

        // Check ERC20 balances
        for (uint256 i = 0; i < recipe.items20.length;) {
            if (!recipe.items20[i].native) {
                uint256 balance = IERC20(recipe.items20[i].contractAddress).balanceOf(_user);
                if (balance < recipe.items20[i].amount) {
                    return (false, "Insufficient ERC20 balance");
                }
            }
            unchecked {
                i++;
            }
        }

        return (true, "Can fabricate");
    }

    function getRecipeCount() external view returns (uint256) {
        return recipeCount;
    }

    function getRecipeCreator(uint256 _recipeId) external view returns (address) {
        if (_recipeId >= recipeCount) revert RecipeDoesNotExist(_recipeId);
        return recipes[_recipeId].creator;
    }

    function getRecipeMintItem(uint256 _recipeId) external view returns (MintItem memory) {
        if (_recipeId >= recipeCount) revert RecipeDoesNotExist(_recipeId);
        return recipes[_recipeId].mintItem;
    }

    // Batch View Functions
    function getBatchRecipeDetails(uint256[] calldata _recipeIds)
        external
        view
        returns (
            MintItem[] memory mintItems,
            address[] memory creators,
            Item1155[][] memory items1155,
            Item20[][] memory items20
        )
    {
        uint256 length = _recipeIds.length;
        mintItems = new MintItem[](length);
        creators = new address[](length);
        items1155 = new Item1155[][](length);
        items20 = new Item20[][](length);

        for (uint256 i = 0; i < length;) {
            uint256 recipeId = _recipeIds[i];
            if (recipeId >= recipeCount) revert RecipeDoesNotExist(recipeId);

            Recipe storage recipe = recipes[recipeId];
            mintItems[i] = recipe.mintItem;
            creators[i] = recipe.creator;
            items1155[i] = recipe.items1155;
            items20[i] = recipe.items20;

            unchecked {
                i++;
            }
        }

        return (mintItems, creators, items1155, items20);
    }

    function getBatchRecipeRequirements(uint256[] calldata _recipeIds)
        external
        view
        returns (uint256[] memory totalEthRequired, Item1155[][] memory items1155, Item20[][] memory items20)
    {
        uint256 length = _recipeIds.length;
        totalEthRequired = new uint256[](length);
        items1155 = new Item1155[][](length);
        items20 = new Item20[][](length);

        for (uint256 i = 0; i < length;) {
            uint256 recipeId = _recipeIds[i];
            if (recipeId >= recipeCount) revert RecipeDoesNotExist(recipeId);

            Recipe storage recipe = recipes[recipeId];

            // Calculate total ETH required
            for (uint256 j = 0; j < recipe.items20.length;) {
                if (recipe.items20[j].native) {
                    totalEthRequired[i] += recipe.items20[j].amount;
                }
                unchecked {
                    j++;
                }
            }

            items1155[i] = recipe.items1155;
            items20[i] = recipe.items20;

            unchecked {
                i++;
            }
        }

        return (totalEthRequired, items1155, items20);
    }

    function canFabricateBatch(uint256[] calldata _recipeIds, address _user)
        external
        view
        returns (bool[] memory canFabricate, string[] memory reasons)
    {
        uint256 length = _recipeIds.length;
        canFabricate = new bool[](length);
        reasons = new string[](length);

        for (uint256 i = 0; i < length;) {
            uint256 recipeId = _recipeIds[i];
            if (recipeId >= recipeCount) {
                canFabricate[i] = false;
                reasons[i] = "Recipe does not exist";
                unchecked {
                    i++;
                }
                continue;
            }

            Recipe storage recipe = recipes[recipeId];

            // Check if contract is minter
            if (!isMinter(recipe.mintItem.contractAddress)) {
                canFabricate[i] = false;
                reasons[i] = "Contract is not minter";
                unchecked {
                    i++;
                }
                continue;
            }

            // Check ERC1155 balances
            bool hasEnoughBalance = true;
            for (uint256 j = 0; j < recipe.items1155.length;) {
                uint256 balance =
                    IInventoryV1155(recipe.items1155[j].contractAddress).balanceOf(_user, recipe.items1155[j].id);
                if (balance < recipe.items1155[j].amount) {
                    canFabricate[i] = false;
                    reasons[i] = "Insufficient ERC1155 balance";
                    hasEnoughBalance = false;
                    break;
                }
                unchecked {
                    j++;
                }
            }

            if (!hasEnoughBalance) {
                unchecked {
                    i++;
                }
                continue;
            }

            // Check ERC20 balances
            for (uint256 j = 0; j < recipe.items20.length;) {
                if (!recipe.items20[j].native) {
                    uint256 balance = IERC20(recipe.items20[j].contractAddress).balanceOf(_user);
                    if (balance < recipe.items20[j].amount) {
                        canFabricate[i] = false;
                        reasons[i] = "Insufficient ERC20 balance";
                        hasEnoughBalance = false;
                        break;
                    }
                }
                unchecked {
                    j++;
                }
            }

            if (hasEnoughBalance) {
                canFabricate[i] = true;
                reasons[i] = "Can fabricate";
            }

            unchecked {
                i++;
            }
        }

        return (canFabricate, reasons);
    }

    function getBatchRecipeCreators(uint256[] calldata _recipeIds) external view returns (address[] memory) {
        uint256 length = _recipeIds.length;
        address[] memory creators = new address[](length);

        for (uint256 i = 0; i < length;) {
            uint256 recipeId = _recipeIds[i];
            if (recipeId >= recipeCount) revert RecipeDoesNotExist(recipeId);
            creators[i] = recipes[recipeId].creator;
            unchecked {
                i++;
            }
        }

        return creators;
    }

    function getBatchRecipeMintItems(uint256[] calldata _recipeIds) external view returns (MintItem[] memory) {
        uint256 length = _recipeIds.length;
        MintItem[] memory mintItems = new MintItem[](length);

        for (uint256 i = 0; i < length;) {
            uint256 recipeId = _recipeIds[i];
            if (recipeId >= recipeCount) revert RecipeDoesNotExist(recipeId);
            mintItems[i] = recipes[recipeId].mintItem;
            unchecked {
                i++;
            }
        }

        return mintItems;
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
