package bglib.utils;

import sys.thread.Deque;

/**
 * Utility class for working with Deque.
**/
class DequeTools {
    /**
     * Calls the call back function on all the elements until the
     * queue is empty.
     * @param q the deque
     * @param f the function to call
    **/
    public static function emptyOut<T>(q:Deque<T>, f:(v:T) -> Void) {
        while (true) {
            var v:T = q.pop(false);
            if (v == null) break;
            f(v);
        }
    }
}
