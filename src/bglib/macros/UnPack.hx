package bglib.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Constraints.Function;

using Lambda;
using StringTools;

using haxe.macro.Tools;

/**
 * Macro which unpacks an array or struct of arguments into a function call.
**/
class UnPack {
    #if macro
    static function getType(t:haxe.macro.Type):String {
        switch (t) {
            case TAbstract(t, params):
                return t.toString();
            case TInst(t, params):
                return t.toString();
            default:
                return null;
        }
    }

    static function injectMap(
        requiredRight:Array<Int>, requiredArgs:Int, expr:Expr, args:Expr
    ):Expr {
        // create the argument map based on the number of arguments
        // always matches all of the required args whilst preserving the
        // args call order.
        var finalExpr = macro {
            var __unpacked_map__ = $v{requiredRight};
            var __unpacked_pos__ = 0;
            var __unpacked_args__ = ${args}.length;
            var __unpacked_non_pos__ = ${args}.length;
            for (i in 0...__unpacked_map__.length) {
                var r = __unpacked_map__[i];
                if (r < __unpacked_args__) {
                    __unpacked_map__[i] = __unpacked_pos__++;
                    __unpacked_args__--;
                } else {
                    __unpacked_map__[i] = __unpacked_non_pos__++;
                    // __unpacked_map__[i] = -1;
                }
            }
            if (${args}.length < $v{requiredArgs}) {
                throw new bglib.macros.UnpackingException(
                    ${args}.length,
                    $v{requiredArgs}
                );
            }
            $expr;
        };
        return finalExpr;
    }

    static function arrUnpack(fn:Expr, args:Expr):Expr {
        var expr = macro fn();
        var fnArgs = [];

        switch (Context.typeof(fn)) {
            case TFun(fArgs, ret):
                fnArgs = fArgs;
            default:
                Context.error("Expected a function", fn.pos);
        }

        if (fnArgs.exists((arg) -> getType(arg.t) == "haxe.Rest")) {
            Context.error("Cannot unpack variable arguments", fn.pos);
        }

        var requiredArgs = 0;
        fnArgs.reverse();
        // rolling sum of required arguments.
        var requiredRight = fnArgs.map((arg) -> {
            if (!arg.opt) {
                requiredArgs++;
                return 0;
            } else return requiredArgs;
        });
        requiredRight.reverse();
        fnArgs.reverse();

        var eArgs:Array<Expr> = [];
        for (i in 0...fnArgs.length) {
            var arg = fnArgs[i];

            // TODO: cast to the correct type.
            // Unify?
            eArgs.push(macro ${args}[__unpacked_map__[$v{i}]]);
        }

        expr.expr = ECall(fn, eArgs);
        var finalExpr = injectMap(requiredRight, requiredArgs, expr, args);
        finalExpr = rePos(args.pos, finalExpr);

        return finalExpr;
    }

    static function rePos(pos:Position, e:Expr):Expr {
        return switch (e.expr) {
            case EThrow(e):
                {expr: EThrow(e), pos: pos};
            default:
                e.map(rePos.bind(pos));
        }
    }

    static function structUnpack(fn:Expr, st:Expr):Expr {
        var expr = macro fn();
        var eArgs:Array<Expr> = [];
        switch (Context.typeof(fn)) {
            case TFun(fargs, ret):
                for (i in 0...fargs.length) {
                    var s = fargs[i].name;
                    eArgs.push(macro $st.$s);
                }
            default:
                Context.error("Expected a function", fn.pos);
        }
        expr.expr = ECall(fn, eArgs);
        return expr;
    }
    #end

    /**
     * Unpacks an array of arguments into a function call.
     * 
     * @param fn to call.
     * @param args to unpack.
     * @return unpacked function call.
     * @throws UnpackingException if the arguments are not valid.
    **/
    macro static public function unpack(fn:ExprOf<Function>, args:Expr):Expr {
        var exp = switch (Context.typeof(args)) {
            case TInst(_.get().name => "Array", params) |
                TAbstract(_.get().name => "Vector" | "Rest", params):
                arrUnpack(fn, args);
            case TAnonymous(a):
                structUnpack(fn, args);
            default:
                Context.error("Expected struct or array like", args.pos);
        }
        #if (debug >= "2")
        @SuppressWarning("checkstyle:Trace")
        Sys.println(exp.toString());
        #end
        return exp;
    }
}
