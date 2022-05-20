// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";

import { IERC20 } from "../interfaces/IERC20.sol";
import { CToken } from "../interfaces/CToken.sol";
import { IOracle } from "../interfaces/IOracle.sol";
import { IComptroller } from "../interfaces/IComptroller.sol";
import { IUSDT } from "../interfaces/IUSDT.sol";
import { IFeed } from "../interfaces/IFeed.sol";
import { IYearnVault } from "../interfaces/IYearnVault.sol";
import { ICurvePool } from "../interfaces/ICurvePool.sol";

import { YVCrv3CryptoFeed } from "../YVCrv3CryptoFeed.sol";
import { YVCrvStETHFeed } from "../YVCrvStETHFeed.sol";
import { YVDAIFeed } from "../YVDAIFeed.sol";
import { YVUSDTFeed } from "../YVUSDTFeed.sol";
import { YVUSDCFeed } from "../YVUSDCFeed.sol";
import { YVCrvDolaFeed } from "../YVCrvDolaFeed.sol";
import { YVIronBankFeed } from "../YVIronBankFeed.sol";
import { YVWETHFeed } from "../YVWETHFeed.sol";
import { YVYFIFeed } from "../YVYFIFeed.sol";
import { YVCVXETHFeed } from "../YVCVXETHFeed.sol";

