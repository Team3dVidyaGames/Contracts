// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

/*
  _______                   ____  _____  
 |__   __|                 |___ \|  __ \ 
    | | ___  __ _ _ __ ___   __) | |  | |
    | |/ _ \/ _` | '_ ` _ \ |__ <| |  | |
    | |  __/ (_| | | | | | |___) | |__| |
    |_|\___|\__,_|_| |_| |_|____/|_____/ 
    https://team3d.io
    https://discord.gg/team3d
    NFT Agnosia contract
*/
/**
 * @author Team3d.R&D
 */
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../../../lib/openzeppelin/contracts/access/AccessControl.sol";
import "../../../lib/openzeppelin/contracts/utils/Strings.sol";
import "../../../lib/openzeppelin/contracts/utils/Base64.sol";

contract TCGInventory is ERC721Enumerable, AccessControl, ReentrancyGuard {
    event updatedCardStats(uint256 indexed tokenId);
    event templateAdded(uint256 indexed id);

    struct Card {
        uint256 templateId;
        uint8 level;
        uint8 top;
        uint8 left;
        uint8 right;
        uint8 bottom;
        uint256 winCount;
        uint256 playedCount;
    }

    struct Data {
        string imageURL;
        string name;
        string description;
        string jsonStorage;
        uint8 level;
        uint8 top;
        uint8 left;
        uint8 right;
        uint8 bottom;
        uint8 slot;
    }

    mapping(uint256 => Data) public template;
    mapping(uint256 => Card) public cardData;
    mapping(uint8 => uint8) public levelSlots;

    uint256 public tokenID;
    uint256 public templateLength;

    // Access Control stuff
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");

    constructor() ERC721("Agnosia", "AGN") {
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CONTRACT_ROLE, ADMIN_ROLE);
        tokenID++;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function mint(uint256 templateID, address to) external onlyRole(MINTER_ROLE) returns (uint256) {
        (bool truth,) = templateExists(templateID);
        require(truth, "Template does not exist.");
        uint256 tD = tokenID;
        _mint(to, tokenID);
        tokenID++;
        _transposeData(templateID, tD);

        return tD;
    }

    function templateExists(uint256 templateID) public view returns (bool truth, uint8 level) {
        truth = templateID > 0 && templateID <= templateLength;
        if (truth) {
            level = template[templateID].level;
        }
    }

    function _transposeData(uint256 _templateID, uint256 _tokenID) internal {
        Card storage c = cardData[_tokenID];
        c.top = template[_templateID].top;
        c.left = template[_templateID].left;
        c.right = template[_templateID].right;
        c.bottom = template[_templateID].bottom;
        c.level = template[_templateID].level;
        c.templateId = _templateID;
    }

    function updateCardGameInformation(uint256 addWin, uint256 addPlayed, uint256 tokenId)
        public
        onlyRole(CONTRACT_ROLE)
    {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Sender not approved or token doesn't exist.");
        Card storage c = cardData[tokenId];
        c.winCount += addWin;
        c.playedCount += addPlayed;

        emit updatedCardStats(tokenId);
    }

    function burn(uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Sender not approved or owner or token doesn't exist.");
        _burn(tokenId);
    }

    function updateCardData(uint256 tokenId, uint8 top, uint8 left, uint8 right, uint8 bottom)
        public
        onlyRole(CONTRACT_ROLE)
    {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Sender not approved or owner or token doesn't exist.");
        Card storage c = cardData[tokenId];
        c.top = top;
        c.left = left;
        c.right = right;
        c.bottom = bottom;

        emit updatedCardStats(tokenId);
    }

    function dataReturn(uint256 tokenId)
        public
        view
        returns (
            uint8 level,
            uint8 top,
            uint8 left,
            uint8 right,
            uint8 bottom,
            uint256 winCount,
            uint256 playedCount,
            uint8 slot
        )
    {
        Card memory c = cardData[tokenId];
        level = c.level;
        top = c.top;
        left = c.left;
        right = c.right;
        bottom = c.bottom;
        winCount = c.winCount;
        playedCount = c.playedCount;
        slot = template[c.templateId].slot;
    }

    function addTemplateId(
        string memory imageURL,
        string memory description,
        string memory name,
        uint8 top,
        uint8 left,
        uint8 right,
        uint8 bottom,
        uint8 level
    ) external onlyRole(ADMIN_ROLE) {
        levelSlots[level]++;
        require(levelSlots[level] < 12, "Only 11 slots per level.");
        templateLength++;
        template[templateLength] =
            Data(imageURL, name, description, "", level, top, left, right, bottom, levelSlots[level]);
        template[templateLength].jsonStorage = _templateIdString(templateLength);

        emit templateAdded(templateLength);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        (
            uint8 level,
            uint8 top,
            uint8 left,
            uint8 right,
            uint8 bottom,
            uint256 winCount,
            uint256 playedCount,
            uint8 slot
        ) = dataReturn(tokenId);
        uint256 templateId = cardData[tokenId].templateId;
        string memory attributes = _attributes(templateId, level, top, left, right, bottom, winCount, playedCount, slot);
        string memory _json =
            Base64.encode(bytes(string(abi.encodePacked(template[templateId].jsonStorage, attributes))));

        return string(abi.encodePacked("data:application/json;base64,", _json));
    }

    function _templateIdString(uint256 templateId) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                '{"name": "',
                template[templateId].name,
                '", "description": "',
                template[templateId].description,
                '","image": "',
                template[templateId].imageURL,
                '",'
            )
        );
    }

    function updateImageURL(uint256 position, string memory newURL) external onlyRole(ADMIN_ROLE) {
        (bool truth,) = templateExists(position);
        require(truth, "Template doesn't exist.");
        template[position].imageURL = newURL;
        template[position].jsonStorage = _templateIdString(position);
    }

    function updateDescription(uint256 position, string memory newDescription) external onlyRole(ADMIN_ROLE) {
        (bool truth,) = templateExists(position);
        require(truth, "Template doesn't exist.");
        template[position].description = newDescription;
        template[position].jsonStorage = _templateIdString(position);
    }

    function updateName(uint256 position, string memory newName) external onlyRole(ADMIN_ROLE) {
        (bool truth,) = templateExists(position);
        require(truth, "Template doesn't exist.");
        template[position].name = newName;
        template[position].jsonStorage = _templateIdString(position);
    }

    function _attributes(
        uint256 id,
        uint8 level,
        uint8 top,
        uint8 left,
        uint8 right,
        uint8 bottom,
        uint256 winCount,
        uint256 playedCount,
        uint8 slot
    ) internal view returns (string memory) {
        string memory attribute = _attributes1(level, top, left, right, bottom);
        string memory _wc = Strings.toString(winCount);
        string memory _pc = Strings.toString(playedCount);
        string memory _slot = Strings.toString(slot);

        return string(
            abi.encodePacked(
                '"attributes": [{ "trait_type": "Name", "value": "',
                template[id].name,
                attribute,
                '" }, { "trait_type": "Win Count", "value": "',
                _wc,
                '" }, { "trait_type": "Played Count", "value": "',
                _pc,
                '" }, { "trait_type": "Slot", "value": "',
                _slot,
                '" }]}'
            )
        );
    }

    function _attributes1(uint8 level, uint8 top, uint8 left, uint8 right, uint8 bottom)
        internal
        pure
        returns (string memory)
    {
        string memory _level = Strings.toString(level);
        string memory _top = Strings.toString(top);
        string memory _left = Strings.toString(left);
        string memory _right = Strings.toString(right);
        string memory _bottom = Strings.toString(bottom);

        return string(
            abi.encodePacked(
                '" }, { "trait_type": "Level", "value": "',
                _level,
                '" }, { "trait_type": "Top", "value": "',
                _top,
                '" }, { "trait_type": "Left", "value": "',
                _left,
                '" }, { "trait_type": "Right", "value": "',
                _right,
                '" }, { "trait_type": "Bottom", "value": "',
                _bottom
            )
        );
    }

    function ownerTokenArray(address user) public view returns (uint256[] memory tokenArray) {
        uint256 l = balanceOf(user);
        tokenArray = new uint256[](l);
        for (uint256 i = 0; i < l;) {
            tokenArray[i] = tokenOfOwnerByIndex(user, i);
            unchecked {
                i++;
            }
        }
    }

    function getHighestLevelCard(address owner) public view returns (uint8 highestLevel) {
        uint256[] memory ownedTokens = ownerTokenArray(owner);

        uint8 highestTokenLevel = 0;

        for (uint256 i = 0; i < ownedTokens.length; i++) {
            uint256 currentTokenId = ownedTokens[i];
            uint8 currentTokenLevel = cardData[currentTokenId].level;

            if (currentTokenLevel > highestTokenLevel) {
                highestTokenLevel = currentTokenLevel;
            }
        }

        return (highestTokenLevel);
    }
}
