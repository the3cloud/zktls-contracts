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

    function verifyGas(uint256 gasUsed_, uint256 maxGasPrice_, uint256 /* publicValuesLength_ */ )
        external
        view
        returns (address[] memory verifiers_, uint256[] memory paymentVerifyFees_)
    {
        verifiers_ = new address[](1);
        verifiers_[0] = address(0);

        paymentVerifyFees_ = new uint256[](1);

        if (tx.gasprice > maxGasPrice_) {
            paymentVerifyFees_[0] = gasUsed_ * maxGasPrice_;
        } else {
            paymentVerifyFees_[0] = gasUsed_ * tx.gasprice;
        }
    }
}
