package oops;

import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

class SingletonTests {
    public function new() {}

    public function singleton():Assertions {
        return assert(NoOne.chickenJockey.field == "hello");
    }

    public function subSingleton():Assertions {
        return assert(NoOne.SubNoOne.instance.field == "hello from sub");
    }
}
