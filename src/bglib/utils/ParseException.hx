package bglib.utils;
import haxe.Exception;

/**
 * Exception when parsing.
**/
class ParseException extends Exception {
    public function new(message:String) {
        super(message);
    }
}
