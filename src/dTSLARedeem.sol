//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {ConfirmedOwner} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {dTSLARouter} from "./dTSLARouter.sol";
import {Constants} from "./Constants.sol";

contract dTSLARedeem is ConfirmedOwner, FunctionsClient , Constants{
  dTSLARouter dtsla;
  ERC20 usdc;
  
    struct dTSLARequestRedeem {
        uint256 amountOfToken;
        address requester;
        MintOrRedeem mintOrRedeem;
    }

    enum MintOrRedeem {
        mint,
        redeem
    }

    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;

    mapping(bytes32 requestId => dTSLARequestRedeem request) private s_requestIdtoRequestRedeem;
   

   address immutable i_dTSLA_CONTRACT;
   uint64 immutable i_subId;

  
    string private s_redeemSourceCode;
    mapping (address => bool) private s_isRedeemActive;
    bytes32 private s_MostRecentRequestId;

 
    mapping(address => uint256) private s_userToWithdrawlAmount;
    constructor(
        address dTSLA_CONTRACT,
        string memory redeemSourceCode,
        uint64 subId
        
    )
        ConfirmedOwner(msg.sender)
        FunctionsClient(SEPOLIA_FUNCTION_ROUTER)
   
    {dtsla = dTSLARouter(dTSLA_CONTRACT);
    usdc = ERC20(SEPOILA_USDC);
       s_redeemSourceCode = redeemSourceCode;
       i_subId = subId;
        
    }

     function sendRedeemRequest(uint256 amountdTsla , address user) external {
        s_isRedeemActive[user] = true;
        uint256 amountUsdInTsla =   dtsla.getUsdValueOfTsla(amountdTsla);
        uint256 amountTslaInUsdc = dtsla.getUsdcValueOfUsd(
         amountUsdInTsla
        );
        if (amountdTsla < MINIMUM_WITHDRAWL_AMOUNT) {
            revert dTSLA_WithdrawlAmountTooLow();
        }
        FunctionsRequest.Request memory req;

        req.addDONHostedSecrets(donHostedSlotId, donHostedSecretsVersion);
        req.initializeRequestForInlineJavaScript(s_redeemSourceCode);

        string[] memory args = new string[](1);
        args[0] = amountdTsla.toString();
      
        req.setArgs(args);

        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            i_subId,
            GAS_LIMIT,
            DON_ID
        );

        s_requestIdtoRequestRedeem[requestId] = dTSLARequestRedeem(
            amountdTsla,
            user,
            MintOrRedeem.redeem
        );

        s_userToWithdrawlAmount[
           s_requestIdtoRequestRedeem[requestId].requester
        ] += amountTslaInUsdc;

        dtsla.burn(amountdTsla , user);
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory
    ) internal override {
        uint256 tslaAmountSold = uint256(bytes32(response));
        if (tslaAmountSold == 0) {
            uint256 amountofTslaBurned = s_requestIdtoRequestRedeem[requestId]
                .amountOfToken;
            dtsla.mint(amountofTslaBurned,
                s_requestIdtoRequestRedeem[requestId].requester
              
            );
            s_userToWithdrawlAmount[
            s_requestIdtoRequestRedeem[requestId].requester
        ] = 0;
            s_isRedeemActive[s_requestIdtoRequestRedeem[requestId].requester] = false;
            return;
        }

        s_isRedeemActive[s_requestIdtoRequestRedeem[requestId].requester] = false;

       
    }
    function withdraw(address user) public{
        require(s_isRedeemActive[user] == false, "Redeem is active");
       
        require(
            s_userToWithdrawlAmount[user] != 0,
            "No funds to withdraw"
        );
        uint256 amount = s_userToWithdrawlAmount[user];
        s_userToWithdrawlAmount[user] = 0;

       uint256 final_amount = amount / 1e12;
        
        dtsla.sendUsdcToUser(final_amount, user);
    }
    
    

     function getRedeemSourceCode() public view returns (string memory) {
        return s_redeemSourceCode;
    }

    function changedTSLA (address newAddress) external onlyOwner {
        dtsla = dTSLARouter(newAddress);
    }

    function changeRedeemSourceCode(string memory newSourceCode) external onlyOwner {
        s_redeemSourceCode = newSourceCode;
    }
    




}

