
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Fallout.sol";

contract FalloutSolve is Script {
    Fallout public fallout = Fallout(0xf96C8C1685180b9551f86952992baAA220E7C91C);
    Vault public vault = fallout.vault();
    address player = vm.envAddress("PLAYER");


    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Fallout : ", address(fallout));
        console.log("Vault : ", address(vault));

        uint256 qx = fallout.Qx();
        uint256 qy = fallout.Qy();
        uint256  a = vault.a();
        uint256  b = vault.b();
        uint256  gx = vault.gx();
        uint256  gy = vault.gy();
        uint256  p = vault.p();
        uint256 n = 4007911249843509079694969957202343357280666055654537667969; // n = Ep.order()

        console.log("Qx = ", qx);
        console.log("Qy = ", qy);
        console.log("a = ", a);
        console.log("b = ", b);
        console.log("gx = ", gx);
        console.log("gy = ", gy);
        console.log("p = ", p);
        console.log("n = ", n);
        console.log("isSolved() : ", fallout.isSolved());
        
        bytes32 hash = keccak256(abi.encode(player, 1_000_000 ether));

        console.logBytes32(hash);

        uint256[2] memory rs = [uint256(2195097151127120065579326181785367043581509779126357541128), 928540552076520879873320608471470817377985074596666122262];
        fallout.mint(player, 1_000_000 ether, rs);
        console.log("isSolved() : ", fallout.isSolved());
        
    }


}