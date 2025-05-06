// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../../../lib/openzeppelin/contracts/utils/Context.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IInventoryV1155.sol";

/**
 * @title MerchantV1
 * @dev A contract for managing the sale of ERC1155 tokens with role-based access control
 * and reentrancy protection. Allows adding merchandise, purchasing items, and managing inventory.
 */
contract MerchantV1 is AccessControl, ReentrancyGuard {
    // Events
    event TreasuryUpdated(
        address indexed oldTreasury,
        address indexed newTreasury
    );
    event InventoryUpdated(
        address indexed oldInventory,
        address indexed newInventory
    );
    event MerchandiseAdded(
        uint256 indexed merchandiseId,
        uint256 indexed tokenId,
        uint256 unitPrice,
        uint256 quantity
    );
    event MerchandisePurchased(
        uint256 indexed merchandiseId,
        address indexed buyer,
        uint256 quantity,
        uint256 totalPrice
    );
    event MerchandiseBatchPurchased(
        address indexed buyer,
        uint256[] merchandiseIds,
        uint256[] quantities,
        uint256 totalPrice
    );
    event MerchandiseRestocked(
        uint256 indexed merchandiseId,
        uint256 addedQuantity,
        uint256 newTotalQuantity
    );
    event MerchandiseStatusChanged(
        uint256 indexed merchandiseId,
        bool isActive
    );
    event MerchandisePriceUpdated(
        uint256 indexed merchandiseId,
        uint256 oldPrice,
        uint256 newPrice
    );
    event Withdrawal(address indexed to, uint256 amount);

    bytes32 public SHOP_ROLE = "SHOP_ROLE";

    /**
     * @dev Structure to store merchandise information
     * @param tokenId The ERC1155 token ID
     * @param unitPrice Price per unit in wei
     * @param quantity Available quantity for sale
     * @param sold Number of units sold
     * @param isActive Whether the merchandise is available for purchase
     * @param isSoldOut Whether the merchandise is sold out
     */
    struct Merchandise {
        uint256 tokenId;
        uint256 unitPrice;
        uint256 quantity;
        uint256 sold;
        bool isActive;
        bool isSoldOut;
    }

    address public treasury;
    address public inventory1155;

    mapping(uint256 => Merchandise) private merchandise;
    mapping(uint256 => bool) private tokenIdsUsed;
    uint256 private merchandiseCount;

    /**
     * @dev Constructor initializes the contract with admin and shop roles
     * Grants DEFAULT_ADMIN_ROLE and SHOP_ROLE to the deployer
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(SHOP_ROLE, _msgSender());
        _setRoleAdmin(SHOP_ROLE, DEFAULT_ADMIN_ROLE);
        merchandiseCount = 1;
    }

    // Setters

    /**
     * @dev Sets the treasury address where payments will be sent
     * @param _treasury The new treasury address
     * @notice Only callable by admin role
     */
    function setTreasury(
        address _treasury
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address oldTreasury = treasury;
        treasury = _treasury;
        emit TreasuryUpdated(oldTreasury, _treasury);
    }

    /**
     * @dev Sets the ERC1155 inventory contract address
     * @param _inventory1155 The new inventory contract address
     * @notice Only callable by admin role
     */
    function setInventory1155(
        address _inventory1155
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address oldInventory = inventory1155;
        inventory1155 = _inventory1155;
        emit InventoryUpdated(oldInventory, _inventory1155);
    }

    /**
     * @dev Sets the active status of a merchandise item
     * @param merchandiseId The ID of the merchandise
     * @param isActive The new active status
     * @notice Only callable by shop role
     */
    function setMerchandiseActive(
        uint256 merchandiseId,
        bool isActive
    ) external onlyRole(SHOP_ROLE) {
        merchandise[merchandiseId].isActive = isActive;
        emit MerchandiseStatusChanged(merchandiseId, isActive);
    }

    /**
     * @dev Updates the unit price of a merchandise item
     * @param merchandiseId The ID of the merchandise
     * @param unitPrice The new unit price in wei
     * @notice Only callable by shop role
     */
    function setMerchandiseUnitPrice(
        uint256 merchandiseId,
        uint256 unitPrice
    ) external onlyRole(SHOP_ROLE) {
        uint256 oldPrice = merchandise[merchandiseId].unitPrice;
        merchandise[merchandiseId].unitPrice = unitPrice;
        emit MerchandisePriceUpdated(merchandiseId, oldPrice, unitPrice);
    }

    /**
     * @dev Adds new merchandise to the shop
     * @param tokenId The ERC1155 token ID
     * @param unitPrice Price per unit in wei
     * @param quantity Initial quantity available
     * @notice Only callable by shop role
     */
    function addMerchandise(
        uint256 tokenId,
        uint256 unitPrice,
        uint256 quantity
    ) public onlyRole(SHOP_ROLE) {
        require(tokenIdsUsed[tokenId] == false, "Token ID already used");
        merchandise[merchandiseCount] = Merchandise({
            tokenId: tokenId,
            unitPrice: unitPrice,
            quantity: quantity,
            sold: 0,
            isActive: true,
            isSoldOut: false
        });
        tokenIdsUsed[tokenId] = true;
        emit MerchandiseAdded(merchandiseCount, tokenId, unitPrice, quantity);
        merchandiseCount++;
    }

    // Buy Merchandise

    /**
     * @dev Allows users to purchase a single merchandise item
     * @param merchandiseId The ID of the merchandise to purchase
     * @param quantity The quantity to purchase
     * @notice Requires exact payment amount in wei
     * @notice Protected against reentrancy attacks
     */
    function buyMerchandise(
        uint256 merchandiseId,
        uint256 quantity
    ) public payable nonReentrant {
        uint256 value = msg.value;
        payable(treasury).transfer(value);
        _buyMerchandise(merchandiseId, quantity, value);
        IInventoryV1155(inventory1155).mint(
            _msgSender(),
            merchandise[merchandiseId].tokenId,
            quantity
        );
        emit MerchandisePurchased(merchandiseId, _msgSender(), quantity, value);
    }

    /**
     * @dev Allows users to purchase multiple merchandise items in a single transaction
     * @param merchandiseIds Array of merchandise IDs to purchase
     * @param quantities Array of quantities to purchase for each merchandise
     * @notice Requires exact payment amount in wei
     * @notice Protected against reentrancy attacks
     */
    function buyMerchandiseBatch(
        uint256[] memory merchandiseIds,
        uint256[] memory quantities
    ) public payable nonReentrant {
        uint256 remainingValue = msg.value;
        payable(treasury).transfer(remainingValue);
        require(
            merchandiseIds.length == quantities.length,
            "Array lengths must match"
        );
        require(merchandiseIds.length > 0, "Empty arrays");
        for (uint256 i = 0; i < merchandiseIds.length; i++) {
            remainingValue = _buyMerchandise(
                merchandiseIds[i],
                quantities[i],
                remainingValue
            );
        }
        IInventoryV1155(inventory1155).mintBatch(
            _msgSender(),
            merchandiseIds,
            quantities
        );
        emit MerchandiseBatchPurchased(
            _msgSender(),
            merchandiseIds,
            quantities,
            msg.value
        );
    }

    /**
     * @dev Internal function to handle merchandise purchase logic
     * @param merchandiseId The ID of the merchandise to purchase
     * @param quantity The quantity to purchase
     * @param value The payment amount in wei
     * @return remainingValue The remaining value after purchase
     */
    function _buyMerchandise(
        uint256 merchandiseId,
        uint256 quantity,
        uint256 value
    ) internal returns (uint256 remainingValue) {
        Merchandise storage _merchandise = merchandise[merchandiseId];
        require(_merchandise.isActive, "Merchandise is not active");
        require(_merchandise.isSoldOut == false, "Merchandise is sold out");
        require(
            quantity <= _merchandise.quantity,
            "Quantity is greater than the available quantity"
        );
        require(
            value >= _merchandise.unitPrice * quantity,
            "Insufficient balance"
        );

        remainingValue = value - (_merchandise.unitPrice * quantity);
        tokenIdsUsed[_merchandise.tokenId] = true;
        _merchandise.quantity -= quantity;
        _merchandise.sold += quantity;
        if (_merchandise.quantity == 0) {
            _merchandise.isSoldOut = true;
        }
    }

    // Getters

    /**
     * @dev Returns the merchandise information for a given ID
     * @param merchandiseId The ID of the merchandise
     * @return Merchandise struct containing all merchandise details
     */
    function getMerchandise(
        uint256 merchandiseId
    ) external view returns (Merchandise memory) {
        return merchandise[merchandiseId];
    }

    /**
     * @dev Returns the total number of merchandise items
     * @return The total count of merchandise items
     */
    function getMerchandiseCount() external view returns (uint256) {
        return merchandiseCount;
    }

    /**
     * @dev Returns an array of all token IDs used in merchandise
     * @return Array of token IDs
     */
    function getTokenIdsUsed() external view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](merchandiseCount);
        for (uint256 i = 0; i < merchandiseCount; i++) {
            tokenIds[i] = merchandise[i].tokenId;
        }
        return tokenIds;
    }

    /**
     * @dev Returns the unit price and active status of a merchandise item
     * @param merchandiseId The ID of the merchandise
     * @return unitPrice The unit price in wei
     * @return isActive The active status of the merchandise
     */
    function getUnitPrice(
        uint256 merchandiseId
    ) external view returns (uint256, bool) {
        return (
            merchandise[merchandiseId].unitPrice,
            merchandise[merchandiseId].isActive
        );
    }

    /**
     * @dev Checks if a token ID has been used in any merchandise
     * @param merchandiseId The ID of the merchandise to check
     * @return Boolean indicating if the token ID is used
     */
    function getTokenIdUsed(
        uint256 merchandiseId
    ) external view returns (bool) {
        return tokenIdsUsed[merchandise[merchandiseId].tokenId];
    }

    /**
     * @dev Restocks a merchandise item with additional quantity
     * @param merchandiseId The ID of the merchandise to restock
     * @param quantity The quantity to add
     * @notice Only callable by shop role
     */
    function restockMerchandise(
        uint256 merchandiseId,
        uint256 quantity
    ) public onlyRole(SHOP_ROLE) {
        uint256 oldQuantity = merchandise[merchandiseId].quantity;
        merchandise[merchandiseId].quantity += quantity;
        merchandise[merchandiseId].isSoldOut = false;
        emit MerchandiseRestocked(
            merchandiseId,
            quantity,
            oldQuantity + quantity
        );
    }

    // Withdraw

    /**
     * @dev Withdraws all contract balance to the treasury address
     * @notice Only callable by admin role
     */
    function withdraw() external {
        uint256 amount = address(this).balance;
        payable(treasury).transfer(amount);
        emit Withdrawal(treasury, amount);
    }

    /**
     * @dev Allows the contract to receive ETH
     */
    receive() external payable {}
}
