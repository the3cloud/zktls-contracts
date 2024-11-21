// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IZkTlsResponseHandler {
	function handleResponse(
		bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response
	) external payable;
}
