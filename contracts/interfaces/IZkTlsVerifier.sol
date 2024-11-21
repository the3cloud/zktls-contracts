// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IZkTlsVerifier {
	function verify(
		bytes calldata publicValues, // requestHash + responseData
    bytes calldata proof
	) external returns (bool);
}
