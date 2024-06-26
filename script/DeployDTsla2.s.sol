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
  // dTSLARouter dtslarouter; 

function run() public {
string memory mintSource = vm.readFile(alpacaMintSource);
string memory redeemSource = vm.readFile(alpacaRedeemSource);
address dtslarouter = 0x43Cbc6f4fDA0905F3E2E3050FF34EE177E4d0787;
 vm.startBroadcast();
// dtslarouter = new dTSLARouter(msg.sender, subId, mintSource );
dtslaredeem = new dTSLARedeem( dtslarouter, redeemSource, subId );
// dtslarouter.changeRedeemContractAddress(address(dtslaredeem));
vm.stopBroadcast(); 
// console2.log("Deployed dtsla router at contract address: " , address(dtslarouter));
console2.log("Deployed dTSLA redeem contract at address: ", address(dtslaredeem));


}
 }
