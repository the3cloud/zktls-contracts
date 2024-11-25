// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Config} from "./Config.sol";

import {MockVerifier} from "../src/mock/MockVerifier.sol";
import {ExampleDApp} from "../src/mock/ExampleDApp.sol";
import {ZkTLSManager} from "../src/ZkTLSManager.sol";
import {ZkTLSAccount} from "../src/ZkTLSAccount.sol";

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";

contract Deploy is Script, Config {
    function run() external {
        address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        ProxyConfig memory proxyConfig = getProxyConfig();

        vm.startBroadcast();

        /// Deploy and register mock verifier
        MockVerifier verifier = new MockVerifier();
        bytes32 proverId = keccak256("MockProver");
        ZkTLSManager(proxyConfig.ZkTLSManager).registerProver(proverId, address(verifier), owner, owner);

        /// Register account
        (address account, address accessManager) = ZkTLSManager(proxyConfig.ZkTLSManager).registerAccount(owner);

        console.log("Account deployed at", account);
        console.log("AccessManager deployed at", accessManager);

        /// Deploy example dApp
        ExampleDApp dApp = new ExampleDApp(account);
        /// Setup DApp in account.
        ZkTLSAccount(payable(account)).addDApp(address(dApp));

        vm.stopBroadcast();
    }
}
