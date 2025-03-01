// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../lib/openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin/contracts/access/AccessControl.sol";

contract InventoryV1155 is AccessControl, ERC1155 {
    uint256 public tokenID = 1;

    mapping(uint256 => Item) private itemData;
    mapping(uint256 => mapping(uint256 => uint256)) public itemAttributeInfo;

    struct Item {
        uint256[] attributeData;
        uint256[] attributeId;
        string tokenURI;
        uint256 characterSlot;
    }

    //events
    event ItemAdded(uint256 indexed tokenId, address admin);
    event ItemUpdated(uint256 indexed tokenId, address admin);

    //errors
    error ItemDataAndIDMisMatch(address admin, uint256 length);
    error TokenDoesNotExist(uint256 tokenId);

    // Access Control stuff
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory baseUri) ERC1155(baseUri) {
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
    }

    function addItem(Item memory newItem) external onlyRole(ADMIN_ROLE) {
        if (newItem.attributeId.length != newItem.attributeData.length) {
            revert ItemDataAndIDMisMatch(
                msg.sender,
                newItem.attributeData.length
            );
        }
        for (uint256 i = 0; i < newItem.attributeData.length; i++) {
            itemAttributeInfo[tokenID][newItem.attributeId[i]] = newItem
                .attributeData[i];
        }
        itemData[tokenID] = newItem;
        tokenID++;
        emit ItemAdded(tokenID - 1, msg.sender);
    }

    function updateItemData(
        Item memory updateItem,
        uint256 tokenId
    ) external onlyRole(ADMIN_ROLE) {
        if (updateItem.attributeId.length != updateItem.attributeData.length) {
            revert ItemDataAndIDMisMatch(
                msg.sender,
                updateItem.attributeData.length
            );
        }
        if (!tokenExist(tokenId)) {
            revert TokenDoesNotExist(tokenId);
        }

        Item storage item = itemData[tokenId];

        //remove Old attributes
        for (uint256 i = 0; i < item.attributeData.length; i++) {
            itemAttributeInfo[tokenID][item.attributeId[i]] = 0;
        }

        //add new attribute information
        for (uint256 i = 0; i < updateItem.attributeData.length; i++) {
            itemAttributeInfo[tokenID][updateItem.attributeId[i]] = updateItem
                .attributeData[i];
        }

        itemData[tokenId] = updateItem;

        emit ItemUpdated(tokenId, msg.sender);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (!tokenExist(tokenId)) {
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
        if (!tokenExist(tokenId)) {
            revert TokenDoesNotExist(tokenId);
        }
        _mint(to, tokenId, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) external onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < ids.length; i++) {
            if (!tokenExist(ids[i])) {
                revert TokenDoesNotExist(ids[i]);
            }
        }
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

    function fullBalanceOf(
        address account
    ) external view returns (uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](tokenID);

        for (uint256 i = 1; i < tokenID; i++) {
            batchBalances[i] = balanceOf(account, i);
        }

        return batchBalances;
    }

    function tokenExist(uint256 tokenId) public view returns (bool) {
        return (tokenId < tokenID && tokenId != 0);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC1155) returns (bool) {
        bool truth = (AccessControl.supportsInterface(interfaceId) ||
            ERC1155.supportsInterface(interfaceId));
        return truth;
    }
}
