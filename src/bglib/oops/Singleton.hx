package bglib.oops;

import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

using haxe.macro.Tools;

/**
 * Macro to create a singleton class.
**/
class SingletonMacro {
    /**
     * Build the class.
     * adds a static instance field and a static get_instance method.
     * @return Array<Field>
    **/
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var classType = Context.getLocalClass().get();
        var pathType:TypePath = classType.toTypePath();

        if (classType.params.length > 0) {
            Context.error(
                "Singletons cannot have type parameters", classType.pos
            );
        }

        var complexType = Grain.safeGetType(classType.name).toComplexType();

        var st = macro class Singleton {
            public static var instance(get, null):$complexType;

            public static function get_instance():$complexType {
                if (instance == null) {
                    instance = new $pathType();
                }
                return instance;
            }
        }
        var newFields = st.fields.filter(
            f -> fields.any(f -> f.name == f.name));
        fields = fields.concat(newFields);
        return fields;
    }
}

/**
 * Implements a singleton interface via a macro.
**/
@:autoBuild(bglib.oops.SingletonMacro.build())
interface Singleton {}
