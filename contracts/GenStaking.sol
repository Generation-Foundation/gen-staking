pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GenStaking {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public rewardBalance;

    string public name = "Gen Staking";

    // IERC20 public daiToken;
    // CoffeeToken public coffeeToken;

    IERC20 public stGenToken;
    IERC20 public genToken;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(
        // IERC20 _daiToken,
        // CoffeeToken _coffeeToken
        IERC20 _stGenToken,
        IERC20 _genToken
        ) {
            stGenToken = _stGenToken;
            genToken = _genToken;
        }

    // TODO: safemath로 바꾸기   
    // addResult = SafeMath.add(a,b);
    // subResult = SafeMath.sub(a,b);
    // mulResult = SafeMath.mul(a,b);
    // divResult = SafeMath.div(a,b);
    // modResult = SafeMath.mod(a,b);

    receive() external payable {}

    function stake(uint256 amount) public {
        require(
            amount > 0 &&
            stGenToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            rewardBalance[msg.sender] += toTransfer;
        }
        
        stGenToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        stGenToken.transfer(msg.sender, balTransfer);
        rewardBalance[msg.sender] += yieldTransfer;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer);
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;

        // 리워드 계산(현재 epoch 에 할당된 총 리워드에서 (유저 staked)/(총 staked) 로 비율 계산한다(Epoch는 7일 단위).
        // stGenToken.balanceOf(address(this))
        




        return rawYield;
    } 

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 ||
            rewardBalance[msg.sender] > 0,
            "Nothing to withdraw"
            );
            
        if(rewardBalance[msg.sender] != 0){
            uint256 oldBalance = rewardBalance[msg.sender];
            rewardBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        // coffeeToken.mint(msg.sender, toTransfer);
        // TODO: GEN Token Transfer
        genToken.safeTransfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }

    function getThisAddressGenTokenBalance() public view returns (uint256) {
        uint balance = genToken.balanceOf(address(this));
        return balance;
    }

    function getThisAddressStGenTokenBalance() public view returns (uint256) {
        uint balance = stGenToken.balanceOf(address(this));
        return balance;
    }

    // address public manager;
    // mapping(string => string) public requestedDatas;

    // receive() external payable {}

    // constructor() { manager = msg.sender; }

    // function version() public pure returns (string memory) {
    //     return "0.0.1";
    // }

    // function name() public pure returns (string memory) {
    //     return "Gen Contract";
    // }

    // // event for EVM logging
    // event ManagerSet(address indexed oldManager, address indexed newManager);

    // // modifier to check if caller is manager
    // modifier isManager() {
    //     // If the first argument of 'require' evaluates to 'false', execution terminates and all
    //     // changes to the state and to Ether balances are reverted.
    //     // This used to consume all gas in old EVM versions, but not anymore.
    //     // It is often a good idea to use 'require' to check if functions are called correctly.
    //     // As a second argument, you can also provide an explanation about what went wrong.
    //     require(msg.sender == manager, "Caller is not manager");
    //     _;
    // }
    
    // function changeManager(address newManager) public isManager {
    //     emit ManagerSet(manager, newManager);
    //     manager = newManager;
    // }

    // function getManager() external view returns (address) {
    //     return manager;
    // }

    // function addDataUidAndIpfsHash(string memory dataUid, string memory ipfsHash) public isManager {
    //     requestedDatas[dataUid] = ipfsHash;
    // }

    // function getRequestedDataHash(string memory dataUid) external view returns (string memory) {
    //     return requestedDatas[dataUid];
    // }

    // function removeDataUidAndIpfsHash(string memory dataUid) public isManager {
    //     delete requestedDatas[dataUid];
    // }

    // function transferReward(address _token, address receiver, uint amount) public isManager {
    //     IERC20(_token).safeTransfer(receiver, amount);
    // }

    // function withdrawETH() public isManager returns(bool) {
    //     payable(msg.sender).transfer(address(this).balance);
    //     return true;
    // }
}