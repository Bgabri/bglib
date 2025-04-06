package bglib.macros;

import haxe.macro.Expr;

using Lambda;
using StringTools;

using haxe.macro.Tools;

/**
 * Macro utils.
**/
class Grain {
    /**
     * Tree like expression printer.
     * @param e to print
     * @param maxDepth max depth to print
     * @param depth current depth
    **/
    public static function exprTree(e:Expr, maxDepth = -1, depth:Int = 0) {
        if (e == null) return;
        if (e.expr == null) return;
        if (depth > maxDepth && maxDepth != -1) return;

        var str = StringTools.lpad("", " ", depth);
        if (depth == 0) str = "";

        Sys.println('$str${e.expr.getName()}, ${e.pos}');

        e.iter(exprTree.bind(_, maxDepth, ++depth));
    }

    /**
     * Reposition the expression to a new position.
     * @param e expression to modify
     * @param pos to set
     * @return Expr modified expression
    **/
    public static function rePos(e:Expr, pos:Position):Expr {
        var eNew = e.map(rePos.bind(_, pos));
        return {
            pos: pos,
            expr: eNew.expr,
        };
    }
}
