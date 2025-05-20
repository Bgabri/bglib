package bglib.oops;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.TypePath;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;

using Lambda;
using StringTools;

using haxe.macro.Tools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

private typedef BuilderBuildParams = {
    var product:ClassType;
    var ?useInherited:Bool;
    // var ?productName:String;
    // var ?buildMethodName:String;
}

private typedef ProductField = {
    var name:String;
    var classField:ClassField;
}

/**
 * Macro to create builder classes.
**/
class BuilderMacro {
    static final metadataName:String = ":builder";
    static final metaParams:Array<MetaParam> = [
        {
            name: "product",
            type: "Class",
            pattern: "EConst(_)",
            extractValue: true,
        },
        {
            name: "useInherited",
            type: "Bool",
            pattern: "EConst(CIdent(_))",
            optional: true,
            extractValue: true,
        }
    ];

    #if macro
    static function getProductFields(
        product:ClassType, inherit:Bool
    ):Array<ProductField> {
        var cFields = product.fields.get();
        cFields = cFields.filter((f) -> {
            return f.kind.match(FVar(_, _));
        });
        var fields = cFields.map(f -> {
            name: f.name,
            classField: f
        });

        if (inherit && product.superClass != null) {
            var superClass = product.superClass.t.get();
            fields.concatenated(getProductFields(superClass, inherit));
        }
        return fields;
    }

    static function buildBuilderProductField(field:ProductField):Array<Field> {
        var fieldName = field.name;
        var setFieldMethodName = fieldName;
        var complexType = field.classField.type.toComplexType();

        var newClass = macro class {
            public function $setFieldMethodName(v : $complexType) {
                @:privateAccess
                obj.$fieldName = v;
                return this;
            }
        }

        return newClass.fields;
    }

    static function buildBuilderProductFields(
        prodFields:Array<ProductField>
    ):Array<Field> {
        var fields = [];

        for (prodField in prodFields) {
            fields.concatenated(buildBuilderProductField(prodField));
        }

        return fields;
    }

    static function buildBuilderBuildField(
        prod:ClassType, extending:Bool
    ):Array<Field> {
        var prodName = prod.name;
        if (prod.module != null && prod.module != "") {
            prodName = prod.module + "." + prodName;
        }

        var complexType = Grain.safeGetType(prodName).toComplexType();
        var typePath = prod.toTypePath();

        var constructor = macro class {
            var obj:Dynamic; // TODO: change to static type

            public function new() {
                obj = new $typePath();
            }
        };

        var inheritConstructor = macro class {
            public function new() {
                super();
                obj = new $typePath();
            }
        };

        var buildMethod = macro class {
            public function build():$complexType {
                return bglib.utils.PrimitiveTools.copy(obj);
            }
        }

        var inheritBuildMethod = macro class {
            override public function build():$complexType {
                return bglib.utils.PrimitiveTools.copy(obj);
            }
        }

        var fields = [];
        if (extending) {
            fields = inheritConstructor.fields;
            fields.push(inheritBuildMethod.fields[0]);
        } else {
            fields = constructor.fields;
            fields.push(buildMethod.fields[0]);
        }

        return fields;
    }

    static function makeBuilderFields(
        product:ClassType, ?useInherited:Bool = false
    ):Array<Field> {
        var prodFields = getProductFields(product, useInherited);
        var newFields = buildBuilderProductFields(prodFields);

        var extending = !Context.getLocalClass()
            .get()
            .interfaces.any((i) -> i.t.toString() == "bglib.oops.Builder");

        var buildFields = buildBuilderBuildField(product, extending);
        newFields.concatenated(buildFields);

        var contextPos = Context.getLocalClass()
            .get()
            .pos;

        newFields.iter((f) -> {
            f.pos = contextPos;
        });

        var fields = Context.getBuildFields();
        fields.leftJoin(newFields);

        return fields;
    }
    #end

    static macro function build():Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: metadataName,
            doc: "singleton class options",
            params: metaParams.map((p) -> p.parseParam())
        });

        var entry:MetadataEntry = Grain.getLocalClassMetadata(metadataName, true);
        var params:BuilderBuildParams = entry.extractMetadata(metaParams, true);

        return makeBuilderFields(params.product, params.useInherited);
    }
}

@:autoBuild(bglib.oops.BuilderMacro.build())
interface Builder {}

interface Buildable {
    function builder():Builder;
}
