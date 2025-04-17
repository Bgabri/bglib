import bglib.oops.*;

class NoOne implements Singleton {
    function new() {
        trace("hello there");
    }
}

class Oops implements Singleton {
    static function main() {
        trace(NoOne.instance);
        trace(Oops.instance);
    }
}
