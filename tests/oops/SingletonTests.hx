package oops;

import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

/**
 * Tests the singleton macro
**/
class SingletonTests {
    public function new() {}

    /**
     * Tests for a singleton with custom instance field.
     * @return Assertions
    **/
    public function singleton():Assertions {
        return assert(NoOne.chickenJockey.field == "hello");
    }

    /**
     * Tests for a singleton in a submodule.
     * @return Assertions
    **/
    public function subSingleton():Assertions {
        return assert(NoOne.SubNoOne.instance.field == "hello from sub");
    }
    /**
     * Tests for a singleton with inheritance.
     * @return Assertions
    **/
    public function singletonInheritance():Assertions {
        return assert(NoOne.NoOneChild.instance.field == "hello from child");
    }
}
