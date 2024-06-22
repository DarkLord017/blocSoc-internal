//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {ConfirmedOwner} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract dTSLA is ConfirmedOwner, FunctionsClient, ERC20 {
    error dTSLA_WithdrawlAmountTooLow();
    error d_TSLA_WithdrawlFailed();
    error dTSLA_NotEnoughCollateral();

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
    uint256 constant PRECISION = 1e18;
    uint256 constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 constant COLLATERAL_RATIO = 200;
    uint256 constant COLLATERAL_PRECISION = 100;
    address constant SEPOLIA_FUNCTION_ROUTER =
        0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    address constant SEPOLIA_TSLA_PRICE_FEED =
        0xc59E3633BAAC79493d908e63626716e204A45EdF;
    address constant USDC_USD_PRICE_FEED =
        0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    address constant SEPOILA_USDC = 0xf08A50178dfcDe18524640EA6618a1f965821715;
    uint8 donHostedSlotId = 0;
    uint64 donHostedSecretsVersion = 1718912260;
    bytes32 constant DON_ID =
        hex"66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000";
    uint32 constant GAS_LIMIT = 300_000;
    uint256 constant MINIMUM_WITHDRAWL_AMOUNT = 100e6;

    uint64 immutable i_subId;

    string private s_mintSourceCode;
    string private s_redeemSourceCode;
    uint256 private s_portfolioBalance;
    bytes32 private s_MostRecentRequestId;

    mapping(bytes32 requestId => dTSLARequest request)
        private s_requestIdtoRequest;
    mapping(address => uint256) private s_userToWithdrawlAmount;
    constructor(
        string memory mintSourceCode,
        uint64 subId,
        string memory redeemSourceCode
    )
        ConfirmedOwner(msg.sender)
        FunctionsClient(SEPOLIA_FUNCTION_ROUTER)
        ERC20("dTSLA", "dTSLA")
    {
        s_mintSourceCode = mintSourceCode;
        s_redeemSourceCode = redeemSourceCode;
        i_subId = subId;
    }
    ///Send an user a request to
    //1. See how much Tesla is bought
    //2. If enough Tesla is in alpaca account mint tesla
    ///mint TSLA
    //transaction function
    function sendMintRequest(uint256 amountOfToken) private {
        FunctionsRequest.Request memory req;

        req.addDONHostedSecrets(donHostedSlotId, donHostedSecretsVersion);
        req.initializeRequestForInlineJavaScript(s_mintSourceCode);

        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            i_subId,
            GAS_LIMIT,
            DON_ID
        );

        s_MostRecentRequestId = requestId;
        s_requestIdtoRequest[requestId] = dTSLARequest(
            amountOfToken,
            msg.sender,
            MintOrRedeem.mint
        );
    }

    

    function mint(uint256 amountOfToken) external {
       uint256 amountOfTokenInUsdc = (getUsdcValueOfUsd(
            getCalculatedNewTotalValue(amountOfToken)
        ) * COLLATERAL_RATIO )/ COLLATERAL_PRECISION;
        
        bool success = ERC20(SEPOILA_USDC).approve(address(this), amountOfTokenInUsdc); 
        if(!success){
            revert dTSLA_NotEnoughCollateral();
        }
       bool success =  ERC20(SEPOILA_USDC).transferFrom(msg.sender, address(this), amountOfTokenInUsdc);
         if(!success){
              revert dTSLA_NotEnoughCollateral();
        }
        sendMintRequest(amountOfToken);
    }

    function _mintFulfillRequest(
        bytes32 requestId,
        bytes memory response
    ) internal {
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

    //@notice Request to sell TSLA for USDC(redemptionToken)
    //This waill call the chainlink function alpaca
    //do this
    //1. Sell TSLA on brokergae
    //2. Buy USDC on brokerage
    //3. Send USDC to the contract for trhe user to withdraw
    function sendRedeemRequest(uint256 amountdTsla) external {
        uint256 amountTslaInUsdc = getUsdcValueOfUsd(
            getUsdValueOfTsla(amountdTsla)
        );
        if (amountTslaInUsdc < MINIMUM_WITHDRAWL_AMOUNT) {
            revert dTSLA_WithdrawlAmountTooLow();
        }
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_redeemSourceCode);

        string[] memory args = new string[](2);
        args[0] = amountdTsla.toString();
        args[1] = amountTslaInUsdc.toString();
        req.setArgs(args);

        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            i_subId,
            GAS_LIMIT,
            DON_ID
        );
        s_requestIdtoRequest[requestId] = dTSLARequest(
            amountdTsla,
            msg.sender,
            MintOrRedeem.redeem
        );

        _burn(msg.sender, amountdTsla);
    }

    function getUsdcValueOfUsd(
        uint256 Usdamount
    ) public view returns (uint256) {
        return ((Usdamount * getUsdPrice()) / PRECISION);
    }

    function _redeemFulfillRequest(
        bytes32 requestId,
        bytes memory response
    ) internal {
        uint256 usdcAmount = uint256(bytes32(response));
        if (usdcAmount == 0) {
            uint256 amountofTslaBurned = s_requestIdtoRequest[requestId]
                .amountOfToken;
            _mint(
                s_requestIdtoRequest[requestId].requester,
                amountofTslaBurned
            );
            return;
        }

        s_userToWithdrawlAmount[
            s_requestIdtoRequest[requestId].requester
        ] += usdcAmount;
    }

    function withdraw() external {
        require(
            s_userToWithdrawlAmount[msg.sender] != 0,
            "No funds to withdraw"
        );
        uint256 amount = s_userToWithdrawlAmount[msg.sender];
        s_userToWithdrawlAmount[msg.sender] = 0;

        bool success = ERC20(SEPOILA_USDC).transfer(msg.sender, amount);
        if (!success) {
            revert d_TSLA_WithdrawlFailed();
        }
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory
    ) internal override {
        //     if(s_requestIdtoRequest[requestId].mintOrRedeem == MintOrRedeem.mint){
        //         _mintFulfillRequest();
        // }else{
        //     _redeemFulfillRequest();
        // }
        s_portfolioBalance = uint256(bytes32(response));
    }

    function finishMint() external onlyOwner {
        uint256 amountOfTokensToMint = s_requestIdtoRequest[
            s_MostRecentRequestId
        ].amountOfToken;
        _mint(
            s_requestIdtoRequest[s_MostRecentRequestId].requester,
            amountOfTokensToMint
        );
    }

    function _collateralRatioAdjustedTotalBalance(
        uint256 amountOfTokensToMint
    ) internal view returns (uint256) {
        uint256 calculatedTotalValue = getCalculatedNewTotalValue(
            amountOfTokensToMint
        );
        return (calculatedTotalValue * COLLATERAL_RATIO) / COLLATERAL_PRECISION;
    }

    function getCalculatedNewTotalValue(
        uint256 amountOfTokensToMint
    ) internal view returns (uint256) {
        return
            ((totalSupply() + amountOfTokensToMint) * getTslaPrice()) /
            PRECISION;
    }

    function getTslaPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            SEPOLIA_TSLA_PRICE_FEED
        );
        (, int price, , , ) = priceFeed.latestRoundData();
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

    function getRedeemSourceCode() public view returns (string memory) {
        return s_redeemSourceCode;
    }
}
