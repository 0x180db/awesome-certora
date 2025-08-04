// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import {Bar} from "./Bar.sol";

contract Foo {
    bool public flag = true;
    Bar public b;

    constructor(address _b) {
        b = Bar(_b);
    }

    function foo() public {
        if (flag) {
            flag = false;
            b.bar();
        }
    }
}

