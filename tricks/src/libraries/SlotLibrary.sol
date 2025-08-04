// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

library SlotLibrary {
    function getSlot(string memory contractName, string memory name, uint256 version) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                uint256(keccak256(abi.encodePacked("awesome.certora.storage.", contractName, name, version))) - 1
            )
        ) & ~bytes32(uint256(0xff));
    }
}

