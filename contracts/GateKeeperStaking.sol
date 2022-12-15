// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GateKeeperStaking is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    // 5% -> 500:10000
    uint256 public apr = 500;

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        
        stakingToken.transferFrom(msg.sender, address(this), amount);

        if (staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] -= amount;

        stakingToken.safeTransfer(msg.sender, amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewardsYear = staked[msg.sender] * secondsStaked / 3.154e7;
        // 이자 상수가 3.154e7(3.154e7 = seven decimals = 31,540,000) 일 때 1년 간 스테이킹 APR이 100% 이다.
        uint256 tempReward = SafeMath.mul(rewardsYear, apr);
        uint256 rewards = SafeMath.div(tempReward, 10000);
        
        stakedFromTS[msg.sender] = block.timestamp;

        rewardToken.safeTransfer(msg.sender, rewards);
    }

    function estimateReward() public view returns (uint256) {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewardsYear = staked[msg.sender] * secondsStaked / 3.154e7;
        uint256 tempReward = SafeMath.mul(rewardsYear, apr);
        uint256 rewards = SafeMath.div(tempReward, 10000);
        return rewards;
    }

    function setApr(uint256 _apr) public onlyOwner {
        require(_apr > 0 && _apr <= 10000, "Invalid APR(_apr > 0 && _apr <= 10000, 10000 == 100%)");
        apr = _apr;
    }

    function recoverERC20(address token, uint amount) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Recovered(token, amount);
    }

    function recoverETH() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /* ========== EVENTS ========== */
    event Recovered(address token, uint256 amount);
    // TODO: Stake, Unstake, Claim
}