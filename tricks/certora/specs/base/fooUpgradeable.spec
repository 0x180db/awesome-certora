using FooUpgradeableHarness as _FooUpgradeable;

/////////////////// METHODS ///////////////////////
methods {
    function _FooUpgradeable.foo() external;
    function _FooUpgradeable.flag() external returns (bool) envfree;
    function _FooUpgradeable.isInitializing() external returns(bool) envfree;
    function _FooUpgradeable.b() external returns(address) envfree;

    // function _FooUpgradeable.renounceOwnership() external envfree;
    // function _FooUpgradeable.resetFlag() external envfree;
    // function _FooUpgradeable.transferOwnership(address) external envfree;
}


///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////

///////////////// PROPERTIES //////////////////////
