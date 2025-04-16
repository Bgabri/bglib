package macros;

import tink.testrunner.Assertions;
import tink.testrunner.Assertion;
import tink.unit.Assert.assert;
import tink.unit.AssertionBuffer;

using bglib.macros.UnPack;
using bglib.macros.UnpackingException;

@:asserts
class UnPackTests {
    public function new() {}

    function multiply(a:Int, b:Int):Int {
        return a * b;
    }

    function multiply3(?a:Int, b:Int, c:Int = 10):Int {
        if (a == null) a = 4;
        return a * b * c;
    }

    function varMultiply(...args:Int):Int {
        var result = 1;
        for (arg in args) {
            result *= arg;
        }
        return result;
    }

    function oFunc(?a:Int, b:Int, c:Int, ?d:Int, e:Int, ?f:Int, ?g:Int):String {
        return '$a, $b, $c, $d, $e, $f, $g';
    }

    function oFunc2(?a:Int, b:Int):String {
        return '$a, $b';
    }

    public function funcUnpack():Assertions {
        asserts.assert(oFunc2.unpack([0]) == "null, 0");
        asserts.assert(oFunc2.unpack([0, 1]) == "0, 1");
        asserts.assert(
            oFunc.unpack([0, 1, 2]) == "null, 0, 1, null, 2, null, null"
        );
        asserts.assert(
            oFunc.unpack([0, 1, 2, 3]) == "0, 1, 2, null, 3, null, null"
        );
        asserts.assert(
            oFunc.unpack([0, 1, 2, 3, 4]) == "0, 1, 2, 3, 4, null, null"
        );
        return asserts.done();
    }

    public function exceptionUnpack():Assertions {
        var msg = "oFunc.unpack([0, 1]) (throws UnUnpackingException)";
        try {
            oFunc.unpack([0, 1]);
            return new Assertion(false, msg);
        } catch (e:UnpackingException) {
            return new Assertion(true, msg);
        }
    }

    public function arrUnpack():Assertions {
        var as:Array<Int> = [2, 5, 7];
        asserts.assert(multiply3.unpack(as) == 70);
        return asserts.done();
    }

    public function objUnpack():Assertions {
        var as = {
            a: 3,
            b: 5
        };
        return assert(multiply.unpack(as) == 15);
    }
    

    public function vecUnpack():Assertions {
        var as:haxe.ds.Vector<Int> = new haxe.ds.Vector(2, 2);
        return assert(multiply.unpack(as) == 4);
    }
}
