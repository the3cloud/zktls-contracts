# ZkTLSManager
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/ZkTLSManager.sol)

**Inherits:**
Initializable, UUPSUpgradeable, OwnableUpgradeable

**Author:**
the3cloud
This contract used to register provers and register Account.

ZkTLS manager contract


## State Variables
### accountBeacon
Account beacon address


```solidity
address public accountBeacon;
```


### accessManagerBeacon
AccessManager beacon address


```solidity
address public accessManagerBeacon;
```


### paymentToken
Payment token address


```solidity
address public paymentToken;
```


### paddingGas
Padding gas


```solidity
uint256 public paddingGas;
```


### zkTLSGateway
ZkTLSGateway address


```solidity
address public zkTLSGateway;
```


### isRegisteredAccount
Is registered account


```solidity
mapping(address => bool) public isRegisteredAccount;
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
function initialize(
    address owner_,
    address zkTLSGateway_,
    address accountBeacon_,
    address accessManagerBeacon_,
    address paymentToken_,
    uint256 paddingGas_
) public initializer;
```

### registerAccount

Register account


```solidity
function registerAccount(address admin_) public returns (address account, address accessManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin_`|`address`|Admin address|


### setAccountBeacon


```solidity
function setAccountBeacon(address accountBeacon_) external onlyOwner;
```

### setAccessManagerBeacon


```solidity
function setAccessManagerBeacon(address accessManagerBeacon_) external onlyOwner;
```

### registerProver

Register prover to ZkTLSGateway

*For now, this function only can set by owner. In future, anyone can become a prover.*


```solidity
function registerProver(
    bytes32 proverId_,
    address verifierAddress_,
    address submitterAddress_,
    address beneficiaryAddress_
) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proverId_`|`bytes32`|Prover ID|
|`verifierAddress_`|`address`|Verifier address|
|`submitterAddress_`|`address`|Submitter address|
|`beneficiaryAddress_`|`address`|Beneficiary address|


### setGateway

Set ZkTLSGateway address by owner


```solidity
function setGateway(address zkTLSGateway_) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`zkTLSGateway_`|`address`|ZkTLSGateway address|


### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

## Events
### ProverRegistered

```solidity
event ProverRegistered(
    bytes32 indexed proverId, address verifierAddress, address submitterAddress, address beneficiaryAddress
);
```

### AccountRegistered

```solidity
event AccountRegistered(address indexed account);
```

