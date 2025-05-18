
//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Staking fixed amount


contract StakingApp is Ownable{

    // Variables
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    mapping (address => uint256) public userBalance;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    
    
    constructor(address stakingToken_ ,  address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_)  Ownable(owner_){
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;

    }

    // Functions 

    // External functions
    
    // 1. Deposit 
    function depositTokens(uint256 tokenAmountToDeposit_) external {
        require(tokenAmountToDeposit_ == fixedStakingAmount, "Incorrect Amount");
        require (userBalance[msg.sender] == 0, "User already deposited");
        IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmountToDeposit_);
        userBalance[msg.sender] += tokenAmountToDeposit_;

        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }
    // 2. Withdraw
    function withdrawTokens() external {
        
        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, 10);
        
    }

    // 3. Claim rewards

    // Internal functions 

    // Staking reward period
    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    
    


}