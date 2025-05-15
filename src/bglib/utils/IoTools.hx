package bglib.utils;

import haxe.io.BytesBuffer;
import haxe.io.Input;

/**
 * Helper class for reading from input.
 **/
class IoTools {
    /**
     * Reads a word from the input ending at a white space.
     * @param inp buffer
     * @return String
     **/
    public static function readWord(inp:Input):String {
        var buf = new BytesBuffer();
        var last:Int;
        while ((last = inp.readByte()) > 33) {
            buf.addByte(last);
        }

        return buf.getBytes().toString();
    }

    /**
     * Parses a float from the input.
     * @param inp buffer
     * @return Float
     **/
    public static function parseFloat(inp:Input):Float {
        var s = readWord(inp);
        return Std.parseFloat(s);
    }

    /**
     * Parses a int from the input.
     * @param inp buffer
     * @return Int
     **/
    public static function parseInt(inp:Input):Int {
        var s = readWord(inp);
        return Std.parseInt(s);
    }

    /**
     * Parses a bool from the input
     * @param inp buffer
     * @return Bool
     **/
    public static function parseBool(inp:Input):Bool {
        var s = readWord(inp);
        return s == "true" || s == "1";
    }
}
