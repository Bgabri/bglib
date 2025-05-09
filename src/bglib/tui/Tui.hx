package bglib.tui;

import bglib.oops.Singleton;

/**
 * A helper class to facilitate clearing and drawing a Trees buffer.
**/
class Tui implements Singleton {
    var screenBuffer:Array<Trees>;
    var currentBuffer:Array<Trees>;

    function new() {
        screenBuffer = [];
        currentBuffer = [];
    }

    /**
     * Prints the current screen buffer to the screen.
    **/
    function print() {
        var buffer = new StringBuf();
        for (line in screenBuffer) {
            buffer.add(line.toString() + "\n");
            buffer.add(Ansi.csi + "G");
        }
        Sys.print(buffer.toString());
    }

    /**
     * Clears the current screen buffer from the screen.
     * @param fullClear clears the entire screen
    **/
    public function clearScreen(fullClear:Bool = false) {
        if (fullClear) {
            Sys.print(Ansi.clear);
            return;
        }
        var buffer = new StringBuf();
        for (line in currentBuffer) {
            buffer.add(Ansi.moveCursorY(-1));
            buffer.add(Ansi.clearLine);
        }
        Sys.print(buffer.toString());
    }

    /**
     * Clears and draws the screen buffer.
    **/
    function refresh(fullClear:Bool = false) {
        clearScreen(fullClear);
        currentBuffer = screenBuffer;
        print();
    }

    /**
     * Redraws the given buffer to the screen.
     * @param buffer to draw
     * @param fullClear clears the entire screen before drawing
    **/
    public function redraw(buffer:Array<Trees>, fullClear:Bool = false) {
        screenBuffer = buffer;
        refresh(fullClear);
    }

    // public function insert(x:Int, y:Int, c:String) {}
    // public function replace(x:Int, y:Int, c:String) {}
    // public function delete(x:Int, y:Int, l:Int) {}

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

    /**
     * Returns the number of characters available in the current terminal.
     * @return {w:Int, h:Int}
    **/
    public function screenSize():{w:Int, h:Int} {
        Sys.print(Ansi.hideCursor);

        Sys.print(Ansi.moveCursorX(2048));
        var p = cursorPosition();
        Sys.print(Ansi.moveCursorX(-2048));

        Sys.print(Ansi.showCursor);

        return {w: p.x, h: p.y};
    }

    /**
     * Returns the current cursor position in the terminal.
     * @return {x:Int, y:Int}
    **/
    public function cursorPosition():{x:Int, y:Int} {
        Sys.print(Ansi.csi + "6n");
        var char = Sys.getChar(false); // ESC
        var char = Sys.getChar(false); // [
        var y:Int = Std.parseInt(readString(";".code));
        var x:Int = Std.parseInt(readString("R".code));
        return {x: x, y: y};
    }
}
