# ITCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/c23d2f00a078c0b63e567bcd930645e3fd252715/src/contracts/agnosia/templateCounter.sol)


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

