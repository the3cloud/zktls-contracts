// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {ZkTLSGateway} from "../src/ZkTLSGateway.sol";
import {Forge} from "../script/Forge.sol";
import {ZkTLSManager} from "../src/ZkTLSManager.sol";
import {ZkTLSAccount} from "../src/ZkTLSAccount.sol";
import {The3CloudCoin} from "../src/PaymentToken.sol";
import {MockVerifier} from "../src/mock/MockVerifier.sol";
import {ExampleDApp} from "../src/mock/ExampleDApp.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

contract ZkTLSTestLib {
    address public constant OWNER = address(uint160(uint256(keccak256("Owner"))));
    address public constant BENEFICIARY = address(uint160(uint256(keccak256("Beneficiary"))));
    address public constant SUBMITTER = address(uint160(uint256(keccak256("Submitter"))));

    address public constant USER_ADMIN = address(uint160(uint256(keccak256("UserAdmin"))));

    uint256 public constant PADDING_GAS = 1000;
    bytes32 public constant PROVER_ID = keccak256("PROVER_ID");

    ZkTLSGateway public zkTLSGateway;
    address public zkTLSGatewayImplementation;

    address public zkTLSAccountBeacon;
    address public zkTLSAccountImplementation;

    address public accessManagerBeacon;
    address public accessManagerImplementation;

    address public userAccount;
    address public userAccessManager;

    ExampleDApp public dApp;

    ZkTLSManager public zkTLSManager;
    address public zkTLSManagerImplementation;

    The3CloudCoin public paymentToken;

    MockVerifier public verifier;

    function readImplementation(address proxy) internal view returns (address) {
        bytes32 slot =
            Forge.safeVm().load(proxy, bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc));

        return address(uint160(uint256(slot)));
    }

    function deployUUPSUpgradeable(string memory contractName, bytes memory args)
        internal
        returns (address proxy, address implementation)
    {
        implementation = Forge.safeVm().deployCode(contractName);

        proxy = address(new ERC1967Proxy(implementation, args));
    }

    function deployUpgradeableBeacon(string memory contractName, address owner)
        internal
        returns (address beacon, address implementation)
    {
        implementation = Forge.safeVm().deployCode(contractName);

        beacon = address(new UpgradeableBeacon(implementation, owner));
    }

    function setupContracts() public {
        paymentToken = new The3CloudCoin(OWNER);

        (address zkTLSGatewayAddress, address zkTLSGatewayImplementationAddress) =
            deployUUPSUpgradeable("ZkTLSGateway", abi.encodeWithSelector(ZkTLSGateway.initialize.selector, OWNER));
        zkTLSGateway = ZkTLSGateway(zkTLSGatewayAddress);
        zkTLSGatewayImplementation = zkTLSGatewayImplementationAddress;

        (address zkTLSAccountBeaconAddress, address zkTLSAccountImplementationAddress) =
            deployUpgradeableBeacon("ZkTLSAccount", OWNER);
        zkTLSAccountBeacon = zkTLSAccountBeaconAddress;
        zkTLSAccountImplementation = zkTLSAccountImplementationAddress;

        (address accessManagerBeaconAddress, address accessManagerImplementationAddress) =
            deployUpgradeableBeacon("AccessManagerUpgradeable", OWNER);
        accessManagerBeacon = accessManagerBeaconAddress;
        accessManagerImplementation = accessManagerImplementationAddress;

        (address zkTLSManagerAddress, address zkTLSManagerImplementationAddress) = deployUUPSUpgradeable(
            "ZkTLSManager",
            abi.encodeCall(
                ZkTLSManager.initialize,
                (
                    OWNER,
                    zkTLSGatewayAddress,
                    zkTLSAccountBeaconAddress,
                    accessManagerBeaconAddress,
                    address(paymentToken),
                    PADDING_GAS
                )
            )
        );
        zkTLSManager = ZkTLSManager(zkTLSManagerAddress);
        zkTLSManagerImplementation = zkTLSManagerImplementationAddress;

        Forge.vm().prank(OWNER);
        zkTLSGateway.setManager(zkTLSManagerAddress);

        verifier = new MockVerifier();
        dApp = new ExampleDApp(userAccount);
    }
}

contract ZkTLSTest is ZkTLSTestLib, Test {
    function setUp() public {
        setupContracts();
    }

    uint256 public counter;

    function test_PaymentTokenDeployed() public view {
        assertEq(paymentToken.owner(), OWNER);
        assertEq(paymentToken.balanceOf(OWNER), 9999999000000000000000000);
    }

    function test_ZkTLSGatewayDeployed() public view {
        assertEq(zkTLSGateway.owner(), OWNER);
        assertEq(readImplementation(address(zkTLSGateway)), address(zkTLSGatewayImplementation));
    }

    function test_ZkTLSAccountDeployed() public view {
        assertEq(UpgradeableBeacon(zkTLSAccountBeacon).implementation(), address(zkTLSAccountImplementation));
        assertEq(UpgradeableBeacon(zkTLSAccountBeacon).owner(), OWNER);
    }

    function test_AccessManagerDeployed() public view {
        assertEq(UpgradeableBeacon(accessManagerBeacon).implementation(), address(accessManagerImplementation));
        assertEq(UpgradeableBeacon(accessManagerBeacon).owner(), OWNER);
    }

    function test_ZkTLSManagerDeployed() public view {
        assertEq(zkTLSManager.owner(), OWNER);
        assertEq(readImplementation(address(zkTLSManager)), address(zkTLSManagerImplementation));
    }

    function test_RegisterVerifier() public {
        Forge.vm().prank(OWNER);
        zkTLSManager.registerProver(PROVER_ID, address(verifier), SUBMITTER, BENEFICIARY);
    }

    function test_RegisterAccount() public {
        Forge.vm().prank(USER_ADMIN);
        (userAccount, userAccessManager) = zkTLSManager.registerAccount(USER_ADMIN);
    }

    function test_AddDApp() public {
        Forge.vm().prank(USER_ADMIN);
        ZkTLSAccount(payable(userAccount)).addDApp(address(dApp));
    }

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.test_RegisterAccount.selector) {
            beforeTestCalldata = new bytes[](6);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PaymentTokenDeployed.selector);
            beforeTestCalldata[1] = abi.encodePacked(this.test_ZkTLSGatewayDeployed.selector);
            beforeTestCalldata[2] = abi.encodePacked(this.test_ZkTLSAccountDeployed.selector);
            beforeTestCalldata[3] = abi.encodePacked(this.test_AccessManagerDeployed.selector);
            beforeTestCalldata[4] = abi.encodePacked(this.test_ZkTLSManagerDeployed.selector);
            beforeTestCalldata[5] = abi.encodePacked(this.test_RegisterVerifier.selector);
        }

        if (testSelector == this.test_AddDApp.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_RegisterAccount.selector);
        }
    }
}
