
import bglib.oops.*;

class NoOne implements Singleton {
    function new() {
        trace("hello there");
    }
}
class Oops {
    static function main() {
        trace(NoOne.instance);
    }
}