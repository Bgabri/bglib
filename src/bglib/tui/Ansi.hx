package bglib.tui;

/**
 * Defines the ANSI input control sequences.
 **/
enum Control {
    Up;
    Down;
    Left;
    Right;
    End;
    Home;
    Insert;
    Delete;
    PgUp;
    PgDn;
    ESC; // ?
    Fn(i:Int);
    DEL;
    Undefined;
}

/**
 * Defines the ANSI char input.
 **/
enum Input {
    Code(c:Int);
    Control(c:Control);
    Invalid;
}

/**
 * A utility class which defines possible ANSI escape codes.
 **/
class Ansi {

    // control
    public static inline final esc:String = "\x1b";
    public static inline final csi:String = esc+"[";
    public static inline final clear:String = csi + "1J";
    public static inline final clearLine:String = csi + "2K";

    // Select Graphic Rendition
    public static inline final reset:String      = csi + "0m";
    public static inline final bold:String       = csi + "1m";
    public static inline final faint:String      = csi + "2m";
    public static inline final italic:String     = csi + "3m";
    public static inline final underline:String  = csi + "4m";
    public static inline final slowBlink:String  = csi + "5m";
    public static inline final rapidBlink:String = csi + "6m";
    public static inline final invert:String     = csi + "7m";
    public static inline final hide:String       = csi + "8m";
    public static inline final crossOut:String   = csi + "9m";

    // colors
    // foreground
    public static final black:String         = csi + "30m";
    public static final red:String           = csi + "31m";
    public static final green:String         = csi + "32m";
    public static final yellow:String        = csi + "33m";
    public static final blue:String          = csi + "34m";
    public static final magenta:String       = csi + "35m";
    public static final cyan:String          = csi + "36m";
    public static final white:String         = csi + "37m";
    public static final brightBlack:String   = csi + "90m";
    public static final brightRed:String     = csi + "91m";
    public static final brightGreen:String   = csi + "92m";
    public static final brightYellow:String  = csi + "93m";
    public static final brightBlue:String    = csi + "94m";
    public static final brightMagenta:String = csi + "95m";
    public static final brightCyan:String    = csi + "96m";
    public static final brightWhite:String   = csi + "97m";

    // backGround
    public static final blackBackGround:String         = csi + "40m";
    public static final redBackGround:String           = csi + "41m";
    public static final greenBackGround:String         = csi + "42m";
    public static final yellowBackGround:String        = csi + "43m";
    public static final blueBackGround:String          = csi + "44m";
    public static final magentaBackGround:String       = csi + "45m";
    public static final cyanBackGround:String          = csi + "46m";
    public static final whiteBackGround:String         = csi + "47m";
    public static final brightBlackBackGround:String   = csi + "100m";
    public static final brightRedBackGround:String     = csi + "101m";
    public static final brightGreenBackGround:String   = csi + "102m";
    public static final brightYellowBackGround:String  = csi + "103m";
    public static final brightBlueBackGround:String    = csi + "104m";
    public static final brightMagentaBackGround:String = csi + "105m";
    public static final brightCyanBackGround:String    = csi + "106m";
    public static final brightWhiteBackGround:String   = csi + "107m";

    // Cursor
    public static final hideCursor:String = csi + "?25l";
    public static final showCursor:String = csi + "?25h";
    public static final nextLine:String   = csi + "E";

    /**
     * Moves the cursor by n lines.
     * @param n lines
     * @return String
     **/
    public static function moveCursorY(n = 0):String {
        if (n == 0) return "";
        if (n < 0) {
            n = -n;
            return csi + '${n}A';
        }
        return csi + '${n}B';
    }

    /**
     * Moves the cursor by n columns.
     * @param n columns
     * @return String
     **/
    public static function moveCursorX(n = 0):String {
        if (n == 0) return "";
        if (n < 0) {
            n = -n;
            return csi + '${n}D';
        }
        return csi + '${n}C';
    }

