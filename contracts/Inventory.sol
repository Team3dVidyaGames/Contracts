// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Inventory Contract
 */
contract Inventory is ERC1155, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    /// @notice Event emitted only on construction.
    event InventoryDeployed();

    /// @notice Event emitted when user equipped with position.
    event Equipped(address user, uint256 tokenId, uint8 position);

    /// @notice Event emitted when user unequipped with position.
    event Unequipped(address user, uint8 position);

    string private _pathStart;
    string private _pathEnd;

    // Treasure chest reward token (VIDYA)
    IERC20 public constant treasureChestRewardToken =
        IERC20(0x3D3D35bb9bEC23b06Ca00fe472b50E7A4c692C30);

    // Mapping of contract addresses that are allowed to edit item features
    mapping(address => ApprovedGame) private _approvedGameContract;

    // Mapping from token ID to respective treasure chest rewards in VIDYA tokens
    mapping(uint256 => uint256) public treasureChestRewards;

    // Mapping to calculate how many treasure hunts an address has participated in
    mapping(address => uint256) public treasureHuntPoints;

    // Mapping for the different equipment items of each address/character
    // 0 - head, 1 - left hand, 2 - neck, 3 - right hand, 4 - chest, 5 - legs
    mapping(address => uint256[6]) public characterEquipment;

    // To check if a template exists
    mapping(uint256 => bool) _templateExists;

    /* Item struct holds the itemId, a total of 4 additional features
    and the burned status */
    struct Item {
        uint256 templateId; // id of Template in the itemTemplates array
        uint8 feature1;
        uint8 feature2;
        uint8 feature3;
        uint8 feature4;
        uint8 equipmentPosition;
        bool burned;
    }

    struct ApprovedGame {
        bool approved;
        uint256 minTemplateId;
        uint256 maxTemplateId;
    }

    // All items created, ever, both burned and not burned
    Item[] public allItems;
    string[] public templateURI;

    modifier onlyApprovedGame() {
        require(
            _approvedGameContract[msg.sender].approved,
            "Inventory: Caller is not an approved game contract"
        );
        _;
    }

    modifier isTokenExists(uint256 _tokenId) {
        require(allItems[_tokenId].burned, "Invenotry: Token does not exist");
        _;
    }

    modifier isCallerOwnedToken(address _caller, uint256 _tokenId) {
        require(
            balanceOf(_caller, _tokenId) != 0,
            "Invenotry: Caller hasn't got this token"
        );
        _;
    }

    modifier isTemplateExists(uint256 _templateId) {
        require(
            _templateExists[_templateId],
            "Inventory: Template does not exist"
        );
        _;
    }

    modifier isTemplateNotExists(uint256 _templateId) {
        require(
            !_templateExists[_templateId],
            "Inventory: Template already exists"
        );
        _;
    }

    /**
     * @dev Constructor function
     * @param _uri Token URI
     */
    constructor(string memory _uri) ERC1155(_uri) {
        _pathStart = "https://team3d.io/inventory/json/";
        _pathEnd = ".json";

        addNewTemplate(0, 0);
    }

    function checkAndTransferVIDYA(uint256 _amount) private {
        require(
            treasureChestRewardToken.transferFrom(
                msg.sender,
                address(this),
                _amount
            ) == true,
            "transfer must succeed"
        );
    }

    /**
     * @dev External function to equip. This function can be called when only token is existed.
     * @param _tokenId Token Id
     * @param _equipmentPosition Position of equipment
     */
    function equip(uint256 _tokenId, uint8 _equipmentPosition)
        external
        isCallerOwnedToken(msg.sender, _tokenId)
    {
        require(
            _equipmentPosition < 6,
            "Invenotry: Invalid equipment position value."
        );
        require(
            allItems[_tokenId].equipmentPosition == _equipmentPosition,
            "Invenotry: Item cannot be equipped in this slot"
        );

        characterEquipment[msg.sender][_equipmentPosition] = _tokenId;

        emit Equipped(msg.sender, _tokenId, _equipmentPosition);
    }

    /**
     * @dev External function to unequip.
     * @param _equipmentPosition Position of equipment
     */
    function unequip(uint8 _equipmentPosition) external {
        require(
            _equipmentPosition < 6,
            "Invenotry: Invalid equipment position value."
        );
        characterEquipment[msg.sender][_equipmentPosition] = 0;

        emit Unequipped(msg.sender, _equipmentPosition);
    }

    /**
     * @dev External function to withdraw any ERC20 tokens which Inventory contract holds. This function can be called by only owner.
     * @param _tokenContract Address of ERC20 token.
     */
    function withdrawERC20Tokens(address _tokenContract) external onlyOwner {
        IERC20 token = IERC20(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, amount);
    }

    /**
     * @dev External function to set game settings. This function can be called by only owner.
     * @param _game Address of game
     * @param _status Game status(Approve or disapprove)
     * @param _minTemplateId Minimum template id
     * @param _maxTemplateId Maximum template id
     */
    function setGameSettings(
        address _game,
        bool _status,
        uint256 _minTemplateId,
        uint256 _maxTemplateId
    ) external onlyOwner {
        _approvedGameContract[_game].approved = _status;
        _approvedGameContract[_game].minTemplateId = _minTemplateId;
        _approvedGameContract[_game].maxTemplateId = _maxTemplateId;
    }

    /**
     * @dev External function to set URI path. This function can be called by only owner.
     * @param _newPathStart New start path
     * @param _newPathEnd New end path
     */
    function setPaths(
        string calldata _newPathStart,
        string calldata _newPathEnd
    ) external onlyOwner {
        _pathStart = _newPathStart;
        _pathEnd = _newPathEnd;
    }

    /**
     * @dev Public function to add new templates. This function can be called by only owner.
     * @param _templateId Id of template
     * @param _equipmentPosition Equipment position
     */
    function addNewTemplate(uint256 _templateId, uint8 _equipmentPosition)
        public
        onlyOwner
        isTemplateNotExists(_templateId)
    {
        templateURI.push(toString(_templateId));
        _templateExists[_templateId] = true;
        allItems.push(Item(_templateId, 0, 0, 0, 0, _equipmentPosition, false));
        uint256 id = allItems.length - 1;
        _mint(msg.sender, id, 1, "");
    }

    /**
     * @dev Public function to add new template and transfer it to user. This function can be called by only owner.
     * @param _templateId Id of template
     * @param _equipmentPosition Equipment position
     * @param _receiver Address of receiver
     */
    function addNewTemplateAndTransfer(
        uint256 _templateId,
        uint8 _equipmentPosition,
        address _receiver
    ) public onlyOwner isTemplateNotExists(_templateId) {
        templateURI.push(toString(_templateId));
        _templateExists[_templateId] = true;
        allItems.push(Item(_templateId, 0, 0, 0, 0, _equipmentPosition, false));
        uint256 id = allItems.length - 1;
        _mint(_receiver, id, 1, "");
    }

    /**
     * @dev Public function to create item from templates. This function can be called by approved games only.
     * @param _templateId Id of template
     * @param _feature1 Feature 1
     * @param _feature2 Feature 2
     * @param _feature3 Feature 3
     * @param _feature4 Feature 4
     * @param _equipmentPosition Equipment position
     * @param _amount Amount of Item
     * @param _player Address of player
     * @return Token Id
     */
    function createItemFromTemplate(
        uint256 _templateId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition,
        uint256 _amount,
        address _player
    ) public isTemplateExists(_templateId) onlyApprovedGame returns (uint256) {
        require(
            _approvedGameContract[_player].minTemplateId <= _templateId &&
                _templateId <= _approvedGameContract[_player].maxTemplateId,
            "Inventory: Template id is the out of range"
        );
        uint256 id;

        allItems.push(
            Item(
                _templateId,
                _feature1,
                _feature2,
                _feature3,
                _feature4,
                _equipmentPosition,
                false
            )
        );

        id = allItems.length - 1;
        _mint(_player, id, _amount, "");

        return id;
    }

    /**
     * @dev Public function to change features for item. This function can be called by approved games only.
     * @param _tokenId Id of Token
     * @param _feature1 Feature 1
     * @param _feature2 Feature 2
     * @param _feature3 Feature 3
     * @param _feature4 Feature 4
     * @param _equipmentPosition Equipment position
     * @param _player Address of player
     */
    function changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition,
        address _player
    ) public onlyApprovedGame isCallerOwnedToken(_player, _tokenId) {
        _changeFeaturesForItem(
            _tokenId,
            _feature1,
            _feature2,
            _feature3,
            _feature4,
            _equipmentPosition
        );
    }

    /**
     * @dev Internal function to change features for item.
     * @param _tokenId Id of Token
     * @param _feature1 Feature 1
     * @param _feature2 Feature 2
     * @param _feature3 Feature 3
     * @param _feature4 Feature 4
     * @param _equipmentPosition Equipment position
     */
    function _changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    ) internal {
        Item storage item = allItems[_tokenId];

        item.feature1 = _feature1;
        item.feature2 = _feature2;
        item.feature3 = _feature3;
        item.feature4 = _feature4;
        item.equipmentPosition = _equipmentPosition;
    }

    /**
     * @dev External function to add treasure chest. This function can be called by only approved games.
     * @param _tokenId Token id
     * @param _rewardsAmount Rewards amount
     * @param _user Address of user
     */
    function addTreasureChest(
        uint256 _tokenId,
        uint256 _rewardsAmount,
        address _user
    ) external onlyApprovedGame isCallerOwnedToken(_user, _tokenId) {
        treasureChestRewards[_tokenId] =
            _rewardsAmount *
            balanceOf(_user, _tokenId);
    }

    /**
     * @dev Public function to burn the token.
     * @param _tokenId Token id
     * @param _owner Address of token owner
     */
    function burn(uint256 _tokenId, address _owner)
        public
        isCallerOwnedToken(_owner, _tokenId)
    {
        allItems[_tokenId].burned = true;

        _burn(_owner, _tokenId, balanceOf(_owner, _tokenId));
        uint256 treasureChestRewardsForToken = treasureChestRewards[_tokenId];
        if (treasureChestRewardsForToken > 0) {
            treasureChestRewardToken.safeTransfer(
                _owner,
                treasureChestRewardsForToken
            );
            treasureHuntPoints[_owner]++;
        }
    }

    /**
     * @dev Internal function to convert uint256 to string
     * @param _i uint256 variable
     */
    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
