// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract DeployMock is Script {
	function run() external {
		vm.startBroadcast();

		vm.stopBroadcast();
	}
}
