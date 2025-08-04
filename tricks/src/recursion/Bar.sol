// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import {Foo} from "./Foo.sol";

contract Bar {
    bool public flag = false;
    Foo public f;

    constructor(address _f) {
        f = Foo(_f);
    }

    function bar() public {
        flag = true;
        f.foo();
    }
}
