package tui;

import bglib.tui.Ansi;
import bglib.tui.Trees.*;
import bglib.tui.Trees;

import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

@:asserts
class TreesTests {
    public function new() {}

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

    public function colourBright():Assertions {
        var expr = Colour(Bright(Red), "enm");
        return assert(expr.toString() == "\x1b[91menm\x1b[0m");
    }

    public function colourBackGround():Assertions {
        var expr = Colour(BackGround(Bright(Red)), "enm");

        return assert(expr.toString() == "\x1b[101menm\x1b[0m");
    }

    public function cross():Assertions {
        var expr:Trees = Bold(Cross("Hello") + " World");
        asserts.assert(expr.length == 11);
        asserts.assert(
            expr.toString() == "\x1b[1m\x1b[9mHello\x1b[0m\x1b[1m World\x1b[0m"
        );
        return asserts.done();
    }

    public function bold():Assertions {
        var t = Bold("Hello");
        asserts.assert(t.length == 5);
        asserts.assert(t.toString() == "\x1b[1mHello\x1b[0m");
        return asserts.done();
    }

    public function encapsulate():Assertions {
        var inner = Colour(Bright(Blue), "hello");
        var expr = Colour(Red, inner);
        asserts.assert(expr.length == 5);
        asserts.assert(expr.toString() == "\x1b[31m\x1b[94mhello\x1b[0m");
        return asserts.done();
    }
}
