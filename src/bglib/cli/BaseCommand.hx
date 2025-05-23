package bglib.cli;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.TypePath;

using Lambda;

using haxe.macro.Tools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

/**
 * Macro parameters.
 **/
private typedef BaseCommandParam = {
    ?useMain:Bool,
    ?command:String
};

/**
  * Convenience macro to build a tink cli command.
 **/
class BaseCommandMacro {
    static final metadata:String = ":baseCommand";
    static final metaParams:Array<MetaParam> = [
        {
            name: "useMain",
            type: "Bool",
            pattern: "EConst(CIdent(true|false))",
            optional: true,
            extractValue: true
        },
        {
            name: "command",
            type: "String",
            pattern: "EConst(CString(_))",
            optional: true,
            extractValue: true
        }
    ];

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
            public function run(rest:tink.cli.Rest<Any>) {
                if (help) printHelp();
                try {
                    bglib.macros.UnPack.unpack($i{command}, rest);
                } catch (e:bglib.macros.UnpackingException) {
                    throw new bglib.cli.exceptions.MalformedRequest(
                        "Malformed input: Insufficient arguments." +
                        ' Expected: ${e.requiredArgs} or more, Got: ${e.args}'
                    );
                }
            }
        }

        return c.fields;
    }

    /**
     * Creates the main entry point for the cli command.
     * @param classPath the class path
     * @return Array<Field> the class fields
    **/
    static function getMainFields(classPath:TypePath):Array<Field> {
        var cm = macro class BaseCommandMain {
            @:handleException
            static function handleMalformedRequest(
                e:bglib.cli.exceptions.MalformedRequest
            ) {
                Sys.println(e.message);
                Sys.println("Include the --help flag for usage");
                Sys.exit(1);
            }

            @:handleException
            static function handleException(e:haxe.Exception) {
                Sys.print("Internal error: " + e.message);
                Sys.println(haxe.CallStack.toString(e.stack));
                Sys.exit(1);
            }

            public static function main() {
                tink.Cli.process(Sys.args(), new $classPath())
                    .handle(bglib.cli.Exit.handler);
            }
        }
        return cm.fields;
    }

    static function buildFields(useMain:Bool = false, command:String = "cmd") {
        var fields = Context.getBuildFields();
        var localType = Context.getLocalClass().get();

        var cmdFields = getBaseCmdFields(command);

        for (f in cmdFields) {
            if (fields.exists((cf) -> cf.name == f.name)) continue;
            fields.push(f);
        }

        if (useMain) {
            var mainFields = getMainFields(localType.toTypePath());
            for (f in mainFields) {
                if (fields.exists((cf) -> cf.name == f.name)) continue;
                fields.push(f);
            }
        }
        return fields;
    }
    #end

    /**
     * Macro to build a cli command.
     * @param useMain add the main entry point.
     * @param command the default command function name to call.
     * @return Array<Field>
    **/
    @:allow("bglib.cli.BaseCommand")
    static macro function build():Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: metadata,
            doc: "base command options",
            params: metaParams.map((p) -> p.parseParam())
        });
        var entry:MetadataEntry = Grain.getLocalClassMetadata(metadata);
        if (entry == null) return buildFields();
        var ps:BaseCommandParam = entry.extractMetadata(metaParams);
        return buildFields(ps.useMain, ps.command);
    }
}

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
 * 
 * @:baseCommand(useMain:Bool = false, command:String = "cmd")
**/
@:autoBuild(bglib.cli.BaseCommandMacro.build())
interface BaseCommand {}
