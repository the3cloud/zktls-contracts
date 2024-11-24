/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {VmSafe} from "forge-std/Vm.sol";

library Forge {
    address constant CHEATCODE_ADDRESS = address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function safeVm() internal pure returns (VmSafe vm) {
        vm = VmSafe(CHEATCODE_ADDRESS);
    }
}
