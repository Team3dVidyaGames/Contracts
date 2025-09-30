# Fabricator
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/597a494a06b3d5533e4bc67b2d1a7487539c85dc/src/contracts/Fabricator.sol)

**Inherits:**
ReentrancyGuard


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


### recipes

```solidity
mapping(uint256 => Recipe) public recipes;
```


### recipeCount

```solidity
uint256 public recipeCount;
```


## Functions
### constructor


```solidity
constructor();
```

### onlyRole


```solidity
modifier onlyRole(bytes32 role, address contractAddress);
```

### addRecipe


```solidity
function addRecipe(Recipe memory _recipe) external onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress);
```

### _recipeAdjustment


```solidity
function _recipeAdjustment(uint256 _recipeId, Recipe memory _recipe) internal;
```

### removeRecipe


```solidity
function removeRecipe(uint256 _recipeId) external onlyRole(ADMIN_ROLE, recipes[_recipeId].mintItem.contractAddress);
```

### adjustRecipe


```solidity
function adjustRecipe(uint256 _recipeId, Recipe memory _recipe)
    external
    onlyRole(ADMIN_ROLE, _recipe.mintItem.contractAddress);
```

### isMinter


```solidity
function isMinter(address _contractAddress) public view returns (bool);
```

### _fabricateRecipe


```solidity
function _fabricateRecipe(uint256 _recipeId, address _user, uint256 _ethAmount) internal returns (uint256 ethUsed);
```

### fabricate


```solidity
function fabricate(uint256 _recipeId) external payable nonReentrant;
```

### hasDuplicateRecipeIds


```solidity
function hasDuplicateRecipeIds(uint256[] calldata _recipeIds) public pure returns (bool);
```

### batchFabricate


```solidity
function batchFabricate(uint256[] calldata _recipeIds) external payable nonReentrant;
```

### getRecipeDetails


```solidity
function getRecipeDetails(uint256 _recipeId)
    external
    view
    returns (MintItem memory mintItem, address creator, Item1155[] memory items1155, Item20[] memory items20);
```

### getRecipeRequirements


```solidity
function getRecipeRequirements(uint256 _recipeId)
    external
    view
    returns (uint256 totalEthRequired, Item1155[] memory items1155, Item20[] memory items20);
```

### willFabricate


```solidity
function willFabricate(uint256 _recipeId, address _user)
    external
    view
    returns (bool canFabricate, string memory reason);
```

### getRecipeCount


```solidity
function getRecipeCount() external view returns (uint256);
```

### getRecipeCreator


```solidity
function getRecipeCreator(uint256 _recipeId) external view returns (address);
```

### getRecipeMintItem


```solidity
function getRecipeMintItem(uint256 _recipeId) external view returns (MintItem memory);
```

### getBatchRecipeDetails


```solidity
function getBatchRecipeDetails(uint256[] calldata _recipeIds)
    external
    view
    returns (
        MintItem[] memory mintItems,
        address[] memory creators,
        Item1155[][] memory items1155,
        Item20[][] memory items20
    );
```

### getBatchRecipeRequirements


```solidity
function getBatchRecipeRequirements(uint256[] calldata _recipeIds)
    external
    view
    returns (uint256[] memory totalEthRequired, Item1155[][] memory items1155, Item20[][] memory items20);
```

### canFabricateBatch


```solidity
function canFabricateBatch(uint256[] calldata _recipeIds, address _user)
    external
    view
    returns (bool[] memory canFabricate, string[] memory reasons);
```

### getBatchRecipeCreators


```solidity
function getBatchRecipeCreators(uint256[] calldata _recipeIds) external view returns (address[] memory);
```

### getBatchRecipeMintItems


```solidity
function getBatchRecipeMintItems(uint256[] calldata _recipeIds) external view returns (MintItem[] memory);
```

## Events
### RecipeAdded

```solidity
event RecipeAdded(uint256 indexed recipeId, address indexed creator, MintItem mintItem);
```

### RecipeRemoved

```solidity
event RecipeRemoved(uint256 indexed recipeId);
```

### RecipeAdjusted

```solidity
event RecipeAdjusted(uint256 indexed recipeId, address indexed creator, MintItem mintItem);
```

### ItemFabricated

```solidity
event ItemFabricated(uint256 indexed recipeId, address indexed user, MintItem mintItem);
```

### ItemBurned

```solidity
event ItemBurned(address indexed user, address indexed contractAddress, uint256 id, uint256 amount);
```

### ItemTransferred

```solidity
event ItemTransferred(
    address indexed from, address indexed to, address indexed contractAddress, uint256 id, uint256 amount
);
```

### NativeTokenTransferred

```solidity
event NativeTokenTransferred(address indexed from, address indexed to, uint256 amount);
```

### ERC20Transferred

```solidity
event ERC20Transferred(address indexed from, address indexed to, address indexed token, uint256 amount);
```

### BatchFabricationCompleted

```solidity
event BatchFabricationCompleted(uint256[] recipeIds, address indexed user);
```

## Errors
### NotAuthorized

```solidity
error NotAuthorized(address caller, bytes32 role);
```

### NotMinter

```solidity
error NotMinter(address contractAddress);
```

### RecipeDoesNotExist

```solidity
error RecipeDoesNotExist(uint256 recipeId);
```

### TooManyItems

```solidity
error TooManyItems(uint256 count, uint256 max);
```

### CreatorNotSet

```solidity
error CreatorNotSet();
```

### InsufficientBalance

```solidity
error InsufficientBalance(address token, uint256 required, uint256 available);
```

### InsufficientEth

```solidity
error InsufficientEth(uint256 required, uint256 sent);
```

### TransferFailed

```solidity
error TransferFailed(address token, uint256 amount);
```

### InvalidRecipe

```solidity
error InvalidRecipe(uint256 recipeId);
```

### BatchFabricationFailed

```solidity
error BatchFabricationFailed(uint256 recipeId, string reason);
```

### InvalidBatchLength

```solidity
error InvalidBatchLength();
```

### DuplicateRecipeInBatch

```solidity
error DuplicateRecipeInBatch();
```

### RecipeIdOutOfBounds

```solidity
error RecipeIdOutOfBounds(uint256 recipeId, uint256 maxRecipeId);
```

### NoItemsListed

```solidity
error NoItemsListed();
```

## Structs
### Recipe

```solidity
struct Recipe {
    MintItem mintItem;
    address creator;
    Item1155[] items1155;
    Item20[] items20;
}
```

### MintItem

```solidity
struct MintItem {
    address contractAddress;
    uint256 id;
    uint256 amount;
}
```

### Item1155

```solidity
struct Item1155 {
    address contractAddress;
    uint256 id;
    uint256 amount;
    bool burn;
}
```

### Item20

```solidity
struct Item20 {
    address contractAddress;
    uint256 amount;
    bool native;
}
```

