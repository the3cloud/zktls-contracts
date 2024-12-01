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

### Deployment

```bash
# deploy contracts with create2
forge script script/DeployCreate2.sol:Deploy --rpc-url <url> --private-key <key>
# deploy general contracts
forge script script/Deploy.sol:Deploy --rpc-url <url> --private-key <key>
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

| Contract Name | Address | Deployed BlockChains |
| --- | --- | --- |
| The3Cloud create2 factory | `0x04761a3E8093decaF771b5958B5702A0E17f38A3` | [linea sepolia](https://sepolia.lineascan.build/address/0x04761a3E8093decaF771b5958B5702A0E17f38A3) |
| ZkTLSGateway proxy   | `0x0d26e10ab50fc195f38ca31a61e5bedf761413a4` | [linea sepolia](https://sepolia.lineascan.build/address/0x0d26e10ab50fc195f38ca31a61e5bedf761413a4) |
| ZkTLSManager proxy   | `0xeE937b49eD211144A8478d892346811E2feAcAE9` | [linea sepolia](https://sepolia.lineascan.build/address/0xeE937b49eD211144A8478d892346811E2feAcAE9) | 
| ZkTLSAccount Beacon  | `0x...` | |
| The3CloudCoin Faucet | `0x...` | |




