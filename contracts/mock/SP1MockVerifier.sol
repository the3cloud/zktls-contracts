// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISP1Verifier} from "../interfaces/ISP1Verifier.sol";

/// @title SP1 Mock Verifier
/// @author Succinct Labs
/// @notice This contracts implements a Mock solidity verifier for SP1.
contract SP1MockVerifier is ISP1Verifier {

    error InvalidProof();

    /// @notice Verifies a mock proof with given public values and vkey.
    /// @param proofBytes The proof of the program execution the SP1 zkVM encoded as bytes.
    function verifyProof(bytes32, bytes calldata, bytes calldata proofBytes) external pure {
        if (proofBytes.length != 0) revert InvalidProof();
        assert(proofBytes.length == 0);
    }
}