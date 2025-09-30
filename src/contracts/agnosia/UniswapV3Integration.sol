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
    UniswapV3 swapper

    @author Team3d.R&D
*/

import "./UniRouterDataV3.sol";
import "../../../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV3Integration {
    address public immutable Weth9;

    ISwapRouter immutable uniswapV3Router;

    constructor(address _uniswapV3Router) {
        ISwapRouter __uniswapV3Router = ISwapRouter(_uniswapV3Router);
        uniswapV3Router = __uniswapV3Router;
        Weth9 = __uniswapV3Router.WETH9();
    }

    /**
     * @dev function to buy primary token and send to the contract
     */
    function _buyTokenETH(address token, uint256 amount, address to, uint24 poolFee) internal {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: Weth9,
            tokenOut: token,
            fee: poolFee,
            recipient: to,
            amountIn: amount, // amount going to buy tokens
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // Executes the swap.
        uniswapV3Router.exactInputSingle{value: amount}(params);
    }

    function buyTokenETH(address token, uint24 poolFee) public payable {
        _buyTokenETH(token, msg.value, msg.sender, poolFee);
    }
}
