import "./base/fooUpgradeable.spec";
import "./base/barUpgradeable.spec"; 

methods {
    function _.setValue(uint256) external => DISPATCHER(true);
}

rule fooIntegrity(env e) {
    require(_BarUpgradeable._barStorageSlot == to_bytes32(0x1));

    bool fooFlagBefore = _FooUpgradeable.flag();
    uint256 barValueBefore = _BarUpgradeable.value();
    
    uint256 balanceBefore = _BarUpgradeable.balanceOf(e.msg.sender);
    foo@withrevert(e);
    bool isReverted = lastReverted;

    bool fooFlagAfter = _FooUpgradeable.flag();
    uint256 barValueAfter = _BarUpgradeable.value();
    uint256 balanceAfter = _BarUpgradeable.balanceOf(e.msg.sender);

    assert(
        !isReverted
            => barValueAfter == e.msg.value
            // Unexpected: the balance changed too.
            && balanceBefore == balanceAfter
    );
} 
