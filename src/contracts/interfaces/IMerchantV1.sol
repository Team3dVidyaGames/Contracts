// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../InventoryV1155.sol";

/**
 * @title IMerchantV1
 * @dev Interface for the MerchantV1 contract
 */
interface IMerchantV1 {
    // Structs
    struct Merchandise {
        uint256 tokenId;
        uint256 unitPrice;
        uint256 quantity;
        uint256 sold;
        bool isActive;
        bool isSoldOut;
    }

    // Events
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event InventoryUpdated(address indexed oldInventory, address indexed newInventory);
    event MerchandiseAdded(uint256 indexed merchandiseId, uint256 indexed tokenId, uint256 unitPrice, uint256 quantity);
    event MerchandisePurchased(
        uint256 indexed merchandiseId, address indexed buyer, uint256 quantity, uint256 totalPrice
    );
    event MerchandiseBatchPurchased(
        address indexed buyer, uint256[] merchandiseIds, uint256[] quantities, uint256 totalPrice
    );
    event MerchandiseRestocked(uint256 indexed merchandiseId, uint256 addedQuantity, uint256 newTotalQuantity);
    event MerchandiseStatusChanged(uint256 indexed merchandiseId, bool isActive);
    event MerchandisePriceUpdated(uint256 indexed merchandiseId, uint256 oldPrice, uint256 newPrice);
    event Withdrawal(address indexed to, uint256 amount);

    // View Functions
    function SHOP_ROLE() external view returns (bytes32);

    function treasury() external view returns (address);

    function inventory1155() external view returns (address);

    function getUnitPrice(uint256 merchandiseId) external view returns (uint256 unitPrice, bool isActive);

    function getMerchandise(uint256 merchandiseId) external view returns (Merchandise memory);

    function getMerchandiseCount() external view returns (uint256);

    // State-Changing Functions
    function setTreasury(address _treasury) external;

    function setInventory1155(address _inventory1155) external;

    function setMerchandiseActive(uint256 merchandiseId, bool isActive) external;

    function setMerchandiseUnitPrice(uint256 merchandiseId, uint256 unitPrice) external;

    function addMerchandise(uint256 tokenId, uint256 unitPrice, uint256 quantity) external;

    function buyMerchandise(uint256 merchandiseId, uint256 quantity) external payable;

    function buyMerchandiseBatch(uint256[] memory merchandiseIds, uint256[] memory quantities) external payable;

    function restockMerchandise(uint256 merchandiseId, uint256 quantity) external;

    function withdraw() external;
}
