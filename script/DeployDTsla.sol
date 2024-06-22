//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {dTSLA} from "../src/dTSLA.sol";

import {console2} from "forge-std/Test.sol";

contract DeployDTsla is Script {
    string constant alpacaMintSource = "./functions/sources/alpacaBalance.js";
    string constant alpacaRedeemSource = "";
    uint64 constant subId = 3124;
    dTSLA dtsla;
    function run() public {
        string memory mintSource = vm.readFile(alpacaMintSource);
        vm.startBroadcast();
        dtsla = new dTSLA(mintSource, subId, alpacaRedeemSource);
        vm.stopBroadcast();
        console2.log("Deployed dTSLA contract at address: ", address(dtsla));
    }
}
