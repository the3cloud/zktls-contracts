// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { console } from "forge-std/console.sol";
import { stdToml } from "forge-std/StdToml.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { Create2Deployer } from "../contracts/Create2Deployer.sol";

import { Config } from "./Config.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract UpgradeableDeployer is Config {
	struct DeployedContract {
		string name;
		address contractAddress;
	}

	DeployedContract[] public allImplementationContracts;
	DeployedContract[] public allProxyContracts;
	DeployedContract[] public allBeaconContracts;

	function deployImplementation(
		Create2Deployer deployer,
		string memory contractName,
		bytes memory bytecode
	) public returns (address) {
		// Deploy the implementation contract
		bytes32 implementationSalt = keccak256(
			abi.encode(contractName, "implementation")
		);
		address implementation = deployer.deploy(
			implementationSalt,
			bytecode,
			bytes("")
		);

		allImplementationContracts.push(
			DeployedContract({
				name: contractName,
				contractAddress: implementation
			})
		);

		console.log(
			string(
				abi.encodePacked(contractName, " Implementation deployed at")
			),
			implementation
		);

		return implementation;
	}

	function deployUUPS(
		Create2Deployer deployer,
		string memory contractName,
		bytes memory bytecode,
		bytes memory args,
		uint256 amount
	) public returns (address) {
		address implementation = deployImplementation(
			deployer,
			contractName,
			bytecode
		);

		// Deploy the proxy contract
		bytes32 proxySalt = keccak256(abi.encode(contractName, "proxy"));
		bytes memory deployArgs = abi.encode(implementation, args);
		address proxy = deployer.deploy{ value: amount }(
			proxySalt,
			type(ERC1967Proxy).creationCode,
			deployArgs
		);

		allProxyContracts.push(
			DeployedContract({ name: contractName, contractAddress: proxy })
		);

		return proxy;
	}

	function deployUUPS(
		Create2Deployer deployer,
		string memory contractName,
		bytes memory bytecode,
		bytes memory args
	) public returns (address) {
		return deployUUPS(deployer, contractName, bytecode, args, 0);
	}

	function deployBeacon(
		Create2Deployer deployer,
		string memory contractName,
		bytes memory bytecode,
		address owner
	) public returns (address) {
		address implementation = deployImplementation(
			deployer,
			contractName,
			bytecode
		);

		bytes32 beaconSalt = keccak256(abi.encode(contractName, "beacon"));
		address beacon = deployer.deploy(
			beaconSalt,
			type(UpgradeableBeacon).creationCode,
			abi.encode(implementation, owner)
		);

		allBeaconContracts.push(
			DeployedContract({ name: contractName, contractAddress: beacon })
		);

		return beacon;
	}

	function saveContractDeployInfo(string memory path) public {
		Config.DeployConfig memory deployConfig = getDeployConfig();

		string memory configStr = stdJson.serialize(
			"config",
			'{"deploy": {}, "implementation": {}, "proxy": {}, "beacon": {}}'
		);
		stdToml.write(configStr, path);

		/// Rebuild deploy config
		stdToml.serialize("deploy", "owner_address", deployConfig.ownerAddress);
		stdToml.serialize(
			"deploy",
			"payment_token_address",
			deployConfig.paymentTokenAddress
		);
		stdToml.serialize("deploy", "padding_gas", deployConfig.paddingGas);
		string memory deployStr = stdToml.serialize(
			"deploy",
			"create2_deployer_address",
			deployConfig.create2DeployerAddress
		);

		console.log(deployStr);

		stdToml.write(deployStr, path, ".deploy");

		string memory implementationStr;
		for (uint256 i = 0; i < allImplementationContracts.length; i++) {
			implementationStr = stdToml.serialize(
				"implementation",
				allImplementationContracts[i].name,
				allImplementationContracts[i].contractAddress
			);
		}
		stdToml.write(implementationStr, path, ".implementation");

		/// Write proxy config
		string memory proxyStr;
		for (uint256 i = 0; i < allProxyContracts.length; i++) {
			proxyStr = stdToml.serialize(
				"proxy",
				allProxyContracts[i].name,
				allProxyContracts[i].contractAddress
			);
		}
		stdToml.write(proxyStr, path, ".proxy");

		/// Write beacon config
		string memory beaconStr;
		for (uint256 i = 0; i < allBeaconContracts.length; i++) {
			beaconStr = stdToml.serialize(
				"beacon",
				allBeaconContracts[i].name,
				allBeaconContracts[i].contractAddress
			);
		}
		stdToml.write(beaconStr, path, ".beacon");
	}
}
