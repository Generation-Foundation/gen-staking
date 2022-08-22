pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GenStaking {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public rewardBalance;

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

    // TODO: safemath로 바꾸기   
    // addResult = SafeMath.add(a,b);
    // subResult = SafeMath.sub(a,b);
    // mulResult = SafeMath.mul(a,b);
    // divResult = SafeMath.div(a,b);
    // modResult = SafeMath.mod(a,b);

    function version() public pure returns (string memory) {
        return "0.0.2";
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
    
    function changeManager(address newManager) public isManager {
        emit ManagerSet(manager, newManager);
        manager = newManager;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    receive() external payable {}

    function setEpochTotalReward (uint256 amount) public isManager {
        epochTotalReward = amount;
        emit EpochUpdated(amount);
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
        require(
            amount > 0 &&
            stGenToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            rewardBalance[msg.sender] += toTransfer;
        } else {
            addressLUT.push(msg.sender);
        }

        stGenToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);

        calculateAllRewardBalance();
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);

        // TODO: 7일간 pending 상태였다가 7일 후에 처리되어야함
        
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        stGenToken.transfer(msg.sender, balTransfer);
        rewardBalance[msg.sender] += yieldTransfer;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
            // TODO: addressLUT.pop(msg.sender); 필요
        }
        emit Unstake(msg.sender, balTransfer);

        calculateAllRewardBalance();
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400 * 7;
        uint256 timeRate = time / rate;
        
        // 리워드 계산(현재 epoch 에 할당된 총 리워드에서 (유저 staked)/(총 staked) 로 비율 계산한다(Epoch는 7일 단위).
        uint256 totalStaked = stGenToken.balanceOf(address(this));
        uint256 rawYield = epochTotalReward * ( stakingBalance[user] * 10**18 / totalStaked ) * timeRate / 10**36;
        return rawYield;
    }

    function calculateAllRewardBalance() public {
        address[] memory k = addressLUT;
        for (uint i = 0; i < size(); i++) {
            address user = k[i];
            if (isStaking[user] == true) {
                uint256 toTransfer = calculateYieldTotal(user);
                rewardBalance[user] += toTransfer;
                startTime[user] = block.timestamp;
            }
        }
    }

    function getMyRewards(address user) public view returns(uint256) {
        uint256 toTransfer = calculateYieldTotal(user);
        uint256 oldBalance = rewardBalance[user];
        toTransfer += oldBalance;
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
            toTransfer += oldBalance;
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
}