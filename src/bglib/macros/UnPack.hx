package bglib.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;

using haxe.macro.ExprTools;

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
    #end

    static function arrUnpack(fn:Expr, args:Expr):Array<Expr> {
        var eargs:Array<Expr> = [];
        #if macro
        switch (Context.typeof(fn)) {
            case TFun(fargs, ret):
                for (i in 0...fargs.length) {
                    if (getType(fargs[i].t) == "haxe.Rest") {
                        // eargs.push(macro ${args}.slice($v{i}));
                        Context.error(
                            "Cannot unpack variable arguments", fn.pos
                        );
                    } else {
                        eargs.push(macro ${args}[$v{i}]);
                    }
                }
            default:
                Context.error("Expected a function", fn.pos);
        }
        #end
        return eargs;
    }

    static function structUnpack(fn:Expr, st:Expr):Array<Expr> {
        var eargs:Array<Expr> = [];
        #if macro
        switch (Context.typeof(fn)) {
            case TFun(fargs, ret):
                for (i in 0...fargs.length) {
                    var s = fargs[i].name;
                    eargs.push(macro $st.$s);
                }
            default:
                Context.error("Expected a function", fn.pos);
        }
        #end
        return eargs;
    }

    /**
     * Unpacks an array of arguments into a function call.
     * @param fn to call.
     * @param args to unpack.
     * @return unpacked function call.
    **/
    macro static public function unpack(fn:Expr, args:Expr):Expr {
        // trace(Context.getType("haxe./ds.Vector").getParameters()[0]);
        // trace(Context.typeof(args);
        var exp = macro fn();
        var eargs:Array<Expr> = [];
        switch (Context.typeof(args)) {
            case TInst(_.get().name => "Array", params) |
                TAbstract(_.get().name => "Vector", params):
                eargs = arrUnpack(fn, args);
            case TAnonymous(a):
                eargs = structUnpack(fn, args);
            default:
                Context.error("Expected struct or array like", args.pos);
        }
        exp.expr = ECall(fn, eargs);
        #if debug
        @SuppressWarning("checkstyle:Trace")
        trace(exp.toString());
        #end
        return exp;
    }
}
