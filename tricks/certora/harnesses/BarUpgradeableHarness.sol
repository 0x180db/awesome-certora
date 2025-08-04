// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../../src/upgradeable/BarUpgradeable.sol";

contract BarUpgradeableHarness is BarUpgradeable {
    constructor(string memory name_, uint256 version_) BarUpgradeable(name_, version_) {}

    function isInitializing() public view returns (bool) {
        return _isInitializing();
    }
}
