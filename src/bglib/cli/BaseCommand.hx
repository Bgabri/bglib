package bglib.cli;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

using Lambda;

/**
 * Convenience macro to build a cli command.
 * Defines a default help flag, multi argument and error handler.
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
            public function run(rest:tink.cli.Rest<String>) {
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
     * @return Field main class field
    **/
    static function getMainField() {
        var cm = macro class CmdMain {
            public static function main() {
                try { // TODO: find a way to not need create()
                    tink.Cli.process(Sys.args(), create()).handle(Exit.handler);
                } catch (e:bglib.cli.exceptions.MalformedRequest) {
                    Sys.println(e.message);
                    Sys.println("Use --help for usage");
                    Sys.exit(1);
                } catch (e:haxe.Exception) {
                    Sys.println("Inernal error: " + e.message);
                    Sys.exit(1);
                }
            }
        }
        return cm.fields[0];
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
        if (useMain && !fields.exists((f) -> f.name == "main")) {
            fields.push(getMainField());
        }
        return fields;
    }
}
