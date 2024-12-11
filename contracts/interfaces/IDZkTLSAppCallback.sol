// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title ZkTLSDAppCallback interfacie, implemented by ddApps
interface IZkTLSDAppCallback {
    /// @notice Callback function that receives the response from a ZkTLS request
    /// @dev This function is called by the ZkTLS gatewal when a response is ready
    /// @param requestId_ The unique identifier of the TLS request
    /// @param response_ The verified response data from the TLS request
    function deliveryResponse(bytes32 requestId_, bytes[] calldata response_) external;
}
