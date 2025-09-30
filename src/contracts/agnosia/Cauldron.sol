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
    Distribution contract
*/
/**
 * @author Team3d.R&D
 */
import "../interfaces/ITCGInventory.sol";
import "./DistributionSystem.sol";
import "../../../lib/openzeppelin/contracts/access/Ownable.sol";

contract Cauldron is Ownable(msg.sender), DistributionSystem {
    event GatewaySet(address _gateway);

    ITCGInventory immutable nft;

    uint256 public spillage;
    uint256 public totalCardsBurned;
    uint8 public highestLevelBurned;
    address public gateway;

    uint256[11] public pointPerLevel;

    mapping(uint8 => mapping(uint8 => uint256)) public levelToSlotToBurnCount;
    mapping(address => uint256) public agnosia;
    mapping(address => uint256) public totalCardsBurnedPerUser;
    mapping(address => uint256) public highestLevelBurnedPerUser;

    constructor(address _rewardToken, address _nft) DistributionSystem(_rewardToken) {
        nft = ITCGInventory(_nft);
    }

    function gatewaySet() public view returns (bool) {
        return gateway != address(0);
    }

    function setGateway(address _gateway) external onlyOwner {
        require(!gatewaySet(), "Gateway already set");
        gateway = _gateway;

        emit GatewaySet(gateway);
    }

    function _processClaim(address user, uint256 tokensToClaim) internal override {
        spillage += (((16 - highestLevelBurned) * tokensToClaim) / 100); // max 15% to a minium of 6% of tokensToClaim go to future gateway
        if (gatewaySet()) {
            _transferClaim(gateway, spillage);
            spillage = 0;
        }

        super._processClaim(user, tokensToClaim);
    }

    function rewardSupply() public view override returns (uint256 supply) {
        supply = super.rewardSupply();
        if (!gatewaySet()) {
            supply -= spillage;
        }
    }

    function UIHelperForUser(address user)
        external
        view
        returns (uint256 _tokensClaimable, uint256 userWeight, uint256 totalWeight, uint256 _rewardsClaimed)
    {
        (_tokensClaimable, userWeight, totalWeight) = tokensClaimable(user);
        _rewardsClaimed = rewardsClaimed[user];
    }

    function UIHelperForGeneralInformation() external view returns (uint256 _totalClaimed, uint256 _totalBurned) {
        _totalBurned = totalCardsBurned;
        _totalClaimed = totalRewardsClaimed;
    }

    function increaseCauldronPortion(uint256[] memory tokenIds) external {
        uint256 weightToAdd;
        for (uint256 i = 0; i < tokenIds.length;) {
            require(nft.ownerOf(tokenIds[i]) == msg.sender, "Not the card owner.");

            agnosia[msg.sender]++;

            (uint8 level,,,,, uint256 winCount,, uint8 slot) = nft.dataReturn(tokenIds[i]);
            nft.burn(tokenIds[i]);

            // Do point math...
            weightToAdd += (bonusMultiplier(tokenIds[i]) * (pointPerLevel[level] + (winCount / level)));
            levelToSlotToBurnCount[level][slot]++;
            highestLevelBurned = level > highestLevelBurned ? level : highestLevelBurned;
            highestLevelBurnedPerUser[msg.sender] =
                level > highestLevelBurnedPerUser[msg.sender] ? level : highestLevelBurnedPerUser[msg.sender];
            unchecked {
                i++;
            }
        }

        totalCardsBurned += tokenIds.length;
        totalCardsBurnedPerUser[msg.sender]++;
        _addWeight(msg.sender, weightToAdd);
    }

    function initialize() external onlyOwner {
        pointPerLevel[1] = 1;

        for (uint256 i = 2; i < 11;) {
            pointPerLevel[i] = (12 * pointPerLevel[i - 1]);
            unchecked {
                i++;
            }
        }
    }

    function bonusMultiplier(uint256 _tokenId) public view returns (uint256 bonusMulti) {
        (uint8 _level,,,,,,, uint8 _slot) = nft.dataReturn(_tokenId);
        bonusMulti = (50 / (levelToSlotToBurnCount[_level][_slot] + 1)) > 0
            ? (50 / (levelToSlotToBurnCount[_level][_slot] + 1))
            : 1;
    }

    function getBatchBrewValueMulti(uint256[] memory _tokenIds)
        public
        view
        returns (uint256[] memory cardsPointValue, uint256 sumOfCards, uint256 userPoints, uint256 contractPoints)
    {
        cardsPointValue = new uint256[](_tokenIds.length);
        uint256[12][12] memory sutoCardBurner;
        address user = msg.sender;
        for (uint256 x = 0; x < _tokenIds.length; x++) {
            (uint8 _level,,,,, uint256 _wincount,, uint8 _slot) = nft.dataReturn(_tokenIds[x]);
            sutoCardBurner[_level][_slot]++;
            uint256 b = (50 / (levelToSlotToBurnCount[_level][_slot] + sutoCardBurner[_level][_slot])) > 0
                ? (50 / (levelToSlotToBurnCount[_level][_slot] + sutoCardBurner[_level][_slot]))
                : 1;
            cardsPointValue[x] = b * (pointPerLevel[_level] + (_wincount / _level));
            sumOfCards += cardsPointValue[x];
        }

        (, userPoints, contractPoints) = tokensClaimable(user);
    }

    function changeTime(uint256 newTime) external onlyOwner {
        timeSet = newTime;
    }
}
