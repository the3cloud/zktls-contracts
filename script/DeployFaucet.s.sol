// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {DeployRecorder} from "./DeployRecorder.sol";

import {Create2Deployer} from "../contracts/Create2Deployer.sol";
import {SimpleFaucet} from "../contracts/SimpleFaucet.sol";

contract Deploy is Script, DeployRecorder {
    function run() external {
        DeployConfig memory config = getDeployConfig();

        Create2Deployer deployer = Create2Deployer(config.create2DeployerAddress);

        vm.startBroadcast();

        address simpleFaucet = deployer.deploy(
            keccak256(abi.encode("SimpleFaucet")),
            type(SimpleFaucet).creationCode,
            abi.encode(config.paymentTokenAddress, config.ownerAddress, 10 ether, 0.01 ether)
        );

        console.log("SimpleFaucet deployed at", simpleFaucet);

        saveFaucet(configPath(), simpleFaucet);

        vm.stopBroadcast();
    }
}
