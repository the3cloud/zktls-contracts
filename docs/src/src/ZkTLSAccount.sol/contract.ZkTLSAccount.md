# ZkTLSAccount
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/ZkTLSAccount.sol)

**Inherits:**
[IZkTLSAccount](/src/interfaces/IZkTLSAccount.sol/interface.IZkTLSAccount.md), Initializable, AccessManagedUpgradeable


## State Variables
### TX_STATIC_GAS
The static gas for a transaction


```solidity
uint256 constant TX_STATIC_GAS = 21000;
```


### gateway
The gateway address


```solidity
address public gateway;
```


### paymentToken
The payment token address


```solidity
address public paymentToken;
```


### paddingGas
The padding gas


```solidity
uint256 public paddingGas;
```


### dApps
Which dApps are allowed to use this account


```solidity
mapping(address => bool) public dApps;
```


### requestFrom
Which dApp sent a request


```solidity
mapping(bytes32 => address) public requestFrom;
```


### requestCallbackGasLimit
Mapping of requestId to callback gas limit


```solidity
mapping(bytes32 => uint256) public requestCallbackGasLimit;
```


### requestExpectedGasPrice
Mapping of requestId to expected gas price


```solidity
mapping(bytes32 => uint256) public requestExpectedGasPrice;
```


### requestPaymentFee
Mapping of requestId to payment fee


```solidity
mapping(bytes32 => uint256) public requestPaymentFee;
```


### lockedToken
Mapping of token to locked amount


```solidity
mapping(address => uint256) public lockedToken;
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor();
```

### initialize


```solidity
function initialize(address gateway_, address admin_, address paymentToken_, uint256 paddingGas_) public initializer;
```

### requestTLSCallTemplate

Request a TLS call template


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

### deliveryResponse

Delivery the response

*This function only can be called by gateway.*


```solidity
function deliveryResponse(uint256 gas_, bytes32 requestId_, address proverBeneficiaryAddress_, bytes calldata response_)
    external;
```

### addDApp


```solidity
function addDApp(address dapp_) external restricted;
```

### removeDApp


```solidity
function removeDApp(address dapp_) external restricted;
```

### withdrawERC20


```solidity
function withdrawERC20(address token_, uint256 amount_) external restricted;
```

### withdrawNative


```solidity
function withdrawNative(uint256 amount_) external restricted;
```

### fallback


```solidity
fallback() external payable;
```

### receive


```solidity
receive() external payable;
```

