package bglib.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

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

    static function arrUnpack(fn:Expr, args:Expr):Expr {
        var expr = macro fn();
        var fnArgs = [];

        switch (Context.typeof(fn)) {
            case TFun(fArgs, ret):
                fnArgs = fArgs;
            default:
                Context.error("Expected a function", fn.pos);
        }

        var requiredArgs = 0;
        var eArgs:Array<Expr> = [];
        for (i in 0...fnArgs.length) {
            var arg = fnArgs[i];
            if (getType(arg.t) == "haxe.Rest") {
                Context.error("Cannot unpack variable arguments", fn.pos);
            }
            if (!arg.opt) requiredArgs++;
            eArgs.push(macro ${args}[$v{i}]);
        }

        expr.expr = ECall(fn, eArgs);
        var finalExpr = macro {
            if (${args}.length < $v{requiredArgs}) {
                throw new bglib.macros.UnpackingException(
                    "Not enough unpacking arguments"
                );
            }
            $expr;
        };

        finalExpr = finalExpr.map(rePos.bind(args.pos));
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
     * @param fn to call.
     * @param args to unpack.
     * @return unpacked function call.
     * @throws UnpackingException if the arguments are not valid.
    **/
    macro static public function unpack(fn:Expr, args:Expr):Expr {
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
        trace(exp.toString());
        #end
        return exp;
    }
}
