using ERC20Mock as _ERC20;

/////////////////// METHODS ///////////////////////
methods {
    function _.name() external => DISPATCHER(true);
    function _.symbol() external => DISPATCHER(true);
    function _.decimals() external => DISPATCHER(true);
    function _.totalSupply() external => DISPATCHER(true);
    function _.balanceOf(address) external => DISPATCHER(true);
    function _.allowance(address, address) external => DISPATCHER(true);
    function _.approve(address, uint256) external => DISPATCHER(true);
    function _.transfer(address, uint256) external => DISPATCHER(true);
    function _.transferFrom(address, address, uint256) external => DISPATCHER(true);
}

///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////
ghost mathint sumOfBalances {
    init_state axiom sumOfBalances == 0;
}

hook Sload uint256 balance _ERC20._balances[KEY address addr] {
    require sumOfBalances >= balance;
}

hook Sstore _ERC20._balances[KEY address addr] uint256 newValue (uint256 oldValue) {
    sumOfBalances = sumOfBalances - oldValue + newValue;
}

///////////////// PROPERTIES //////////////////////
invariant totalSupplyIsSumOfBalances()
    _ERC20.totalSupply() == sumOfBalances;


