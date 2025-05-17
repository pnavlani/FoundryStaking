
//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

// Staking fixed amount


contract StakingApp is Ownable{

    // Variables
    address public stakingToken;
    uint256 public stakingPeriod;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    
    
    constructor(address stakingToken_ ,  address owner_, uint256 stakingPeriod_)  Ownable(owner_){
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;

    }

    // Functions 

    // External functions 

    // Internal functions 

    // Staking reward period
    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    
    


}