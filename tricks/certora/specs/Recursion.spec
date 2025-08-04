import "./base/foo.spec";
import "./base/bar.spec";

methods {
    // unresolved external in Foo.foo() => DISPATCH [
    //     Bar._
    // ] default HAVOC_ALL;
}

rule recursion(env e) {
    // require(b(e) == _Bar);
    require(_Foo.flag() == true);
    foo();
    bool after = _Bar.flag();
    assert(after == true);
}
