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
    var useInherited:Bool;
    var product:ClassType;
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

    static function addBuilderField(field:ProductField):Array<Field> {
        var fieldName = field.name;
        var setFieldMethodName =
            "set" +
            fieldName.charAt(0).toUpperCase() +
            fieldName.substr(1);
        var complexType = field.classField.type.toComplexType();

        var newClass = macro class {
            private var $fieldName:$complexType;

            public function $setFieldMethodName(v : $complexType) {
                this.$fieldName = v;
                return this;
            }
        }

        return newClass.fields;
    }

    static function buildBuilderFields(
        prodFields:Array<ProductField>
    ):Array<Field> {
        var builderFields = Context.getBuildFields();
        var builderFieldNames = builderFields.map((f) -> f.name);

        for (prodField in prodFields) {
            if (builderFieldNames.contains(prodField.name)) continue;

            builderFields.concatenated(addBuilderField(prodField));
        }

        var pos = Context.getLocalClass()
            .get()
            .pos;

        builderFields.iter((f) -> {
            f.pos = pos;
        });

        return builderFields;
    }

    static function addBuilderBuildField(
        prod:ClassType, builderFields:Array<ProductField>
    ):Array<Field> {
        var prodName = prod.name;
        if (prod.module != null && prod.module != "") {
            prodName = prod.module + "." + prodName;
        }

        var complexType = Grain.safeGetType(prodName).toComplexType();
        var typePath = prod.toTypePath();

        var setExprs:Array<Expr> = [];
        for (field in builderFields) {
            var fieldName = field.name;
            setExprs.push(
                macro obj.$fieldName = this.$fieldName
            );
        }

        var newClass = macro class {
            public function new() {}

            public function build():$complexType {
                var obj = new $typePath();
                $b{setExprs};
                return obj;
            }
        }

        return newClass.fields;
    }

    static function makeBuilderFields(
        product:ClassType, ?useInherited:Bool = true
    ):Array<Field> {
        var prodFields = getProductFields(product, useInherited);
        var buildFields = buildBuilderFields(prodFields);
        var fields = addBuilderBuildField(product, prodFields);
        Sys.println("");
        return fields.concat(buildFields);
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

interface Buildable<T> {
    /**
     * @return Builder
    **/
    function builder():Builder;
}
