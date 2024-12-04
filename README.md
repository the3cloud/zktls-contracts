# ZkTLS Contract

The core ZkTLS contracts consist of three components:

- `ZkTLSManager`: A Manager that handles account and prover setups. 
- `ZkTLSGateway`: A Gateway that handles various TLS requests and emits events for relaying interactions.
- `ZkTLSAccount`: Gateway Clients that each client/account associates with a single dApp and enableso interactions with The3Cloud ZkTLS Gateway.


### Install Dependencies
```bash
git clone https://github.com/the3cloud/zktls-contracts
cd zktls-contracts
forge soldeer install
```

### Deployment on Anvil

```bash
anvil
# deploy the3cloud deployer for deterministic deployment, then payment toekn, gateway and manager
# transfer gas to deployer
cast send --private-key <src_pk> --rpc-url <url> --value <amount> <deployer_addr>
# check balance
cast balance --rpc-url=<url> <deployer_addr>
# deploy the3cloud contracts
forge script script/Deploy.sol:Deploy --rpc-url <url> --private-key <key>
# deploy faucet contract
forge script script/DeployCreate2.sol:Deploy --rpc-url <url> --private-key <key>


## contracts verification
```bash
forge verify-contract --chain-id <chain_id> --etherscan-api-key <etherscan_api_key> <contract_address> <contract_path>
```

## Directory Structure 

```
/zktls-contracts
|-- config (forge cli configuration)
|-- contracts (core contracts)
|-- script (deployment scripts)
      |-- interfaces (interface definitions)
      |-- lib (share struct definitions)
      |-- mock (mock contracts for testing)
      |-- prover (wapper verifier contracts for risc0 and sp verifiers)
      |-- Create2Deployer.sol (deterministic create2 deployer)
      |-- SimpleFaucetsol (The3CloudCoin Faucet contract)
      |-- ZkTLSGateway.sol (the entrypoint contract for ZkTLS)
      |-- ZkTLSManager.sol (the manager contract for ZkTLSGateway)
      |-- ZkTLSAccount.sol (the acount/client contract for ZkTLSGateway, associated with dApps)
|-- test (unit tests for ci)
|-- lib (dependencies installed by forge)
|-- mdbook (mdbook configuration for documentation)
|-- foundry.toml (foundry configuration)
```

## Deployments

Please refer to the [config directory](https://github.com/the3cloud/zktls-contracts/tree/main/config) and find related chain id to find deployed contract address.

## Deployed Prover ID

| Prover ID | Native Gas Cost | Payment Fee | Verifier Type |
|-----------|----------------|-------------|---------------|
| 0xe4f395abcf8e2cf08d98b83966e70024139469def2c9bfc97266900c3983454d | 1000 | 1000 | mock |
