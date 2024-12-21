// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {SP1Verifier} from "sp1-contracts/v3.0.0/SP1VerifierGroth16.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        SP1Verifier verifier = new SP1Verifier();

        console.log("SP1Verifier deployed at", address(verifier));

        vm.stopBroadcast();
    }
}
