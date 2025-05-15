package bglib.cli.exceptions;

/**
 * Exception thrown when a request is malformed.
 **/
class MalformedRequest extends haxe.Exception {
    public function new(?msg:String) {
        if (msg == null) msg = "Malformed request";
        super(msg);
    }
}