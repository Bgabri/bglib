package bglib.oops;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.TypePath;

using Lambda;
using StringTools;

using haxe.macro.Tools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

/**
 * Macro parameters.
 **/
private typedef SingletonBuildParams = {
    var fieldName:String;
}

/**
 * Macro to create a singleton class.
**/
class SingletonMacro {
    static final metadataName:String = ":singleton";
    static final metaParams:Array<MetaParam> = [
        {
            name: "fieldName",
            type: "String",
            pattern: "EConst(CString(_))",
            extractValue: true,
        }
    ];

    #if macro
    /**
     * Build the class.
     * adds a static instance field and a static get_instance method.
     * @param fieldName the name of the field to use for the singleton
     * @return Array<Field>
    **/
    static function inject(fieldName:String = "instance"):Array<Field> {
        var fields = Context.getBuildFields();
        var classType = Context.getLocalClass().get();
        var pathType:TypePath = classType.toTypePath();

        if (classType.params.length > 0) {
            Context.error(
                "Singletons cannot have type parameters", classType.pos
            );
        }

        var complexType = Grain.safeGetType(classType.name).toComplexType();

        var getField = "get_" + fieldName;
        var st = macro class Singleton {
            public static var $fieldName(get, null):$complexType;

            function new() {}

            public static function $getField():$complexType {
                if ($p{[fieldName]} == null) {
                    $p{[fieldName]} = new $pathType();
                }
                return $p{[fieldName]};
            }
        }
        var newFields = st.fields.filter(
            stf -> !(fields.any(f -> stf.name == f.name)));
        fields = fields.concat(newFields);
        return fields;
    }
    #end

    @:allow(bglib.oops.Singleton)
    static macro function build():Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: metadataName,
            doc: "singleton class options",
            params: metaParams.map((p) -> p.parseParam())
        });
        var entry:MetadataEntry = Grain.getLocalClassMetadata(metadataName);
        if (entry == null) return inject();
        var params:SingletonBuildParams = entry.extractMetadata(metaParams);
        return inject(params.fieldName);
    }
}

/**
 * Implements a singleton interface via a macro.
 * 
 * @:singleton(fieldName:String = "instance")
**/
@:autoBuild(bglib.oops.SingletonMacro.build())
interface Singleton {}
