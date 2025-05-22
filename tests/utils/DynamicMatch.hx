package utils;

import bglib.utils.ParseException;

import tink.testrunner.Assertions;
import tink.unit.AssertionBuffer;

using bglib.utils.PrimitiveTools;

/**
 * Enum for testing dynamicMatch.
**/
enum B {
    singleS(a:String);
    doubleS(a:String, b:String);
    singleI(a:Int);
    doubleI(a:Int, b:Int);
    singleA(a:A);
    doubleA(a:A, b:A);
}

/**
 * Enum for testing dynamicMatch.
**/
enum A {
    singleS(a:String);
    doubleS(a:String, b:String);
    singleI(a:Int);
    singleF(a:Float);
    doubleI(a:Int, b:Int);
    singleB(a:B);
    doubleB(a:B, b:B);
    C(c:C);
}

/**
 * class for testing dynamicMatch.
**/
class C {
    public function new() {}
}

/**
 * typedef for testing dynamicMatch.
**/
typedef ETest = {
    var e:EnumValue;
    var pattern:String;
}

/**
 * Tests for dynamic enum matching.
**/
@:asserts
class DynamicMatch {
    public function new() {}

    function assertTests(
        asserts:AssertionBuffer, tests:Array<ETest>
    ):Assertions {
        for (t in tests) {
            asserts.assert(
                t.e.dynamicMatch(t.pattern), t.e +
                " == " +
                t.pattern
            );
        }
        return asserts.done();
    }

    /**
     * Tests for wildcard (_) matching.
     * @return Assertions
    **/
    public function matchWildcard():Assertions {
        var tests:Array<ETest> = [
            {
                e: B.singleS("a"),
                pattern: "singleS(_)"
            },
            {
                e: B.singleA(A.doubleI(43, 29)),
                pattern: "singleA(_)"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(_), doubleS(_, _))"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(_), _)"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "b")),
                pattern: "doubleA(_, doubleS(a, b))",
            },
            {
                e: A.doubleS("a", "c"),
                pattern: "doubleS(_, c)",
            }
        ];
        return assertTests(asserts, tests);
    }

    /**
     * Tests for basic type matching.
     * @return Assertions
    **/
    public function matchType():Assertions {
        var tests:Array<ETest> = [
            {
                e: B.singleS("a"),
                pattern: "singleS(a)"
            },
            {
                e: B.singleI(57),
                pattern: "singleI(57)"
            },
            {
                e: A.singleF(33.3),
                pattern: "singleF(33.3)"
            },
            {
                e: A.C(null),
                pattern: "C(null)"
            },
            {
                e: A.C(new C()),
                pattern: "C(_)"
            }
        ];
        return assertTests(asserts, tests);
    }

    /**
     * Tests fo dynamic matching with OR (|).
     * @return Assertions
    **/
    public function matchOrPattern():Assertions {
        var tests:Array<ETest> = [
            {
                e: B.doubleA(A.singleI(null), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(null), _)"
            },
            {
                e: B.singleI(42),
                pattern: "singleI(4)|singleI(42)"
            },
            {
                e: B.singleI(42),
                pattern: "singleI(4|42)"
            },
            {
                e: B.doubleA(A.singleI(null), A.doubleS("a", "b")),
                pattern: "doubleA(_, doubleS(a, b)|singleS(a|b))"
            },
            {
                e: B.doubleA(A.singleI(null), A.singleS("b")),
                pattern: "doubleA(_, doubleS(a, b)|singleS(a|b))"
            }
        ];
        return assertTests(asserts, tests);
    }

    /**
     * Tests for matches that should fail.
     * @return Assertions
    **/
    public function matchFail():Assertions {
        var tests:Array<ETest> = [
            {
                e: A.singleS("c"),
                pattern: "singleB(_)"
            },
            {
                e: A.singleS("c"),
                pattern: "singleS(b)"
            },
            {
                e: B.doubleA(A.singleI(null), A.singleS("c")),
                pattern: "doubleA(singleI(_), doubleS(_, _))"
            },
            {
                e: B.singleI(3),
                pattern: "singleI(4)|singleI(95)|singleI(42)"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "c")),
                pattern: "doubleA(_, doubleS(a, b))",
            },
            {
                e: A.doubleS("a", "c"),
                pattern: "doubleS(_, b)",
            },
            {
                e: A.doubleS("c", "b"),
                pattern: "doubleS(a, _)",
            }
        ];

        for (t in tests) {
            asserts.assert(
                !t.e.dynamicMatch(t.pattern), t.e +
                " != " +
                t.pattern
            );
        }
        return asserts.done();
    }

    /**
     * Tests for matches that should throw ParseException.
     * @return Assertions
    **/
    public function matchParseException():Assertions {
        var e = B.singleS("a");
        var tests:Array<ETest> = [
            {
                e: A.singleS("a"),
                pattern: "singleS("
            } // to many _ or to little _
        ];

        for (t in tests) {
            var msg = t.e + " == " + t.pattern;
            try {
                t.e.dynamicMatch(t.pattern);
                asserts.assert(false, msg + " (throws ParseException)");
            } catch (e:ParseException) {
                asserts.assert(true, msg + " (throws ParseException)");
            }
        }
        return asserts.done();
    }
}
