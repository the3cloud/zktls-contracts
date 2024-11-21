// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IZkTlsAccount } from "./interfaces/IZkTlsAccount.sol";
import { IZkTlsGateway } from "./interfaces/IZkTlsGateway.sol";
import { IZkTlsManager } from "./interfaces/IZkTlsManager.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IZkTlsResponseHandler } from "./interfaces/IZkTlsResponseHandler.sol";

/**
 * @title SimpleZkTlsAccount
 * @notice Represents individual accounts that can make TLS requests
 * @dev Handles request management, fee handling and response processing
 */
contract SimpleZkTlsAccount is IZkTlsAccount, Initializable {
	/** @notice Manager contract address */
	address public manager;
	/** @notice Gateway contract address */
	address public gateway;
	/** @notice Response handler contract address */
	address public responseHandler;
	/** @notice Payment token address */
	address public paymentToken;
	/** @notice Address to receive refunds */
	address public refundAddress;
	/** @notice Request nonce for sequencing */
	uint64 public nonce;
	/** @notice Amount of payment tokens locked for pending requests */
	uint256 public lockedAmount;
	/** @notice Contract version for upgrades */
	uint8 public constant VERSION = 1;

	/**
	 * @notice Initializes the account with required addresses and settings
	 * @param manager_ Address of the ZkTls manager contract
	 * @param gateway_ Address of the ZkTls gateway contract
	 * @param paymentToken_ Address of the token used for payments
	 * @param responseHandler_ Address of the contract handling responses
	 * @param refundAddress_ Address to receive any refunds
	 */
	function initialize(
		address manager_,
		address gateway_,
		address paymentToken_,
		address responseHandler_,
		address refundAddress_
	) public initializer {
		manager = manager_;
		gateway = gateway_;
		paymentToken = paymentToken_;
		responseHandler = responseHandler_;
		refundAddress = refundAddress_;
		nonce = 0;
	}

	/**
	 * @notice Sends a templated TLS request through the gateway
	 * @param proverId Identifier of the TLS provider
	 * @param remote Remote endpoint URL
	 * @param serverName TLS server name
	 * @param encryptedKey Encrypted key for secure communication
	 * @param enableEncryption Whether to enable response encryption
	 * @param request Templated request parameters
	 * @param fee Amount of tokens to lock for the request
	 * @param maxResponseBytes Maximum expected response size in bytes
	 * @return requestId Unique identifier for the request
	 */
	function requestTLSCallTemplate(
		bytes32 proverId,
		string calldata remote,
		string calldata serverName,
		bytes calldata encryptedKey,
		bool enableEncryption,
		TemplatedRequest calldata request,
		uint256 fee,
		uint256 maxResponseBytes
	) public payable returns (bytes32 requestId) {
		// check payment token balance and gas
		_lockFee(fee);
		if (estimateCallbackGas(maxResponseBytes) > address(this).balance)
			revert InsufficientPaidGas();
		// send request to gateway
		requestId = IZkTlsGateway(gateway).requestTLSCallTemplate(
			proverId,
			remote,
			serverName,
			encryptedKey,
			enableEncryption,
			request,
			fee,
			nonce,
			maxResponseBytes
		);

		nonce++;
	}

	/**
	 * @notice Callback function called by gateway to deliver TLS response
	 * @param requestId Unique identifier of the request
	 * @param requestHash Hash of the original request
	 * @param response Response data from the TLS call
	 * @param lockedFee Amount of tokens that were locked for this request
	 * @param actualUsedBytes Actual number of bytes used in the response
	 */
	function deliveryResponse(
		bytes32 requestId,
		bytes32 requestHash,
		bytes calldata response,
		uint256 lockedFee,
		uint256 actualUsedBytes
	) external payable {
		if (msg.sender != gateway) revert UnauthorizedCaller();

		uint256 start = gasleft();
		bytes memory data = abi.encodeWithSelector(
			IZkTlsResponseHandler.handleResponse.selector,
			requestId,
			requestHash,
			response
		);
		// TODO: callback with exact gas limit
		(bool success, bytes memory returndata) = responseHandler.call(data);
		//(bool success, bytes memory returndata) = responseHandler.call{gas: paidGas}(data);
		if (!success) {
			// If the call reverts, bubble up the revert reason if there is one
			if (returndata.length > 0) {
				assembly {
					let returndata_size := mload(returndata)
					revert(add(32, returndata), returndata_size)
				}
			} else {
				revert("Call failed");
			}
		}
		
		uint256 usedGas = start - gasleft();
		uint256 usedFee = _transferFee(usedGas, lockedFee, actualUsedBytes);
		// uint256 paidFee = 1000;
		emit PaymentInfo(usedGas, lockedFee, usedFee);
	}

	function _transferFee(
		uint256 usedGas,
		uint256 lockedFee,
		uint256 usedBytes
	) internal returns (uint256 usedFee) {
		if (address(this).balance < usedGas) revert InsufficientPaidGas();
		usedFee =
			usedBytes *
			IZkTlsManager(manager).tokenWeiPerBytes();
		// transfer fee and used gass to fee receiver
		SafeERC20.safeTransfer(
			IERC20(paymentToken),
			IZkTlsManager(manager).feeReceiver(),
			usedFee
		);
		lockedAmount -= lockedFee;
		Address.sendValue(
			payable(IZkTlsManager(manager).feeReceiver()),
			usedGas
		);
	}

	function _lockFee(uint256 fee) internal {
		if (IERC20(paymentToken).balanceOf(address(this)) - lockedAmount < fee)
			revert InsufficientTokenBalance();
		lockedAmount += fee;
	}

	/**
	 * @notice Updates the response handler contract address
	 * @param responseHandler_ New response handler contract address
	 */
	function setResponseHandler(address responseHandler_) public {
		responseHandler = responseHandler_;
	}

	/**
	 * @notice Calculates the estimated gas needed for the callback
	 * @param maxResponseBytes Maximum expected response size in bytes
	 * @return Estimated gas amount needed for the callback
	 */
	function estimateCallbackGas(
		uint256 maxResponseBytes
	) public view returns (uint256) {
		return
			IZkTlsManager(manager).callbackBaseGas() +
			maxResponseBytes * IZkTlsManager(manager).CALLBACK_UNIT_GAS();
	}

	receive() external payable {}

}
