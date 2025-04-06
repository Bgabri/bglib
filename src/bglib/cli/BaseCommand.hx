package bglib.cli;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

using Lambda;

/**
 * Convenience macro to build a cli command.
 * Defined variables:
 *  var help:Bool;
 * Defined functions:
 *  function new();
 *  public function printHelp();
 *  public function run();
 *  public static function main();
 *  static function handleMalformedRequest();
 *  static function handleException();
 * 
 * Implement a function to override it.
**/
class BaseCommand {
    #if macro
    /**
     * Creates the default fields for the cli commands.
     * @param command the default command function name to call.
     * @return Array<Field> the class fields
    **/
    static function getBaseCmdFields(command:String):Array<Field> {
        var c = macro class BaseCommand {
            function new() {}

            /**
             * prints this help message
            **/
            public var help:Bool = false;

            function printHelp() {
                var doc = bglib.cli.Doc.builder().build();
                Sys.print(tink.Cli.getDoc(this, doc));
                Sys.exit(0);
            }

            /**
             * run the cli
             * @param rest cli args
            **/
            @:defaultCommand
            public function run(rest:tink.cli.Rest<Dynamic>) {
                if (help) printHelp();
                try {
                    bglib.macros.UnPack.unpack($i{command}, rest);
                } catch (e:bglib.macros.UnpackingException) {
                    throw new bglib.cli.exceptions.MalformedRequest(
                        "Malformed input: not enough arguments"
                    );
                }
            }
        }

        return c.fields;
    }

    /**
     * Creates the main entry point for the cli command.
     * @return Array<Field> the class fields
    **/
    static function getMainFields():Array<Field> {
        var cm = macro class BaseCommandMain {
            @:handleException
            static function handleMalformedRequest(
                e:bglib.cli.exceptions.MalformedRequest
            ) {
                Sys.println(e.message);
                Sys.println("Use --help for usage");
                Sys.exit(1);
            }

            @:handleException
            static function handleException(e:haxe.Exception) {
                Sys.println("Internal error: " + e.message);
                Sys.exit(1);
            }

            public static function main() {
                // TODO: is create the best option?
                tink.Cli.process(Sys.args(), create())
                    .handle(bglib.cli.Exit.handler);
            }
        }
        return cm.fields;
    }
    #end

    /**
     * Macro to build a cli command.
     * @param useMain add the main entry point.
     * @param command the default command function name to call.
     * @return Array<Field>
    **/
    public static macro function build(
        useMain:Bool = false, command:String = "cmd"
    ):Array<Field> {
        var fields = Context.getBuildFields();
        var cName = Context.getLocalClass()
            .get()
            .name;

        var cmdFields = getBaseCmdFields(command);

        for (f in cmdFields) {
            if (fields.exists((cf) -> cf.name == f.name)) continue;
            fields.push(f);
        }
        if (useMain) {
            var mainFields = getMainFields();
            for (f in mainFields) {
                if (fields.exists((cf) -> cf.name == f.name)) continue;
                fields.push(f);
            }
        }
        return fields;
    }
}
