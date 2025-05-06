// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../../src/contracts/InventoryV1155.sol";

contract MockInventoryV1155 is InventoryV1155 {
    // Mock specific state variables
    bool public shouldFailMint;
    bool public shouldFailBurn;
    bool public shouldFailBatchMint;
    bool public shouldFailBatchBurn;
    mapping(uint256 => bool) public tokenExists;

    constructor(string memory baseUri) InventoryV1155(baseUri) {}

    // Mock functions to control behavior
    function setShouldFailMint(bool _shouldFail) external {
        shouldFailMint = _shouldFail;
    }

    function setShouldFailBurn(bool _shouldFail) external {
        shouldFailBurn = _shouldFail;
    }

    function setShouldFailBatchMint(bool _shouldFail) external {
        shouldFailBatchMint = _shouldFail;
    }

    function setShouldFailBatchBurn(bool _shouldFail) external {
        shouldFailBatchBurn = _shouldFail;
    }

    function setTokenExists(uint256 tokenId, bool exists) external {
        tokenExists[tokenId] = exists;
    }

    // Override functions for testing
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external override {
        if (shouldFailMint) {
            revert("Mock mint failure");
        }
        super.mint(to, tokenId, amount);
    }

    function burn(address from, uint256 id, uint256 value) external override {
        if (shouldFailBurn) {
            revert("Mock burn failure");
        }
        super.burn(from, id, value);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) external override {
        if (shouldFailBatchMint) {
            revert("Mock batch mint failure");
        }
        super.mintBatch(to, ids, values);
    }

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) external override {
        if (shouldFailBatchBurn) {
            revert("Mock batch burn failure");
        }
        super.burnBatch(from, ids, values);
    }

    function tokenExist(uint256 tokenId) public view override returns (bool) {
        if (tokenExists[tokenId]) {
            return true;
        }
        return super.tokenExist(tokenId);
    }

    // Helper functions for testing
    function forceSetBalance(
        address account,
        uint256 tokenId,
        uint256 amount
    ) external {
        _mint(account, tokenId, amount, "");
    }

    function forceSetBatchBalance(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        _mintBatch(account, ids, amounts, "");
    }

    function forceSetItemData(uint256 tokenId, Item memory item) external {
        itemData[tokenId] = item;
    }
}
