// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProofVerifier {
	function verifyProof(
		bytes calldata publicValues,
		bytes calldata proofBytes
	) external view;

	function nativeVerifyGas()
		external
		view
		returns (uint256 nativeVerifyGas, uint256 paymentVerifyFee);
}
