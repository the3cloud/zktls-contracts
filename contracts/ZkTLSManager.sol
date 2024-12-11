// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

import {AddressRegisterLib} from "./lib/AddressRegisterLib.sol";
import {AddressRegister} from "./AddressRegister.sol";
import {Create2Deployer} from "./Create2Deployer.sol";
import {ZkTLSClient} from "./ZkTLSClient.sol";

contract ZkTLSManager is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Client beacon address
    address public clientBeacon;

    /// @notice ClientManager beacon address
    address public clientManagerBeacon;

    /// @notice Register
    AddressRegister public register;

    /// @notice Is registered client
    mapping(address => bool) public isRegisteredClient;

    function initialize(address owner_, address register_) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();

        register = AddressRegister(register_);
    }

    event ClientRegistered(address client, address clientManager);

    function registerClient(bytes32 salt_, address owner_) public returns (address clientManager, address client) {
        address create2Deployer = register.registeredAddress(AddressRegisterLib.CREATE2_DEPLOYER_ADDRESS);

        Create2Deployer deployer = Create2Deployer(create2Deployer);

        clientManager = deployer.deploy(
            salt_,
            type(AccessManagerUpgradeable).creationCode,
            abi.encodeCall(AccessManagerUpgradeable.initialize, (owner_))
        );

        client = deployer.deploy(
            salt_, type(ZkTLSClient).creationCode, abi.encodeCall(ZkTLSClient.initialize, (address(register), owner_))
        );

        isRegisteredClient[client] = true;

        emit ClientRegistered(client, clientManager);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
