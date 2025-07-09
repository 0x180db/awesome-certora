// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VaultScript is Script {
    Vault public counter;
    ERC20Mock public asset;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        asset = new ERC20Mock();
        counter = new Vault(address(asset));

        vm.stopBroadcast();
    }
}
