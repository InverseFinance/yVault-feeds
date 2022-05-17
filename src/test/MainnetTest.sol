// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
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

interface ICurvePool {
    function get_virtual_price() external view returns (uint256 price);
}

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
    function token() external view returns (address);
    function deposit(uint256) external returns (uint256);
}

interface IFeed {
    function decimals() external view returns (uint8);
    function latestAnswer() external view returns (uint);
    function vault() external returns (IYearnVault);
}

contract MainnetTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    //Price feeds
    YVCrvStETHFeed yvCrvStETHFeed;
    YVDAIFeed yvDaiFeed;
    YVCrvDolaFeed yvCrvDolaFeed;
    YVIronBankFeed yvIronBankFeed;
    YVUSDTFeed yvUSDTFeed;
    YVUSDCFeed yvUSDCFeed;
    YVWETHFeed yvWethFeed;
    YVYFIFeed yvYfiFeed;
    YVCVXETHFeed yvCvxETHFeed;

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

    function setUp() public {}

    function testReportedPrices() public {
        uint256 yvDAI = new YVDAIFeed().latestAnswer();
        uint256 yvUSDC = new YVUSDCFeed().latestAnswer();
        uint256 yvUSDT = new YVUSDTFeed().latestAnswer();
        uint256 yvCrvDOLA = new YVCrvDolaFeed().latestAnswer();
        uint256 yvYFI = new YVYFIFeed().latestAnswer();
        uint256 yvWETH = new YVWETHFeed().latestAnswer();
        uint256 yvIB = new YVIronBankFeed().latestAnswer();
        uint256 yvCrvStETH = new YVCrvStETHFeed().latestAnswer();
        uint256 yvCvxETH = new YVCVXETHFeed().latestAnswer();
        uint256 yvCrv3Crypto = new YVCrv3CryptoFeed().latestAnswer();

        uint256[10] memory prices = [yvDAI, yvUSDC, yvUSDT, yvCrvDOLA, yvYFI, yvWETH, yvIB, yvCrvStETH, yvCvxETH, yvCrv3Crypto];
        string[10] memory symbols = ["yvDAI", "yvUSDC", "yvUSDT", "yvCrvDOLA", "yvYFI", "yvWETH", "yvIB", "yvCrvStETH", "yvCvxETH", "yvCrv3Crypto"];
        
        for (uint i = 0; i < prices.length; i++) {
            emit log_named_uint(symbols[i], prices[i]);
            emit log_named_uint(string.concat(symbols[i], " $"), prices[i] / 1e18);
            emit log_string("\n");
        }
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

    //Give `_addr` crvDOLA LP tokens equal to `crvDolaBorrowAmount` + `crvDolaAirdropAmount`
    function distributeCrvDola(address _addr) public {
        bytes32 slot;

        assembly {
            mstore(0, 0x18)
            mstore(0x20, _addr)
            slot := keccak256(0, 0x40)
        }

        vm.store(CrvDola, slot, bytes32(crvDolaBorrowAmount + crvDolaAirdropAmount));
    }
}
