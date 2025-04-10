package bglib.cli;

import sys.thread.Mutex;

import haxe.Timer;
import haxe.MainLoop;
import haxe.MainLoop.MainEvent;

import sys.thread.Thread;
import sys.thread.Deque;

/**
 * Utility class for working with Deque.
**/
class DequeTools {
    public static function empty<T>(q:Deque<T>, block:Bool, f:(v:T) -> Void) {
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
    var timerMutex:Mutex;
    var charQ:Deque<Int>;
    var readEvent:MainEvent;

    /**
     * Callback function when running the loop.
     * @param q characters read.
     **/
    public var onEvent(never, set):(Deque<Int>) -> Void;

    var t:Thread;

    public function new(interval:Int) {
        charQ = new Deque<Int>();
        readEvent = MainLoop.add(read);
        readEvent.isBlocking = true;
        timerMutex = new Mutex();
        t = Thread.createWithEventLoop(() -> {
            timerMutex.acquire();
            timer = new Timer(interval);
            timerMutex.release();
        });
        Sys.sleep(1);
    }

    function read() {
        var c = Sys.getChar(false);
        charQ.push(c);
        onChar(c);
    }

    /**
     * Call back function when a character is read.
     * Warning: check for control characters when overriding.
     * @param c read character
     **/
    public dynamic function onChar(c:Int) {
        if (c == 0 || c == 3 || c == 4) {
            stop();
        }
    }

    /**
     * Stops the loop and read event.
    **/
    public function stop() {
        readEvent.stop();
        timerMutex.acquire();
        timer.stop();
        timerMutex.release();
        onExit();
    }

    /**
     * Call back function when the timer ends.
    **/
    public dynamic function onExit() {}

    function set_onEvent(func:Deque<Int>->Void):Deque<Int>->Void {
        timerMutex.acquire();
        timer.run = func.bind(charQ);
        timerMutex.release();
        return func;
    }
}
