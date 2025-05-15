package bglib.tui;

using bglib.utils.PrimitiveTools;

/**
 * Defines the possible ANSI colors.
**/
enum EColor {
    Black;
    Red;
    Green;
    Yellow;
    Blue;
    Magenta;
    Cyan;
    White;
    Bright(c:EColor);
    BackGround(c:EColor);
    ForeGround(c:EColor);
    RGB(r:Int, g:Int, b:Int);
}

/**
 * Defines the possible ANSI CSI decorations.
**/
private enum TreEnum {
    TString(s:String);
    TConcat(t1:TreEnum, t2:TreEnum);
    TColor(c:EColor, t:TreEnum);
    TBold(t:TreEnum);
    TFaint(t:TreEnum);
    TItalic(t:TreEnum);
    TUnderline(t:TreEnum);
    TSlowBlink(t:TreEnum);
    TFastBlink(t:TreEnum);
    TInvert(t:TreEnum);
    THide(t:TreEnum);
    TCross(t:TreEnum);
}

/**
 * Adds and formats ANSI decorations around strings;
**/
abstract Trees(TreEnum) from TreEnum to TreEnum {
    public var length(get, never):Int;

    /**
     * Returns the length of the string.
     * @return Int
    **/
    public function get_length():Int {
        return lengthRec(this);
    }

    /**
     * Recursively calculates the length of the string.
     * @param tre to get the length.
     * @return Int
    **/
    static function lengthRec(tre:TreEnum):Int {
        return switch tre {
            case TString(s): s.length;
            case TConcat(t1, t2): lengthRec(t1) + lengthRec(t2);
            case TColor(_, t): lengthRec(t);
            case t: lengthRec(t.getParameters()[0]);
        }
    }

    /**
     * Parses the color to its ANSI color code.
     * @param c color enum
     * @return String
     **/
    static function parseColor(c:EColor):String {
        function colorCode(c:EColor):Int {
            return switch c {
                case Black: 30;
                case Red: 31;
                case Green: 32;
                case Yellow: 33;
                case Blue: 34;
                case Magenta: 35;
                case Cyan: 36;
                case White: 37;
                case Bright(c): colorCode(c) + 60;
                case BackGround(c): colorCode(c) + 10;
                case ForeGround(c): colorCode(c);
                case _: 0;
            }
        }

        inline function rgbCode(r:Int, g:Int, b:Int):String {
            return r + ";" + g + ";" + b;
        }

        var code = switch c {
            case BackGround(RGB(r, g, b)): "48;2;" + rgbCode(r, g, b);
            case ForeGround(RGB(r, g, b)): "38;2;" + rgbCode(r, g, b);
            case Bright(RGB(r, g, b)): "38;2;" + rgbCode(r, g, b);
            case RGB(r, g, b): "38;2;" + rgbCode(r, g, b);
            case c: Std.string(colorCode(c));
        }

        return Ansi.csi + code + "m";
    }

    /**
     * Parses the Trees to its ANSI string.
     * @param stack to parse.
     * @param tre to parse.
     * @return String
    **/
    static function parse(stack:Array<String>, tre:TreEnum):String {
        stack = stack.copy();

        switch tre {
            case TColor(c, _):
                stack.push(parseColor(c));
            case TBold(_):
                stack.push(Ansi.bold);
            case TFaint(_):
                stack.push(Ansi.faint);
            case TItalic(_):
                stack.push(Ansi.italic);
            case TUnderline(_):
                stack.push(Ansi.underline);
            case TSlowBlink(_):
                stack.push(Ansi.slowBlink);
            case TFastBlink(_):
                stack.push(Ansi.rapidBlink);
            case TInvert(_):
                stack.push(Ansi.invert);
            case THide(_):
                stack.push(Ansi.hide);
            case TCross(_):
                stack.push(Ansi.crossOut);
            case _:
        }

        var parsed = switch tre {
            case TString(s):
                if (!stack.empty()) {
                    s = stack.join("") + s + Ansi.reset;
                }
                s;
            case TConcat(t1, t2): parse(stack, t1) + parse(stack, t2);
            case TColor(c, t): parse(stack, t);
            case t: parse(stack, t.getParameters()[0]);
        };

        return parsed;
    }

    /**
     * Color text using ANSI codes.
     * @param c text color
     * @param t text
     * @return Trees
    **/
    public static function Color(c:EColor, t:Trees):Trees {
        return TColor(c, t);
    }

    /**
     * Make text bold using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Bold(t:Trees):Trees return TBold(t);

    /**
     * Make text faint using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Faint(t:Trees):Trees return TFaint(t);

    /**
     * Make text italic using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Italic(t:Trees):Trees return TItalic(t);

    /**
     * Underline text using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Underline(t:Trees):Trees return TUnderline(t);

    /**
     * Slowly blink text using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function SlowBlink(t:Trees):Trees return TSlowBlink(t);

    /**
     * Rapidly blink text using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function FastBlink(t:Trees):Trees return TFastBlink(t);

    /**
     * Invert text color using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Invert(t:Trees):Trees return TInvert(t);

    /**
     * Hide text using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Hide(t:Trees):Trees return THide(t);

    /**
     * Cross out text using ANSI codes.
     * @param t text
     * @return Trees
    **/
    public static function Cross(t:Trees):Trees return TCross(t);

    /**
     * Concatenates this ansi text with another.
     * @param tre to concat.
    **/
    @:op(a += b)
    public inline function concatenated(tre:Trees) {
        this = TConcat(this, tre);
    }

    /**
     * Concatenates this ansi text with another.
     * @param tre to concat.
     * @return Trees concatenated string.
    **/
    @:op(a + b)
    public function concat(tre:Trees):Trees {
        return TConcat(this, tre);
    }

    /**
     * Concatenates an ansi text with this.
     * @param tre to concat.
     * @return Trees concatenated string.
    **/
    @:commutative
    @:op(a + b)
    public function concatInv(tre:Trees):Trees {
        return TConcat(tre, this);
    }

    /**
     * Converts this ansi text to its escaped string.
     * @return String
    **/
    public function escaped():String {
        var s = parse([], this);

        var buf = new StringBuf();
        for (c in s) {
            if (c == Ansi.esc.charCodeAt(0)) {
                buf.add("\\x1b");
            } else {
                buf.addChar(c);
            }
        }
        return buf.toString();
    }

    @:to
    public function toString():String {
        return parse([], this);
    }

    /**
     * Converts a string to an ansi text.
     * @param str to convert.
     * @return Trees
    **/
    @:from
    public static function fromString(str:String):Trees {
        return TString(str);
    }
}
