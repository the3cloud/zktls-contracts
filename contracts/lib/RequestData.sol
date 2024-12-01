// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library RequestData {
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

        uint64[] memory fields = new uint64[](light.encryptedOffset);
        bytes[] memory values = new bytes[](light.encryptedOffset);

        for (uint256 i = 0; i < light.encryptedOffset; i++) {
            fields[i] = light.fields[i];
            values[i] = light.values[i];
        }

        return keccak256(abi.encode(light.encryptedOffset, fields, values, segment));
    }
}
