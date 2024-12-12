/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {VmSafe, Vm} from "forge-std/Vm.sol";

library Forge {
    address constant CHEATCODE_ADDRESS = address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function safeVm() internal pure returns (VmSafe vm_) {
        vm_ = VmSafe(CHEATCODE_ADDRESS);
    }

    function vm() internal pure returns (Vm vm_) {
        vm_ = Vm(CHEATCODE_ADDRESS);
    }
}
