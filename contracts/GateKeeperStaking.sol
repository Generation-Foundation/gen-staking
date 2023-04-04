// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface GenStakingInterface {
    function getStakedAmount(address userAddress) external view returns (uint256);
}

contract Staking is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    // 10000 -> 100%, 498 -> 4.98%, 500 -> 5%, 
    // 400000 -> 4000%, 390715 -> 3907.15 %
    // 0 ~ 4294967296
    uint32 public apr = 390777;

    // Fever Staking을 위한 최소 GEN Staking 조건
    uint256 public minimumGenStaked = 100000000000000000000;

    // 전체 게이트키퍼의 스테이킹 총량
    uint256 public totalStaked;

    bool public stakingFlag;

    address public genStakingContractAddress;

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;

        stakingFlag = true;
    }

    // [주의] Fever Staking의 경우 GEN Staking 컨트랙트 주소를 입력해야 한다.
    function setGenStakingContractAddress(address contractAddress) onlyOwner public {
        genStakingContractAddress = contractAddress;
        emit GenStakingAddressUpdated(genStakingContractAddress);
    }

    function getStakingType() public view returns (string memory) {
        string memory result ;
        if (stakingToken == rewardToken) {
            result = "gen";
        } else {
            result = "fever";
        }
        return result;
    }

    function getStakedAmount(address userAddress) external view returns (uint256) {
        return staked[userAddress];
    }

    // 이 컨트랙트가 Fever Staking 컨트랙트라면 GEN Staking을 100 GEN 이상 하고 있는지 체크하기
    function isValidGateKeeper(address userAddress) internal view returns (bool) {
        uint256 stakedAmount = GenStakingInterface(genStakingContractAddress).getStakedAmount(userAddress);
        bool result = false;
        if (stakedAmount >= minimumGenStaked) {
            result = true;
        }
        return result;
    }

    modifier onlyGateKeeper() {
        // Fever Staking의 경우 GEN 스테이킹을 100개 이상 하고 있는지 체크
        if (stakingToken != rewardToken) {
            require(isValidGateKeeper(msg.sender), "You must stake a minimum of 100 GEN to GEN Staking Contract.");
        }
        _;
    }

    function stake(uint256 amount) onlyGateKeeper public {
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

    function unstake(uint256 amount) onlyGateKeeper public {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] = SafeMath.sub(staked[msg.sender], amount);
        totalStaked = SafeMath.sub(totalStaked, amount);
        stakingToken.safeTransfer(msg.sender, amount);

        emit Unstake(msg.sender, amount);
    }

    function claim() onlyGateKeeper public {
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
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewardsYear = staked[msg.sender] * secondsStaked / 3.154e7;
        uint256 tempReward = SafeMath.mul(rewardsYear, apr);
        uint256 rewards = SafeMath.div(tempReward, 10000);
        return rewards;
    }

    function setMinimumGenStaked(uint256 _minimumGenStaked) onlyOwner public {
        require(_minimumGenStaked >= 0, "Invalid minimumGenStaked(minimumGenStaked >= 0)");
        minimumGenStaked = _minimumGenStaked;
        emit AprUpdated(apr);
    }

    function setApr(uint32 _apr) onlyOwner public {
        require(_apr >= 0 && _apr <= 4294967296, "Invalid APR(_apr > 0 && _apr <= 4294967296, 10000 == 100%)");
        apr = _apr;
        emit AprUpdated(apr);
    }

    function setStakingFlag(bool _stakingFlag) onlyOwner public {
        stakingFlag = _stakingFlag;
        emit StakingFlagUpdated(stakingFlag);
    }

    function getStakingFlag() public view returns (bool) {
        return stakingFlag;
    }

    function recoverERC20(address token, uint256 amount) onlyOwner public {
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Recovered(token, amount);
    }

    function recoverETH() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    /* ========== EVENTS ========== */
    event Recovered(address token, uint256 amount);
    event StakingFlagUpdated(bool flag);
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event Claim(address indexed to, uint256 amount);
    event GenStakingAddressUpdated(address contractAddress);
    event AprUpdated(uint32 apr);
}
