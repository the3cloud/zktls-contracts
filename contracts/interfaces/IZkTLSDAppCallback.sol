// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title ZkTLSDAppCallback interfacie, implemented by ddApps
interface IZkTLSDAppCallback {
    function deliveryResponse(bytes32 requestId_, bytes calldata response_) external;
}
