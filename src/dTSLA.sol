//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {ConfirmedOwner} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Constants} from "./Constants.sol";
import {TslaPriceFeed} from "./TslaPriceFeed.sol";

contract dTSLA is ConfirmedOwner, FunctionsClient, ERC20 , Constants {
    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;
      enum MintOrRedeem {
        mint,
        redeem
    }

    struct dTSLARequest {
        uint256 amountOfToken;
        address requester;
        MintOrRedeem mintOrRedeem;
    }
    
  

    uint64 immutable i_subId;

    string private s_mintSourceCode;
 
    uint256 private s_portfolioBalance;
  

    mapping(bytes32 requestId => dTSLARequest request)
        private s_requestIdtoRequest;
 
    constructor(
        string memory mintSourceCode,
        uint64 subId
    )
        ConfirmedOwner(msg.sender)
        FunctionsClient(SEPOLIA_FUNCTION_ROUTER)
        ERC20("dTSLA", "dTSLA")
    {
       
        s_mintSourceCode = mintSourceCode;
        i_subId = subId;
    }
    ///Send an user a request to
    //1. See how much Tesla is bought
    //2. If enough Tesla is in alpaca account mint tesla
    ///mint TSLA
    //transaction function
    function sendMintRequest(uint256 amountOfToken , address user) internal {
        FunctionsRequest.Request memory req;

        req.addDONHostedSecrets(donHostedSlotId, donHostedSecretsVersion);
        req.initializeRequestForInlineJavaScript(s_mintSourceCode);

        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            i_subId,
            GAS_LIMIT,
            DON_ID
        );

       
        s_requestIdtoRequest[requestId] = dTSLARequest(
            amountOfToken,
            user,
            MintOrRedeem.mint
        );
    }



    //@notice Request to sell TSLA for USDC(redemptionToken)
    //This waill call the chainlink function alpaca
    //do this
    //1. Sell TSLA on brokergae
    //2. Buy USDC on brokerage
    //3. Send USDC to the contract for trhe user to withdraw
    
    function getUsdcValueOfUsd(
        uint256 Usdamount
    ) public view returns (uint256) {
        return ((Usdamount * getUsdPrice()) / PRECISION);
    }

    

   

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory
    ) internal virtual override {
       uint256 amountOfTokensToMint = s_requestIdtoRequest[requestId]
            .amountOfToken;
        s_portfolioBalance = uint256(bytes32(response));

        if (
            _collateralRatioAdjustedTotalBalance(amountOfTokensToMint) >
            s_portfolioBalance
        ) {
            revert dTSLA_NotEnoughCollateral();
        }

        if (amountOfTokensToMint != 0) {
            _mint(
                s_requestIdtoRequest[requestId].requester,
                amountOfTokensToMint
            );
        }
    }

    

    function _collateralRatioAdjustedTotalBalance(
        uint256 amountOfTokensToMint
    ) internal  view returns (uint256) {
        uint256 calculatedTotalValue = getCalculatedNewTotalValue(
            amountOfTokensToMint
        );
        return (calculatedTotalValue * COLLATERAL_RATIO) / COLLATERAL_PRECISION;
    }

    function getCalculatedNewTotalValue(
        uint256 amountOfTokensToMint
    ) public view returns (uint256) {
        return
            ((totalSupply() + amountOfTokensToMint) * getTslaPrice()) /
            PRECISION;
    }

    function getTslaPrice() public view returns (uint256) {
       TslaPriceFeed tsla = TslaPriceFeed(
            SEPOLIA_TSLA_PRICE_FEED
        );
        (, int price, , , ) = tsla.latestRoundData();
        return uint256(price) * ADDITIONAL_FEED_PRECISION;
    }

    function getUsdPrice() public view returns (uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(
            USDC_USD_PRICE_FEED
        );
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * ADDITIONAL_FEED_PRECISION;
    }

    function getUsdValueOfTsla(
        uint256 tslaAmount
    ) public view returns (uint256) {
        return (tslaAmount * getTslaPrice()) / PRECISION;
    }

    

    // function getRequest(
    //     uint256 requestId
    // ) public view returns (dTSLARequest memory) {
    //     return s_requestIdtoRequest[requestId];
    // }

    function getPortfolioBalance() public view returns (uint256) {
        return s_portfolioBalance;
    }

    function getMintSourceCode() public view returns (string memory) {
        return s_mintSourceCode;
    }

      function changeMintSourceCode(string memory newSourceCode) external onlyOwner {
        s_mintSourceCode = newSourceCode;
    }

    
   
}
