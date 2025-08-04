// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import {BazUpgradeable} from "./BazUpgradeable.sol";

contract BarUpgradeable is BazUpgradeable, ERC20Upgradeable {
    constructor(string memory name_, uint256 version_) BazUpgradeable(name_, version_) {}

    function initialize(bytes calldata data) external initializer {
        (string memory name_, string memory symbol_) =
            abi.decode(data, (string, string));
        __ERC20_init(name_, symbol_);
    }

} 
