# IProofVerifier
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/interfaces/IProofVerifier.sol)


## Functions
### verifyProof


```solidity
function verifyProof(bytes calldata publicValues, bytes calldata proofBytes) external view;
```

### verifyGas


```solidity
function verifyGas() external view returns (uint256 nativeVerifyGas, uint256 paymentVerifyFee);
```

