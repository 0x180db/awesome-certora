import "./base/vault.spec";
import "./dependencies/erc20.spec";

using ERC20Mock as _Asset;
 
/////////////////// METHODS ///////////////////////
methods {
    function _Asset.balanceOf(address) external returns (uint256) envfree;
    function _Asset.totalSupply() external returns (uint256) envfree;
}

///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////

///////////////// PROPERTIES //////////////////////
rule depositIntegrityProblematic(env e) {
    uint256 amount;

    require(e.msg.sender != currentContract);
    require(amount > 0);

    uint256 balanceOfUserBefore = balances(e.msg.sender);
    uint256 assetBalanceOfVaultBefore = _Asset.balanceOf(currentContract);

    deposit(e, amount);

    uint256 balanceOfUserAfter = balances(e.msg.sender);
    uint256 assetBalanceOfVaultAfter = _Asset.balanceOf(currentContract);

    // This could overflow! assetBalanceOfVaultAfter might wrap around
    assert(assetBalanceOfVaultAfter > assetBalanceOfVaultBefore);
}

rule depositIntegrityFixed(env e) {
    uint256 amount;
    
    requireInvariant totalSupplyIsSumOfBalances; // This is the key!

    require(e.msg.sender != currentContract);
    require(amount > 0);

    uint256 balanceOfUserBefore = balances(e.msg.sender);
    uint256 assetBalanceOfVaultBefore = _Asset.balanceOf(currentContract);

    deposit(e, amount);

    uint256 balanceOfUserAfter = balances(e.msg.sender);
    uint256 assetBalanceOfVaultAfter = _Asset.balanceOf(currentContract);

    // Now assetBalanceOfVaultAfter cannot overflow
    assert(assetBalanceOfVaultAfter > assetBalanceOfVaultBefore);
}

