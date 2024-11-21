#! /bin/bash

source .env
source ./scripts/contract_info.sh
source ./scripts/utils.sh

function estimate_fee() {
    local request_bytes=$1
    local max_response_bytes=$2

    local rst=$(cast call -r $SEPOLIA_RPC_URL $ZKTLS_GATEWAY_ADDRESS \
        "estimateFee(uint256,uint256)(uint256)" \
        $request_bytes \
        $max_response_bytes)
    echo "$rst"
}

EstimatedFee=$(estimate_fee 16 2000)
echo $EstimatedFee


cast send 0x8622F295950BB1F09e8984B6e9193AF96cE837dA \
    "requestTLSCallTemplate(bytes32,string,string,bytes,bool,(bytes32,bytes32,uint64[],bytes[]),uint256,uint256)" \
    0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6 \
    "https://httpbin.org" "httpbin.org" 0x false \
    '(0xc26377b8ba957d5463fea7b3a81a449e137f035c247ecb3dc46c0583a17c23e3,0x44d3146233af2c13228abf0bae80dd653527f799f167edf382f73c3fb9ccf9ee,[25,39],[0x6874747062696e2e6f7267,0x436c6f7365])' \
      2016000000000 \
      2000 \
      --value 0.01ether \
      --private-key <private_key> \
      --rpc-url <rpc-url>


cast calldata \
"requestTLSCallTemplate(bytes32,string,string,bytes,bool,(bytes32,bytes32,uint64[],bytes[]),uint256,uint256)" \
    0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6 \
    "httpbin.org:443" \
    "httpbin.org" 0x false \
    '(0xc26377b8ba957d5463fea7b3a81a449e137f035c247ecb3dc46c0583a17c23e3,0x44d3146233af2c13228abf0bae80dd653527f799f167edf382f73c3fb9ccf9ee,[25,39],[0x6874747062696e2e6f7267,0x436c6f7365])' \
    2016000000000 2000

 