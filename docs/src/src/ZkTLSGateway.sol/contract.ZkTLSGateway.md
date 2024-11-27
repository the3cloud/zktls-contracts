# ZkTLSGateway
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/ZkTLSGateway.sol)

**Inherits:**
[IZkTLSGateway](/src/interfaces/IZkTLSGateway.sol/interface.IZkTLSGateway.md), Initializable, UUPSUpgradeable, OwnableUpgradeable


## State Variables
### manager
Address of the zkTLS manager contract


```solidity
address public manager;
```


### requestHash
Mapping of requestId to callbackInfo


```solidity
mapping(bytes32 => bytes32) public requestHash;
```


### requestProverId
Mapping of requestId to proverId


```solidity
mapping(bytes32 => bytes32) public requestProverId;
```


### requestFromAccount
Mapping of requestId to account


```solidity
mapping(bytes32 => address) public requestFromAccount;
```


### proverVerifierAddress
Mapping of ProverID to verifier address


```solidity
mapping(bytes32 => address) public proverVerifierAddress;
```


### proverSubmitterAddress
Mapping of ProverID to prover submitter address


```solidity
mapping(bytes32 => address) public proverSubmitterAddress;
```


### proverBeneficiaryAddress
Mapping of ProverID to prover beneficiary address


```solidity
mapping(bytes32 => address) public proverBeneficiaryAddress;
```


### nonce
Nonce


```solidity
uint256 public nonce;
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
function initialize(address owner_) external initializer;
```

### setManager


```solidity
function setManager(address manager_) external onlyOwner;
```

### setProverVerifier

Set the verifier for a prover

*Only the manager or owner can set the verifier for a prover*


```solidity
function setProverVerifier(
    bytes32 proverId,
    address verifierAddress_,
    address submitterAddress_,
    address beneficiaryAddress_
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proverId`|`bytes32`|The ID of the prover|
|`verifierAddress_`|`address`|The address of the verifier|
|`submitterAddress_`|`address`|The address of the submitter|
|`beneficiaryAddress_`|`address`|The address of the beneficiary|


### requestTLSCallTemplate

Request a TLS call template

*only account can call this function.*


```solidity
function requestTLSCallTemplate(
    bytes32 proverId_,
    bytes calldata requestData_,
    bytes calldata responseTemplateData_,
    bytes calldata encryptedKey_,
    uint256 maxResponseBytes_
) external payable returns (bytes32 requestId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proverId_`|`bytes32`|The ID of the prover|
|`requestData_`|`bytes`|The request data|
|`responseTemplateData_`|`bytes`|The response template data|
|`encryptedKey_`|`bytes`|The encrypted key|
|`maxResponseBytes_`|`uint256`|The maximum response bytes|


### deliveryResponse

Delivery the response

*This function only can be called by prover defined by request..*


```solidity
function deliveryResponse(bytes32 requestId_, bytes32 requestHash_, bytes calldata response_, bytes calldata proof_)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestId_`|`bytes32`|The ID of the request|
|`requestHash_`|`bytes32`|The hash of the request|
|`response_`|`bytes`|The response|
|`proof_`|`bytes`|The proof|


### computeFee


```solidity
function computeFee(bytes32 proverId_, bytes calldata, uint256 maxResponseBytes_)
    public
    view
    returns (uint256 nativeGas, uint256 paymentFee);
```

### beneficiaryAddressByRequestId


```solidity
function beneficiaryAddressByRequestId(bytes32 requestId_) internal view returns (address);
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

## Events
### ResponseVerified

```solidity
event ResponseVerified(bytes32 requestId, bytes32 requestHash);
```

