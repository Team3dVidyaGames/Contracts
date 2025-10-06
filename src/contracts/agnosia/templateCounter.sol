// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

interface ITCGInventory {
    function ownerTokenArray(address user) external view returns (uint256[] memory);

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
}

interface IGame {
    function playersDeck(address user) external view returns (uint256[] memory);

    function tokenIdToCard(uint256 tokenId) external view returns (uint256 tokenID, address owner);

    function deckInfo(address user) external view returns (uint256 size, uint256[] memory deck);
}

contract TemplateCounter {
    ITCGInventory private inventoryContract;
    IGame private gameContract;

    struct TemplateCount {
        uint256 templateId;
        uint256 count;
    }

    constructor(address _tcgInventoryAddress, address _gameAddress) {
        inventoryContract = ITCGInventory(_tcgInventoryAddress);
        gameContract = IGame(_gameAddress);
    }

    function countTemplatesByOwner(address owner) public view returns (TemplateCount[] memory) {
        uint256[] memory ownedTokens = inventoryContract.ownerTokenArray(owner);
        (, uint256[] memory depositedTokens) = gameContract.deckInfo(owner);
        uint256[] memory counts = new uint256[](110); // Assuming 110 unique templates

        // Count owned tokens
        for (uint256 i = 0; i < ownedTokens.length; i++) {
            (uint256 templateId,,,,,,,) = inventoryContract.cardData(ownedTokens[i]);
            if (templateId >= 1 && templateId <= 110) {
                counts[templateId - 1]++;
            }
        }

        // Count deposited tokens
        for (uint256 i = 0; i < depositedTokens.length; i++) {
            (uint256 templateId,,,,,,,) = inventoryContract.cardData(depositedTokens[i]);
            if (templateId >= 1 && templateId <= 110) {
                counts[templateId - 1]++;
            }
        }

        uint256 numTemplates = 0;
        for (uint256 i = 0; i < 110; i++) {
            if (counts[i] > 0) {
                numTemplates++;
            }
        }

        TemplateCount[] memory result = new TemplateCount[](numTemplates);
        uint256 index = 0;
        for (uint256 i = 0; i < 110; i++) {
            if (counts[i] > 0) {
                result[index] = TemplateCount({templateId: i + 1, count: counts[i]});
                index++;
            }
        }
        return result;
    }
}
