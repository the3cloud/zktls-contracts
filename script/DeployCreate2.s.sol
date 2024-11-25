// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Create2Deployer} from "../src/Create2Deployer.sol";

import {DeployRecorder} from "./DeployRecorder.sol";

contract Deploy is Script, DeployRecorder {
    function run() external {
        vm.startBroadcast();

        Create2Deployer deployer = new Create2Deployer();

        console.log("Create2Deployer deployed at", address(deployer));

        saveCreate2Deployer(configPath(), address(deployer));

        vm.stopBroadcast();
    }
}
