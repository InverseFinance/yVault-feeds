// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

contract YVWETHFeed is IFeed {
    IYearnVault public constant vault = IYearnVault(0xa9fE4601811213c340e850ea305481afF02f5b28);
    IAggregator public constant ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    function latestAnswer() public view returns (uint256) {
        uint256 yvWethPrice = uint256(ETH.latestAnswer()) * vault.pricePerShare();

        return yvWethPrice / 1e8;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
}