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

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    // 500 -> 5%, 10000 -> 100%
    uint16 public apr = 500;

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;

    // 전체 게이트키퍼의 스테이킹 총량
    uint256 public totalStaked;

    bool public stakingFlag;

    // withdraw 용(유저 주소, amount, timestamp)
    // token 은 stakingToken 으로 고정
    struct WithdrawToken {
        address userAccount;
        uint256 amount;
        uint256 timestamp;
        bool completed;
    }

    WithdrawToken[] withdrawList;

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;

        stakingFlag = true;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "amount is < 0");

        stakingToken.transferFrom(msg.sender, address(this), amount);

        if (staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] = SafeMath.add(staked[msg.sender], amount);
        totalStaked = SafeMath.add(totalStaked, amount);
        
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] = SafeMath.sub(staked[msg.sender], amount);
        totalStaked = SafeMath.sub(totalStaked, amount);
        // stakingToken.safeTransfer(msg.sender, amount);

        // 7d delay 작업 필요
        // 1) unstake와 withdraw 분리. unstake
        // 2) unstake 하면 withdrawMap 에 유저 주소, amount, timestamp 를 push

        withdrawList.push(WithdrawToken(msg.sender, amount, block.timestamp, false));
        
        emit Unstake(msg.sender, amount);
    }

    // 
    function withdraw(uint256 idx) public {
        require(!withdrawList[idx].completed, "completed must be false.");

        uint256 current = block.timestamp;
        require(withdrawList[idx].timestamp > 0, "Invalid withdrawList[idx].timestamp");
        // Unstaking 기간: 7일
        require(SafeMath.sub(current, withdrawList[idx].timestamp) >= SECONDS_PER_DAY * 7, "Unstaking pending period is 7 days.");

        withdrawList[idx].completed = true;
        stakingToken.safeTransfer(withdrawList[idx].userAccount, withdrawList[idx].amount);

        emit Withdraw(withdrawList[idx].userAccount, withdrawList[idx].amount);
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

        emit Claim(msg.sender, rewards);
    }

    function estimateReward() public view returns (uint256) {
        // require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewardsYear = staked[msg.sender] * secondsStaked / 3.154e7;
        uint256 tempReward = SafeMath.mul(rewardsYear, apr);
        uint256 rewards = SafeMath.div(tempReward, 10000);
        return rewards;
    }

    function setApr(uint16 _apr) public onlyOwner {
        require(_apr > 0 && _apr <= 10000, "Invalid APR(_apr > 0 && _apr <= 10000, 10000 == 100%)");
        apr = _apr;
    }

    function setStakingFlag (bool _stakingFlag) public onlyOwner {
        stakingFlag = _stakingFlag;
        emit StakingFlagUpdated(stakingFlag);
    }

    function getStakingFlag() public view returns (bool) {
        return stakingFlag;
    }

    function recoverERC20(address token, uint256 amount) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Recovered(token, amount);
    }

    function recoverETH() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /* ========== EVENTS ========== */
    event Recovered(address token, uint256 amount);
    event StakingFlagUpdated(bool flag);
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);
    event Claim(address indexed to, uint256 amount);
}