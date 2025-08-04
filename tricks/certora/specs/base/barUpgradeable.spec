using BarUpgradeableHarness as _BarUpgradeable;

/////////////////// METHODS ///////////////////////
methods {
    function _BarUpgradeable.setValue(uint256) external envfree;
    function _BarUpgradeable.value() external returns (uint256) envfree;
    function _BarUpgradeable.isInitializing() external returns(bool) envfree;
    function _BarUpgradeable.balanceOf(address) external returns (uint256) envfree;
    // function _BarUpgradeable.initialize(address) external envfree;
    // function _BarUpgradeable.renounceOwnership() external envfree;
    // function _BarUpgradeable.resetFlag() external envfree;
    // function _BarUpgradeable.transferOwnership(address) external envfree;
}


///////////////// DEFINITIONS /////////////////////

////////////////// FUNCTIONS //////////////////////

///////////////// GHOSTS & HOOKS //////////////////

///////////////// PROPERTIES //////////////////////
