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
    Starter Pack Seller for Inventory System

    @author Team3d.R&D
*/

import "./UniswapV3Integration.sol";
import "../../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../../lib/openzeppelin/contracts/access/AccessControl.sol"; //Make access control using access manager
import "../interfaces/ITCGInventory.sol";
import "../interfaces/IVRFConsumer.sol";

contract StarterPackSeller is ReentrancyGuard, AccessControl, UniswapV3Integration {
    event CostUpdate(uint256 cost);
    event NftUpdate(address indexed NFT);
    event Success(bool success, address location);
    event TemplateAdded(uint256 templateId);
    event ChangeSubscriptionId(uint64 indexed newId);

    uint256 public packCost = 0.005 ether;
    address public nft;
    address public splitter = 0x26f8d863819210A81D3CA079720e71056F0f1823;
    address public vault = 0x26f8d863819210A81D3CA079720e71056F0f1823;
    uint256 public split = 50;
    uint256 public referralSplit = 10;
    uint256 public vaultSplit = 25;
    uint256 public totalSplit = 85;
    address public primaryToken = 0x46c8651dDedD50CBDF71de85D3de9AaC80247B62;
    address public consumer;
    uint8 public constant cardsInPack = 7;

    struct RequestInfo {
        address user;
        uint8 requestCount;
        uint8 level;
        uint256[] templateIdToMint;
    }

    mapping(uint8 => uint256[]) public levelToTemplateIds;
    mapping(uint256 => RequestInfo) public requestData;
    mapping(address => uint256) public userToRequestID; // RequestID from Chainlink
    mapping(address => bool) public userHasPendingRequest;
    mapping(address => uint256) public referralToClaim;
    mapping(address => uint256) public userPoints;
    mapping(address => mapping(address => bool)) public userReferrals; // Stores which addresses have been referred by which address
    mapping(address => uint256) public referralCount; // Stores the number of unique referrals for each address
    mapping(address => uint256) public ascensionCount; // Ascension counter
    mapping(address => uint256) public packsOpened; // Pack counter

    constructor(address _uniswapV3Router) UniswapV3Integration(_uniswapV3Router) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }

    // Function to adjust where the Vault split is going
    function changeVault(address newVault) external onlyRole(DEFAULT_ADMIN_ROLE) {
        vault = newVault;
    }

    // Function to change the Consumer
    function changeConsumer(address newConsumer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        consumer = newConsumer;
    }

    // Function to adjust where the Splitter is
    function changeSplitter(address newSplitter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        splitter = newSplitter;
    }

    // Function to change the cost of the starter Pack
    function changeCost(uint256 newCost) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newCost > 0, "Cost must be greater than 0");
        require(newCost > IVRFConsumer(consumer).requestFee(), "Cost must be greater than Consumer request fee");
        packCost = newCost;
        emit CostUpdate(newCost);
    }

    function userPoint(address user) external view returns (uint256) {
        return userPoints[user];
    }

    // Function to change the NFT contract it's minting from
    // WARNING if change to new NFT contract ensure that the templatesID match up prior to adding.
    function changeNFT(address newNFT) external onlyRole(DEFAULT_ADMIN_ROLE) {
        nft = newNFT;
        emit NftUpdate(newNFT);
    }

    // Function to addTemplateIds to the minting process
    // A template can be added more then once to increase its probability of being minted
    function addTemplateId(uint256[] memory templates) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < templates.length; i++) {
            // if templateId exist add it to the array
            (bool truth, uint8 level) = ITCGInventory(nft).templateExists(templates[i]);
            if (truth) {
                levelToTemplateIds[level].push(templates[i]);
                emit TemplateAdded(templates[i]);
            }
        }
    }

    // Function to removeTemplateIds in the array
    function removeTemplateIds(uint8 level, uint256 position) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 l = levelToTemplateIds[level].length;
        require(position < l, "Out of bounds");
        levelToTemplateIds[level][position] = levelToTemplateIds[level][l - 1];
        levelToTemplateIds[level].pop();
    }

    function storedTemplates(uint8 level) external view returns (uint256[] memory templatesDisplay) {
        templatesDisplay = levelToTemplateIds[level];
    }

    /**
     * @dev function to set Splits between the entities
     * @param _newDev DevSplit goes to splitter
     * @param _newVault Vault Split goes to vault
     * @param _newReferral goes to referer
     */
    function setSplits(uint256 _newDev, uint256 _newVault, uint256 _newReferral)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 sum = _newDev + _newVault + _newReferral;
        totalSplit = sum;
        require(totalSplit > 0, "Must be at least 1");
        vaultSplit = _newVault;
        referralSplit = _newReferral;
        split = _newDev;
    }

    /**
     * @dev function called to request randomness from smart contracts
     * @return uint256 requestId
     */
    function requestRandomWords(uint8 cardsToMint, address user, uint8 level) internal returns (uint256) {
        uint256 amount = IVRFConsumer(consumer).requestFee();
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }
        uint256 s_requestId = IVRFConsumer(consumer).requestRandomness{value: amount}(cardsToMint);
        handleRequest(user, cardsToMint, s_requestId, level);
        return s_requestId;
    }

    /**
     * @dev function to handle the requestData to mint tokens
     */
    function handleRequest(address user, uint8 cards, uint256 requestId, uint8 level) internal {
        RequestInfo storage r = requestData[requestId];
        r.user = user;
        r.requestCount = cards;
        r.level = level;
        userToRequestID[user] = requestId;
        userHasPendingRequest[user] = true; // Set the pending status to true
    }

    /**
     * @dev external function that is used to buy a StarterPack
     * @param referral is the address referring the user for a split
     */
    function buyStarterPack(address referral) external payable nonReentrant returns (uint256 requestId) {
        require(
            !userHasPendingRequest[msg.sender], "User has a pending buy or hasn't opened their last starter pack yet."
        );
        require(msg.value == packCost, "Not enough funds sent");
        splitFunds(msg.value, referral);
        requestId = requestRandomWords(cardsInPack, msg.sender, 1);
    }

    /**
     * @dev Function to upgrade a set of tokens to the next level.
     * @param tokenIds An array of 11 token IDs to upgrade.
     * @return requestId The ID of the request for the new upgraded token.
     */
    function ascendToNextLevel(uint256[11] memory tokenIds) external nonReentrant returns (uint256 requestId) {
        address user = msg.sender;

        // Ensure the user has no pending requests and owns the tokens
        require(!userHasPendingRequest[user], "User has a pending buy or hasn't opened their last starter pack yet.");

        bool[12] memory truths; // Used to track slots
        ITCGInventory _nft = ITCGInventory(nft);

        // Get data for the first token in the list
        (uint8 level,,,,,,,) = _nft.dataReturn(tokenIds[0]);
        require(level < 10, "Can't upgrade the final level.");
        require(levelToTemplateIds[level + 1].length >= 11, "Not enough templates to mint from.");

        // Verify all cards are unique and of the same level, and burn them
        for (uint8 i = 0; i < 11;) {
            (uint8 lvl,,,,,,, uint8 slot) = _nft.dataReturn(tokenIds[i]);
            truths[slot] = !truths[slot]; // If duplicate it'll make it false
            require(truths[slot], "All cards must be unique.");
            require(level == lvl, "All cards must be of the same level.");
            require(_nft.ownerOf(tokenIds[i]) == user, "Not the owner of the card.");
            _nft.burn(tokenIds[i]);

            unchecked {
                i++;
            }
        }

        // Request for 1x level+1 card
        requestId = requestRandomWords(1, user, level + 1);

        // Increment the ascension count for the user
        ascensionCount[user]++;
        return requestId;
    }

    /**
     * @dev splits the Funds from buying the pack
     * @param amount the amount for the referrer and vault
     */
    function splitFunds(uint256 amount, address referral) internal {
        uint256 base = (amount - ((IVRFConsumer(consumer).requestFee() * 150) / 100)) / totalSplit;
        uint256 amountToSplit = (vaultSplit + referralSplit) * base;
        tokenPart(referral, amountToSplit);
        amountToSplit = base * split;
        bool success = false;
        if (amountToSplit <= address(this).balance) {
            (success,) = address(splitter).call{value: amountToSplit}("");
        }

        // Record referral if it's a valid address and hasn't been recorded yet
        if (referral != address(0) && !userReferrals[referral][msg.sender]) {
            userReferrals[referral][msg.sender] = true;
            referralCount[referral]++;
        }
        emit Success(success, splitter);
    }

    /**
     * @dev function to split between referrer and vault
     * @param location the referrer
     * @param amount eth to spend
     * WARNING if location is not able to claim erc20 from contract tokens will be lost in contract
     */
    function tokenPart(address location, uint256 amount) internal {
        if (amount > 0) {
            uint256 beforeBuy = IERC20(primaryToken).balanceOf(address(this));
            _buyTokenETH(primaryToken, amount, address(this), 10000);
            uint256 boughtAmount = IERC20(primaryToken).balanceOf(address(this)) - beforeBuy;
            if (location == vault || location == address(0)) {
                IERC20(primaryToken).transfer(vault, boughtAmount);
            } else {
                uint256 referAmount = (boughtAmount * referralSplit) / (referralSplit + vaultSplit);
                referralToClaim[location] += referAmount;
                uint256 vaultAmount = boughtAmount - referAmount;
                if (vaultAmount > 0) {
                    IERC20(primaryToken).transfer(vault, vaultAmount);
                }
            }
        }
    }

    /**
     * @dev function to retrieve the random words from the consumer
     * @param requestId the request id
     */
    function _retrieveRandomWords(uint256 requestId) internal {
        RequestInfo storage r = requestData[requestId];
        uint256[] memory randomWords = IVRFConsumer(consumer).getRandomness(requestId);
        uint256 l = levelToTemplateIds[r.level].length;
        uint8 rL = uint8(randomWords.length);
        // Set pending status to false
        userHasPendingRequest[r.user] = false;
        for (uint8 i = 0; i < rL;) {
            uint256 pos = randomWords[i] % l;
            r.templateIdToMint.push(levelToTemplateIds[r.level][pos]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev function to see if user can claim from contract
     * @param user the address to claim
     * @return claimable can claim
     */
    function canClaimRewards(address user) public view returns (bool claimable) {
        claimable = referralToClaim[user] > 0;
    }

    /**
     * This function allows a user to claim their referral rewards.
     */
    function claimRewards() external nonReentrant {
        require(canClaimRewards(msg.sender), "Nothing to claim.");
        // Transfer the user's referral rewards to their account.
        _tokenClaim(msg.sender);
    }

    /**
     * @dev the internal claim function
     */
    function _claim(address user) internal returns (uint256[] memory results) {
        _tokenClaim(user);
        if (canOpenStarterPack(user)) {
            results = _mint(user);
        }
    }

    /**
     * @dev function to mint NFT tokens if the User has a current position to claim from
     * will only claim from one starter pack at a time
     */
    function _mint(address user) internal returns (uint256[] memory) {
        _retrieveRandomWords(userToRequestID[user]);
        RequestInfo storage r = requestData[userToRequestID[user]];
        uint256 l = r.templateIdToMint.length;
        userToRequestID[user] = 0;
        uint256[] memory result = new uint256[](l);

        for (uint256 i = 0; i < l; i++) {
            uint256 id = ITCGInventory(nft).mint(r.templateIdToMint[i], r.user);
            result[i] = id;
            userPoints[user] += r.level;
        }

        return result;
    }

    /**
     * @dev function to send any referral tokens to user
     */
    function _tokenClaim(address user) internal {
        if (referralToClaim[user] > 0) {
            uint256 amount = referralToClaim[user];
            referralToClaim[user] = 0;
            IERC20(primaryToken).transfer(user, amount);
        }
    }

    receive() external payable {}

    /**
     * This function checks if a user can open a starter pack.
     * @param user The address of the user to check.
     * @return True if the user can open a starter pack, false otherwise.
     */
    function canOpenStarterPack(address user) public view returns (bool) {
        return userToRequestID[user] > 0 && IVRFConsumer(consumer).requestIdToFullfilled(userToRequestID[user]);
    }

    /**
     * @dev This function allows a user to open a starter pack.
     * @return results The IDs of the minted tokens.
     */
    function openStarterPack() external nonReentrant returns (uint256[] memory results) {
        require(canOpenStarterPack(msg.sender), "No starter pack to open.");

        // Increment the packs opened count
        packsOpened[msg.sender]++;

        // Mint new NFTs and assign them to the user
        return _claim(msg.sender);
    }
}
