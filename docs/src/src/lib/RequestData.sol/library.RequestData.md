# RequestData
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/lib/RequestData.sol)


## Functions
### parseRequestDataLight


```solidity
function parseRequestDataLight(bytes memory data) internal pure returns (RequestDataLight memory);
```

### encodeRequestDataFull


```solidity
function encodeRequestDataFull(RequestDataFull memory requestData) internal pure returns (bytes memory);
```

### parseRequestDataFull


```solidity
function parseRequestDataFull(bytes memory data) public pure returns (RequestDataFull memory);
```

### hash


```solidity
function hash(bytes calldata data) public pure returns (bytes32);
```

## Structs
### RequestDataFull

```solidity
struct RequestDataFull {
    uint256 encryptedOffset;
    uint64[] fields;
    bytes[] values;
    string remote;
    string serverName;
    bytes32 requestTemplateHash;
}
```

### RequestDataLight

```solidity
struct RequestDataLight {
    uint256 encryptedOffset;
    uint64[] fields;
    bytes[] values;
}
```

