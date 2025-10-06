# TCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/c23d2f00a078c0b63e567bcd930645e3fd252715/src/contracts/agnosia/TCGInventory.sol)

**Inherits:**
ERC721Enumerable, AccessControl, ReentrancyGuard

**Author:**
Team3d.R&D


## State Variables
### template

```solidity
mapping(uint256 => Data) public template;
```


### cardData

```solidity
mapping(uint256 => Card) public cardData;
```


### levelSlots

```solidity
mapping(uint8 => uint8) public levelSlots;
```


### tokenID

```solidity
uint256 public tokenID;
```


### templateLength

```solidity
uint256 public templateLength;
```


### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


### CONTRACT_ROLE

```solidity
bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");
```


## Functions
### constructor


```solidity
constructor() ERC721("Agnosia", "AGN");
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721Enumerable, AccessControl)
    returns (bool);
```

### _isApprovedOrOwner


```solidity
function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool);
```

### mint


```solidity
function mint(uint256 templateID, address to) external onlyRole(MINTER_ROLE) returns (uint256);
```

### templateExists


```solidity
function templateExists(uint256 templateID) public view returns (bool truth, uint8 level);
```

### _transposeData


```solidity
function _transposeData(uint256 _templateID, uint256 _tokenID) internal;
```

### updateCardGameInformation


```solidity
function updateCardGameInformation(uint256 addWin, uint256 addPlayed, uint256 tokenId) public onlyRole(CONTRACT_ROLE);
```

### burn


```solidity
function burn(uint256 tokenId) external;
```

### updateCardData


```solidity
function updateCardData(uint256 tokenId, uint8 top, uint8 left, uint8 right, uint8 bottom)
    public
    onlyRole(CONTRACT_ROLE);
```

### dataReturn


```solidity
function dataReturn(uint256 tokenId)
    public
    view
    returns (
        uint8 level,
        uint8 top,
        uint8 left,
        uint8 right,
        uint8 bottom,
        uint256 winCount,
        uint256 playedCount,
        uint8 slot
    );
```

### addTemplateId


```solidity
function addTemplateId(
    string memory imageURL,
    string memory description,
    string memory name,
    uint8 top,
    uint8 left,
    uint8 right,
    uint8 bottom,
    uint8 level
) external onlyRole(ADMIN_ROLE);
```

### tokenURI


```solidity
function tokenURI(uint256 tokenId) public view virtual override returns (string memory);
```

### _templateIdString


```solidity
function _templateIdString(uint256 templateId) internal view returns (string memory);
```

### updateImageURL


```solidity
function updateImageURL(uint256 position, string memory newURL) external onlyRole(ADMIN_ROLE);
```

### updateDescription


```solidity
function updateDescription(uint256 position, string memory newDescription) external onlyRole(ADMIN_ROLE);
```

### updateName


```solidity
function updateName(uint256 position, string memory newName) external onlyRole(ADMIN_ROLE);
```

### _attributes


```solidity
function _attributes(
    uint256 id,
    uint8 level,
    uint8 top,
    uint8 left,
    uint8 right,
    uint8 bottom,
    uint256 winCount,
    uint256 playedCount,
    uint8 slot
) internal view returns (string memory);
```

### _attributes1


```solidity
function _attributes1(uint8 level, uint8 top, uint8 left, uint8 right, uint8 bottom)
    internal
    pure
    returns (string memory);
```

### ownerTokenArray


```solidity
function ownerTokenArray(address user) public view returns (uint256[] memory tokenArray);
```

### getHighestLevelCard


```solidity
function getHighestLevelCard(address owner) public view returns (uint8 highestLevel);
```

## Events
### updatedCardStats

```solidity
event updatedCardStats(uint256 indexed tokenId);
```

### templateAdded

```solidity
event templateAdded(uint256 indexed id);
```

## Structs
### Card

```solidity
struct Card {
    uint256 templateId;
    uint8 level;
    uint8 top;
    uint8 left;
    uint8 right;
    uint8 bottom;
    uint256 winCount;
    uint256 playedCount;
}
```

### Data

```solidity
struct Data {
    string imageURL;
    string name;
    string description;
    string jsonStorage;
    uint8 level;
    uint8 top;
    uint8 left;
    uint8 right;
    uint8 bottom;
    uint8 slot;
}
```

