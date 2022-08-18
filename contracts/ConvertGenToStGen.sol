pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ConvertGenToStGen {
    using SafeERC20 for IERC20;

    string public name = "Convert GEN to stGEN";

    IERC20 public stGenToken;
    IERC20 public genToken;

    event Convert(address indexed from, uint256 amount);

    address public manager;

    constructor(
        IERC20 _stGenToken,
        IERC20 _genToken
        ) {
            stGenToken = _stGenToken;
            genToken = _genToken;

            manager = msg.sender;
        }

    // TODO: safemath로 바꾸기   
    // addResult = SafeMath.add(a,b);
    // subResult = SafeMath.sub(a,b);
    // mulResult = SafeMath.mul(a,b);
    // divResult = SafeMath.div(a,b);
    // modResult = SafeMath.mod(a,b);

    function version() public pure returns (string memory) {
        return "0.0.1";
    }

    // event for EVM logging
    event ManagerSet(address indexed oldManager, address indexed newManager);

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

    function convertGen(uint256 amount) public {
        // 100:1 = GEN:stGEN
        require(
            amount > 0 &&
            genToken.balanceOf(msg.sender) >= amount, 
            "You cannot convert zero tokens");
            
        // GEN 이동
        // TODO: burn 주소로 이동해야함
        genToken.transferFrom(msg.sender, address(this), amount);
        // stGEN 이동
        uint256 stGenAmount = SafeMath.div(amount, 100);
        stGenToken.safeTransfer(msg.sender, stGenAmount);
        emit Convert(msg.sender, amount);
    }

    function withdrawToken(address _token, address receiver, uint amount) public isManager {
        IERC20(_token).safeTransfer(receiver, amount);
    }

    function withdrawETH() public isManager returns(bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }
}