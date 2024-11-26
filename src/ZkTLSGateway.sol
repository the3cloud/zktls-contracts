// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IZkTLSGateway} from "./interfaces/IZkTLSGateway.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {RequestId} from "./lib/RequestId.sol";
import {RequestData} from "./lib/RequestData.sol";
import {IProofVerifier} from "./interfaces/IProofVerifier.sol";
import {ZkTLSAccount} from "./ZkTLSAccount.sol";
import {ZkTLSManager} from "./ZkTLSManager.sol";

contract ZkTLSGateway is IZkTLSGateway, Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Address of the zkTLS manager contract
    address public manager;

    /// @notice Bytes weight
    uint256 public bytesWeight;

    /// @notice Mapping of requestId to callbackInfo
    mapping(bytes32 => bytes32) public requestHash;

    /// @notice Mapping of requestId to proverId
    mapping(bytes32 => bytes32) public requestProverId;

    /// @notice Mapping of requestId to account
    mapping(bytes32 => address) public requestFromAccount;

    /// @notice Mapping of ProverID to verifier address
    mapping(bytes32 => address) public proverVerifierAddress;

    /// @notice Mapping of ProverID to prover submitter address
    mapping(bytes32 => address) public proverSubmitterAddress;

    /// @notice Mapping of ProverID to prover beneficiary address
    mapping(bytes32 => address) public proverBeneficiaryAddress;

    /// @notice Nonce
    uint256 public nonce;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner_, uint256 bytesWeight_) external initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();

        bytesWeight = bytesWeight_;
    }

    function setManager(address manager_) external onlyOwner {
        manager = manager_;
    }

    function setBytesWeight(uint256 bytesWeight_) external onlyOwner {
        bytesWeight = bytesWeight_;
    }

    /// @notice Set the verifier for a prover
    /// @dev Only the manager or owner can set the verifier for a prover
    /// @param proverId The ID of the prover
    /// @param verifierAddress_ The address of the verifier
    /// @param submitterAddress_ The address of the submitter
    /// @param beneficiaryAddress_ The address of the beneficiary
    function setProverVerifier(
        bytes32 proverId,
        address verifierAddress_,
        address submitterAddress_,
        address beneficiaryAddress_
    ) external {
        require(msg.sender == manager || msg.sender == owner(), "Only manager or owner can set prover verifier");
        require(verifierAddress_ != address(0), "Invalid verifier address");

        proverVerifierAddress[proverId] = verifierAddress_;
        proverSubmitterAddress[proverId] = submitterAddress_;
        proverBeneficiaryAddress[proverId] = beneficiaryAddress_;
    }

    /// @notice Request a TLS call template
    /// @dev only account can call this function.
    /// @param proverId_ The ID of the prover
    /// @param requestData_ The request data
    /// @param responseTemplateData_ The response template data
    /// @param encryptedKey_ The encrypted key
    /// @param maxResponseBytes_ The maximum response bytes
    function requestTLSCallTemplate(
        bytes32 proverId_,
        bytes calldata requestData_,
        bytes calldata responseTemplateData_,
        bytes calldata encryptedKey_,
        uint256 maxResponseBytes_
    ) external payable returns (bytes32 requestId) {
        require(
            ZkTLSManager(manager).isRegisteredAccount(msg.sender),
            "Only registered account can request TLS call template"
        );

        requestId = RequestId.compute(msg.sender, nonce++);

        requestHash[requestId] = RequestData.hash(requestData_);
        requestProverId[requestId] = proverId_;
        requestFromAccount[requestId] = msg.sender;

        emit RequestTLSCallBegin(
            requestId, proverId_, requestData_, responseTemplateData_, encryptedKey_, maxResponseBytes_
        );
    }

    event ResponseVerified(bytes32 requestId, bytes32 requestHash);

    /// @notice Delivery the response
    /// @dev This function only can be called by prover defined by request..
    /// @param requestId_ The ID of the request
    /// @param requestHash_ The hash of the request
    /// @param response_ The response
    /// @param proof_ The proof
    function deliveryResponse(bytes32 requestId_, bytes32 requestHash_, bytes calldata response_, bytes calldata proof_)
        external
    {
        require(msg.sender == proverSubmitterAddress[requestProverId[requestId_]], "Only prover can delivery response");

        uint256 gas = gasleft();

        bytes memory receipt = abi.encode(requestHash_, response_);

        address verifier = proverVerifierAddress[requestProverId[requestId_]];

        IProofVerifier(verifier).verifyProof(receipt, proof_);

        emit ResponseVerified(requestId_, requestHash_);

        ZkTLSAccount(payable(requestFromAccount[requestId_])).deliveryResponse(
            gas, requestId_, beneficiaryAddressByRequestId(requestId_), response_
        );

        delete requestHash[requestId_];
        delete requestProverId[requestId_];
        delete requestFromAccount[requestId_];
    }

    function computeFee(bytes32 proverId_, bytes calldata, /* responseTemplateData_ */ uint256 responseBytes_)
        public
        view
        returns (uint256 nativeGas, uint256 paymentFee)
    {
        (uint256 nativeVerifyGas, uint256 paymentVerifyFee) =
            IProofVerifier(proverVerifierAddress[proverId_]).verifyGas();

        // compute native gas
        nativeGas = responseBytes_ * 16 + nativeVerifyGas;

        // compute payment token gas
        paymentFee = paymentVerifyFee + responseBytes_ * bytesWeight;
    }

    function beneficiaryAddressByRequestId(bytes32 requestId_) internal view returns (address) {
        return proverBeneficiaryAddress[requestProverId[requestId_]];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
