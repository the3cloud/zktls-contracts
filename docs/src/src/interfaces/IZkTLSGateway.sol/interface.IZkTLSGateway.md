# IZkTLSGateway
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/interfaces/IZkTLSGateway.sol)


## Functions
### deliveryResponse


```solidity
function deliveryResponse(bytes32 requestId, bytes32 requestHash, bytes calldata response, bytes calldata proofs)
    external;
```

## Events
### RequestTLSCallBegin

```solidity
event RequestTLSCallBegin(
    bytes32 indexed requestId,
    bytes32 indexed prover,
    bytes requestData,
    bytes responseTemplateData,
    bytes encryptedKey,
    uint256 maxResponseBytes
);
```

