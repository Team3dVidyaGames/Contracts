// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.10;

contract Inventory is ERC165, IERC721, IERC721Metadata, IERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    string private _name;
    string private _symbol;
    string private _pathStart;
    string private _pathEnd;
    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Treasure chest reward token (VIDYA)
    ERC20Token public constant treasureChestRewardToken = ERC20Token(0x3D3D35bb9bEC23b06Ca00fe472b50E7A4c692C30);
    
    // Uniswap token 
    ERC20Token public constant UNI_ADDRESS = ERC20Token(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    
    // Unicorn's Head
    uint256 private constant UNICORN_TEMPLATE_ID = 11;
	uint256 public UNICORN_TOTAL_SUPPLY = 0;
	mapping (address => bool) public unicornClaimed;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned tokens
    mapping (address => uint256) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    // Mapping of contract addresses that are allowed to edit item features 
    mapping (address => bool) private _approvedGameContract;

    // Mapping from token ID to respective treasure chest rewards in VIDYA tokens
    mapping (uint256 => uint256) public treasureChestRewards;

    // Mapping to calculate how many treasure hunts an address has participated in
    mapping (address => uint256) public treasureHuntPoints;
    
    // Mapping for the different equipment items of each address/character
    // 0 - head, 1 - left hand, 2 - neck, 3 - right hand, 4 - chest, 5 - legs
    mapping (address => uint256[6]) public characterEquipment;
    
    // To check if a template exists
    mapping (uint256 => bool) _templateExists; 

    /* Item struct holds the templateId, a total of 4 additional features
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
    
    /* Template struct holds the uri for each Item- 
    a reference to the json file which describes them */
    struct Template {
        string uri;
    }
    
    // All items created, ever, both burned and not burned 
    Item[] public allItems;
    
    // Admin editable templates for each item 
    Template[] public itemTemplates;
    
    modifier onlyApprovedGame() {
        require(_approvedGameContract[msg.sender], "msg.sender is not an approved game contract");
        _;
    }
    
    modifier tokenExists(uint256 _tokenId) {
        require(_exists(_tokenId), "Token does not exist");
        _;
    }
    
    modifier isOwnedByOrigin(uint256 _tokenId) {
        require(ownerOf(_tokenId) == tx.origin, "tx.origin is not the token owner");
        _;
    }
    
    modifier isOwnerOrApprovedGame(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender || _approvedGameContract[msg.sender], "Not owner or approved game");
        _;
    }
    
    modifier templateExists(uint256 _templateId) {
        require(_templateExists[_templateId], "Template does not exist");
        _;
    }

    constructor() 
        public  
    {
        _name = "Inventory";
        _symbol = "ITEM";
        _pathStart = "https://team3d.io/inventory/json/";
        _pathEnd = ".json";
        _registerInterface(InterfaceId_ERC721Metadata);
        _registerInterface(_InterfaceId_ERC721Enumerable);
        _registerInterface(_InterfaceId_ERC721);
        
        // Add the "nothing" item to msg.sender
        // This is a dummy item so that valid items in allItems start with 1
        addNewItem(0,0);
    }
    
    // Get the Unicorn's head item
    function mintUnicorn()
        external
    {
        uint256 id;
        
        require(UNICORN_TOTAL_SUPPLY < 100, "Unicorns are now extinct");
		require(!unicornClaimed[msg.sender], "You have already claimed a unicorn");
        require(UNI_ADDRESS.balanceOf(msg.sender) >= 1000 * 10**18, "Min balance 1000 UNI");
        require(_templateExists[UNICORN_TEMPLATE_ID], "Unicorn template has not been added yet");
        checkAndTransferVIDYA(1000 * 10**18); // Unicorn's head costs 1000 VIDYA 
        
        id = allItems.push(Item(UNICORN_TEMPLATE_ID,0,0,0,0,0,false)) -1;
		
		UNICORN_TOTAL_SUPPLY = UNICORN_TOTAL_SUPPLY.add(1);
		unicornClaimed[msg.sender] = true;
        
        // Materialize 
        _mint(msg.sender, id);
    }
    
    function checkAndTransferVIDYA(uint256 _amount) private {
        require(treasureChestRewardToken.transferFrom(msg.sender, address(this), _amount) == true, "transfer must succeed");
    }
    
    function equip(
        uint256 _tokenId, 
        uint8 _equipmentPosition
    ) 
        external
        tokenExists(_tokenId)
    {
        require(_equipmentPosition < 6);
        require(allItems[_tokenId].equipmentPosition == _equipmentPosition, 
            "Item cannot be equipped in this slot");
            
        characterEquipment[msg.sender][_equipmentPosition] = _tokenId;
    }

    function unequip(
        uint8 _equipmentPosition
    ) 
        external
    {
        require(_equipmentPosition < 6);
        characterEquipment[msg.sender][_equipmentPosition] = 0;
    }

    function getEquipment(
        address player
    ) 
        public 
        view 
        returns(uint256[6] memory)
    {
        return characterEquipment[player];
    }

    // The total supply of any one item
    // Ask for example how many of "Torch" item exist
    function getIndividualCount(
        uint256 _templateId
    ) 
        public 
        view 
        returns(uint256) 
    {
        uint counter = 0;
        
        for (uint i = 0; i < allItems.length; i++) {
            // If match found & is not burned 
            if (allItems[i].templateId == _templateId && !allItems[i].burned) {
                counter++;
            }
        }
        
        // Total supply of item using the _templateId
        return counter;
    }
    
    // Total supply of any one item owned by _owner
    // Ask for example how many of "Torch" item does the _owner have 
    function getIndividualOwnedCount(
        uint256 _templateId,
        address _owner
    )
        public 
        view 
        returns(uint256)
    {
        uint counter = 0;
        uint[] memory ownedItems = getItemsByOwner(_owner);
        
        for(uint i = 0; i < ownedItems.length; i++) {
            
            /* If ownedItems[i]'s templateId matches the one in allItems[] */
            if(allItems[ownedItems[i]].templateId == _templateId) {
                counter++;
            }
        }
        
        // Total supply of _templateId that _owner owns 
        return counter;
    }
    
    // Given a _tokenId returns how many other tokens exist with 
    // the same _templateId
    function getIndividualCountByID(
        uint256 _tokenId
    )
        public
        view
        tokenExists(_tokenId)
        returns(uint256)
    {
        uint256 counter = 0;
        uint256 templateId = allItems[_tokenId].templateId; // templateId we are looking for 
        
        for(uint i = 0; i < allItems.length; i++) {
            if(templateId == allItems[i].templateId && !allItems[i].burned) {
                counter++;
            }
        }
        
        return counter;
    }
    
    // Given a _tokenId returns how many other tokens the _owner has 
    // with the same _templateId
    function getIndividualOwnedCountByID(
        uint256 _tokenId,
        address _owner 
    )
        public
        view
        tokenExists(_tokenId)
        returns(uint256)
    {
        uint256 counter = 0;
        uint256 templateId = allItems[_tokenId].templateId; // templateId we are looking for 
        uint[] memory ownedItems = getItemsByOwner(_owner);
        
        for(uint i = 0; i < ownedItems.length; i++) {
            // The item cannot be burned because of getItemsByOwner(_owner), no need to check 
            if(templateId == allItems[ownedItems[i]].templateId) {
                counter++;
            }
        }
        
        return counter;
    }
    
    /*  Given an array of _tokenIds return the corresponding _templateId count 
        for each of those _tokenIds */
    function getTemplateCountsByTokenIDs(
        uint[] memory _tokenIds
    )
        public
        view
        returns(uint[] memory)
    {
        uint[] memory counts = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            counts[i] = getIndividualCountByID(_tokenIds[i]);
        }
        
        return counts;
    }
    
    /*  Given an array of _tokenIds return the corresponding _templateId count 
        for each of those _tokenIds that the _owner owns */
    function getTemplateCountsByTokenIDsOfOwner(
        uint[] memory _tokenIds,
        address _owner 
    )
        public
        view
        returns(uint[] memory)
    {
        uint[] memory counts = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            counts[i] = getIndividualOwnedCountByID(_tokenIds[i], _owner);
        }
        
        return counts;
    }
    
    /*  Given an array of _tokenIds return the corresponding _templateIds 
        for each of those _tokenIds 
        
        Useful for cross referencing / weeding out duplicates to populate the UI */
    function getTemplateIDsByTokenIDs(
        uint[] memory _tokenIds
    )
        public
        view
        returns(uint[] memory)
    {
        uint[] memory templateIds = new uint[](_tokenIds.length);
        
        for(uint i = 0; i < _tokenIds.length; i++) {
            templateIds[i] = allItems[_tokenIds[i]].templateId;
        }
        
        return templateIds;
    }

    // Get all the item id's by owner 
    function getItemsByOwner(
        address _owner
    ) 
        public 
        view 
        returns(uint[] memory) 
    {
        uint[] memory result = new uint[](_ownedTokensCount[_owner]);
        uint counter = 0;
        
        for (uint i = 0; i < allItems.length; i++) {
            // If owner is _owner and token is not burned 
            if (_tokenOwner[i] == _owner && !allItems[i].burned) {
                result[counter] = i;
                counter++;
            }
        }
        
        // Array of ID's in allItems that _owner owns 
        return result;
    }

    // Function to withdraw any ERC20 tokens
    function withdrawERC20Tokens(
        address _tokenContract
    ) 
        external 
        onlyOwner 
        returns(bool) 
    {
        ERC20Token token = ERC20Token(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(msg.sender, amount);
    }
    
    // Admin can approve (or disapprove) game contracts 
    function approveGameContract(
        address _game,
        bool _status
    )
        external 
        onlyOwner
    {
        _approvedGameContract[_game] = _status;
    }
    
    // Admin function to set _pathStart and _pathEnd
    function setPaths(
        string calldata newPathStart,
        string calldata newPathEnd
    )
        external
        onlyOwner
        returns(bool)
    {
        bool success;
        
        if(keccak256(abi.encodePacked(_pathStart)) != keccak256(abi.encodePacked(newPathStart))) {
            _pathStart = newPathStart;
            success = true;
        }
        
        if(keccak256(abi.encodePacked(_pathEnd)) != keccak256(abi.encodePacked(newPathEnd))) {
            _pathEnd = newPathEnd;
            success = true;
        }
        
        return success;
    }

    /* Admin can add new item template
    The _templateId is a reference to Template struct in itemTemplates[] */
    function addNewItem(
        uint256 _templateId,
        uint8 _equipmentPosition
    )
        public 
        onlyOwner
    {
        uint256 id;
        
        // Does the _templateId exist or do we need to add it?
        if(!_templateExists[_templateId]) {
            // Add template id for this item as reference
            itemTemplates.push(Template(uint2str(_templateId)));
            _templateExists[_templateId] = true;
        }
        
        id = allItems.push(Item(_templateId,0,0,0,0,_equipmentPosition,false)) -1;
        
        // Materialize 
        _mint(msg.sender, id);
    }
    
    /* Admin can add new item template and send it to receiver in 
    one call */
    function addNewItemAndTransfer(
        uint256 _templateId,
        uint8 _equipmentPosition,
        address receiver 
    )
        public 
        onlyOwner
    {
        uint256 id;
        
        // Does the _templateId exist or do we need to add it?
        if(!_templateExists[_templateId]) {
            // Add template id for this item as reference 
            itemTemplates.push(Template(uint2str(_templateId)));
            _templateExists[_templateId] = true;
        }
        
        id = allItems.push(Item(_templateId,0,0,0,0,_equipmentPosition,false)) -1;
        
        // Materialize 
        _mint(receiver, id);
    }
    
    /*  Allows approved game contracts to create new items from 
        already existing templates (added by admin)
        
        In other words this function allows a game to spawn more 
        of ie. "Torch" and set its default features etc */
    function createFromTemplate(
        uint256 _templateId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public
        templateExists(_templateId)
        onlyApprovedGame
        returns(uint256)
    {
        uint256 id; 
        address player = tx.origin;
        
        id = allItems.push(
            Item(
                _templateId,
                _feature1,
                _feature2,
                _feature3,
                _feature4,
                _equipmentPosition,
                false
            )
        ) -1;
        
        // Materialize to tx.origin (and not msg.sender aka. the game contract)
        _mint(player, id);
        
        // id of the new item 
        return id;
    }

    /*
    Change feature values of _tokenId
    
    Only succeeds when:
        the tx.origin (a player) owns the item 
        the msg.sender (game contract) is a manually approved game address 
    */
    function changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        public 
        onlyApprovedGame // msg.sender has to be a manually approved game address 
        tokenExists(_tokenId) // check if _tokenId exists in the first place 
        isOwnedByOrigin(_tokenId) // does the tx.origin (player in a game) own the token?
        returns(bool)
    {
        return (
            _changeFeaturesForItem(
                _tokenId,
                _feature1,
                _feature2,
                _feature3,
                _feature4,
                _equipmentPosition
            )
        );
    }

    function _changeFeaturesForItem(
        uint256 _tokenId,
        uint8 _feature1,
        uint8 _feature2,
        uint8 _feature3,
        uint8 _feature4,
        uint8 _equipmentPosition
    )
        internal
        returns(bool)
    {
        Item storage item = allItems[_tokenId];

        if(item.feature1 != _feature1) {
            item.feature1 = _feature1;
        }
        
        if(item.feature2 != _feature2) {
            item.feature2 = _feature2;
        }
        
        if(item.feature3 != _feature3) {
            item.feature3 = _feature3;
        }
        
        if(item.feature4 != _feature4) {
            item.feature4 = _feature4;
        }
        
        if(item.equipmentPosition != _equipmentPosition) {
            item.equipmentPosition = _equipmentPosition;
        }
        
        return true;
    }
    
    /*
    Features of _tokenId 
    Useful in various games where the _tokenId should 
    have traits etc.
    
    Example: a "Torch" could start with 255 and degrade 
    during gameplay over time 
    
    Note: maximum value for uint8 type is 255 
    */
    function getFeaturesOfItem(
        uint256 _tokenId 
    )
        public 
        view 
        returns(uint8[] memory)
    {
        Item storage item = allItems[_tokenId];
        uint8[] memory features = new uint8[](4);
        
        features[0] = item.feature1;
        features[1] = item.feature2;
        features[2] = item.feature3;
        features[3] = item.feature4;
        
        return features;
    }

    /*
    Turn uint256 into a string
    
    Reason: ERC721 standard needs token uri to return as string,
    but we don't want to store long urls to the json files on-chain.
    Instead we use this returned string (which is actually just an ID)
    and say to front ends that the token uri can be found at 
    somethingsomething.io/tokens/<id>.json 
    */
    function uint2str(
        uint256 i
    ) 
        internal 
        pure 
        returns(string memory) 
    {
        if (i == 0) return "0";
        
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10)); 
            i /= 10;
        }
        return string(bstr);
    }
    
    function append(
        string memory a, 
        string memory b, 
        string memory c
    ) 
        internal 
        pure 
        returns(string memory) 
    {
        return string(
            abi.encodePacked(a, b, c)
        );
    }
    
    /*
     * Adds an NFT and the corresponding reward for whoever finds it and burns it.
     */
    function addTreasureChest(uint256 _tokenId, uint256 _rewardsAmount) 
    external
    tokenExists(_tokenId)
    onlyApprovedGame 
    {
        treasureChestRewards[_tokenId] = _rewardsAmount;
    }

    /*  Burn the _tokenId
        Succeeds when:
            token exists 
            msg.sender is either direct owner of the token OR 
            msg.sender is a manually approved game contract 
        
        If tx.origin and msg.sender are different, burn the 
        _tokenId of the tx.origin (the player, not the game contract)
    */
    function burn(
        uint256 _tokenId
    )
        public
        tokenExists(_tokenId)
        isOwnerOrApprovedGame(_tokenId)
        returns(bool)
    {
        if (tx.origin == msg.sender) {
            return _burn(_tokenId, msg.sender);
        } else {
            return _burn(_tokenId, tx.origin);
        }
    }
    
    // Burn owner's tokenId 
    function _burn(
        uint256 _tokenId,
        address owner
    )
        internal
        returns(bool)
    {
        // Set burned status on token
        allItems[_tokenId].burned = true;
        
        // Set new owner to 0x0 
        _tokenOwner[_tokenId] = address(0);
        
        // Remove from old owner 
        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);

        // Check if it's a treasure hunt token
        uint256 treasureChestRewardsForToken = treasureChestRewards[_tokenId];
        if (treasureChestRewardsForToken > 0) {
            treasureChestRewardToken.transfer(msg.sender, treasureChestRewardsForToken);
            treasureHuntPoints[owner]++;
        }

        // Fire event 
        emit Transfer(owner, address(0), _tokenId);
        
        return true;
    }

    function getLevel(address player) public view returns(uint256) {
        return treasureHuntPoints[player];
    }

    // Return the total supply
    function totalSupply() 
        public 
        view 
        returns(uint256)
    {
        uint256 counter;
        for(uint i = 0; i < allItems.length; i++) {
            if(!allItems[i].burned) {
                counter++;
            }
        }
        
        // All tokens which are not burned 
        return counter;
    }
    
    // Return the templateId of _index token
    function tokenByIndex(
        uint256 _index
    ) 
        public 
        view 
        returns(uint256) 
    {
        require(_index < totalSupply());
        return allItems[_index].templateId;
    }
    
    // Return The token templateId for the index'th token assigned to owner
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) 
        public 
        view 
        returns 
        (uint256 tokenId) 
    {
        require(index < balanceOf(owner));
        return getItemsByOwner(owner)[index];
    }

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() 
        external 
        view 
        returns(string memory) 
    {
        return _name;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() 
        external 
        view 
        returns(string memory) 
    {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(
        uint256 tokenId
    ) 
        external 
        view 
        returns(string memory) 
    {
        require(_exists(tokenId));
        uint256 tokenTemplateId = allItems[tokenId].templateId;
        
        string memory id = uint2str(tokenTemplateId);
        return append(_pathStart, id, _pathEnd);
    }

    /**
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(
        address owner
    ) 
        public 
        view 
        returns(uint256) 
    {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(
        uint256 tokenId
    ) 
        public 
        view 
        returns(address) 
    {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        require(!allItems[tokenId].burned, "This token is burned"); // Probably useless require at this point 
        
        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(
        address to, 
        uint256 tokenId
    ) 
        public 
    {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(
        uint256 tokenId
    ) 
        public 
        view 
        returns(address)
    {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(
        address to, 
        bool approved
    ) 
        public 
    {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(
        address owner, 
        address operator
    ) 
        public 
        view 
        returns(bool) 
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        public 
    {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     *
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    )
        public 
    {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory _data
    ) 
        public 
    {
        transferFrom(from, to, tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function _exists(
        uint256 tokenId
    ) 
        internal 
        view 
        returns(bool) 
    {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(
        address spender, 
        uint256 tokenId
    ) 
        internal 
        view 
        returns(bool) 
    {
        address owner = ownerOf(tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
            spender == owner || 
            getApproved(tokenId) == spender || 
            isApprovedForAll(owner, spender)
        );
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(
        address to, 
        uint256 tokenId
    ) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
    {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory _data
    ) 
        internal 
        returns(bool) 
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(
            msg.sender, 
            from, 
            tokenId, 
            _data
        );
        
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(
        uint256 tokenId
    ) 
        private 
    {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}