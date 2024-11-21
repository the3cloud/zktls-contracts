// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { IZkTlsManager } from "./interfaces/IZkTlsManager.sol";
import { SimpleZkTlsAccount } from "./SimpleZkTlsAccount.sol";

/**
 * @title ZkTlsManager
 * @notice Manages ZkTls accounts and system configurations
 * @dev Implements UUPS upgradeable pattern for account management
 */
contract ZkTlsManager is
	IZkTlsManager,
	Initializable,
	UUPSUpgradeable,
	OwnableUpgradeable
{
	/** @notice Gas cost per byte for callbacks */
	uint256 public constant CALLBACK_UNIT_GAS = 4;

	/** @notice Payment token address */
	address public paymentToken;
	/** @notice Address that receives fees */
	address public feeReceiver;
	/** @notice Implementation beacon for account proxies */
	address public accountBeacon;
	/** @notice Base gas cost for callbacks */
	uint256 public callbackBaseGas;
	/** @notice Token fee per byte of data */
	uint256 public tokenWeiPerBytes;

	/** @notice Tracks authorized proxy accounts */
	mapping(address => bool) public proxyAccounts;

	/**
	 * @notice Initializes the contract with the specified payment token and owner.
	 * @dev This function can only be called once due to the `initializer` modifier.
	 * @param callbackBaseGas_ The base gas for callback.
	 * @param tokenWeiPerBytes_ The token wei per bytes.
	 * @param feeReceiver_ The address of the fee receiver.
	 * @param accountBeacon_ The address of the account beacon.
	 * @param owner_ The address that will be set as the owner of the contract.
	 */
	function initialize(
		uint256 callbackBaseGas_,
		uint256 tokenWeiPerBytes_,
		address feeReceiver_,
		address accountBeacon_,
		address paymentToken_,
		address owner_
	) public initializer {
		__UUPSUpgradeable_init();
		__Ownable_init(owner_);
		callbackBaseGas = callbackBaseGas_;
		tokenWeiPerBytes = tokenWeiPerBytes_;
		feeReceiver = feeReceiver_;
		accountBeacon = accountBeacon_;
		paymentToken = paymentToken_;
	}
	function hasAccess(address account) external view returns (bool) {
		return proxyAccounts[account];
	}

	function setProxyAccount(address account, bool access) external onlyOwner {
		proxyAccounts[account] = access;
	}

	/**
	 * @notice Sets the address of the account beacon.
	 * @dev This function can only be called by the contract owner.
	 * @param accountBeacon_ The new address of the account beacon.
	 */
	function setAccountBeacon(address accountBeacon_) external onlyOwner {
		accountBeacon = accountBeacon_;
	}
	
	/**  
	 * @notice Authorizes an upgrade to a new contract implementation.
	 * @dev Emits an `UpgradeAuthorized` event upon successful authorization.
	 * @param newImplementation The address of the new contract implementation.
	 */
	function _authorizeUpgrade(
		address newImplementation
	) internal override onlyOwner {
		emit UpgradeAuthorized(newImplementation);
	}

	/**
	 * @notice Creates a new account and links it to the specified gateway and response handler.
	 * @dev Reverts if the account beacon is uninitialized or the gateway ID is invalid.
	 * @param gateway The address of the gateway for which the account is created.
	 * @param responseHandler The address to handle responses for the account.
	 * @param refundAddress The address to receive refunds.
	 * @return account The address of the newly created account proxy.
	 */
	function createAccount(
		address gateway,
		address responseHandler,
		address refundAddress
	) external returns (address account) {
		if (accountBeacon == address(0)) revert UnInitializedBeacon();

		bytes memory data = abi.encodeCall(
			SimpleZkTlsAccount.initialize,
			(
				address(this),
				gateway,
				paymentToken,
				responseHandler,
				refundAddress
			)
		);
		BeaconProxy beaconProxy = new BeaconProxy(accountBeacon, data);
		proxyAccounts[address(beaconProxy)] = true;
		emit SimpleZkTlsAccountCreated(gateway, address(beaconProxy));
		return address(beaconProxy);
	}
}
