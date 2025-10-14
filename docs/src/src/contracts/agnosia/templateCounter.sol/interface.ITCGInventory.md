# ITCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/e59a3c26fbd24f4aff21370c713588eae3cb43b1/src/contracts/agnosia/templateCounter.sol)


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

