// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title ZkTLSAccount interface
interface IZkTLSAccount {
    /// @notice This function initiates a secure TLS request to zkTLS account.
    /// @param proverId_ The unique identifier of the prover, you can find prover listed at [ZkTL contracts doc](https://docs.the3cloud.io/zktls-contracts/)
    /// @param requestData_ The encoded request data containing HTTP request
    /// @param responseTemplateData_ the encoded response template, which may contain regex patterns for response matching
    /// @param encryptedKey_ The encrypted session key for secure communication
    /// @param maxResponseBytes_ Maximum allowed size of the response in bytes
    /// @param requestCallbackGasLimit_ Gas limit for the callback function execution
    /// @param expectedGasPrice_ Expected gas price for transaction execution
    /// @return requestId A unique identifier for tracking this TLS request
    function requestTLSCallTemplate(
        bytes32 proverId_,
        bytes calldata requestData_,
        bytes calldata responseTemplateData_,
        bytes calldata encryptedKey_,
        uint256 maxResponseBytes_,
        uint256 requestCallbackGasLimit_,
        uint256 expectedGasPrice_
    ) external payable returns (bytes32 requestId);
}
