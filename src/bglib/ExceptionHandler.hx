package bglib;

import haxe.display.Display.MetadataTarget;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr.Field;

using haxe.macro.Tools;
using haxe.EnumTools;
using haxe.macro.ExprTools;

using bglib.utils.PrimitiveTools;
using bglib.macros.Grain;

private typedef ExceptionHandlerParam = {
    var ?funcName:String;
}

class ExceptionHandlerMacro {
    static final classMetadata:String = ":ExceptionHandler";
    static final metaParams:Array<MetaParam> = [
        {
            name: "funcName",
            type: "String",
            pattern: "EConst(CString(_))",
            optional: true
        }
    ];
    static final fieldMetadataName:String = ":handleException";

    #if macro
    static function extractCatch(field:Field):Catch {
        var func:Function;
        switch field.kind {
            case FFun(f):
                func = f;
            default:
                Context.error("Handler is not a function", field.pos);
        }
        if (func.args.length != 1) {
            Context.error("Handler must have one argument", field.pos);
        }

        // make catch expression
        var arg = func.args[0];
        var catchExpr = macro {
            $i{field.name}($i{arg.name});
        };
        catchExpr = Grain.rePos(catchExpr, field.pos);

        var c:Catch = {
            expr: catchExpr,
            name: arg.name,
            type: arg.type,
        };

        return c;
    }

    static function injectTryCatch(field:Field, catches:Array<Catch>):Expr {
        // create try-catch expression and warp it around field
        var fieldFunc;
        switch field.kind {
            case FFun(f):
                fieldFunc = f;
            default:
                Context.error('\'${field.name}\' is not a function', field.pos);
        }

        var fieldTryCatch:Expr = {
            pos: fieldFunc.expr.pos,
            expr: ETry(fieldFunc.expr, catches),
        }

        fieldFunc.expr = fieldTryCatch;
        #if (debug >= 3)
        Grain.exprTree(fieldTryCatch);
        #elseif (debug >= 2)
        Sys.println(fieldTryCatch.toString());
        #end
        return fieldTryCatch;
    }

    static function handle(?name:String = "main"):Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: fieldMetadataName,
            doc: "handle an exception"
        });
        // TODO: call handle from anywhere.
        // Compiler.getConfiguration().mainClass
        var fields = Context.getBuildFields();
        var field:Field = fields.find((f) -> f.name == name);

        if (field == null) {
            Context.error('No function \'$name\' found', Context.currentPos());
        }

        var catches:Array<Catch> = [];
        for (field in fields) {
            if (field.meta.exists((m) -> m.name == fieldMetadataName)) {
                catches.push(extractCatch(field));
            }
        }

        // TODO: topo-sort catches for arbitrary ordering
        injectTryCatch(field, catches);
        return fields;
    }
    #end

    @:allow("bglib.ExceptionHandler")
    macro static function build():Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: classMetadata,
            doc: "exception handler options",
            params: metaParams.map((p) -> p.parseParam())
        });
        var entry:MetadataEntry = Grain.getLocalClassMetadata(classMetadata);
        var ps:ExceptionHandlerParam = {};
        if (entry != null) {
            ps = PrimitiveTools.dynamicMap(
                entry.extractMetadata(metaParams), ExprTools.getValue
            );
        }

        return handle(ps.funcName);
    }
}

/**
 * Global exception handler.
 * Wraps the specified function with a try-catch blocks.
 * Use @:handleException on a function to catch the 
 * specified exceptions.
 * 
 * @example
 * ```haxe
 * @:handleException
 * static function handle(e:Exception) {...}
 * ```
**/
@:autoBuild(bglib.ExceptionHandlerMacro.build())
interface ExceptionHandler {}
