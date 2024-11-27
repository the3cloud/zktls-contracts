// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library RequestId {
    function compute(address account, uint256 nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(address(this), account, nonce));
    }
}
