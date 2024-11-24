// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {console} from "forge-std/console.sol";

import {Create2Deployer} from "../src/Create2Deployer.sol";

import {DeployRecorder} from "./DeployRecorder.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract UpgradeableDeployer is DeployRecorder {
    function deployImplementation(Create2Deployer deployer, string memory contractName, bytes memory bytecode)
        public
        returns (address)
    {
        // Deploy the implementation contract
        bytes32 implementationSalt = keccak256(abi.encode(contractName, "implementation"));
        address implementation = deployer.deploy(implementationSalt, bytecode, bytes(""));

        allImplementationContracts.push(DeployedContract({name: contractName, contractAddress: implementation}));

        console.log(string(abi.encodePacked(contractName, " Implementation deployed at")), implementation);

        return implementation;
    }

    function deployUUPS(
        Create2Deployer deployer,
        string memory contractName,
        bytes memory bytecode,
        bytes memory args,
        uint256 amount
    ) public returns (address) {
        address implementation = deployImplementation(deployer, contractName, bytecode);

        // Deploy the proxy contract
        bytes32 proxySalt = keccak256(abi.encode(contractName, "proxy"));
        bytes memory deployArgs = abi.encode(implementation, args);
        address proxy = deployer.deploy{value: amount}(proxySalt, type(ERC1967Proxy).creationCode, deployArgs);

        allProxyContracts.push(DeployedContract({name: contractName, contractAddress: proxy}));

        return proxy;
    }

    function deployUUPS(Create2Deployer deployer, string memory contractName, bytes memory bytecode, bytes memory args)
        public
        returns (address)
    {
        return deployUUPS(deployer, contractName, bytecode, args, 0);
    }

    function deployBeacon(Create2Deployer deployer, string memory contractName, bytes memory bytecode, address owner)
        public
        returns (address)
    {
        address implementation = deployImplementation(deployer, contractName, bytecode);

        bytes32 beaconSalt = keccak256(abi.encode(contractName, "beacon"));
        address beacon =
            deployer.deploy(beaconSalt, type(UpgradeableBeacon).creationCode, abi.encode(implementation, owner));

        allBeaconContracts.push(DeployedContract({name: contractName, contractAddress: beacon}));

        return beacon;
    }
}
