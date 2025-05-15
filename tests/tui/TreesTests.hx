package tui;

import bglib.tui.Trees.*;
import bglib.tui.Trees;

import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

/**
 * Tests for the ANSI Trees module.
**/
@:asserts
class TreesTests {
    public function new() {}

    /**
     * Tests for concatenation.
     * @return Assertions
    **/
    public function concatenation():Assertions {
        var abs:Trees = " abs";
        var enm:Trees = Bold(Italic(" enm"));
        var str:String = " str";
        asserts.assert(str + str == " str str");
        asserts.assert(enm + str == "\x1b[1m\x1b[3m enm\x1b[0m str");
        asserts.assert(abs + str == " abs str");

        asserts.assert(str + enm == " str\x1b[1m\x1b[3m enm\x1b[0m");
        asserts.assert(
            enm + enm == "\x1b[1m\x1b[3m enm\x1b[0m\x1b[1m\x1b[3m enm\x1b[0m"
        );
        asserts.assert(abs + enm == " abs\x1b[1m\x1b[3m enm\x1b[0m");

        asserts.assert(str + abs == " str abs");
        asserts.assert(enm + abs == "\x1b[1m\x1b[3m enm\x1b[0m abs");
        asserts.assert(abs + abs == " abs abs");
        return asserts.done();
    }

    /**
     * Tests for bright colors.
     * @return Assertions
    **/
    public function colorBright():Assertions {
        var expr = Color(Bright(Red), "enm");
        return assert(expr.toString() == "\x1b[91menm\x1b[0m");
    }

    /**
     * Tests for background colors.
     * @return Assertions
    **/
    public function colorBackGround():Assertions {
        var expr = Color(BackGround(Bright(Red)), "enm");

        return assert(expr.toString() == "\x1b[101menm\x1b[0m");
    }

    /**
     * Tests for crossed text.
     * @return Assertions
    **/
    public function cross():Assertions {
        var expr:Trees = Bold(Cross("Hello") + " World");
        asserts.assert(expr.length == 11);
        asserts.assert(
            expr.toString() == "\x1b[1m\x1b[9mHello\x1b[0m\x1b[1m World\x1b[0m"
        );
        return asserts.done();
    }

    /**
     * Tests for bold text.
     * @return Assertions
    **/
    public function bold():Assertions {
        var t = Bold("Hello");
        asserts.assert(t.length == 5);
        asserts.assert(t.toString() == "\x1b[1mHello\x1b[0m");
        return asserts.done();
    }

    /**
     * Tests for encapsulated text.
     * @return Assertions
    **/
    public function encapsulate():Assertions {
        var aa = Color(Red, "aa" + Color(Blue, "bb") + "cc");
        asserts.assert(
            aa == "\x1b[31maa\x1b[0m\x1b[31m\x1b[34mbb\x1b[0m\x1b[31mcc\x1b[0m"
        );

        var inner = Color(Bright(Blue), "hello");
        var expr = Color(Red, inner);
        asserts.assert(expr.length == 5);
        asserts.assert(expr.toString() == "\x1b[31m\x1b[94mhello\x1b[0m");
        return asserts.done();
    }
}
