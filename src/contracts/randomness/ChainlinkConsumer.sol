// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import {VRFConsumerBaseV2Plus} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../../../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract ChainlinkConsumer is VRFConsumerBaseV2Plus {
    constructor(
        address vrfCoordinator,
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(vrfCoordinator, subscriptionId) {}

    function requestRandomWords() public {
        VRFV2PlusClient.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit
        );
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
    ) internal override {
        randomResult = randomWords[0];
    }
}
