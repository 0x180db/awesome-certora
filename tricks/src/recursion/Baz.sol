// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

contract Baz {
    bool public flag = false;

    function bar() public {
        flag = true;
    }
}
