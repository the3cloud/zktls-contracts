// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {console} from "forge-std/console.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";

import {Forge} from "./Forge.sol";

contract Config {
    struct ImplementationConfig {
        address ZkTLSAccount;
        address ZkTLSGateway;
        address ZkTLSManager;
    }

    struct ProxyConfig {
        address ZkTLSGateway;
        address ZkTLSManager;
    }

    struct BeaconConfig {
        address ZkTLSAccount;
    }

    struct DeployConfig {
        address ownerAddress;
        address paymentTokenAddress;
        uint256 paddingGas;
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
        deployConfig.paymentTokenAddress = stdToml.readAddress(file, "$.deploy.payment_token_address");
        deployConfig.paddingGas = stdToml.readUint(file, "$.deploy.padding_gas");
        deployConfig.create2DeployerAddress = stdToml.readAddress(file, "$.deploy.create2_deployer_address");
        deployConfig.faucetAddress = stdToml.readAddress(file, "$.deploy.faucet_address", address(0));
    }

    function getImplementationConfig() public view returns (ImplementationConfig memory implementationConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        implementationConfig.ZkTLSAccount = stdToml.readAddress(file, "$.implementation.ZkTLSAccount");
        implementationConfig.ZkTLSGateway = stdToml.readAddress(file, "$.implementation.ZkTLSGateway");
        implementationConfig.ZkTLSManager = stdToml.readAddress(file, "$.implementation.ZkTLSManager");
    }

    function getProxyConfig() public view returns (ProxyConfig memory proxyConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        proxyConfig.ZkTLSGateway = stdToml.readAddress(file, "$.proxy.ZkTLSGateway");
        proxyConfig.ZkTLSManager = stdToml.readAddress(file, "$.proxy.ZkTLSManager");
    }

    function getBeaconConfig() public view returns (BeaconConfig memory beaconConfig) {
        VmSafe vm = Forge.safeVm();

        string memory file = vm.readFile(configPath());

        beaconConfig.ZkTLSAccount = stdToml.readAddress(file, "$.beacon.ZkTLSAccount");
    }
}
