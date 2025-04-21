// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {IProofVerifier} from "./interfaces/IProofVerifier.sol";
import {ZkTLSClient} from "./ZkTLSClient.sol";

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

    error InvalidLengthIfGasTokenAndFee();

    event TokenCharged(address indexed client, bytes32 indexed proverId, bytes32 indexed responseId);

    function chargeGas(ZkTLSClient client_, bytes32 responseId_, bytes32 proverId_) private {
        (address[] memory tokens_, uint256[] memory paymentVerifyFees_) =
            IProofVerifier(proverVerifierAddress[proverId_]).verifyGas();

        if (tokens_.length != paymentVerifyFees_.length) {
            revert InvalidLengthIfGasTokenAndFee();
        }

        address beneficiary = proverBeneficiaryAddress[proverId_];

        client_.chargeToken(tokens_, payable(beneficiary), paymentVerifyFees_);

        emit TokenCharged(address(client_), proverId_, responseId_);
    }

    event ResponseDeliveredData(bytes32 indexed responseId, bytes32 indexed proverId, bytes proof, bytes publicValues);

    function deliverResponse(
        bytes32 proverId_,
        bytes32 responseId_,
        address client_,
        bytes32 dapp_,
        bytes32 publicValuesHash_,
        bytes calldata proof_
    ) public {
        // Check if the prover is valid
        checkProver(proverId_);

        // Check if the client is registered
        ZkTLSClient client = ZkTLSClient(payable(client_));

        if (!client.isDAppKeyRegistered(dapp_)) {
            revert DAppNotRegistered();
        }

        // Verify the proof
        bytes memory publicValues = abi.encode(responseId_, client_, dapp_, publicValuesHash_);
        IProofVerifier(proverVerifierAddress[proverId_]).verifyProof(publicValues, proof_);
        emit ResponseDeliveredData(responseId_, proverId_, proof_, publicValues);

        chargeGas(client, responseId_, proverId_);
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
