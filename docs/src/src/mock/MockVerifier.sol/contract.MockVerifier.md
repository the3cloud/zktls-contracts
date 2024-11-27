# MockVerifier
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/mock/MockVerifier.sol)

**Inherits:**
[IProofVerifier](/src/interfaces/IProofVerifier.sol/interface.IProofVerifier.md)


## State Variables
### VERIFY_GAS

```solidity
uint256 public VERIFY_GAS = 1000;
```


### VERIFY_FEE

```solidity
uint256 public VERIFY_FEE = 1000;
```


### expectedProofLength

```solidity
uint256 public expectedProofLength = 0;
```


## Functions
### constructor


```solidity
constructor();
```

### verifyProof


```solidity
function verifyProof(bytes calldata, bytes calldata proofBytes) external view;
```

### verifyGas


```solidity
function verifyGas() external view returns (uint256 nativeVerifyGas, uint256 paymentVerifyFee);
```

## Errors
### InvalidProof

```solidity
error InvalidProof();
```

