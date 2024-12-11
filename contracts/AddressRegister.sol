// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AddressRegister is Ownable {
    mapping(bytes32 => address) public registeredAddress;

    constructor(address owner_) Ownable(owner_) {}

    function register(bytes32 salt_, address addr) public {
        registeredAddress[salt_] = addr;
    }
}
