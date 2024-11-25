// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {SimpleFaucet} from "../src/SimpleFaucet.sol";
import {The3CloudCoin} from "../src/PaymentToken.sol";
import {Forge} from "../script/Forge.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract SimpleFaucetTest is Test {
    using Address for address payable;

    address public constant OWNER = address(uint160(uint256(keccak256("Owner"))));
    address public constant USER = address(uint160(uint256(keccak256("User"))));

    SimpleFaucet public simpleFaucet;
    The3CloudCoin public paymentToken;

    function setUp() public {
        paymentToken = new The3CloudCoin(OWNER);
        simpleFaucet = new SimpleFaucet(address(paymentToken), OWNER, 10 ether, 0.01 ether);

        Forge.vm().prank(OWNER);
        paymentToken.transfer(address(simpleFaucet), 1000 ether);
    }

    function test_Request() public {
        Forge.vm().prank(USER);
        Forge.vm().deal(USER, 0.01 ether);
        payable(address(simpleFaucet)).sendValue(0.01 ether);

        assertEq(paymentToken.balanceOf(USER), 10 ether);
    }
}
