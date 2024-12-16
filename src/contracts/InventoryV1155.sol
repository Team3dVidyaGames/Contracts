// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract InventoryV1155 is AccessControl {
    uint256 public tokenID;

    Item[] private itemData;
    string[] public slots;

    struct Item {
        uint256[] attributeData;
        uint256 attributeLength;
        string tokenURI;
        uint256 characterSlot;
    }

    //events
    event ItemAdded(uint256 indexed tokenId, address admin);

    event ItemUpdated(uint256 indexed tokenId, address admin);

    // Access Control stuff
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory baseUri) ERC1155(baseUri) {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
    }

    function addItem(Item memory newItem) external onlyRole(ADMIN_ROLE) {
        itemData.push(newItem);
        tokenID++;
        emit ItemAdded(tokenID - 1, msg.sender);
    }

    function updateItemData(
        Item memory updateItem,
        uint256 tokenId
    ) external onlyRole(ADMIN_ROLE) {
        itemData[tokenId] = updateItem;
        emit ItemUpdated(tokenId, msg.sender);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (tokenId > tokenID || tokenId == 0) {
            return super.uri(tokenId);
        } else {
            return itemData[tokenId].tokenURI;
        }
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) external onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, values, "");
    }

    function burn(address from, uint256 id, uint256 value) external {
        address sender = msg.sender;
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _burn(from, id, value);
    }

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) external {
        address sender = msg.sender;
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _burnBatch(from, ids, values);
    }
}
