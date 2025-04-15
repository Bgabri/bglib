import haxe.Exception;
import bglib.ExceptionHandler;

class DummyException extends Exception {}

class ExHandler implements ExceptionHandler {
    var someProp:String;

    @:handleException
    static function wrongArg(v:Int) {}

    @:handleException
    static function testDummy(de:DummyException) {
        trace("dummy exception");
        trace(de.message);
    }

    @:handleException
    static function test(e:Exception) {
        trace("Hello from test");
        reThrow(e);
    }

    static function reThrow(e:Exception) {
        throw e;
    }

    public static function main() {
        throw "Hello from main";
    }
}
