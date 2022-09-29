pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GenStaking {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public rewardBalance;
    // stGen unstake pending 기록
    // endTime 은 unstake 한 시점에 기록하고 가장 마지막 unstake 를 기록한다.
    // 예를 들어, A유저가 10 stGEN을 unstake 하고 하루 뒤에 10 stGEN 을 unstake 했다면 110 stGEN은 10 stGEN을 unstake한 시점으로부터 7일 뒤에 출금할 수 있다.
    mapping(address => bool) public isPending;
    mapping(address => uint256) public endTime;
    mapping(address => uint256) public stGenPendingBalance;

    address[] public addressLUT;

    function size() public view returns (uint256) {
        return addressLUT.length;
    }

    string public name = "Gen Staking";

    uint256 public epochTotalReward;

    IERC20 public stGenToken;
    IERC20 public genToken;

    address public manager;

    bool public feverStakingFlag;

    constructor(
        IERC20 _stGenToken,
        IERC20 _genToken
        ) {
            stGenToken = _stGenToken;
            genToken = _genToken;

            manager = msg.sender;

            feverStakingFlag = true;
        }

    function version() public pure returns (string memory) {
        return "0.1.0";
    }

    // modifier to check if caller is manager
    modifier isManager() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == manager, "Caller is not manager");
        _;
    }
    
    function changeManager(address _newManager) public isManager {
        emit ManagerSet(manager, _newManager);
        manager = _newManager;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    receive() external payable {}

    function setEpochTotalReward (uint256 _amount) public isManager {
        epochTotalReward = _amount;
        emit EpochUpdated(_amount);
    }

    function getEpochTotalReward() public view returns (uint256) {
        return epochTotalReward;
    }

    function setFeverStakingFlag (bool _feverStakingFlag) public isManager {
        feverStakingFlag = _feverStakingFlag;
        emit FeverStakingFlagUpdated(_feverStakingFlag);
    }

    function getFeverStakingFlag() public view returns (bool) {
        return feverStakingFlag;
    }

    function stake(uint256 amount) public {
        // feverStakingFlag
        require(feverStakingFlag, "Fever staking is off.");

        require(
            amount > 0 &&
            stGenToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            // rewardBalance[msg.sender] += toTransfer;
            rewardBalance[msg.sender] = SafeMath.add(rewardBalance[msg.sender], toTransfer);
        } else {
            addressLUT.push(msg.sender);
        }

        stGenToken.transferFrom(msg.sender, address(this), amount);
        // stakingBalance[msg.sender] += amount;
        stakingBalance[msg.sender] = SafeMath.add(stakingBalance[msg.sender], amount);

        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);

        calculateAllRewardBalance();
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "Invalid amount");

        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );

        uint256 yieldTransfer = calculateYieldTotal(msg.sender);

        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        // stakingBalance[msg.sender] -= balTransfer;
        stakingBalance[msg.sender] = SafeMath.sub(stakingBalance[msg.sender], balTransfer);
        // stGenToken.transfer(msg.sender, balTransfer);

        // TODO: stGenToken transfer는 7일간 pending 상태였다가 7일 후에 처리되어야함
        isPending[msg.sender] = true;
        endTime[msg.sender] = block.timestamp + 86400 * 7;
        // stGenPendingBalance[msg.sender] = balTransfer;
        stGenPendingBalance[msg.sender] = SafeMath.add(stGenPendingBalance[msg.sender], balTransfer);
        
        // unstake 할 때 rewardBalance 에 지금까지 유저가 모아둔 reward를 정리해서 입력해야 unstake 이후 claim 할 때 그 리워드 출금이 가능...
        // rewardBalance[msg.sender] += yieldTransfer;
        rewardBalance[msg.sender] = SafeMath.add(rewardBalance[msg.sender], yieldTransfer);
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
            // TODO: addressLUT.pop(msg.sender); 필요
        }
        emit Unstake(msg.sender, balTransfer);

        calculateAllRewardBalance();
    }

    function withdrawUnstaking() public {
        require(
                isPending[msg.sender] = true &&
                stGenPendingBalance[msg.sender] > 0, 
                "Nothing to withdraw"
            );

        uint256 current = block.timestamp;
        require(endTime[msg.sender] != 0, "Unstaking pending period is 7 days.");
        require(SafeMath.sub(current, endTime[msg.sender]) >= 86400 * 7, "Unstaking pending period is 7 days.");
        
        uint256 pendingTransfer = stGenPendingBalance[msg.sender];
        stGenPendingBalance[msg.sender] = 0;
        isPending[msg.sender] = false;
        endTime[msg.sender] = 0;
        
        stGenToken.transfer(msg.sender, pendingTransfer);

        emit Withdraw(msg.sender, pendingTransfer);
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        // uint256 totalTime = end - startTime[user];
        uint256 totalTime = SafeMath.sub(end, startTime[user]);
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400 * 7;
        // uint256 timeRate = time / rate;
        uint256 timeRate = SafeMath.div(time, rate);
        
        // 리워드 계산(현재 epoch 에 할당된 총 리워드에서 (유저 staked)/(총 staked) 로 비율 계산한다(Epoch는 7일 단위).
        uint256 totalStaked = stGenToken.balanceOf(address(this));

        // uint256 rawYield = epochTotalReward * ( stakingBalance[user] * 10**18 / totalStaked ) * timeRate / 10**36;
        uint256 rateForStaking = SafeMath.div(stakingBalance[user] * 10**18, totalStaked);
        uint256 rewardShare = SafeMath.mul(epochTotalReward, rateForStaking);
        uint256 rawYield = SafeMath.mul(rewardShare, timeRate) / 10**36;

        return rawYield;
    }

    function calculateAllRewardBalance() public {
        // save gas price
        address[] memory k = addressLUT;
        for (uint i = 0; i < size(); i++) {
            address user = k[i];
            if (isStaking[user] == true) {
                uint256 toTransfer = calculateYieldTotal(user);
                // rewardBalance[user] += toTransfer;
                rewardBalance[user] = SafeMath.add(rewardBalance[user], toTransfer);
                startTime[user] = block.timestamp;
            }
        }
    }

    function getMyRewards(address user) public view returns(uint256) {
        uint256 toTransfer = calculateYieldTotal(user);
        uint256 oldBalance = rewardBalance[user];
        // toTransfer += oldBalance;
        toTransfer = SafeMath.add(toTransfer, oldBalance);
        return toTransfer;
    }

    function claimYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 ||
            rewardBalance[msg.sender] > 0,
            "Nothing to claim"
            );
            
        if(rewardBalance[msg.sender] != 0){
            uint256 oldBalance = rewardBalance[msg.sender];
            rewardBalance[msg.sender] = 0;
            // toTransfer += oldBalance;
            toTransfer = SafeMath.add(toTransfer, oldBalance);
        }

        startTime[msg.sender] = block.timestamp;
        genToken.safeTransfer(msg.sender, toTransfer);
        emit YieldClaim(msg.sender, toTransfer);
    }

    function getRemainedReward() public view returns (uint256) {
        uint balance = genToken.balanceOf(address(this));
        return balance;
    }

    function getTotalStaked() public view returns (uint256) {
        uint256 totalStaked = stGenToken.balanceOf(address(this));
        return totalStaked;
    }

    function recoverERC20(address token, uint amount) public isManager {
        require(token != address(stGenToken), "Cannot withdraw the staking token");
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Recovered(token, amount);
    }

    function withdrawETH() public isManager {
        payable(msg.sender).transfer(address(this).balance);
    }

    /* ========== EVENTS ========== */
    event ManagerSet(address indexed oldManager, address indexed newManager);
    event EpochUpdated(uint256 reward);
    event FeverStakingFlagUpdated(bool flag);
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldClaim(address indexed to, uint256 amount);
    event Recovered(address token, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
}