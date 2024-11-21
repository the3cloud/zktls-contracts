#!/bin/bash
OWNER_PRIVATE_KEY=<owner_private_key>
RPC_URL=<rpc_url>
ACCOUNT_BEACON=0x6cb4185c3D8723252650Ce2Cb6b539c5B8c649f3
ACCOUNT_BEACON_PROXY=0x8622F295950BB1F09e8984B6e9193AF96cE837dA
ZKTLS_MANAGER_ADDRESS=0x894Bf834bc32c9c3c02c99b372283383a2C28f1F

# 1. set account beacon
cast send --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  $ZKTLS_MANAGER_ADDRESS \
  "setAccountBeacon(address)" \
  $ACCOUNT_BEACON

# 2. add proxy account
cast send --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  $ZKTLS_MANAGER_ADDRESS \
  "setProxyAccount(address,bool)" \
  $ACCOUNT_BEACON_PROXY \
  true

cast call $ACCOUNT_BEACON_PROXY "responseHandler()" --rpc-url $RPC_URL
cast call $ACCOUNT_BEACON_PROXY "owner()" --rpc-url $RPC_URL


