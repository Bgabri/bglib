package bglib.macros;

import haxe.macro.Context;
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
    public static function ePrint(e:Expr, maxDepth = -1, depth:Int = 0) {
        if (depth > maxDepth && maxDepth != -1) return;

        var str = StringTools.lpad("", " ", depth);
        if (depth == 0) str = "";
        Sys.println('$str${e.expr.getName()}, ${e.pos}');

        e.iter(ePrint.bind(_, maxDepth, ++depth));
    }
}
