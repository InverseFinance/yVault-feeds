// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;

interface IUSDT {
    function approve(address _spender, uint256 _value) external;
    function balanceOf(address who) external view returns (uint256);
}