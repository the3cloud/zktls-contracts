// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IProofVerifier} from "../interfaces/IProofVerifier.sol";

contract MockVerifier is IProofVerifier {
    error InvalidProof();

    uint256 public expectedProofLength = 0;

    constructor() {}

    function verifyProof(bytes calldata, /* publicValues */ bytes calldata proofBytes) external view {
        if (proofBytes.length != expectedProofLength) revert InvalidProof();
    }

    function verifyGas() external pure returns (address[] memory verifiers_, uint256[] memory paymentVerifyFees_) {
        verifiers_ = new address[](1);
        verifiers_[0] = address(0);

        paymentVerifyFees_ = new uint256[](1);
    }
}
