// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Config} from "./Config.sol";

import {stdToml} from "forge-std/StdToml.sol";

import {Forge} from "./Forge.sol";

contract DeployRecorder is Config {
    struct DeployedContract {
        string name;
        address contractAddress;
    }

    DeployedContract[] public allImplementationContracts;
    DeployedContract[] public allProxyContracts;
    DeployedContract[] public allBeaconContracts;

    function saveCreate2Deployer(string memory path, address create2Deployer) public {
        string memory deployStr = Forge.safeVm().toString(create2Deployer);
        stdToml.write(deployStr, path, ".deploy.create2_deployer_address");
    }

    function savePaymentToken(string memory path, address paymentToken) public {
        string memory paymentTokenStr = Forge.safeVm().toString(paymentToken);
        stdToml.write(paymentTokenStr, path, ".deploy.payment_token_address");
    }

    function saveContractDeployInfo(string memory path, DeployConfig memory deployConfig) public {
        string memory configStr =
            stdToml.serialize("config", '{"deploy": {}, "implementation": {}, "proxy": {}, "beacon": {}}');
        stdToml.write(configStr, path);

        /// Rebuild deploy config
        stdToml.serialize("deploy", "owner_address", deployConfig.ownerAddress);
        stdToml.serialize("deploy", "payment_token_address", deployConfig.paymentTokenAddress);
        stdToml.serialize("deploy", "padding_gas", deployConfig.paddingGas);
        string memory deployStr =
            stdToml.serialize("deploy", "create2_deployer_address", deployConfig.create2DeployerAddress);
        stdToml.write(deployStr, path, ".deploy");

        string memory implementationStr;
        for (uint256 i = 0; i < allImplementationContracts.length; i++) {
            implementationStr = stdToml.serialize(
                "implementation", allImplementationContracts[i].name, allImplementationContracts[i].contractAddress
            );
        }
        stdToml.write(implementationStr, path, ".implementation");

        /// Write proxy config
        string memory proxyStr;
        for (uint256 i = 0; i < allProxyContracts.length; i++) {
            proxyStr = stdToml.serialize("proxy", allProxyContracts[i].name, allProxyContracts[i].contractAddress);
        }
        stdToml.write(proxyStr, path, ".proxy");

        /// Write beacon config
        string memory beaconStr;
        for (uint256 i = 0; i < allBeaconContracts.length; i++) {
            beaconStr = stdToml.serialize("beacon", allBeaconContracts[i].name, allBeaconContracts[i].contractAddress);
        }
        stdToml.write(beaconStr, path, ".beacon");
    }
}
