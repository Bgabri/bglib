package bglib.macros;

/**
 * Exception for when unpacking fails.
**/
class UnpackingException extends haxe.Exception {
    public var requiredArgs:Int;
    public var args:Int;

    public function new(args:Int, requiredArgs:Int, ?msg:String) {
        if (msg == null) msg = "Not enough unpacking arguments";

        this.args = args;
        this.requiredArgs = requiredArgs;

        super(msg);
    }
}
