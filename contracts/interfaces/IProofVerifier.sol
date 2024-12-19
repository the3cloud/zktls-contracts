// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Verifier interface
interface IProofVerifier {
    function verifyProof(bytes calldata publicValues_, bytes calldata proofBytes_) external view;

    function verifyGas(uint256 gasUsed_, uint256 maxGasPrice_, uint256 publicValuesLength_)
        external
        view
        returns (address[] memory verifiers_, uint256[] memory paymentVerifyFees_);
}
