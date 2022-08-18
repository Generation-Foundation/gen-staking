pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Test {
    
    function calculateYieldTotal2() public view returns(uint256) {
        uint256 time = 3600 * 10**18;
        uint256 rate = 86400 * 7;
        uint256 timeRate = time / rate;

        uint256 userStakingBalance = 2;
        uint256 totalStaked = 3;
        

        // uint256 rawYield = epochTotalReward * ( stakingBalance[user] / totalStaked ) * timeRate / 10**18;
        // uint256 reverseShares = userStakingBalance * 10000 / totalStaked;
        // uint256 rawYield = epochTotalReward * shares * timeRate / 10**18;

        // 1000000000000000000 / 2000000000000000000


        // uint256 rawYield = epochTotalReward * ( stakingBalance[user] * 10**9 / totalStaked ) * timeRate / 10**18;
        uint256 rawYield = 1562500000000000000000000 * ( userStakingBalance * 10**18 / totalStaked ) * timeRate / 10**36;
        // 6200396825396824993799 603174603175000000
        // 6200 396825396824993799
        
        return rawYield;
    }

}