    #if debug
    /**
     * Test "every" ANSI escape codes.
     **/
    public static function test() {
        for (i in 1...107) {
            @SuppressWarning("checkstyle:Trace")
            trace(i, "\t" + csi + '${i}m' + "Hello World" + reset);
        }
    }
    #end

    /**
     * Maps the vt code into the control enum.
     * @param code 
     * @return Control
     **/
    static function vtCode(code:Int):Control {
        var control = switch code {
            case 1: Home;
            case 2: Insert;
            case 3: Delete;
            case 4: End;
            case 5: PgUp;
            case 6: PgDn;
            case 7: Home;
            case 8: End;

            case 10: Fn(0);
            case 11: Fn(1);
            case 12: Fn(2);
            case 13: Fn(3);
            case 14: Fn(4);
            case 15: Fn(5);

            case 17: Fn(6);
            case 18: Fn(7);
            case 19: Fn(8);
            case 20: Fn(9);
            case 21: Fn(10);

            case 23: Fn(11);
            case 24: Fn(12);
            case 25: Fn(13);
            case 26: Fn(14);

            case 28: Fn(15);
            case 29: Fn(16);

            case 31: Fn(17);
            case 32: Fn(18);
            case 33: Fn(19);
            case 34: Fn(20);
            case _: Undefined;
        };
        return control;
    }

    /**
     * Checks and parses a vt sequence from std in.
     * @param code 
     * @return Input
     **/
    static function vtSequence(code:Int):Input {
        switch Sys.getChar(false) {
            case ";".code: throw "shortcuts not supported";
            case "P".code: return Control(Fn(1));
            case "Q".code: return Control(Fn(2));
            case "R".code: return Control(Fn(3));
            case "S".code: return Control(Fn(4));
            case "~".code:
                return Control(vtCode(code - "0".code));
            case i if ( "0".code <= i && i <= "9".code):
                return Control(vtCode((code - "0".code)*10 + i - "0".code));
        }
        return Invalid;
    }

    /**
     * Checks and parses an input sequence from std in.
     * @param code 
     * @return Input
     **/
    static function inputSequence():Input {
        var code = Sys.getChar(false);
        switch code {
            case ";".code: throw "not implemented";
            case "A".code: return Control(Up);
            case "B".code: return Control(Down);
            case "C".code: return Control(Right);
            case "D".code: return Control(Left);
            case "F".code: return Control(End);
            case "G".code: return Control(Undefined);
            case "H".code: return Control(Home);
            case i if ( "1".code <= i && i <= "9".code):
                return vtSequence(i);
            case i if ( "A".code <= i && i <= "Z".code):
                return Control(Undefined);
            case _:
        }

        return Invalid;
    }

    static var escaped:Bool = false;

    /**
     * Checks and parses an input from std in.
     * @param code
     * @return Input
     **/
    public static function getCode(?code:Int):Input {
        // https://en.wikipedia.org/wiki/ANSI_escape_code

        if (code == null) {
            code = Sys.getChar(false);
        }
        if (escaped == true && code == "[".code) {
            escaped = false;
            return inputSequence();
        }

        escaped = false;

        if (code == 27) {
            escaped = true;
            return Control(ESC);
        }
        return Code(code);
    }

    /**
     * Converts the input into a string.
     * @param i input enum
     * @return String
     **/
    public static function inputString(i:Input):String {
        return switch i {
            case Code(0): "null";
            case Code(9): "tab";
            case Code(13): "line feed";
            case Code(27): "esc";
            case Code(32): "space";
            case Code(127): "back space";
            case Code(c) if (c > 32): String.fromCharCode(c);
            case Code(c): "^"+String.fromCharCode(c+64);
            case Control(Fn(i)): 'fn$i';
            case Control(c): c.getName();
            case Invalid: "invalid";
        }
    }

    #if debug
    /**
     * Test the input sequence.
     **/
    public static function testCharInput() {
        while (true) {
            var code = Sys.getChar(false);
            @SuppressWarning("checkstyle:Trace")
            trace(code, inputString(Code(code)));
            switch code {
                case "q".code | 3:
                    Sys.println("bye");
                    break;
                case _:
            }
        }
    }
    #end
}
