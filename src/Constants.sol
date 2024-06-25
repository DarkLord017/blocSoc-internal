//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

abstract contract Constants {
error dTSLA_NotEnoughCollateral();
error dTSLA_WithdrawlAmountTooLow();
error d_TSLA_WithdrawlFailed();
error  dTSLA_NotEnoughBalance();
error dTSLA_NoExcessColletralFound();

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
    address constant SEPOILA_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    uint8 donHostedSlotId = 0;
    uint64 donHostedSecretsVersion =  1719297129;
    bytes32 constant DON_ID =
        hex"66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000";
    uint32 constant GAS_LIMIT = 300_000;
        uint256 constant MINIMUM_WITHDRAWL_AMOUNT = 100e6;


}