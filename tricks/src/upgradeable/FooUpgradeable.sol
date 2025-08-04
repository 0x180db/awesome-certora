// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {BarUpgradeable} from "./BarUpgradeable.sol";

contract FooUpgradeable is Initializable, ContextUpgradeable,
OwnableUpgradeable {
    
    /// @dev Storage structure for Foo contract state
    struct FooStorage {
        bool flag;
        BarUpgradeable b;
    }

    /// @dev Storage slot for Foo contract state
    /// @dev keccak256("foo.storage.slot") - 1
    bytes32 private constant _fooStorageSlot = bytes32(uint256(0xabcd));

    /// @dev Returns the storage struct for Foo contract state
    function _fooStorage() internal pure returns (FooStorage storage fs) {
        bytes32 slot = _fooStorageSlot;
        assembly {
            fs.slot := slot
        }
    }

    /// @dev Event emitted when foo function is called
    event FooCalled(address indexed caller, uint256 callCount);
    
    /// @dev Event emitted when flag is reset
    event FlagReset(address indexed admin);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Initializer function replacing constructor for upgradeable contracts
    /// @param _b Address of the Bar contract
    function initialize(address _b) public initializer {
        __Context_init();
        __Ownable_init(_msgSender());

        FooStorage storage $ = _fooStorage();
        $.flag = false;
        $.b = BarUpgradeable(_b);
    }

    /// @dev Main function that checks flag and calls Bar contract
    function foo() public payable {
        FooStorage storage $ = _fooStorage();
        $.flag = true;
        $.b.setValue(msg.value);
    }

    /// @dev Getter for flag state
    function flag() public view returns (bool) {
        FooStorage storage $ = _fooStorage();
        return $.flag;
    }

    /// @dev Getter for Bar contract address
    function b() public view returns (BarUpgradeable) {
        FooStorage storage $ = _fooStorage();
        return $.b;
    }
}
