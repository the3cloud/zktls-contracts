// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IZkTLSGateway } from "./interfaces/IZkTLSGateway.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { RequestId } from "./lib/RequestId.sol";
import { RequestData } from "./lib/RequestData.sol";
import { IProofVerifier } from "./interfaces/IProofVerifier.sol";

contract ZkTLSGateway is
	IZkTLSGateway,
	Initializable,
	UUPSUpgradeable,
	OwnableUpgradeable,
	ReentrancyGuardUpgradeable
{
	/// @notice Address of the zkTLS manager contract
	address public manager;

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

	function initialize(address owner_, address manager_) external initializer {
		__Ownable_init(owner_);
		__ReentrancyGuard_init();

		manager = manager_;
	}

	function setProverVerifier(
		bytes32 proverId,
		address verifierAddress_,
		address submitterAddress_,
		address beneficiaryAddress_
	) external {
		require(
			msg.sender == manager || msg.sender == owner(),
			"Only manager or owner can set prover verifier"
		);
		require(verifierAddress_ != address(0), "Invalid verifier address");

		proverVerifierAddress[proverId] = verifierAddress_;
		proverSubmitterAddress[proverId] = submitterAddress_;
		proverBeneficiaryAddress[proverId] = beneficiaryAddress_;
	}

	function requestTLSCallTemplate(
		bytes32 proverId_,
		bytes calldata requestData_,
		bytes calldata responseTemplateData_,
		bytes calldata encryptedKey_,
		uint256 maxResponseBytes_
	) external payable returns (bytes32 requestId) {
		requestId = RequestId.compute(msg.sender, nonce++);

		requestHash[requestId] = RequestData.hash(requestData_);
		requestProverId[requestId] = proverId_;
		requestFromAccount[requestId] = msg.sender;

		emit RequestTLSCallBegin(
			requestId,
			proverId_,
			requestData_,
			responseTemplateData_,
			encryptedKey_,
			maxResponseBytes_
		);
	}

	function deliveryResponse(
		bytes32 requestId_,
		bytes32 requestHash_,
		bytes calldata response_,
		bytes calldata proof_
	) external {
		bytes memory receipt = abi.encode(requestHash_, response_);

		address verifier = proverVerifierAddress[requestProverId[requestId_]];

		IProofVerifier(verifier).verifyProof(receipt, proof_);

		// TODO: Call account

		delete requestHash[requestId_];
		delete requestProverId[requestId_];
		delete requestFromAccount[requestId_];
	}

	function computeFee(
		bytes32 proverId_,
		bytes calldata,
		uint256 maxResponseBytes_
	) public view returns (uint256 nativeGas, uint256 paymentFee) {
		(uint256 nativeVerifyGas, uint256 paymentVerifyFee) = IProofVerifier(
			proverVerifierAddress[proverId_]
		).nativeVerifyGas();

		// compute native gas
		nativeGas = maxResponseBytes_ * 16 + nativeVerifyGas;

		// compute payment token gas
		uint256 bytesWeight = 20;
		paymentFee = paymentVerifyFee + maxResponseBytes_ * bytesWeight;
	}

	function _authorizeUpgrade(
		address newImplementation
	) internal override onlyOwner {}
}
