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

class ExceptionHandler {
    static final metaDataName:String = "handleException";

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

    static function injectTryCatch(main:Field, catches:Array<Catch>):Expr {
        // create try-catch expression and warp it around the main function
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

        mainFunc.expr = mainTryCatch;
        #if (debug >= 3)
        Grain.exprTree(mainTryCatch);
        #elseif (debug >= 2)
        Sys.println(mainTryCatch.toString());
        #end
        return mainTryCatch;
    }
    #end

    /**
     * Global Exception handler
     * @return Array<Field>
    **/
    macro public static function handle():Array<Field> {
        var fields = Context.getBuildFields();
        var main:Field = fields.find((f) -> f.name == "main");

        if (main == null) {
            Context.error("No main function found", Context.currentPos());
        }

        var catches:Array<Catch> = [];
        for (field in fields) {
            if (field.meta.exists((m) -> m.name == metaDataName)) {
                catches.push(extractCatch(field));
            }
        }

        // TODO: topo-sort catches for arbitrary ordering
        injectTryCatch(main, catches);
        return fields;
    }
}
