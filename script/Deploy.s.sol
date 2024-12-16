// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {UpgradeableDeployer} from "./UpgradeableDeployer.sol";

contract Deploy is Script, UpgradeableDeployer {
    function run() external {
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
