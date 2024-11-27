# SimpleFaucet
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/SimpleFaucet.sol)

**Inherits:**
Ownable


## State Variables
### paymentToken
The payment token


```solidity
address public paymentToken;
```


### minNativeAmount
The minimum amount of native token required to request


```solidity
uint256 public minNativeAmount;
```


### amountPerRequest
The amount of payment token to be sent per request


```solidity
uint256 public amountPerRequest;
```


## Functions
### constructor


```solidity
constructor(address paymentToken_, address owner_, uint256 amountPerRequest_, uint256 minNativeAmount_)
    Ownable(owner_);
```

### request

The function to request the payment token


```solidity
function request() private;
```

### fallback

The fallback function to request the payment token


```solidity
fallback() external payable;
```

### receive

The receive function to request the payment token


```solidity
receive() external payable;
```

### setAmountPerRequest

The function to set the amount of payment token to be sent per request


```solidity
function setAmountPerRequest(uint256 amountPerRequest_) public onlyOwner;
```

### setMinNativeAmount

The function to set the minimum amount of native token required to request


```solidity
function setMinNativeAmount(uint256 minNativeAmount_) public onlyOwner;
```

### setPaymentToken

The function to set the payment token


```solidity
function setPaymentToken(address paymentToken_) public onlyOwner;
```

### withdrawNative

The function to withdraw the native token


```solidity
function withdrawNative(address to, uint256 amount) public onlyOwner;
```

### withdrawToken

The function to withdraw the payment token


```solidity
function withdrawToken(address to, uint256 amount) public onlyOwner;
```

## Errors
### InsufficientNativeAmount
The error thrown when the native amount is insufficient


```solidity
error InsufficientNativeAmount();
```

