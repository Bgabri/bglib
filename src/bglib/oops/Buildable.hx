package bglib.oops;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;

using haxe.macro.Tools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

class BuildableMacro {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        return fields;
    }
}

/**
 * Generates a builder for the given class.
 * 
 * field level:
 * ```
 * @:builderField(?exclude:Bool, ?methodName:String)
 * ```
 * 
 * class level:
 * ```
 * @:builder(?useInherited:Bool = true)
 * ```
**/
@:autoBuild(bglib.oops.BuildableMacro.build())
interface Buildable {}
