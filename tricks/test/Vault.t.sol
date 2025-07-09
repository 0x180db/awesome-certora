// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {Vault} from "../src/Vault.sol";

contract DepositTest is Test {
    Vault public vault;
    ERC20Mock public asset;
    address public user = makeAddr("user");
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        asset = new ERC20Mock();   
        vault = new Vault(address(asset));

        deal(address(asset), user, DEPOSIT_AMOUNT);
    }

    function test_Deposit() public {
        vm.startPrank(user);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(vault.balances(user), DEPOSIT_AMOUNT);
        assertEq(asset.balanceOf(address(vault)), DEPOSIT_AMOUNT);
    }
}
