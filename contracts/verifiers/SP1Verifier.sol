// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IProofVerifier} from "../interfaces/IProofVerifier.sol";

import {ISP1Verifier} from "sp1-contracts/ISP1Verifier.sol";

contract SP1Verifier is IProofVerifier {
    address public immutable sp1Verifier;

    bytes32 public immutable programVKey;

    constructor(address sp1Verifier_, bytes32 programVKey_) {
        sp1Verifier = sp1Verifier_;
        programVKey = programVKey_;
    }

    function verifyProof(bytes calldata publicValues_, bytes calldata proofBytes_) external view {
        ISP1Verifier(sp1Verifier).verifyProof(programVKey, publicValues_, proofBytes_);
    }

    function verifyGas() external pure returns (address[] memory verifiers_, uint256[] memory paymentVerifyFees_) {
        verifiers_ = new address[](1);
        verifiers_[0] = address(0);

        paymentVerifyFees_ = new uint256[](1);
    }
}
