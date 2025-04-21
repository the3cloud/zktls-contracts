// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IProofVerifier} from "../interfaces/IProofVerifier.sol";
import {IRiscZeroVerifier} from "risc0-ethereum/IRiscZeroVerifier.sol";

contract RISC0Verifier is IProofVerifier {
    address public immutable risc0Verifier;

    bytes32 public immutable imageId;

    constructor(address risc0Verifier_, bytes32 imageId_) {
        risc0Verifier = risc0Verifier_;
        imageId = imageId_;
    }

    function verifyProof(bytes calldata publicValues_, bytes calldata proofBytes_) external view {
        bytes32 journalDigest = sha256(publicValues_);

        IRiscZeroVerifier(risc0Verifier).verify(proofBytes_, imageId, journalDigest);
    }

    function verifyGas() external pure returns (address[] memory verifiers_, uint256[] memory paymentVerifyFees_) {
        verifiers_ = new address[](1);
        verifiers_[0] = address(0);

        paymentVerifyFees_ = new uint256[](1);
    }
}
