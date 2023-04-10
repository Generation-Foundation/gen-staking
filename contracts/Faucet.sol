// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Faucet is Ownable {
    using SafeERC20 for IERC20;

    uint256 constant public tokenAmount = 10000000000000000000;
    uint256 constant public waitTime = 12 hours;
    
    mapping(address => uint256) lastAccessTime;

    IERC20 public immutable faucetToken;

    constructor(IERC20 _token) {
        faucetToken = _token;
    }

    function requestTokens() public {
        require(allowedToWithdraw(msg.sender));
        lastAccessTime[msg.sender] = block.timestamp + waitTime;
        faucetToken.transfer(msg.sender, tokenAmount);
    }

    function allowedToWithdraw(address _address) public view returns (bool) {
        if(lastAccessTime[_address] == 0) {
            return true;
        } else if(block.timestamp >= lastAccessTime[_address]) {
            return true;
        }
        return false;
    }

    function recoverERC20(address token, uint256 amount) onlyOwner public {
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}