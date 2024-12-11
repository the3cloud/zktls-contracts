// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {AddressRegisterLib} from "./lib/AddressRegisterLib.sol";
import {AddressRegister} from "./AddressRegister.sol";

contract ZkTLSClient is Initializable, AccessManagedUpgradeable {
    using Address for address payable;

    AddressRegister public register;

    mapping(bytes32 => address) public dAppKeyToAddress;
    mapping(bytes32 => bool) public isDAppKeyRegistered;

    function initialize(address register_, address admin_) public initializer {
        __AccessManaged_init(admin_);

        register = AddressRegister(register_);
    }

    error DAppKeyAlreadyRegistered();

    function addDApp(bytes32 dAppKey_, address dAppAddress_) public restricted {
        if (isDAppKeyRegistered[dAppKey_]) {
            revert DAppKeyAlreadyRegistered();
        }

        isDAppKeyRegistered[dAppKey_] = true;
        dAppKeyToAddress[dAppKey_] = dAppAddress_;
    }

    error OnlySuperAdmin();

    modifier onlySuperAdmin() {
        if (msg.sender != register.registeredAddress(AddressRegisterLib.SUPER_ADMIN_ADDRESS)) {
            revert OnlySuperAdmin();
        }
        _;
    }

    function withdrawToken(address token_, address payable to_, uint256 amount_) public onlySuperAdmin {
        if (token_ == address(0)) {
            to_.sendValue(amount_);
        } else {
            IERC20(token_).transfer(to_, amount_);
        }
    }

    error OnlyService();

    modifier onlyService() {
        // We can add other service in future.
        if (msg.sender != register.registeredAddress(AddressRegisterLib.ZKTLS_GATEWAY_ADDRESS)) {
            revert OnlyService();
        }
        _;
    }

    function chargeToken(address[] calldata tokens_, address payable to_, uint256[] calldata amounts_)
        public
        onlyService
    {
        for (uint256 i = 0; i < tokens_.length; i++) {
            if (tokens_[i] == address(0)) {
                to_.sendValue(amounts_[i]);
            } else {
                IERC20(tokens_[i]).transfer(to_, amounts_[i]);
            }
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
