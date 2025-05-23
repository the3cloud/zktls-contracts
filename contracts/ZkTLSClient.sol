// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {ZkTLSManager} from "./ZkTLSManager.sol";

contract ZkTLSClient is Initializable, AccessManagedUpgradeable {
    using Address for address payable;

    address public gateway;
    ZkTLSManager public manager;

    mapping(bytes32 => address) public dAppKeyToAddress;
    mapping(bytes32 => bool) public isDAppKeyRegistered;

    function initialize(address gateway_, address manager_, address admin_) public initializer {
        __AccessManaged_init(admin_);

        gateway = gateway_;
        manager = ZkTLSManager(manager_);
    }

    error DAppKeyAlreadyRegistered();

    event DAppAdded(bytes32 indexed dAppKey, address indexed dAppAddress);

    function addDApp(bytes32 dAppKey_, address dAppAddress_) public restricted {
        if (isDAppKeyRegistered[dAppKey_]) {
            revert DAppKeyAlreadyRegistered();
        }

        isDAppKeyRegistered[dAppKey_] = true;
        dAppKeyToAddress[dAppKey_] = dAppAddress_;

        emit DAppAdded(dAppKey_, dAppAddress_);
    }

    error OnlyWithdrawer();

    modifier onlyWithdrawer() {
        if (msg.sender != manager.withdrawer()) {
            revert OnlyWithdrawer();
        }
        _;
    }

    event TokenWithdrawn(address indexed token, address indexed to, uint256 amount);

    function withdrawToken(address token_, address payable to_, uint256 amount_) public onlyWithdrawer {
        if (token_ == address(0)) {
            to_.sendValue(amount_);
        } else {
            IERC20(token_).transfer(to_, amount_);
        }

        emit TokenWithdrawn(token_, to_, amount_);
    }

    error OnlyService();

    modifier onlyService() {
        // We can add other service in future.
        if (msg.sender != gateway) {
            revert OnlyService();
        }
        _;
    }

    event TokenCharged(address indexed token, address indexed to, uint256 amount);

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

            emit TokenCharged(tokens_[i], to_, amounts_[i]);
        }
    }

    error DAppKeyNotRegistered();

    function getDAppAddress(bytes32 dAppKey_) public view returns (address) {
        if (!isDAppKeyRegistered[dAppKey_]) {
            revert DAppKeyNotRegistered();
        }

        return dAppKeyToAddress[dAppKey_];
    }

    receive() external payable {}

    fallback() external payable {}
}
