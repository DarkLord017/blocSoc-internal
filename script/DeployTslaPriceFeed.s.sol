//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {TslaPriceFeed} from "../src/TslaPriceFeed.sol";
import {Script} from "forge-std/Script.sol";

contract DeployTslaPriceFeed is Script {
    string constant priceFeedFile = "./functions/sources/tslaPrice.js";
    address constant functionsRouter =
        0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    uint64 constant subId = 3124;
    uint64 secretVersion = 1719379174;
    uint8 secretSlot = 0;
    bytes32 donId =
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    function run() external {
        string memory priceFeedSource = vm.readFile(priceFeedFile);

        vm.startBroadcast();
        new TslaPriceFeed(
            priceFeedSource,
            functionsRouter,
            subId,
            secretVersion,
            secretSlot,
            donId
        );
        vm.stopBroadcast();
    }
}
