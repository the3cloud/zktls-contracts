# ZkTLS Contract

## Deploy

```bash
git clone https://github.com/the3cloud/zktls-contracts
cd contracts
forge soldeer install
forge script script/DeployCreate2.sol:Deploy --rpc-url <url> --private-key <key>
forge script script/Deploy.sol:Deploy --rpc-url <url> --private-key <key>
```

## Deterministic Deployment

