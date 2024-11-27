# IZkTLSAccount
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/interfaces/IZkTLSAccount.sol)


## Functions
### requestTLSCallTemplate


```solidity
function requestTLSCallTemplate(
    bytes32 proverId_,
    bytes calldata requestData_,
    bytes calldata responseTemplateData_,
    bytes calldata encryptedKey_,
    uint256 maxResponseBytes_,
    uint256 requestCallbackGasLimit_,
    uint256 expectedGasPrice_
) external payable returns (bytes32 requestId);
```

