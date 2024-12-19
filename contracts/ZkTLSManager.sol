// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import {Create2Deployer} from "./Create2Deployer.sol";
import {ZkTLSClient} from "./ZkTLSClient.sol";

contract ZkTLSManager is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Client beacon address
    address public clientBeacon;

    /// @notice ClientManager beacon address
    address public clientManagerBeacon;

    Create2Deployer public create2Deployer;

    address public withdrawer;

    address public gateway;

    /// @notice Is registered client
    mapping(address => bool) public isRegisteredClient;

    function initialize(
        address owner_,
        address create2Deployer_,
        address withdrawer_,
        address gateway_,
        address clientBeacon_,
        address clientManagerBeacon_
    ) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();

        create2Deployer = Create2Deployer(create2Deployer_);
        withdrawer = withdrawer_;
        gateway = gateway_;
        clientBeacon = clientBeacon_;
        clientManagerBeacon = clientManagerBeacon_;
    }

    event ClientRegistered(address indexed client, address indexed clientManager);

    function registerClient(bytes32 salt_, address owner_) public returns (address clientManager, address client) {
        clientManager = create2Deployer.deploy(
            salt_,
            type(BeaconProxy).creationCode,
            abi.encode(clientManagerBeacon, abi.encodeCall(AccessManagerUpgradeable.initialize, (owner_)))
        );

        client = create2Deployer.deploy(
            salt_,
            type(BeaconProxy).creationCode,
            abi.encode(clientBeacon, abi.encodeCall(ZkTLSClient.initialize, (gateway, address(this), clientManager)))
        );

        isRegisteredClient[client] = true;

        emit ClientRegistered(client, clientManager);
    }

    function setWithdrawer(address withdrawer_) public onlyOwner {
        withdrawer = withdrawer_;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
