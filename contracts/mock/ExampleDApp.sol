// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IZkTLSDAppCallback} from "../interfaces/IZkTLSDAppCallback.sol";
import {IZkTLSAccount} from "../interfaces/IZkTLSAccount.sol";
import {RequestData} from "../lib/RequestData.sol";

import {console} from "forge-std/console.sol";

contract ExampleDApp is IZkTLSDAppCallback {
    address public immutable account;

    bytes32 public constant PROVER_ID = keccak256("ExampleProver");

    event ResponseGot(bytes32 requestId, bytes response);

    constructor(address account_) {
        account = account_;
    }

    function deliveryResponse(bytes32 requestId_, bytes calldata response_) external {
        emit ResponseGot(requestId_, response_);
    }

    function buildRequestData() public pure returns (RequestData.RequestDataFull memory requestData) {
        uint64[] memory fields = new uint64[](2);
        fields[0] = 25;
        fields[1] = 39;

        bytes[] memory values = new bytes[](2);
        values[0] = "httpbin.org";
        values[1] = "Close";

        requestData = RequestData.RequestDataFull({
            encryptedOffset: 2,
            fields: fields,
            values: values,
            remote: "httpbin.org:443",
            serverName: "httpbin.org",
            /// This template will store the request data:
            /// "GET /get HTTP/1.1\r\nHost: \r\nConnection: \r\n\r\n"
            requestTemplateHash: 0
        });
    }

    function requestTLSCallTemplate() external returns (bytes32 requestId) {
        RequestData.RequestDataFull memory requestData = buildRequestData();

        bytes memory encodedRequestData = RequestData.encodeRequestDataFull(requestData);

        console.logBytes(encodedRequestData);

        requestId = IZkTLSAccount(account).requestTLSCallTemplate(
            PROVER_ID, encodedRequestData, bytes(""), bytes(""), 1000, 30000, 5 gwei
        );
    }
}
