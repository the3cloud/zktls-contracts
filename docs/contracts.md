# ZKTLS Contracts Specification

## ZkTlsGateway

The ZkTlsGateway contract is the main entry point for making TLS requests and handling responses. It implements the UUPS upgradeable pattern and includes the following key features:

### Key Components

-   Manages prover configurations (verifier address and program verification key)
-   Handles request templating and response verification
-   Integrates with verifier for ZK proof verification
-   Tracks request callbacks and fee management

### Key Functions

-   `requestTLSCallTemplate`: Creates a new TLS request with templated fields
-   `deliveryResponse`: Handles verified responses and forwards them to accounts
-   `estimateFee`: Calculates fees based on request and response sizes

### Access Control

-   Only authorized accounts (managed by ZkTlsManager) can make requests
-   Only owner can upgrade contract and set prover configurations

## ZkTlsManager

The ZkTlsManager contract manages ZkTls accounts and system configurations. It implements the UUPS upgradeable pattern.

### Key Components

-   Account creation and management
-   Fee configuration

### Key Functions

-   `createAccount`: Creates new ZkTls accounts using beacon proxy pattern
-   `setProxyAccount`: Manages account access permissions
-   `setAccountBeacon`: Updates the account beacon address for proxy creation

### Configuration Parameters

-   `CALLBACK_UNIT_GAS`: Gas cost per byte for callbacks (4 gas/byte)
-   `tokenWeiPerBytes`: Token fee per byte of data
-   `callbackBaseGas`: Base gas cost for callbacks
-   `feeReceiver`: Address receiving fees
-   `accountBeacon`: Implementation beacon for account proxies

## SimpleZkTlsAccount

The SimpleZkTlsAccount contract represents individual accounts that can make TLS requests.

### Key Components

-   Request management and nonce tracking
-   Fee handling and token management
-   Response callback processing

### Key Functions

-   `requestTLSCallTemplate`: Makes templated TLS requests
-   `deliveryResponse`: Processes responses and handles callbacks
-   `estimateCallbackGas`: Calculates required callback gas

### State Management

-   Tracks locked token amounts
-   Manages nonce for request sequencing
-   Handles response handler configurations

### Interfaces

-   `IZkTlsVerifier`: Interface for TLS verification
-   `IZkTlsManager`: Management interface
-   `IZkTlsGateway`: Gateway interface
-   `IZkTlsAccount`: Account interface
-   `IZkTlsResponseHandler`: Response handling interface
