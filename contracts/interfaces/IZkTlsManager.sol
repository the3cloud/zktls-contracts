// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Specify the compiler version

interface IZkTlsManager { 

  event SetTokenWeiPerBytes(uint256 tokenWeiPerBytes); 
  error UnInitializedBeacon();
  error InvalidGatewayId(uint8 gatewayId);
  error InvalidGatewayAddress(address gateway);

  event UpgradeAuthorized(address indexed newImplementation);

	event SimpleZkTlsAccountCreated(
		address indexed gateway,
		address indexed beaconProxy
	);

	// dynamic types getters
	function CALLBACK_UNIT_GAS() external view returns (uint256);
	function tokenWeiPerBytes() external view returns (uint256);
	function feeReceiver() external view returns (address);
	function callbackBaseGas() external view returns (uint256);

	function hasAccess(address account) external view returns (bool);
}