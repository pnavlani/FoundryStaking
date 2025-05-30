// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
        StakingToken stakingToken;
        StakingApp stakingApp;

        //StakingToken Parameters
        string name_ = "StakingToken";
        string symbol_ = "STK";
        
        //StakingApp Parameters
        address owner_ = vm.addr(1); 
        uint256 stakingPeriod_ = 86400; 
        uint256 fixedStakingAmount_ = 10;
        uint256 rewardPerPeriod_ = 1 ether;  

        address randomUser = vm.addr(2);

        function setUp() external{ 
            stakingToken = new StakingToken(name_, symbol_);
            stakingApp = new StakingApp(address(stakingToken), owner_,  stakingPeriod_,  fixedStakingAmount_,  rewardPerPeriod_ );
        }

        function testStakingTokenCorrectlyDeployed() external view { 
            assert(address(stakingToken) != address(0)); 
        }

        function testStakingAppCorrectlyDeployed() external view { 
            assert(address(stakingApp) != address(0)); 
        }


        function testShouldRevertIfNotOwner() external{
            uint256 newStakingPeriod_ = 1;

            vm.expectRevert();
            stakingApp.changeStakingPeriod(newStakingPeriod_);
        }

           function testShouldChangeStakingPeriod() external{
            vm.startPrank(owner_);
            uint256 newStakingPeriod_ = 1;

           uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
            stakingApp.changeStakingPeriod(newStakingPeriod_);
            uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

            assert(stakingPeriodBefore != newStakingPeriod_);
            assert(stakingPeriodAfter == newStakingPeriod_);

            vm.stopPrank();
        }

        function testContractReceivesEtherCorrectly() external {
            vm.startPrank(owner_);
            vm.deal(owner_, 1 ether);
            uint256 etherValue = 1 ether;

           uint256 balanceBefore= address(stakingApp).balance;
            (bool success, )  = address(stakingApp).call{value: etherValue}("");
            uint256 balanceAfter = address(stakingApp).balance;
            require(success, "Tranfer Failed");

            assert(balanceAfter -  balanceBefore == etherValue);

            vm.stopPrank();

        }

        // Deposit function testing

        function testIncorrectAmountShouldRevert() external {
            vm.startPrank(randomUser);

            uint256 depositAmount = 1;
            vm.expectRevert("Incorrect Amount");
            stakingApp.depositTokens(depositAmount);

            vm.stopPrank();
        }


        function testDepositTokensCorrectly() external{
            vm.startPrank(randomUser);

            uint256 tokenAmount = stakingApp.fixedStakingAmount();
            stakingToken.mint(tokenAmount);
        
            uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            stakingApp.depositTokens(tokenAmount);
            uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

            assert(userBalanceAfter - userBalanceBefore == tokenAmount);
            assert(elapsePeriodBefore == 0);
            assert(elapsePeriodAfter == block.timestamp);
            vm.stopPrank();
        }

        function testUserCanNotDepositMoreThanOnce() external{
            vm.startPrank(randomUser);

            uint256 tokenAmount = stakingApp.fixedStakingAmount();
            stakingToken.mint(tokenAmount);
        
            uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            stakingApp.depositTokens(tokenAmount);
            uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

            assert(userBalanceAfter - userBalanceBefore == tokenAmount);
            assert(elapsePeriodBefore == 0);
            assert(elapsePeriodAfter == block.timestamp);

            stakingToken.mint(tokenAmount);

            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            vm.expectRevert();
            stakingApp.depositTokens(tokenAmount);
            

            vm.stopPrank();
        }


        // Withdraw function testing 

        function testCanOnlyWithdtraw0WithoutDeposit() external {
                vm.startPrank(randomUser);

                uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
                stakingApp.withdrawTokens();
                uint256 userBalanceAfter = stakingApp.userBalance(randomUser);


                assert(userBalanceAfter == userBalanceBefore);

                vm.stopPrank();
        }

        function testWithdrawTokensCorrectly() external{
                vm.startPrank(randomUser);

                uint256 tokenAmount = stakingApp.fixedStakingAmount();
                stakingToken.mint(tokenAmount);
            
                uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
                uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
                IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
                stakingApp.depositTokens(tokenAmount);
                uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
                uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

                assert(userBalanceAfter - userBalanceBefore == tokenAmount);
                assert(elapsePeriodBefore == 0);
                assert(elapsePeriodAfter == block.timestamp);

                
                uint256 userBalanceBefore2 = IERC20(stakingToken).balanceOf(randomUser);
                uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
                stakingApp.withdrawTokens();
                uint256 userBalanceAfter2 = IERC20(stakingToken).balanceOf(randomUser);

                assert(userBalanceAfter2 == userBalanceBefore2 + userBalanceInMapping );



                vm.stopPrank();
        }


        // Claim Rewards function tests

        function testCanNotClaimIfNotStaking() external {
            vm.startPrank(randomUser);


            vm.expectRevert(); // Expect Revert - "Not Staking"
            stakingApp.claimRewards();


            vm.stopPrank();
        }


        function testCanNotClaimIfNotElapsedTime() external{
            vm.startPrank(randomUser);

            uint256 tokenAmount = stakingApp.fixedStakingAmount();
            stakingToken.mint(tokenAmount);
        
            uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            stakingApp.depositTokens(tokenAmount);
            uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

            assert(userBalanceAfter - userBalanceBefore == tokenAmount);
            assert(elapsePeriodBefore == 0);
            assert(elapsePeriodAfter == block.timestamp);

            vm.expectRevert(); // Expect Revert - "Need to wait"
            stakingApp.claimRewards();

            vm.stopPrank();
        }


        function testShouldRevertIfNoEther() external{
            vm.startPrank(randomUser);

            uint256 tokenAmount = stakingApp.fixedStakingAmount();
            stakingToken.mint(tokenAmount);
        
            uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            stakingApp.depositTokens(tokenAmount);
            uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

            assert(userBalanceAfter - userBalanceBefore == tokenAmount);
            assert(elapsePeriodBefore == 0);
            assert(elapsePeriodAfter == block.timestamp);

            
            vm.warp(block.timestamp + stakingPeriod_); // Simulate that the time elapsed
            vm.expectRevert();  // Expect Revert - "Transfer failed"
            stakingApp.claimRewards();

            vm.stopPrank();
        }

        function testCanClaimRewardsCorrectly() external{
            vm.startPrank(randomUser);

            uint256 tokenAmount = stakingApp.fixedStakingAmount();
            stakingToken.mint(tokenAmount);
        
            uint256 userBalanceBefore= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
            IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
            stakingApp.depositTokens(tokenAmount);
            uint256 userBalanceAfter= stakingApp.userBalance(randomUser);
            uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

            assert(userBalanceAfter - userBalanceBefore == tokenAmount);
            assert(elapsePeriodBefore == 0);
            assert(elapsePeriodAfter == block.timestamp);
            vm.stopPrank();

            vm.startPrank(owner_);
            uint256 etherAmount = 100000 ether;
            vm.deal(owner_, etherAmount);
            (bool success, ) = address(stakingApp).call{value: etherAmount}("");
            require(success, "Test transfer failed");
            vm.stopPrank();

            vm.startPrank(randomUser);
            vm.warp(block.timestamp + stakingPeriod_); // Simulate that the time elapsed
            uint256 etherAmountBefore = address(randomUser).balance;
            stakingApp.claimRewards();
            uint256 etherAmountAfter = address(randomUser).balance;
            uint256 elapsedPeriod = stakingApp.elapsePeriod(randomUser);

            assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_ );
            assert(elapsedPeriod == block.timestamp);

            vm.stopPrank();

            
        }






}