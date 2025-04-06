import bglib.cli.Exit;

/**
 * TestCli
 * Usage: cli <command> [flags]
**/
@:build(bglib.cli.BaseCommand.build(true))
@:build(bglib.macros.ExceptionHandler.handle())
class TestCli {
    /**
     * wow field doc
     * @param signal signal to send
    **/
    @:alias("W", "o", "w")
    public var wow:String = "wow";

    /**
     * no alias
     * @param level
    **/
    public var noAlias:Int = 0;

    /**
     * sub field doc
     * @param _1 something
     * @param _2
     * @param _3 asdf
    **/
    @:command
    public var sub:Sub = new Sub();

    function cmd() {
        throw "hi";
        Sys.println("cmd");
    }

    static function create() {
        return new TestCli();
    }
}

/**
 * Sub
**/
class Sub {
    public function new() {}

    @:command
    public var subsub = new SubSub();

    /**
     * main sub command
    **/
    @:defaultCommand
    public function run() {
        Sys.println("sub");
    }
}

/**
 * SubSub
**/
class SubSub {
    public function new() {}

    /**
     * main subsub command
    **/
    @:defaultCommand
    public function run() {
        Sys.println("subsub");
    }
}

// * @param _1 something
// * @param multiLine something else
// * with
// * multiple
// * lines
// * @pAram _2 another thing
// * @param     noDesc
// * @param t_2yped:Type this Is typed @chicken
// * @param t_netsTyped:Type< asdf<>  ss s> this Is typed @chicken nugget
// * @param t_netsTyped:Type< asdf<>  ss s>
// * @return String<yadda taddt <aa>>
