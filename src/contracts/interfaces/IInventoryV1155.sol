// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../../lib/openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../../lib/openzeppelin/contracts/access/IAccessControl.sol";

interface IInventoryV1155 is IERC1155, IAccessControl {
    struct Item {
        uint256[] attributeData;
        uint256[] attributeId;
        string tokenURI;
        uint256 characterSlot;
    }

    // Events
    event ItemAdded(uint256 indexed tokenId, address admin);
    event ItemUpdated(uint256 indexed tokenId, address admin);

    // Errors
    error ItemDataAndIDMisMatch(address admin, uint256 length);
    error TokenDoesNotExist(uint256 tokenId);

    // View functions
    function tokenID() external view returns (uint256);

    function itemAttributeInfo(uint256, uint256) external view returns (uint256);

    function uri(uint256 tokenId) external view returns (string memory);

    function tokenExist(uint256 tokenId) external view returns (bool);

    function getCharacterSlot(uint256 tokenId) external view returns (uint256);

    function itemAttributeIdDetail(uint256 tokenId, uint256 attributeId) external view returns (uint256);

    function getItemAttributes(uint256 tokenId) external view returns (uint256[] memory, uint256[] memory);

    function fullBalanceOf(address account) external view returns (uint256[] memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // State changing functions
    function addItem(Item memory newItem) external;

    function updateItemData(Item memory updateItem, uint256 tokenId) external;

    function mint(address to, uint256 tokenId, uint256 amount) external;

    function mintBatch(address to, uint256[] memory ids, uint256[] memory values) external;

    function burn(address from, uint256 id, uint256 value) external;

    function burnBatch(address from, uint256[] memory ids, uint256[] memory values) external;
}
