package macros;

import haxe.ds.Vector;

import bglib.macros.UnpackingException;

import tink.testrunner.Assertion;
import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

using bglib.macros.UnPack;
using bglib.utils.Utils;

/**
 * Tests for the function unpacking macro.
 * @return Assertions
**/
@:asserts
class UnPackTests {
    public function new() {}

    function divide(a:Int, b:Int):Int {
        return a.div(b);
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

    /**
     * Tests for function unpacking with optional args.
     * @return Assertions
    **/
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

    /**
     * Tests for unpacking with to little args.
     * @return Assertions
    **/
    public function exceptionUnpack():Assertions {
        var msg = "oFunc.unpack([0, 1]) (throws UnpackingException)";
        try {
            oFunc.unpack([0, 1]);
            return new Assertion(false, msg);
        } catch (e:UnpackingException) {
            return new Assertion(true, msg);
        }
    }

    /**
     * Tests unpacking with arrays.
     * @return Assertions
    **/
    public function arrUnpack():Assertions {
        var as:Array<Int> = [2, 5, 7];
        asserts.assert(multiply3.unpack(as) == 70);
        return asserts.done();
    }

    /**
     * Tests unpacking with object access.
     * @return Assertions
    **/
    public function objUnpack():Assertions {
        var as = {
            b: 3,
            a: 15
        };
        return assert(divide.unpack(as) == 5);
    }

    /**
     * Tests unpacking with vectors.
     * @return Assertions
    **/
    public function vecUnpack():Assertions {
        var as:Vector<Int> = Vector.fromArrayCopy([8, 2]);

        return assert(divide.unpack(as) == 4);
    }
}
