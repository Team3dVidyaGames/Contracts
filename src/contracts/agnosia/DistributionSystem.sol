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
    Agnosia Distribution System contract
*/
/**
 * @author Team3d.R&D
 */
import "./WeightedSystem.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DistributionSystem is WeightedSystem {
    event Claimed(address user, uint256 amount);

    IERC20 public immutable rewardToken;

    uint256 public timeSet = 180 days;
    uint256 public totalRewardsClaimed;

    mapping(address => uint256) public lastClaim;
    mapping(address => uint256) public rewardsClaimed;

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    function claim() external {
        require(lastClaim[msg.sender] > 0, "Has not burned cards yet");
        _claim(msg.sender);
    }

    function _claim(address user) internal {
        if (lastClaim[user] == 0) {
            lastClaim[user] = block.timestamp;
        } else {
            (uint256 tokensToClaim,,) = tokensClaimable(user);
            require(tokensToClaim > 0, "Nothing to claim.");
            lastClaim[user] = block.timestamp;
            _processClaim(user, tokensToClaim);
        }
    }

    function _processClaim(address user, uint256 tokensToClaim) internal virtual {
        if (tokensToClaim > rewardSupply()) {
            tokensToClaim = rewardSupply();
        }

        _transferClaim(user, tokensToClaim);
        totalRewardsClaimed += tokensToClaim;
        rewardsClaimed[user] += tokensToClaim;

        emit Claimed(user, tokensToClaim);
    }

    function _transferClaim(address user, uint256 amount) internal {
        rewardToken.transfer(user, amount);
    }

    function _addWeight(address user, uint256 weightToAdd) internal override {
        _claim(user);
        super._addWeight(user, weightToAdd);
    }

    function tokensClaimable(address user)
        public
        view
        returns (uint256 tokensToClaim, uint256 userWeight, uint256 totalWeight)
    {
        (userWeight, totalWeight) = weights(user);

        if (userWeight == 0) {
            tokensToClaim = 0;
        } else {
            tokensToClaim = calculateClaim(user, userWeight, totalWeight);
        }
    }

    function rewardSupply() public view virtual returns (uint256 supply) {
        supply = rewardToken.balanceOf(address(this));
    }

    function calculateClaim(address user, uint256 uw, uint256 tw) internal view returns (uint256 amount) {
        uint256 timeDiff = block.timestamp - lastClaim[user];
        amount = (((rewardSupply() / timeSet) * timeDiff) / tw) * uw;
    }
}
