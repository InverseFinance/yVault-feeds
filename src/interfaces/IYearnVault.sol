// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
    function token() external view returns (address);
    function deposit(uint256) external returns (uint256);
    function balanceOf(address) external returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
}