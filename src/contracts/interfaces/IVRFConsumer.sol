// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

interface IVRFConsumer {
    function getRandomness(uint256) external view returns (uint256[] memory);

    function requestRandomness(uint32 numWords) external payable returns (uint256);

    function getRandomnessPosition(uint256[] memory randomnessPosition) external payable returns (uint256[] memory);
}
