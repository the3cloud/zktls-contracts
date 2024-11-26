// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

import {ZkTLSGateway} from "./ZkTLSGateway.sol";
import {ZkTLSAccount} from "./ZkTLSAccount.sol";

/// @notice ZkTLS manager contract
/// @author the3cloud
/// This contract used to register provers and register Account.
contract ZkTLSManager is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Account beacon address
    address public accountBeacon;

    /// @notice AccessManager beacon address
    address public accessManagerBeacon;

    /// @notice Payment token address
    address public paymentToken;

    /// @notice Padding gas
    uint256 public paddingGas;

    /// @notice ZkTLSGateway address
    address public zkTLSGateway;

    /// @notice Is registered account
    mapping(address => bool) public isRegisteredAccount;

    event ProverRegistered(
        bytes32 indexed proverId, address verifierAddress, address submitterAddress, address beneficiaryAddress
    );

    event AccountRegistered(address indexed account);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address owner_,
        address zkTLSGateway_,
        address accountBeacon_,
        address accessManagerBeacon_,
        address paymentToken_,
        uint256 paddingGas_
    ) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();

        zkTLSGateway = zkTLSGateway_;
        accountBeacon = accountBeacon_;
        accessManagerBeacon = accessManagerBeacon_;
        paymentToken = paymentToken_;
        paddingGas = paddingGas_;
    }

    /// @notice Register account
    /// @param admin_ Admin address
    function registerAccount(address admin_) public returns (address account, address accessManager) {
        accessManager =
            address(new BeaconProxy(accessManagerBeacon, abi.encodeCall(AccessManagerUpgradeable.initialize, (admin_))));

        account = address(
            new BeaconProxy(
                accountBeacon,
                abi.encodeCall(ZkTLSAccount.initialize, (zkTLSGateway, accessManager, paymentToken, paddingGas))
            )
        );

        isRegisteredAccount[address(account)] = true;

        emit AccountRegistered(address(account));
    }

    function setAccountBeacon(address accountBeacon_) external onlyOwner {
        accountBeacon = accountBeacon_;
    }

    function setAccessManagerBeacon(address accessManagerBeacon_) external onlyOwner {
        accessManagerBeacon = accessManagerBeacon_;
    }

    /// @notice Register prover to ZkTLSGateway
    /// @dev For now, this function only can set by owner. In future, anyone can become a prover.
    /// @param proverId_ Prover ID
    /// @param verifierAddress_ Verifier address
    /// @param submitterAddress_ Submitter address
    /// @param beneficiaryAddress_ Beneficiary address
    function registerProver(
        bytes32 proverId_,
        address verifierAddress_,
        address submitterAddress_,
        address beneficiaryAddress_
    ) external onlyOwner {
        ZkTLSGateway(zkTLSGateway).setProverVerifier(
            proverId_, verifierAddress_, submitterAddress_, beneficiaryAddress_
        );

        emit ProverRegistered(proverId_, verifierAddress_, submitterAddress_, beneficiaryAddress_);
    }

    /// @notice Set ZkTLSGateway address by owner
    /// @param zkTLSGateway_ ZkTLSGateway address
    function setGateway(address zkTLSGateway_) external onlyOwner {
        zkTLSGateway = zkTLSGateway_;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
