// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IZkTLSDAppCallback} from "./interfaces/IZkTLSDAppCallback.sol";
import {ZkTLSGateway} from "./ZkTLSGateway.sol";
import {IZkTLSAccount} from "./interfaces/IZkTLSAccount.sol";

/// @title ZkTLSAccount is the client of dApps to interact with ZkTLsGateway.
/// @notice ZkTLSAccount acts as an intermediary between dApps and the ZkTLS system, created and
/// registered through the ZkTLSManager's factory pattern. Each account is deployed as a beacon proxy with its
/// own access manager, allowing for flexible administrative control while maintaining upgradeability.
contract ZkTLSAccount is IZkTLSAccount, Initializable, AccessManagedUpgradeable {
    using Address for address payable;

    /// @notice The static gas for a transaction
    uint256 constant TX_STATIC_GAS = 21000;

    /// @notice The gateway address
    address public gateway;

    /// @notice The payment token address
    address public paymentToken;

    /// @notice The padding gas
    uint256 public paddingGas;

    /// @notice Which dApps are allowed to use this account
    mapping(address => bool) public dApps;

    /// @notice Which dApp sent a request
    mapping(bytes32 => address) public requestFrom;

    /// @notice Mapping of requestId to callback gas limit
    mapping(bytes32 => uint256) public requestCallbackGasLimit;

    /// @notice Mapping of requestId to expected gas price
    mapping(bytes32 => uint256) public requestExpectedGasPrice;

    /// @notice Mapping of requestId to payment fee
    mapping(bytes32 => uint256) public requestPaymentFee;

    /// @notice Mapping of token to locked amount
    mapping(address => uint256) public lockedToken;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address gateway_, address admin_, address paymentToken_, uint256 paddingGas_)
        public
        initializer
    {
        __AccessManaged_init(admin_);

        gateway = gateway_;
        paymentToken = paymentToken_;
        paddingGas = paddingGas_;
    }

    error InvalidDApp(address dApp);
    event LockedToken(
        address index sender,
        bytes32 index requestId, 
        uint256 nativeGasAmount,
        uint256 paymentFeeAmount
    );
    /// @notice This function initiates a secure TLS request to zkTLS account.
    /// @param proverId_ The unique identifier of the prover, you can find prover listed at [ZkTL contracts doc](https://docs.the3cloud.io/zktls-contracts/) 
    /// @param requestData_ The encoded request data containing HTTP request
    /// @param responseTemplateData_ the encoded response template, which may contain regex patterns for response matching
    /// @param encryptedKey_ The encrypted session key for secure communication
    /// @param maxResponseBytes_ Maximum allowed size of the response in bytes
    /// @param requestCallbackGasLimit_ Gas limit for the callback function execution
    /// @param expectedGasPrice_ Expected gas price for transaction execution
    /// @return requestId A unique identifier for tracking this TLS request
    function requestTLSCallTemplate(
        bytes32 proverId_,
        bytes calldata requestData_,
        bytes calldata responseTemplateData_,
        bytes calldata encryptedKey_,
        uint256 maxResponseBytes_,
        uint256 requestCallbackGasLimit_,
        uint256 expectedGasPrice_
    ) external payable returns (bytes32 requestId) {
        if (!dApps[msg.sender]) revert InvalidDApp(msg.sender);

        requestId = ZkTLSGateway(gateway).requestTLSCallTemplate(
            proverId_, requestData_, responseTemplateData_, encryptedKey_, maxResponseBytes_
        );

        requestFrom[requestId] = msg.sender;

        requestCallbackGasLimit[requestId] = requestCallbackGasLimit_;
        requestExpectedGasPrice[requestId] = expectedGasPrice_;

        (uint256 nativeGas, uint256 paymentFee) =
            ZkTLSGateway(gateway).computeFee(proverId_, responseTemplateData_, maxResponseBytes_);

        nativeGas += requestCallbackGasLimit_ + paddingGas + TX_STATIC_GAS;

        uint256 gasFee = nativeGas * expectedGasPrice_;
        lockedToken[address(0)] += gasFee;

        requestPaymentFee[requestId] = paymentFee;
        lockedToken[paymentToken] += paymentFee;

        emit LockedToken(msg.sender, requestId, gasFee, paymentFee);
    }

    error InvalidGateway(address gateway);
    error RequestNotFound(bytes32 requestId);
    error CallbackFailed(bytes32 requestId);

    /// @notice Delivery the response to response handler defined in dApp.
    /// @dev This function only can be called by gateway.
    /// @param gas_ The gas amount used for the response delivery
    /// @param requestId_ The unique identifier of the original TLS request
    /// @param proverBeneficiaryAddress_ The address that will receive the payment for proof verification
    /// @param response_ The verified response data from the TLS request
    function deliveryResponse(
        uint256 gas_,
        bytes32 requestId_,
        address proverBeneficiaryAddress_,
        bytes calldata response_
    ) external {
        if (msg.sender != gateway) revert InvalidGateway(msg.sender);

        address requestFrom_ = requestFrom[requestId_];
        if (requestFrom_ == address(0)) revert RequestNotFound(requestId_);

        uint256 gasLimit = requestCallbackGasLimit[requestId_];
        (bool success,) = address(requestFrom_).call{gas: gasLimit}(
            abi.encodeCall(IZkTLSDAppCallback.deliveryResponse, (requestId_, response_))
        );
        if (!success) revert CallbackFailed(requestId_);

        // TODO: fix here
        IERC20(paymentToken).transfer(proverBeneficiaryAddress_, requestPaymentFee[requestId_]);
        lockedToken[paymentToken] -= requestPaymentFee[requestId_];

        uint256 nativeGas = gas_ - gasleft() + TX_STATIC_GAS;

        uint256 nativeGasValue = 0;
        if (tx.gasprice > requestExpectedGasPrice[requestId_]) {
            nativeGasValue = nativeGas * requestExpectedGasPrice[requestId_];
        } else {
            nativeGasValue = nativeGas * tx.gasprice;
        }

        payable(proverBeneficiaryAddress_).sendValue(nativeGasValue);
        lockedToken[address(0)] -= nativeGasValue;

        // emit PaymentReceived(requestId_, nativeGasValue, requestPaymentFee[requestId_]);
        
        delete requestFrom[requestId_];
        delete requestCallbackGasLimit[requestId_];
        delete requestExpectedGasPrice[requestId_];
    }

    // TODO: events
    function addDApp(address dapp_) external restricted {
        dApps[dapp_] = true;
    }
    // TODO: events
    function removeDApp(address dapp_) external restricted {
        dApps[dapp_] = false;
    }

    function withdrawERC20(address token_, uint256 amount_) external restricted {
        IERC20(token_).transfer(msg.sender, amount_);
    }

    function withdrawNative(uint256 amount_) external restricted {
        payable(msg.sender).transfer(amount_);
    }

    fallback() external payable {}

    receive() external payable {}
}
