// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {IProofVerifier} from "./interfaces/IProofVerifier.sol";
import {ZkTLSClient} from "./ZkTLSClient.sol";
import {IZkTLSDAppCallback} from "./interfaces/IZkTLSAppCallback.sol";

contract ZkTLSGateway is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Mapping of ProverID to verifier address
    mapping(bytes32 => address) public proverVerifierAddress;

    /// @notice Mapping of ProverID to prover submitter address
    mapping(bytes32 => address) public proverSubmitterAddress;

    /// @notice Mapping of ProverID to prover beneficiary address
    mapping(bytes32 => address) public proverBeneficiaryAddress;

    function initialize(address owner_) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
    }

    error OnlySubmitterCanDeliverResponse();
    error ProverNotRegistered();
    error DAppNotRegistered();

    function checkProver(bytes32 proverId_) private view {
        address submitter = proverSubmitterAddress[proverId_];
        address verifier = proverVerifierAddress[proverId_];
        address beneficiary = proverBeneficiaryAddress[proverId_];

        if (submitter == address(0)) {
            revert ProverNotRegistered();
        }
        if (verifier == address(0)) {
            revert ProverNotRegistered();
        }
        if (beneficiary == address(0)) {
            revert ProverNotRegistered();
        }

        // Revert if the message sender is the submitter
        if (msg.sender != submitter) {
            revert OnlySubmitterCanDeliverResponse();
        }
    }

    error InvalidGasVerifyFeesNumber();

    event TokenCharged(address indexed client, address indexed to);

    function chargeGas(
        ZkTLSClient client_,
        uint256 gas_,
        bytes32 proverId_,
        uint256 maxGasPrice_,
        uint256 publicValuesLength_
    ) private {
        uint256 gasCost = gas_ - gasleft();

        (address[] memory tokens_, uint256[] memory paymentVerifyFees_) =
            IProofVerifier(proverVerifierAddress[proverId_]).verifyGas(gasCost, maxGasPrice_, publicValuesLength_);

        address beneficiary = proverBeneficiaryAddress[proverId_];

        client_.chargeToken(tokens_, payable(beneficiary), paymentVerifyFees_);

        emit TokenCharged(address(client_), beneficiary);
    }

    event ResponseDeliveredTo(bytes32 indexed responseId, address indexed client, address indexed dApp);
    event ResponseDeliveredData(bytes32 indexed responseId, bytes32 indexed proverId, bytes proof, bytes publicValues);

    function deliverResponse(
        bytes calldata proof_,
        bytes32 proverId_,
        bytes32 responseId_,
        address client_,
        bytes32 dapp_,
        uint64 maxGasPrice_,
        uint64 gasLimit_,
        bytes calldata responses_
    ) public {
        uint256 gas = gasleft();

        // Check if the prover is valid
        checkProver(proverId_);

        // Check if the client is registered
        ZkTLSClient client = ZkTLSClient(payable(client_));

        if (!client.isDAppKeyRegistered(dapp_)) {
            revert DAppNotRegistered();
        }

        // Verify the proof
        bytes memory publicValues = abi.encode(responseId_, client_, dapp_, maxGasPrice_, gasLimit_, responses_);
        IProofVerifier(proverVerifierAddress[proverId_]).verifyProof(publicValues, proof_);
        emit ResponseDeliveredData(responseId_, proverId_, proof_, publicValues);

        // Call the dApp
        address dAppAddress = callDApp(client, dapp_, gasLimit_, responseId_, responses_);

        emit ResponseDeliveredTo(responseId_, client_, dAppAddress);

        chargeGas(client, gas, proverId_, maxGasPrice_, publicValues.length);
    }

    function callDApp(
        ZkTLSClient client,
        bytes32 dAppKey_,
        uint64 gasLimit_,
        bytes32 responseId_,
        bytes calldata responses_
    ) private returns (address dAppAddress) {
        dAppAddress = client.getDAppAddress(dAppKey_);
        if (dAppAddress != address(0)) {
            (bool success, bytes memory data) = dAppAddress.call{gas: gasLimit_}(
                abi.encodeCall(IZkTLSDAppCallback.deliveryResponse, (responseId_, responses_))
            );

            // bubble up the error if the callback fails
            if (!success) {
                if (data.length > 0) {
                    assembly {
                        revert(add(data, 32), mload(data))
                    }
                } else {
                    revert("DApp callback failed");
                }
            }
        }
    }

    function registerProver(bytes32 proverId_, address verifier_, address submitter_, address beneficiary_)
        public
        onlyOwner
    {
        proverVerifierAddress[proverId_] = verifier_;
        proverSubmitterAddress[proverId_] = submitter_;
        proverBeneficiaryAddress[proverId_] = beneficiary_;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
