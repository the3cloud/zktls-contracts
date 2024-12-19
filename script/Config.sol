// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {console} from "forge-std/console.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";

import {Forge} from "./Forge.sol";

contract Config {
    struct ImplementationConfig {
        address ZkTLSClient;
        address ZkTLSGateway;
        address ZkTLSManager;
    }

    struct ProxyConfig {
        address ZkTLSGateway;
        address ZkTLSManager;
    }

    struct BeaconConfig {
        address ZkTLSClient;
    }

    struct DeployConfig {
        address ownerAddress;
        address withdrawerAddress;
        address paymentTokenAddress;
        address create2DeployerAddress;
        address faucetAddress;
    }

    function configPath() public view returns (string memory) {
        VmSafe vm = Forge.safeVm();
        return string(abi.encodePacked("config/", vm.envString("DEPLOY_CONFIG"), ".toml"));
    }

    function getDeployConfig() public view returns (DeployConfig memory deployConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        deployConfig.ownerAddress = stdToml.readAddress(file, "$.deploy.owner_address");
        deployConfig.withdrawerAddress = stdToml.readAddress(file, "$.deploy.withdrawer_address");
        deployConfig.paymentTokenAddress = stdToml.readAddress(file, "$.deploy.payment_token_address");
        deployConfig.create2DeployerAddress = stdToml.readAddress(file, "$.deploy.create2_deployer_address");
        deployConfig.faucetAddress = stdToml.readAddress(file, "$.deploy.faucet_address");
    }

    function getImplementationConfig() public view returns (ImplementationConfig memory implementationConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        implementationConfig.ZkTLSClient = stdToml.readAddress(file, "$.implementation.zktls_client");
        implementationConfig.ZkTLSGateway = stdToml.readAddress(file, "$.implementation.zktls_gateway");
        implementationConfig.ZkTLSManager = stdToml.readAddress(file, "$.implementation.zktls_manager");
    }

    function getProxyConfig() public view returns (ProxyConfig memory proxyConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        proxyConfig.ZkTLSGateway = stdToml.readAddress(file, "$.proxy.zktls_gateway");
        proxyConfig.ZkTLSManager = stdToml.readAddress(file, "$.proxy.zktls_manager");
    }

    function getBeaconConfig() public view returns (BeaconConfig memory beaconConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        beaconConfig.ZkTLSClient = stdToml.readAddress(file, "$.beacon.zktls_client");
    }
}
