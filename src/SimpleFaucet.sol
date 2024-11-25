// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SimpleFaucet is Ownable {
    using SafeERC20 for IERC20;

    /// @notice The payment token
    address public paymentToken;

    /// @notice The minimum amount of native token required to request
    uint256 public minNativeAmount;

    /// @notice The amount of payment token to be sent per request
    uint256 public amountPerRequest;

    /// @notice The error thrown when the native amount is insufficient
    error InsufficientNativeAmount();

    constructor(address paymentToken_, address owner_, uint256 amountPerRequest_, uint256 minNativeAmount_)
        Ownable(owner_)
    {
        paymentToken = paymentToken_;
        amountPerRequest = amountPerRequest_;
        minNativeAmount = minNativeAmount_;
    }

    /// @notice The function to request the payment token
    function request() private {
        if (msg.value < minNativeAmount) revert InsufficientNativeAmount();

        IERC20(paymentToken).safeTransfer(msg.sender, amountPerRequest);
    }

    /// @notice The fallback function to request the payment token
    fallback() external payable {
        request();
    }

    /// @notice The receive function to request the payment token
    receive() external payable {
        request();
    }

    /// @notice The function to set the amount of payment token to be sent per request
    function setAmountPerRequest(uint256 amountPerRequest_) public onlyOwner {
        amountPerRequest = amountPerRequest_;
    }

    /// @notice The function to set the minimum amount of native token required to request
    function setMinNativeAmount(uint256 minNativeAmount_) public onlyOwner {
        minNativeAmount = minNativeAmount_;
    }

    /// @notice The function to set the payment token
    function setPaymentToken(address paymentToken_) public onlyOwner {
        paymentToken = paymentToken_;
    }

    /// @notice The function to withdraw the native token
    function withdrawNative(address to, uint256 amount) public onlyOwner {
        payable(to).transfer(amount);
    }

    /// @notice The function to withdraw the payment token
    function withdrawToken(address to, uint256 amount) public onlyOwner {
        IERC20(paymentToken).safeTransfer(to, amount);
    }
}