contract MainnetTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    // Pools
    address CrvDola = 0xAA5A67c256e27A5d80712c51971408db3370927D;
    address yvCrvDola = 0xd88dBBA3f9c4391Ee46f5FF548f289054db6E51C;
    ICurvePool DOLA3CRV = ICurvePool(0xAA5A67c256e27A5d80712c51971408db3370927D);

    // Attack parameters
    uint256 crvDolaBorrowAmount = 8_000_000 * 10**18;
    uint256 crvDolaAirdropAmount = 24_000_000 * 10**18;
    uint256 yvCrvDolaCollateralFactorPercent = 80;

    // EOA
    address user = address(0x69);

    // Anchor
    IComptroller unitroller =
        IComptroller(0x4dCf7407AE5C07f8681e1659f626E114A7667339);
    address governance =
        0x926dF14a23BE491164dCF93f4c468A50ef659D5B;
    address anchorOracle = 0xE8929AFd47064EfD36A7fB51dA3F8C5eb40c4cb4;

    // Tokens
    address daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address crvDolaAddr = 0xAA5A67c256e27A5d80712c51971408db3370927D;
    IUSDT USDT = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address crvIBAddr = 0x5282a4eF67D9C33135340fB3289cc1711c13638C;
    address crvCVXETHAddr = 0x3A283D9c08E8b55966afb64C515f5143cf907611;
    address yfiAddr = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address crvStETHAddr = 0x06325440D014e39736583c165C2963BA99fAf14E;

    // Token amounts
    uint256 amount6Decimals = 1_000_000 * 10**6;
    uint256 amount18Decimals = 1_000_000 * 10**18;

    uint256 lastCollateralValue;

    // New Markets
    IFeed yvUSDTFeed = IFeed(0xC2fbb8cbfD3Bd833BE6830d4fd3c9034393E08f8);
    CToken anYvUSDT =
        CToken(0x4597a4cf0501b853b029cE5688f6995f753efc04);

    IFeed yvUSDCFeed = IFeed(0xe7f605388022ca471d068783d2B2DBBE5e96e797);
    CToken anYvUSDC =
        CToken(0x7e18AB8d87F3430968f0755A623FB35017cB3EcA);

    IFeed yvDAIFeed = IFeed(0xD56AB624fF6EEE1A71B07F129d4C9Bf0970790E8);
    CToken anYvDAI =
        CToken(0xD79bCf0AD38E06BC0be56768939F57278C7c42f7);

    IFeed yvCrvDolaFeed = IFeed(0xAd456A380D6032F1D81a09D650406d16473d30C3);
    CToken anYvCrvDOLA =
        CToken(0x3cFd8f5539550cAa56dC901f09C69AC9438E0722);

    IFeed yvCrvIBFeed = IFeed(address(new YVIronBankFeed()));
    CToken anYvCrvIB = CToken(0x80AF8A32A868dA34e4201a90A5636852509672C8);

    IFeed yvWETHFeed = IFeed(address(new YVWETHFeed()));
    CToken anYvWETH = CToken(0xD924Fc65B448c7110650685464c8855dd62c30c0);

    IFeed yvYFIFeed = IFeed(address(new YVYFIFeed()));
    CToken anYvYFI = CToken(0xE809aD1577B7fF3D912B9f90Bf69F8BeCa5DCE32);

    IFeed yvCrvStETHFeed = IFeed(address(new YVCrvStETHFeed()));
    CToken anYvCrvStETH = CToken(0xDab427dDCb0f7F4be42EdedeA399258360a4133b);

    IFeed yvCVXETHFeed = IFeed(address(new YVCVXETHFeed()));
    CToken anYvCVXETH = CToken(0xa6F1a358f0C2e771a744AF5988618bc2E198d0A0);

    function setUp() public {}

    // function testReportedPrices() public {
    //     uint256 yvDAI = yvDAIFeed.latestAnswer();
    //     uint256 yvUSDC = yvUSDCFeed.latestAnswer();
    //     uint256 yvUSDT = yvUSDTFeed.latestAnswer();
    //     uint256 yvCrvDOLA = yvCrvDolaFeed.latestAnswer();
    //     uint256 yvYFI = new YVYFIFeed().latestAnswer();
    //     uint256 yvWETH = new YVWETHFeed().latestAnswer();
    //     uint256 yvIB = new YVIronBankFeed().latestAnswer();
    //     uint256 yvCrvStETH = new YVCrvStETHFeed().latestAnswer();
    //     uint256 yvCvxETH = new YVCVXETHFeed().latestAnswer();
    //     uint256 yvCrv3Crypto = new YVCrv3CryptoFeed().latestAnswer();

    //     uint256[10] memory prices = [yvDAI, yvUSDC, yvUSDT, yvCrvDOLA, yvYFI, yvWETH, yvIB, yvCrvStETH, yvCvxETH, yvCrv3Crypto];
    //     string[10] memory symbols = ["yvDAI", "yvUSDC", "yvUSDT", "yvCrvDOLA", "yvYFI", "yvWETH", "yvIB", "yvCrvStETH", "yvCvxETH", "yvCrv3Crypto"];
        
    //     for (uint i = 0; i < prices.length; i++) {
    //         emit log_named_uint(symbols[i], prices[i]);
    //         emit log_named_uint(string.concat(symbols[i], " $"), prices[i] / 1e18);
    //         emit log_string("\n");
    //     }
    // }

    function testIntegration() public {
        // Give `user` address 1 mill of each coin
        gibCoin(user);

        // Test new markets
        // THESE WORK
        //This one uses USDC address on purpose, need an address that won't fail an approve. can't use USDT since it doesn't follow standard ERC-20 interface
        feedTest(anYvUSDT, yvUSDTFeed, amount6Decimals, 6, usdcAddr, "anYvUSDT");
        feedTest(anYvUSDC, yvUSDCFeed, amount6Decimals, 6, usdcAddr, "anYvUSDC");
        feedTest(anYvDAI, yvDAIFeed, amount18Decimals, 18, daiAddr, "anYvDAI");
        feedTest(anYvCrvDOLA, yvCrvDolaFeed, amount18Decimals, 18, crvDolaAddr, "anYvCrvDOLA");
        feedTest(anYvWETH, yvWETHFeed, 500e18, 18, wethAddr, "anYvWETH");
        feedTest(anYvYFI, yvYFIFeed, 100e18, 18, yfiAddr, "anYvYFI");
        feedTest(anYvCVXETH, yvCVXETHFeed, 3400e18, 18, crvCVXETHAddr, "anYvCVXETH");
        
        // These don't work
        feedTest(anYvCrvIB, yvCrvIBFeed, 1e4, 18, crvIBAddr, "anYvCrvIB");
        feedTest(anYvCrvStETH, yvCrvStETHFeed, 1e18, 18, crvStETHAddr, "anYvCrvStETH");
    }

    function feedTest(
        CToken _cToken,
        IFeed _feed,
        uint256 _tokenAmount,
        uint256 _decimals,
        address _underlyingAddy,
        string memory _name
    ) public {
        // Add price feed to master oracle
        vm.startPrank(governance);
        IOracle(anchorOracle).setFeed(
            address(_cToken),
            address(_feed),
            uint8(_decimals)
        );

        // Sanity check
        require(_cToken.underlying() == _feed.vault(), "cToken's underlying and feed's vault do not match");

        // Add the market
        unitroller._supportMarket(_cToken);
        unitroller._setBorrowPaused(_cToken, true);
        unitroller._setCollateralFactor(_cToken, 0.8 * 10**18);

        // Mint yVault tokens
        vm.startPrank(user);
        USDT.approve(_feed.vault(), _tokenAmount);
        IERC20(_underlyingAddy).approve(_feed.vault(), _tokenAmount);
        IYearnVault(_feed.vault()).deposit(_tokenAmount);

        // Enter market
        address[] memory addrs = new address[](1);
        addrs[0] = address(_cToken);
        unitroller.enterMarkets(addrs);

        // Mint cTokens
        IYearnVault(_feed.vault()).approve(address(_cToken), _tokenAmount);
        _cToken.mint(IYearnVault(_feed.vault()).balanceOf(user));
        
        // Check account liquidity
        (, uint256 collateralValue,) = unitroller.getAccountLiquidity(user);
        uint256 newCollateralValue = collateralValue - lastCollateralValue;

        // Logging
        emit log_named_uint(_name, newCollateralValue);
        emit log_named_uint(string.concat(_name, " $") , newCollateralValue / 1e18);
        emit log_string("\n");

        // Setting this lets us easily get the collateral value of ONLY the asset being tested since state is persistent within the same test function
        lastCollateralValue = collateralValue;
    }

    //Assumes an attacker has no other way of getting vault shares EXCEPT by minting directly from the vault
    //Enabling borrowing on vault tokens would break this assumption and make the attack possible
    // function testAttackYvCrvDola() public {
    //     yvCrvDolaFeed = new YVCrvDolaFeed();
    //     uint256 startPrice = yvCrvDolaFeed.latestAnswer();

    //     // deposit `crvDolaBorrowAmount` crvDOLA LP tokens into yearn vault
    //     // this step is when the attacker receives the vault shares they will be borrowing against
    //     distributeCrvDola(user);
    //     vm.startPrank(user);
    //     IERC20(CrvDola).approve(yvCrvDola, type(uint256).max);
    //     IYearnVault(yvCrvDola).deposit(crvDolaBorrowAmount);

    //     emit log_named_uint("yvCrvDola pricePerShare after deposit", yvCrvDolaFeed.vault().pricePerShare());
    //     emit log_named_uint("yvCrvDola balance", IERC20(yvCrvDola).balanceOf(user));

    //     // Airdrop `crvDolaAirdropAmount` crvDOLA LP tokens to the yearn vault
    //     // `pricePerShare` increase is equal to (amount aidropped / vault total assets)
    //     // ex. crvDOLA has $3.5MM in assets, airdropping $3.5MM to the vault would increase `pricePerShare` 2x
    //     IERC20(CrvDola).transfer(yvCrvDola, crvDolaAirdropAmount);

    //     emit log_named_uint("yvCrvDola pricePerShare after attack", yvCrvDolaFeed.vault().pricePerShare());

    //     uint256 endPrice = yvCrvDolaFeed.latestAnswer();

    //     emit log_named_uint("feed price diff", endPrice - startPrice);
    //     emit log_named_uint("feed times price increase", (endPrice - startPrice)/startPrice);

    //     // Estimate collateral value of attacker's vault shares
    //     uint256 collateralValue = IERC20(yvCrvDola).balanceOf(user) * endPrice / 10**18 * yvCrvDolaCollateralFactorPercent / 100;
    //     uint256 attackCost = crvDolaBorrowAmount + crvDolaAirdropAmount;

    //     emit log_named_uint("attacker's collateral value $", collateralValue / 10**18);
    //     emit log_named_uint("cost of attack $", attackCost / 10**18);

    //     if (collateralValue > attackCost) {
    //         emit log_named_uint("attack profited $", (collateralValue - attackCost) / 10**18);
    //     } else {
    //         emit log_named_uint("attack lost $", (attackCost - collateralValue) / 10**18);
    //     }
    // }

    // Helper Functions

    function gibCoin(address _recipient) public {
        distributeCrvLPTokens(_recipient, crvDolaAddr, 0x18, amount18Decimals);
        distributeCrvLPTokens(_recipient, crvIBAddr, 0x2, amount18Decimals);
        distributeCrvLPTokens(_recipient, crvCVXETHAddr, 0x5, amount18Decimals);
        distributeCrvLPTokens(_recipient, crvStETHAddr, 0x2, amount18Decimals);
        distributeTokens(_recipient, daiAddr, 0x2, amount18Decimals);
        distributeTokens(_recipient, usdcAddr, 0x9, amount6Decimals);
        distributeTokens(_recipient, yfiAddr, 0x0, amount18Decimals);
        distributeTokens(_recipient, wethAddr, 0x3, amount18Decimals);
        distributeTokens(_recipient, address(USDT), 0x2, amount6Decimals);
    }

    // Vyper contracts access mappings the other way around. Couldn't find info anywhere but tried it and it works.
    function distributeCrvLPTokens(address _recipient, address _tokenAddress, uint256 _slot, uint256 _amount) public {
        bytes32 slot;

        assembly {
            mstore(0, _slot)
            mstore(0x20, _recipient)
            slot := keccak256(0, 0x40)
        }

        vm.store(_tokenAddress, slot, bytes32(_amount));
    }

    function distributeTokens(address _recipient, address _tokenAddress, uint256 _slot, uint256 _amount) public {
        bytes32 slot;

        assembly {
            mstore(0, _recipient)
            mstore(0x20, _slot)
            slot := keccak256(0, 0x40)
        }

        vm.store(_tokenAddress, slot, bytes32(_amount));
    }

    //Give `_addr` crvDOLA LP tokens equal to `crvDolaBorrowAmount` + `crvDolaAirdropAmount`
    function distributeCrvDola(address _addr) public {
        bytes32 slot;

        assembly {
            mstore(0, 0x18)
            mstore(0x20, _addr)
            slot := keccak256(0, 0x40)
        }

        vm.store(crvDolaAddr, slot, bytes32(crvDolaBorrowAmount + crvDolaAirdropAmount));
    }
}
