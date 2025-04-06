import haxe.Exception;

class DummyException extends Exception {}

@:build(bglib.macros.ExceptionHandler.handle())
class ExHandler {
    @handleException
    static function wrongArg(v:Int) {}

    @handleException
    static function testDummy(de:DummyException) {
        trace("dummy exception");
        trace(de.message);
    }

    @handleException
    static function test(e:Exception) {
        trace("Hello from test");
        reThrow(e);
    }

    static function reThrow(e:Exception) {
        throw e;
    }

    public static function main() {
        // throw new DummyException("Dummy exception");
        throw "Hello from main";
    }
}
