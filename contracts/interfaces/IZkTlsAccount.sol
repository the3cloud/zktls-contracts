// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IZkTlsAccount {

	error FieldValueLengthMismatch();
	error InsufficientPaidGas();
	error InsufficientTokenBalance();
	error InsufficientTokenAllowance();
	error PaymentTokenTransferFailed();
	error GasRefundFailed();
	error UnauthorizedCaller();
	error InvalidResponseHandler();

	event PaymentInfo(
		uint256 usedGas,
		uint256 lockedFee,
		uint256 usedFee
	);

	struct TemplatedRequest {
		bytes32 requestTemplateHash;
		bytes32 responseTemplateHash;
		uint64[] fields;
		bytes[] values;
	}

	function requestTLSCallTemplate(
		bytes32 proverId,
		string calldata remote,
		string calldata serverName,
		bytes calldata encryptedKey,
		bool enableEncryption,
		TemplatedRequest calldata request,
		uint256 fee,
		uint256 maxResponseBytes
	) external payable returns (bytes32 requestId);

	function deliveryResponse(
		bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response,
		uint256 lockedFee,
		uint256 actualUsedBytes
	) external payable;

}
