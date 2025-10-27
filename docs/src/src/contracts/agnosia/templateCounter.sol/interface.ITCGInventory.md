# ITCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/b8947e8078c83c021a621910f8949582d5e5b7a1/src/contracts/agnosia/templateCounter.sol)


## Functions
### ownerTokenArray


```solidity
function ownerTokenArray(address user) external view returns (uint256[] memory);
```

### cardData


```solidity
function cardData(uint256 tokenId)
    external
    view
    returns (
        uint256 templateId,
        uint8 level,
        uint8 top,
        uint8 left,
        uint8 right,
        uint8 bottom,
        uint256 winCount,
        uint256 playedCount
    );
```

