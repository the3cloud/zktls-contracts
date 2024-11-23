// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { UpgradeableDeployer } from "./UpgradeableDeployer.sol";

import { Create2Deployer } from "../src/Create2Deployer.sol";
import { ZkTLSGateway } from "../src/ZkTlsGateway.sol";
import { ZkTLSAccount } from "../src/ZkTlsAccount.sol";
import { ZkTLSManager } from "../src/ZkTlsManager.sol";
import { The3CloudCoin } from "../src/PaymentToken.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script, UpgradeableDeployer {
	function run() external {
		DeployConfig memory deployConfig = getDeployConfig();

		vm.startBroadcast();

		Create2Deployer deployer;

		if (deployConfig.create2DeployerAddress == address(0)) {
			deployer = new Create2Deployer();
			console.log("Create2Deployer deployed at", address(deployer));

			deployConfig.create2DeployerAddress = address(deployer);
		} else {
			deployer = Create2Deployer(deployConfig.create2DeployerAddress);
		}

		if (deployConfig.paymentTokenAddress == address(0)) {
			deployConfig.paymentTokenAddress = address(
				new The3CloudCoin(deployConfig.ownerAddress)
			);
		}

		/// Deploy ZkTLSGateway
		address zkTLSGatewayAddress = deployUUPS(
			deployer,
			"ZkTLSGateway",
			type(ZkTLSGateway).creationCode,
			abi.encodeCall(ZkTLSGateway.initialize, (deployConfig.ownerAddress))
		);
		console.log("ZkTLSGateway deployed at", zkTLSGatewayAddress);

		/// Deploy ZkTLSAccount in Beacon
		address zkTLSAccountBeaconAddress = deployBeacon(
			deployer,
			"ZkTLSAccount",
			type(ZkTLSAccount).creationCode,
			deployConfig.ownerAddress
		);

		console.log(
			"ZkTLSAccount Beacon deployed at",
			zkTLSAccountBeaconAddress
		);

		/// Deploy ZkTLSManager
		address zkTLSManagerAddress = deployUUPS(
			deployer,
			"ZkTLSManager",
			type(ZkTLSManager).creationCode,
			abi.encodeCall(
				ZkTLSManager.initialize,
				(
					deployConfig.ownerAddress,
					zkTLSGatewayAddress,
					zkTLSAccountBeaconAddress,
					deployConfig.paymentTokenAddress,
					deployConfig.paddingGas
				)
			)
		);

		ZkTLSGateway(zkTLSGatewayAddress).setManager(zkTLSManagerAddress);

		console.log("ZkTLSManager deployed at", zkTLSManagerAddress);

		vm.stopBroadcast();

		saveContractDeployInfo(configPath(), deployConfig);
	}
}
