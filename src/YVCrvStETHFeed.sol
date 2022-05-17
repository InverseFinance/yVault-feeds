// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interfaces/IERC20.sol";

interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

interface ICurvePool {
    function get_virtual_price() external view returns (uint256 price);
}

interface IFeed {
    function decimals() external view returns (uint8);
    function latestAnswer() external view returns (uint);
}

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
}

contract YVCrvStETHFeed is IFeed {
    ICurvePool public constant CRVSTETH = ICurvePool(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    IYearnVault public constant vault = IYearnVault(0xdCD90C7f6324cfa40d7169ef80b12031770B4325);
    IAggregator public constant ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    function latestAnswer() public view returns (uint256) {
        return (CRVSTETH.get_virtual_price() * uint256(ETH.latestAnswer()) * vault.pricePerShare()) / 1e26;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
}