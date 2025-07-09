// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;

    IERC20 public asset;
    mapping(address => uint256) public balances;

    constructor(address _asset) {
        asset = IERC20(_asset);
    }

    function deposit(uint256 amount) public {
        asset.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }
}
