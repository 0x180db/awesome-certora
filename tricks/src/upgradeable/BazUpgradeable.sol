// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../libraries/SlotLibrary.sol";

abstract contract BazUpgradeable is ContextUpgradeable {
    
    /// @dev Storage structure for Baz contract state
    struct BazStorage {
        uint256 value;
    }

    /// @dev Storage slot for Baz contract state
    // bytes32 private constant _barStorageSlot = bytes32(uint256(0xcdef));
    bytes32 private immutable _barStorageSlot = bytes32(uint256(0xcdef));

    /// @dev Returns the storage struct for Baz contract state
    function _barStorage() private view returns (BazStorage storage $) {
        bytes32 slot = _barStorageSlot;
        assembly {
            $.slot := slot
        }
    }

    // function initialize(bytes calldata initParams) external;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(string memory name_, uint256 version_) {
        // _barStorageSlot = SlotLibrary.getSlot("BazUpgradeable", name_, version_);
        _disableInitializers();
    }

    /// @dev Main function that sets flag and calls Foo contract
    function setValue(uint256 value) public {
        BazStorage storage $ = _barStorage();
        
        $.value = value;
    }

    /// @dev Getter for flag state
    function value() public view returns (uint256) {
        BazStorage storage $ = _barStorage();
        return $.value;
    }
}
