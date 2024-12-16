// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {UpgradeableDeployer} from "./UpgradeableDeployer.sol";

import {Create2Deployer} from "../contracts/Create2Deployer.sol";
import {ZkTLSGateway} from "../contracts/ZkTLSGateway.sol";
import {ZkTLSClient} from "../contracts/ZkTLSClient.sol";
import {ZkTLSManager} from "../contracts/ZkTLSManager.sol";

import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

contract Deploy is Script, UpgradeableDeployer {
    function run() external {
        vm.startBroadcast();

        DeployConfig memory deployConfig = getDeployConfig();

        Create2Deployer deployer;

        if (deployConfig.create2DeployerAddress == address(0)) {
            deployer = new Create2Deployer();
            console.log("Create2Deployer deployed at", address(deployer));

            deployConfig.create2DeployerAddress = address(deployer);
        } else {
            deployer = Create2Deployer(deployConfig.create2DeployerAddress);
        }

        address zkTLSGatewayAddress = deployUUPS(
            deployer,
            "ZkTLSGateway",
            type(ZkTLSGateway).creationCode,
            abi.encodeCall(ZkTLSGateway.initialize, (deployConfig.ownerAddress))
        );
        console.log("ZkTLSGateway deployed at", zkTLSGatewayAddress);

        /// Deploy ZkTLSAccount in Beacon
        address zkTLSClientBeaconAddress =
            deployBeacon(deployer, "ZkTLSClient", type(ZkTLSClient).creationCode, deployConfig.ownerAddress);

        console.log("ZkTLSClient Beacon deployed at", zkTLSClientBeaconAddress);

        address accessManagerBeaconAddress = deployBeacon(
            deployer, "AccessManager", type(AccessManagerUpgradeable).creationCode, deployConfig.ownerAddress
        );
        console.log("AccessManager Beacon deployed at", accessManagerBeaconAddress);

        /// Deploy ZkTLSManager
        address zkTLSManagerAddress = deployUUPS(
            deployer,
            "ZkTLSManager",
            type(ZkTLSManager).creationCode,
            abi.encodeCall(
                ZkTLSManager.initialize,
                (deployConfig.ownerAddress, address(deployer), deployConfig.withdrawerAddress, zkTLSGatewayAddress)
            )
        );
        console.log("ZkTLSManager deployed at", zkTLSManagerAddress);

        saveContractDeployInfo(configPath(), deployConfig);

        vm.stopBroadcast();
    }
}
