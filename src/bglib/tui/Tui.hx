package bglib.tui;

/**
 * A helper class to facilitate clearing and drawing a Trees buffer.
 **/
class Tui {

    var screenBuffer:Array<Trees>;
    var currentBuffer:Array<Trees>;
    public static var instance(get, default):Tui;

    function new() {
        screenBuffer = [];
        currentBuffer = [];
    }

    /**
     * Prints the current screen buffer to the screen.
     **/
    function print() {
        for (line in screenBuffer) {
            Sys.println(line.toString());
            Sys.print(Ansi.csi + "G");
        }
    }

    /**
     * Clears the current screen buffer from the screen.
     **/
    public function clearScreen() {
        for (l in currentBuffer) {
            Sys.print(Ansi.moveCursorY(-1));
            Sys.print(Ansi.clearLine);
        }
    }

    /**
     * Clears and draws the screen buffer.
     **/
    function refresh() {
        clearScreen();
        currentBuffer = screenBuffer;
        print();
    }

    /**
     * Redraws the given buffer to the screen.
     * @param buffer to draw
     **/
    public function redraw(buffer:Array<Trees>) {
        screenBuffer = buffer;
        refresh();
    }

    public function insert(x:Int, y:Int, c:String) {}
    public function replace(x:Int, y:Int, c:String) {}
    public function delete(x:Int, y:Int, l:Int) {}

    /**
     * Reads a string from stdin until the given character.
     * @param endChar 
     * @return String
     **/
    function readString(endChar:Int):String {
        var s = "";
        var char = Sys.getChar(false);
        while (char != endChar) {
            s += String.fromCharCode(char);
            char = Sys.getChar(false);
        }
        return s;
    }

    public function screenSize():{x:Int, y:Int} {
        Sys.print(Ansi.hideCursor);

        Sys.print(Ansi.moveCursorX(2048));
        var p = cursorPosition();
        Sys.print(Ansi.moveCursorX(-2048));

        Sys.print(Ansi.showCursor);

        return p;
    }

    public function cursorPosition():{x:Int, y:Int} {
        Sys.print(Ansi.csi + "6n");
        var char = Sys.getChar(false); // ESC
        var char = Sys.getChar(false); // [
        var y:Int = Std.parseInt(readString(";".code));
        var x:Int = Std.parseInt(readString("R".code));
        return {x: x, y: y};
    }

    public static function get_instance():Tui {
        if (instance == null) instance = new Tui();
        return instance;
    }
}
