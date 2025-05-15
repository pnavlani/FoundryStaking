// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract StakingTokenTest is Test {

    StakingToken stakingToken;
    string name_ = "StakingToken";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);
    function setUp() public{
        stakingToken = new StakingToken(name_,  symbol_);
    }

    function testStakingTokenMintsCorrectly() public {
        vm.startPrank(randomUser);
        uint256 amount_ = 1 ether ; // 1 ether = 10^18

        // Token Balance previous
        uint256 balanceBefore_ =  IERC20(address(stakingToken)).balanceOf(randomUser); // UserA = 50 tokens
        stakingToken.mint(amount_); //Mint 1 token

        // Token Balance After
        uint256 balanceAfter_ = IERC20(address(stakingToken)).balanceOf(randomUser); // UserA = 51 tokens

        assert(balanceAfter_ - balanceBefore_ == amount_); // 51 tokens - 50 tokens = 1 token ? 

        vm.stopPrank();
    }
}