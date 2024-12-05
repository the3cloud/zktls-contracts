// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {UpgradeableDeployer} from "./UpgradeableDeployer.sol";

import {Create2Deployer} from "../contracts/Create2Deployer.sol";
import {ZkTLSGateway} from "../contracts/ZkTLSGateway.sol";
import {ZkTLSAccount} from "../contracts/ZkTLSAccount.sol";
import {ZkTLSManager} from "../contracts/ZkTLSManager.sol";
import {The3CloudCoin} from "../contracts/PaymentToken.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

contract Deploy is Script, UpgradeableDeployer {
    function run() external {
        DeployConfig memory deployConfig = getDeployConfig();

        vm.startBroadcast();

        Create2Deployer deployer;

        // if (deployConfig.create2DeployerAddress == address(0)) {
        //     deployer = new Create2Deployer();
        //     console.log("Create2Deployer deployed at", address(deployer));

        //     deployConfig.create2DeployerAddress = address(deployer);
        // } else {
        //     deployer = Create2Deployer(deployConfig.create2DeployerAddress);
        // }

        // if (deployConfig.paymentTokenAddress == address(0)) {
        //     deployConfig.paymentTokenAddress = address(new The3CloudCoin(deployConfig.ownerAddress));
        // }

        /// Deploy ZkTLSGateway
        // address zkTLSGatewayAddress = deployUUPS(
        //     deployer,
        //     "ZkTLSGateway",
        //     type(ZkTLSGateway).creationCode,
        //     abi.encodeCall(ZkTLSGateway.initialize, (deployConfig.ownerAddress, 1 gwei))
        // );
        // console.log("ZkTLSGateway deployed at", zkTLSGatewayAddress);

        // /// Deploy ZkTLSAccount in Beacon
        // address zkTLSAccountBeaconAddress =
        //     deployBeacon(deployer, "ZkTLSAccount", type(ZkTLSAccount).creationCode, deployConfig.ownerAddress);

        // console.log("ZkTLSAccount Beacon deployed at", zkTLSAccountBeaconAddress);

        address accessManagerBeaconAddress = deployBeacon(
            deployer, "AccessManager", type(AccessManagerUpgradeable).creationCode, deployConfig.ownerAddress
        );

        // console.log("AccessManager Beacon deployed at", accessManagerBeaconAddress);

        /// Deploy ZkTLSManager
        address zkTLSManagerAddress = deployUUPS(
            deployer,
            "ZkTLSManager",
            type(ZkTLSManager).creationCode,
            abi.encodeCall(
                ZkTLSManager.initialize,
                (
                    deployConfig.ownerAddress,
                    address(0xb4489aE98b05EB3266fDc120037e8496aeB2E21e),
                    address(0x14f0A862B46a13FAb2CA2542FFeF6B42efeC1E62),
                    accessManagerBeaconAddress,
                    deployConfig.paymentTokenAddress,
                    deployConfig.paddingGas
                )
            )
        );

        console.log("ZkTLSManager deployed at", zkTLSManagerAddress);

        vm.stopBroadcast();

        saveContractDeployInfo(configPath(), deployConfig);
    }
}
