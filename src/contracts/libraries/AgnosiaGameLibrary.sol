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
    TCG 
    
    @author Team3d.R&D
 */

library AgnosiaGameLibrary {
    function sumFind(uint8[4] memory sum) internal pure returns (uint8[4] memory a, bool truth) {
        if (sum[0] > 0) {
            if (sum[0] == sum[1]) {
                a[0] = 1;
                truth = true;
            }
            if (sum[0] == sum[2]) {
                a[0] = 2;
                truth = true;
            }
            if (sum[0] == sum[3]) {
                a[0] = 3;
                truth = true;
            }
        }
        if (sum[1] > 0) {
            if (sum[1] == sum[2]) {
                a[1] = 2;
                truth = true;
            }
            if (sum[1] == sum[3]) {
                a[1] = 3;
                truth = true;
            }
        }
        if (sum[2] > 0) {
            if (sum[2] == sum[3]) {
                a[2] = 3;
                truth = true;
            }
        }
    }

    function cardsToCollect(uint256 tradeRule, uint8 winnerPoints, uint8 otherPoints) internal pure returns (uint8) {
        if (winnerPoints == otherPoints) {
            return 0;
        }
        if (tradeRule == 0) {
            return 1;
        }
        if (tradeRule == 1) {
            uint8 a = winnerPoints - otherPoints;
            if (a > 5) {
                a = 5;
            }
            return a;
        }
        if (tradeRule == 3) {
            return 5;
        }

        return 0;
    }
}
