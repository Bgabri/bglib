package bglib.macros;

/**
 * Exception for when unpacking fails.
 **/
class UnpackingException extends haxe.Exception {
    public function new(msg:String) {
        super(msg);
    }
}