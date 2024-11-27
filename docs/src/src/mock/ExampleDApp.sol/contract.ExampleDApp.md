# ExampleDApp
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/mock/ExampleDApp.sol)

**Inherits:**
[IZkTLSDAppCallback](/src/interfaces/IZkTLSDAppCallback.sol/interface.IZkTLSDAppCallback.md)


## State Variables
### account

```solidity
address public immutable account;
```


### PROVER_ID

```solidity
bytes32 public constant PROVER_ID = keccak256("ExampleProver");
```


## Functions
### constructor


```solidity
constructor(address account_);
```

### deliveryResponse


```solidity
function deliveryResponse(bytes32 requestId_, bytes calldata response_) external;
```

### requestTLSCallTemplate


```solidity
function requestTLSCallTemplate() external;
```

## Events
### ResponseGot

```solidity
event ResponseGot(bytes32 requestId, bytes response);
```

