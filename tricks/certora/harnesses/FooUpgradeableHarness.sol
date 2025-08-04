// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../../src/upgradeable/FooUpgradeable.sol";

contract FooUpgradeableHarness is FooUpgradeable {
    constructor() FooUpgradeable() { }

    function isInitializing() public view returns (bool) {
        return _isInitializing();
    }
}
