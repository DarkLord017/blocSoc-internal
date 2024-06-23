//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {dTSLA} from "./dTSLA.sol";

contract dTSLARouter is ERC20 , dTSLA {

    function mint(uint256 amountOfTokenInUsdc) external {
      if( (getUsdcValueOfUsd(
            getCalculatedNewTotalValue(amountOfToken)
        ) * COLLATERAL_RATIO )/ COLLATERAL_PRECISION > amountOfTokenInUsdc){
            revert dTSLA_NotEnoughCollateral();
        }
        
        bool success = ERC20(SEPOILA_USDC).approve(address(this), amountOfTokenInUsdc); 
        if(!success){
            revert dTSLA_NotEnoughBalance();
        }
       bool succ =  ERC20(SEPOILA_USDC).transferFrom(msg.sender, address(this), amountOfTokenInUsdc);
         if(!succ){
              revert dTSLA_NotEnoughBalance();
        }
        sendMintRequest(amountOfTokenInUsdc , msg.sender);
    }
}
    