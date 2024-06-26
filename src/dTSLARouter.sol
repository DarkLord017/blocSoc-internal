//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {dTSLA} from "./dTSLA.sol";
import {Constants} from "./Constants.sol";
import {dTSLARedeem} from "./dTSLARedeem.sol";
contract dTSLARouter is Constants , dTSLA{
   
  dTSLARedeem dtslaRedeem;
 
    
    

    constructor( address dTSLA_REDEEM_CONTRACT , uint64 subID , string memory mintSourceCode ) dTSLA(mintSourceCode , subID ){
        
       
      
        dtslaRedeem = dTSLARedeem(dTSLA_REDEEM_CONTRACT);
    }

    modifier OnlyRedeem {
        require(msg.sender == address(dtslaRedeem) , "Only Redeem can call this function");
        _;
    }

    function mint(uint256 amountToMint , uint256 amountOfTokenInUsdc) external {
      
      if(((getUsdcValueOfUsd(
            getCalculatedNewTotalValue(amountToMint))*NETWORK_FEE)/NETWORK_FEE_PRECISION)
        > (amountOfTokenInUsdc*1e12)){
            revert dTSLA_NotEnoughCollateral();
        }
        
       bool succ =  ERC20(SEPOILA_USDC).transferFrom(msg.sender, address(this), amountOfTokenInUsdc);
         if(!succ){
              revert dTSLA_NotEnoughBalance();
        }
     
        sendMintRequest(amountToMint , msg.sender);
    }

    function redeem (uint256 amountToRedeem) external {
        dtslaRedeem.sendRedeemRequest(amountToRedeem , msg.sender);
    }

    function withdraw () external {
        dtslaRedeem.withdraw(msg.sender);
    }

    function sendUsdcToUser(uint256 amountUsdc , address user) external OnlyRedeem {
       bool success =  ERC20(SEPOILA_USDC).transfer(user , amountUsdc);
         if(!success){
              revert d_TSLA_WithdrawlFailed();
         }
    }

    function getCollateralforRWATsla(uint256 amountUsdc) public onlyOwner {
         if (
            _collateralRatioAdjustedTotalBalance(0) <
            getPortfolioBalance()
        ) {
            revert ("Enough collateral avalible");
        }

       ERC20(SEPOILA_USDC).transfer(msg.sender , amountUsdc);
    }

    function mint(uint256 amountOfToken , address user) external OnlyRedeem {
        _mint(user , amountOfToken);

    }

    function burn(uint256 amount , address user) external OnlyRedeem {
        _burn(user , amount);
    }

    function changeRedeemContractAddress(address newAddress) external onlyOwner {
        dtslaRedeem = dTSLARedeem(newAddress);
    }

    function changeDonHostedSecretsVersion(uint64 newVersion) external onlyOwner {
        donHostedSecretsVersion = newVersion;
    }

  

}
    