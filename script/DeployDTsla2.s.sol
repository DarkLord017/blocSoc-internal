 //SPDX-License-Identifier:MIT
 pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {dTSLARedeem} from "../src/dTSLARedeem.sol";
import {dTSLARouter} from "../src/dTSLARouter.sol";
import {TslaPriceFeed} from "../src/TslaPriceFeed.sol";
import {console2} from "forge-std/Test.sol";

 contract DeployDTsla is Script {
    string constant alpacaMintSource = "./functions/sources/alpacaBalance.js";
    string constant alpacaRedeemSource = "./functions/sources/sell.js";
uint64 constant subId = 3124;
  dTSLARedeem dtslaredeem;
  dTSLARouter dtslarouter; 

function run() public {
string memory mintSource = vm.readFile(alpacaMintSource);
string memory redeemSource = vm.readFile(alpacaRedeemSource);
address router = 0x3dAD7C8B4a628a83236F684250BA58aE807EeE8b;
 vm.startBroadcast();
// dtslarouter = new dTSLARouter(msg.sender, subId, mintSource );
dtslaredeem = new dTSLARedeem(router, redeemSource, subId );
vm.stopBroadcast(); 
// console2.log("Deployed dTSLA contract at address: ", address(dtslarouter));
console2.log("Deployed dTSLA redeem contract at address: ", address(dtslaredeem));
}

}
