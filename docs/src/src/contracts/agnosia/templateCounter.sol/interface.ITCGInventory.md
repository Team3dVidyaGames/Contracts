# ITCGInventory
[Git Source](https://github.com//Team3dVidyaGames/Contracts/blob/c2c2953897142b895776d58e8b608d1002e4b685/src/contracts/agnosia/templateCounter.sol)


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

