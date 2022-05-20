// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;

import "./CToken.sol";

interface IComptroller {
    function _supportMarket(CToken cToken) external returns (uint256);
    function _setBorrowPaused(CToken cToken, bool state) external returns (bool);
    function _setCollateralFactor(CToken cToken, uint256 newCollateralFactorMantissa) external returns (uint256);
    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);
    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);
}