// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IZkTlsAccount } from "./IZkTlsAccount.sol";

interface IZkTlsGateway {
	error UnauthorizedAccess();
	error ResponseExceedsMaxSize();
	error InsufficientGas();
	error InvalidRequestHash();
	error FieldValueLengthMismatch();
	error InvalidProver();

	struct CallbackInfo {
		bytes32 proverId;
		address proxyAccount;
		uint256 requestBytes;
		uint256 maxResponseBytes;
		uint256 fee;
		uint256 nonce;
		bytes32 requestHash;
		bytes32 requestTemplateHash;
		bytes32 responseTemplateHash;
	}

	struct ProverInfo {
		address verifierAddress;
		bytes32 programVKey;
	}

	event RequestTLSCallBegin(
		bytes32 indexed requestId,
		bytes32 indexed prover,
		bytes32 requestTemplateHash,
		bytes32 responseTemplateHash,
		string remote,
		string serverName,
		bytes encryptedKey,
		uint256 maxResponseBytes
	);
	event RequestTLSCallSegment(
		bytes32 indexed requestId,
		bytes data,
		bool enableEncryption
	);
	event RequestTLSCallTemplateField(
		bytes32 indexed requestId,
		uint64 indexed field,
		bytes value,
		bool enableEncryption
	);
	event RequestTLSCallEnd(bytes32 indexed requestId);
	event GasUsed(
		bytes32 indexed requestId,
		uint256 paiedGas,
		uint256 gasUsed,
		uint256 gasPrice
	);

	function estimateFee(
		uint256 requestBytes,
		uint256 maxResponseBytes
	) external view returns (uint256);

	function requestTLSCallTemplate(
		bytes32 proverId,
		string calldata remote,
		string calldata serverName,
		bytes calldata encryptedKey,
		bool enableEncryption,
		IZkTlsAccount.TemplatedRequest calldata request,
		uint256 fee,
		uint64 nonce,
		uint256 maxResponseBytes
	) external payable returns (bytes32 requestId);

	function deliveryResponse(
		bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response,
		// solhint-disable-next-line no-unused-vars
		bytes calldata proofs
	) external payable;
}
