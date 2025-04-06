package bglib.macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr.Field;

using Lambda;
using StringTools;

using haxe.macro.Tools;
using haxe.EnumTools;

class ExceptionHandler {
    static final metaDataName:String = "handleException";

    #if macro
    static function something(field:Field) {
        trace(field);
    }

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
        var argName = func.args[0].name;
        var catchExpr = macro {
            $i{field.name}($i{argName});
        };
        catchExpr.pos = func.expr.pos;
        var c:Catch = {
            expr: catchExpr,
            name: argName,
            type: func.args[0].type,
        };

        return c;
    }

    static function buildTryCatch(main:Field, catches:Array<Catch>):Expr {
        var mainFunc;
        switch main.kind {
            case FFun(f):
                mainFunc = f;
            default:
                Context.error("main is not a function", main.pos);
        }

        var mainTryCatch:Expr = {
            pos: mainFunc.expr.pos,
            expr: ETry(mainFunc.expr, catches),
        }
        #if (debug >= 2)
        trace(mainTryCatch.toString());
        #end

        mainFunc.expr = mainTryCatch;
        return mainTryCatch;
    }
    #end

    macro public static function handle():Array<Field> {
        var fields = Context.getBuildFields();
        var main:Field = fields.find((f) -> f.name == "main");

        if (main == null) {
            Context.error("No main function found", Context.currentPos());
        }

        var catches:Array<Catch> = [];
        for (field in fields) {
            if (field.meta.exists((m) -> m.name == metaDataName)) {
                var c = extractCatch(field);
                catches.push(c);
            }
        }
        // TODO: topo-sort catches for aribitrary order
        var tryCatch = buildTryCatch(main, catches);
        return fields;
    }
}
