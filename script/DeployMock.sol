// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { Config } from "./Config.sol";

import { MockVerifier } from "../src/mock/MockVerifier.sol";
import { ExampleDApp } from "../src/mock/ExampleDApp.sol";
import { ZkTLSManager } from "../src/ZkTlsManager.sol";
import { ZkTLSAccount } from "../src/ZkTlsAccount.sol";

import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";

contract Deploy is Script, Config {
	function run() external {
		vm.startBroadcast();

		/// Deploy and register mock verifier
		MockVerifier verifier = new MockVerifier();
		bytes32 proverId = keccak256("MockProver");
		ZkTLSManager(getProxyConfig().ZkTLSManager).registerProver(
			proverId,
			address(verifier),
			0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
			0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
		);

		/// Deploy Manager
		AccessManager accessManager = new AccessManager(
			0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
		);

		console.log("AccessManager deployed at", address(accessManager));

		/// Register account
		address account = ZkTLSManager(getProxyConfig().ZkTLSManager)
			.registerAccount(address(accessManager));

		console.log("Account deployed at", account);

		/// Deploy example dApp
		ExampleDApp dApp = new ExampleDApp();
		/// Setup DApp in account.
		ZkTLSAccount(payable(account)).addDApp(address(dApp));

		vm.stopBroadcast();
	}
}
