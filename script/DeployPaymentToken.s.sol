// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {DeployRecorder} from "./DeployRecorder.sol";

import {Create2Deployer} from "../src/Create2Deployer.sol";
import {The3CloudCoin} from "../src/PaymentToken.sol";

contract Deploy is Script, DeployRecorder {
    function run() external {
        DeployConfig memory config = getDeployConfig();

        Create2Deployer deployer = Create2Deployer(config.create2DeployerAddress);

        vm.startBroadcast();

        address the3CloudCoin = deployer.deploy(
            keccak256(abi.encode("The3CloudCoin")), type(The3CloudCoin).creationCode, abi.encode(config.ownerAddress)
        );

        console.log("The3CloudCoin deployed at", address(the3CloudCoin));

        savePaymentToken(configPath(), address(the3CloudCoin));

        vm.stopBroadcast();
    }
}
