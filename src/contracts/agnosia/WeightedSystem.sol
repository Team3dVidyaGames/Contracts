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
    Agnosia Burn Point System contract
*/
/**
 * @author Team3d.R&D
 */
import "../interfaces/ITCGInventory.sol";

contract WeightedSystem {
    event weightUpdated(uint256 _totalWeight, address indexed user, uint256 _userWeight);

    uint256 public totalWeight;
    mapping(address => uint256) public userWeights;
    address[] public users;

    function _addWeight(address user, uint256 weightToAdd) internal virtual {
        require(totalWeight < type(uint256).max - weightToAdd, "Weights are capped out.");

        if (userWeights[user] == 0) users.push(user);
        userWeights[user] += weightToAdd;
        totalWeight += weightToAdd;

        emit weightUpdated(totalWeight, user, userWeights[user]);
    }

    function weights(address user) public view returns (uint256 userW, uint256 totalW) {
        userW = userWeights[user];
        totalW = totalWeight;
    }

    function usersList() public view returns (address[] memory _users) {
        _users = users;
    }
}
