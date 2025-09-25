# ITCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/cb1733471b1d4daa24a16e671f78159e22669528/src/contracts/flattened/flattened_PackSeller.sol)

**Inherits:**
[IERC721](/src/contracts/flattened/flattened_PackSeller.sol/interface.IERC721.md)

**Author:**
Team3d.R&D


## Functions
### dataReturn


```solidity
function dataReturn(uint256 tokenId)
    external
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

### updateCardGameInformation


```solidity
function updateCardGameInformation(uint256 addWin, uint256 addPlayed, uint256 tokenId) external;
```

### updateCardData


```solidity
function updateCardData(uint256 tokenId, uint8 top, uint8 left, uint8 right, uint8 bottom) external;
```

### mint


```solidity
function mint(uint256 templateId, address to) external returns (uint256);
```

### templateExists


```solidity
function templateExists(uint256 templateId) external returns (bool truth, uint8 level);
```

### burn


```solidity
function burn(uint256 tokenId) external;
```

