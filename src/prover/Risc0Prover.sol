// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IProofVerifier} from "../interfaces/IProofVerifier.sol";
import {IRiscZeroVerifier} from "risc0-ethereum/IRiscZeroVerifier.sol";

contract Risc0Prover is IProofVerifier {
    address public immutable risc0Verifier;

    bytes32 public immutable imageId;

    uint256 public immutable nativeVerifyGas;
    uint256 public immutable paymentVerifyFee;

    constructor(address risc0Verifier_, bytes32 imageId_, uint256 nativeVerifyGas_, uint256 paymentVerifyFee_) {
        risc0Verifier = risc0Verifier_;
        imageId = imageId_;
        nativeVerifyGas = nativeVerifyGas_;
        paymentVerifyFee = paymentVerifyFee_;
    }

    function verifyProof(bytes calldata publicValues_, bytes calldata proofBytes_) external view {
        bytes32 journalDigest = sha256(publicValues_);

        IRiscZeroVerifier(risc0Verifier).verify(proofBytes_, imageId, journalDigest);
    }

    function verifyGas() external view returns (uint256 nativeVerifyGas_, uint256 paymentVerifyFee_) {
        return (nativeVerifyGas, paymentVerifyFee);
    }
}
