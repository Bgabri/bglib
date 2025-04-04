package bglib.cli.exceptions;

class MalformedRequest extends haxe.Exception {
    public function new(?msg:String) {
        if (msg == null) msg = "Malformed request";
        super(msg);
    }
}