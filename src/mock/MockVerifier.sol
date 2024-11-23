// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IProofVerifier } from "../interfaces/IProofVerifier.sol";

contract MockVerifier is IProofVerifier {
	error InvalidProof();

	uint256 public VERIFY_GAS = 1000;
	uint256 public VERIFY_FEE = 1000;

	uint256 public expectedProofLength = 0;

	constructor() {}

	function verifyProof(
		bytes calldata /* publicValues */,
		bytes calldata proofBytes
	) external view {
		if (proofBytes.length != expectedProofLength) revert InvalidProof();
	}

	function verifyGas()
		external
		view
		returns (uint256 nativeVerifyGas, uint256 paymentVerifyFee)
	{
		nativeVerifyGas = VERIFY_GAS;
		paymentVerifyFee = VERIFY_FEE;
	}
}
