package bglib.cli;

import haxe.Timer;
import haxe.MainLoop;
import haxe.MainLoop.MainEvent;

import sys.thread.Deque;

/**
 * Utility class for working with Deque.
 **/
class DequeTools {
    static function empty<T>(q:Deque<T>, block:Bool, f:(v:T) -> Void) {
        while (true) {
            var v:T = q.pop(block);
            if (v == null) break;
            f(v);
        }
    }
}

/**
 * Collects characters from stdin while 
 * maintaining a threaded loop. 
 **/
class IoWatch {
    var timer:Timer;
    var charQ:Deque<Int>;
    var readEvent:MainEvent;

    public var run(never, set):(Deque<Int>) -> Void;

    public function new(interval:Int) {
        charQ = new Deque<Int>();
        readEvent = MainLoop.add(read);
        readEvent.isBlocking = true;

        timer = new Timer(interval);
    }

    function read() {
        var c = Sys.getChar(false);
        charQ.push(c);
        if (c == 0 || c == 3 || c == 4) {
            stop();
        }
    }

    /**
     * Stops the loop and read event.
     **/
    public function stop() {
        readEvent.stop();
        timer.stop();
        onExit();
    }

    /**
     * Call back function when the timer ends.
    **/
    public dynamic function onExit() {}

    function set_run(value:Deque<Int>->Void):Deque<Int>->Void {
        timer.run = value.bind(charQ);
        return value;
    }
}
