// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library AddressRegisterLib {
    bytes32 constant CREATE2_DEPLOYER_ADDRESS = keccak256("CREATE2_DEPLOYER_ADDRESS");

    bytes32 constant ZKTLS_GATEWAY_ADDRESS = keccak256("ZKTLS_GATEWAY_ADDRESS");

    bytes32 constant ZKTLS_CLIENT_ADDRESS = keccak256("ZKTLS_CLIENT_ADDRESS");
    bytes32 constant ZKTLS_CLIENT_MANAGER_ADDRESS = keccak256("ZKTLS_CLIENT_MANAGER_ADDRESS");

    bytes32 constant SUPER_ADMIN_ADDRESS = keccak256("SUPER_ADMIN_ADDRESS");

    bytes32 constant ZKTLS_MANAGER_ADDRESS = keccak256("ZKTLS_MANAGER_ADDRESS");
}
