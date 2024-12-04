// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library RequestId {
    function compute(address contract_, address account, uint256 nonce) internal pure returns (bytes32) {
        return keccak256(abi.encode(contract_, account, nonce));
    }
}
