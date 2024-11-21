// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IZkTlsResponseHandler } from "../interfaces/IZkTlsResponseHandler.sol";

contract MockResponseHandler is IZkTlsResponseHandler {
	event ResponseHandled(
		bytes32 requestId,
		bytes32 requestHash,
		bytes response
	);

	function handleResponse(
		bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response
	) external payable{
		// Loop for 1000 iterations, used for gas estimation
    // uint64 sum = 0;
	// 	for (uint64 i = 0; i < 5000; i++) {
	// 		sum += i;
	// 	}
		emit ResponseHandled(requestId, requestHash, response);
	}
}
