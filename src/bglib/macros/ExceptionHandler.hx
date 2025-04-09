package bglib.macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr.Field;

using Lambda;
using StringTools;

using haxe.macro.Tools;
using haxe.EnumTools;

using bglib.macros.Grain;

/**
 * Global exception handler.
 * Wraps the specified function with a try-catch blocks.
 * Use @:handleException on a function to catch the 
 * specified exceptions.
 **/
class ExceptionHandler {
    static final metaDataName:String = ":handleException";

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
    #end

    /**
     * Global Exception handler
     * @param name of the function to wrap around
     * @return Array<Field>
    **/
    macro public static function handle(?name:String = "main"):Array<Field> {
        // TODO: call handle from anywhere.
        var fields = Context.getBuildFields();
        var field:Field = fields.find((f) -> f.name == name);

        if (field == null) {
            Context.error(
                'No function \'$name\' found', Context.currentPos());
        }

        var catches:Array<Catch> = [];
        for (field in fields) {
            if (field.meta.exists((m) -> m.name == metaDataName)) {
                catches.push(extractCatch(field));
            }
        }

        // TODO: topo-sort catches for arbitrary ordering
        injectTryCatch(field, catches);
        return fields;
    }
}
