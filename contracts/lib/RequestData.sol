// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title RequestData library for ZkTLS request data structures
library RequestData {
    /// @notice RequestDataFull is used to structure TLS request data when dApps interact with ZkTLS accounts
    /// @dev This struct contains the offset for encrypted data and an array of field positions
    /// @param encryptedOffset The starting position of encrypted data in the request
    /// @param fields An array of uint64 values representing field positions in the request data
    /// @param values An array of bytes representing the values of the fields
    /// @param remote The remote server address
    /// @param serverName The server name
    /// @param requestTemplateHash The hash of the request template
    struct RequestDataFull {
        uint256 encryptedOffset;
        uint64[] fields;
        bytes[] values;
        string remote;
        string serverName;
        bytes32 requestTemplateHash;
    }

    struct RequestDataLight {
        uint256 encryptedOffset;
        uint64[] fields;
        bytes[] values;
    }

    function parseRequestDataLight(bytes memory data) internal pure returns (RequestDataLight memory) {
        (uint256 encryptedOffset, uint64[] memory fields, bytes[] memory values) =
            abi.decode(data, (uint256, uint64[], bytes[]));

        return RequestDataLight(encryptedOffset, fields, values);
    }

    function encodeRequestDataFull(RequestDataFull memory requestData) internal pure returns (bytes memory) {
        return abi.encode(
            requestData.encryptedOffset,
            requestData.fields,
            requestData.values,
            requestData.remote,
            requestData.serverName,
            requestData.requestTemplateHash
        );
    }

    function parseRequestDataFull(bytes memory data) public pure returns (RequestDataFull memory) {
        (
            uint256 encryptedOffset,
            uint64[] memory fields,
            bytes[] memory values,
            string memory remote,
            string memory serverName,
            bytes32 requestTemplateHash
        ) = abi.decode(data, (uint256, uint64[], bytes[], string, string, bytes32));

        return RequestDataFull(encryptedOffset, fields, values, remote, serverName, requestTemplateHash);
    }

    function hash(bytes calldata data) public pure returns (bytes32) {
        RequestDataLight memory light = parseRequestDataLight(data);

        uint256 segmentLength = uint256(bytes32(data[96:128]));

        bytes calldata segment = data[segmentLength:];

        uint64[] memory fields = new uint64[](light.fields.length - light.encryptedOffset);
        bytes[] memory values = new bytes[](light.values.length - light.encryptedOffset);

        for (uint256 i = 0; i < fields.length; i++) {
            fields[i] = light.fields[i];
            values[i] = light.values[i];
        }

        return keccak256(abi.encode(light.encryptedOffset, fields, values, segment));
    }
}
