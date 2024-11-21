// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Specify the compiler version

interface IZkTlsResponseProcessor {
    
    
  function processResponseBytes(
    bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response
  ) external payable;

}
