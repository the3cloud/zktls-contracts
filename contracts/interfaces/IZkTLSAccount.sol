// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IZkTLSAccount {
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
