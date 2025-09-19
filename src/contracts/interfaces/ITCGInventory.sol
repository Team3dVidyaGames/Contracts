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
    NFT Triad contract
*/
/**
 * @author Team3d.R&D
 */
import "../../../lib/openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITCGInventory is IERC721 {
    function dataReturn(uint256 tokenId)
        external
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
        );

    function updateCardGameInformation(uint256 addWin, uint256 addPlayed, uint256 tokenId) external;

    function updateCardData(uint256 tokenId, uint8 top, uint8 left, uint8 right, uint8 bottom) external;

    function mint(uint256 templateId, address to) external returns (uint256);

    function templateExists(uint256 templateId) external returns (bool truth, uint8 level);

    function burn(uint256 tokenId) external;
}
