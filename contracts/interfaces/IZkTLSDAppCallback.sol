// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IZkTLSDAppCallback {
    function deliveryResponse(bytes32 requestId_, bytes calldata response_) external;
}
