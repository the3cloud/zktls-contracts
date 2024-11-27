// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IProofVerifier} from "../interfaces/IProofVerifier.sol";

import {ISP1Verifier} from "sp1-contracts/ISP1Verifier.sol";

contract SP1Prover is IProofVerifier {
    address public immutable sp1Verifier;

    bytes32 public immutable programVKey;

    uint256 public immutable nativeVerifyGas;
    uint256 public immutable paymentVerifyFee;

    constructor(address sp1Verifier_, bytes32 programVKey_, uint256 nativeVerifyGas_, uint256 paymentVerifyFee_) {
        sp1Verifier = sp1Verifier_;
        programVKey = programVKey_;
        nativeVerifyGas = nativeVerifyGas_;
        paymentVerifyFee = paymentVerifyFee_;
    }

    function verifyProof(bytes calldata publicValues_, bytes calldata proofBytes_) external view {
        ISP1Verifier(sp1Verifier).verifyProof(programVKey, publicValues_, proofBytes_);
    }

    function verifyGas() external view returns (uint256 nativeVerifyGas_, uint256 paymentVerifyFee_) {
        return (nativeVerifyGas, paymentVerifyFee);
    }
}
