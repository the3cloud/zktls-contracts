// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {ZkTLSGateway} from "../contracts/ZkTLSGateway.sol";
import {Forge} from "../script/Forge.sol";
import {ZkTLSManager} from "../contracts/ZkTLSManager.sol";
import {ZkTLSAccount} from "../contracts/ZkTLSAccount.sol";
import {The3CloudCoin} from "../contracts/PaymentToken.sol";
import {MockVerifier} from "../contracts/mock/MockVerifier.sol";
import {ExampleDApp} from "../contracts/mock/ExampleDApp.sol";
import {RequestData} from "../contracts/lib/RequestData.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract ZkTLSTestLib {
    address public constant OWNER = address(uint160(uint256(keccak256("Owner"))));
    address public constant BENEFICIARY = address(uint160(uint256(keccak256("Beneficiary"))));
    address public constant SUBMITTER = address(uint160(uint256(keccak256("Submitter"))));

    address public constant USER_ADMIN = address(uint160(uint256(keccak256("UserAdmin"))));

    uint256 public constant PADDING_GAS = 1000;
    bytes32 public constant PROVER_ID = keccak256("ExampleProver");

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
            deployUUPSUpgradeable("ZkTLSGateway", abi.encodeCall(ZkTLSGateway.initialize, (OWNER, 20)));
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
    }
}

contract ZkTLSTest is ZkTLSTestLib, Test {
    using Address for address payable;
    using SafeERC20 for The3CloudCoin;

    function setUp() public {
        setupContracts();
    }

    uint256 public counter;

    function test_ZkTLSDeployed() public view {
        assertEq(paymentToken.owner(), OWNER);
        assertEq(paymentToken.balanceOf(OWNER), 9999999000000000000000000);

        assertEq(zkTLSGateway.owner(), OWNER);
        assertEq(readImplementation(address(zkTLSGateway)), address(zkTLSGatewayImplementation));
        assertEq(zkTLSGateway.manager(), address(zkTLSManager));

        assertEq(UpgradeableBeacon(zkTLSAccountBeacon).implementation(), address(zkTLSAccountImplementation));
        assertEq(UpgradeableBeacon(zkTLSAccountBeacon).owner(), OWNER);

        assertEq(UpgradeableBeacon(accessManagerBeacon).implementation(), address(accessManagerImplementation));
        assertEq(UpgradeableBeacon(accessManagerBeacon).owner(), OWNER);

        assertEq(zkTLSManager.owner(), OWNER);
        assertEq(readImplementation(address(zkTLSManager)), address(zkTLSManagerImplementation));
        assertEq(zkTLSManager.accountBeacon(), address(zkTLSAccountBeacon));
        assertEq(zkTLSManager.accessManagerBeacon(), address(accessManagerBeacon));
        assertEq(zkTLSManager.paymentToken(), address(paymentToken));
        assertEq(zkTLSManager.paddingGas(), PADDING_GAS);
    }

    function test_TLSCall() public {
        /// Register Prover
        Forge.vm().prank(OWNER);
        zkTLSManager.registerProver(PROVER_ID, address(verifier), SUBMITTER, BENEFICIARY);
        assertEq(zkTLSGateway.proverVerifierAddress(PROVER_ID), address(verifier));
        assertEq(zkTLSGateway.proverSubmitterAddress(PROVER_ID), SUBMITTER);
        assertEq(zkTLSGateway.proverBeneficiaryAddress(PROVER_ID), BENEFICIARY);

        /// Register Account
        Forge.vm().prank(USER_ADMIN);
        (userAccount, userAccessManager) = zkTLSManager.registerAccount(USER_ADMIN);
        assertEq(ZkTLSAccount(payable(userAccount)).gateway(), address(zkTLSGateway));
        assertEq(ZkTLSAccount(payable(userAccount)).paymentToken(), address(paymentToken));
        assertEq(ZkTLSAccount(payable(userAccount)).paddingGas(), PADDING_GAS);

        /// Deploy DApp
        dApp = new ExampleDApp(userAccount);
        assertEq(dApp.account(), userAccount);

        /// Add DApp
        Forge.vm().prank(USER_ADMIN);
        ZkTLSAccount(payable(userAccount)).addDApp(address(dApp));
        assertEq(ZkTLSAccount(payable(userAccount)).dApps(address(dApp)), true);

        /// Transfer payment token
        Forge.vm().prank(OWNER);
        paymentToken.safeTransfer(address(userAccount), 1000 ether);
        assertEq(paymentToken.balanceOf(address(userAccount)), 1000 ether);

        /// Transfer ETH
        Forge.vm().prank(USER_ADMIN);
        Forge.vm().deal(USER_ADMIN, 0.01 ether);
        payable(address(userAccount)).sendValue(0.01 ether);
        assertEq(address(userAccount).balance, 0.01 ether);

        /// Request TLS Call
        Forge.vm().prank(USER_ADMIN);
        bytes32 requestId = dApp.requestTLSCallTemplate();
        assertEq(ZkTLSAccount(payable(userAccount)).requestFrom(requestId), address(dApp));
        assertEq(ZkTLSAccount(payable(userAccount)).requestCallbackGasLimit(requestId), 30000);
        assertEq(ZkTLSAccount(payable(userAccount)).requestExpectedGasPrice(requestId), 5 gwei);
        /// TODO: Add fee and gas check

        bytes memory requestBytes = RequestData.encodeRequestDataFull(dApp.buildRequestData());
        bytes32 requestHash = RequestData.hash(requestBytes);
        assertEq(zkTLSGateway.requestHash(requestId), requestHash);
        assertEq(zkTLSGateway.requestProverId(requestId), PROVER_ID);
        assertEq(zkTLSGateway.requestFromAccount(requestId), userAccount);

        /// Test delivery response
        Forge.vm().prank(SUBMITTER);
        zkTLSGateway.deliveryResponse(requestId, requestHash, abi.encode("response"), bytes(""));
        // TODO: Add gas check

        assertEq(zkTLSGateway.requestHash(requestId), bytes32(0));
        assertEq(zkTLSGateway.requestProverId(requestId), bytes32(0));
        assertEq(zkTLSGateway.requestFromAccount(requestId), address(0));
    }

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.test_TLSCall.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_ZkTLSDeployed.selector);
        }
    }
}
