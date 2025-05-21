package bglib.oops;

/**
 * TODO: builder options (productName, buildMethodName)
 * TODO: can finals and constructor vars be set?
 * TODO: buildable
 * TODO: Error pos msging
 * 
**/
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.TVar;
import haxe.macro.Type.TypedExpr;

using Lambda;
using StringTools;

using haxe.macro.Tools;

using bglib.macros.Grain;
using bglib.utils.PrimitiveTools;

/**
 * builder metadata parameters
**/
private typedef BuilderBuildParams = {
    var product:ClassType;
    var ?useInherited:Bool;
}

private typedef ProductFieldParam = {
    var ?exclude:Bool;
    var ?methodName:String;
}

/**
 * Macro to create builder classes.
 * product: Class to be built
**/
class BuilderMacro {
    static final metadataName:String = ":builder";
    static final metaParams:Array<MetaParam> = [
        {
            name: "product",
            type: "Class", // TODO: fails on module.Class
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

    static final fieldMetaName:String = ":builderField";
    static final fieldMetaParams:Array<MetaParam> = [
        {
            name: "exclude",
            type: "Bool",
            pattern: "EConst(CIdent(_))",
            optional: true,
            extractValue: true,
        },
        {
            name: "methodName",
            type: "String",
            pattern: "EConst(CString(_))",
            optional: true,
            extractValue: true,
        }
    ];

    #if macro
    /**
     * Gets the fields of a product.
     * @param product the class to be built
     * @param inherit if the fields should be inherited
     * @return Array<ProductField>
    **/
    static function getAllProductFields(
        product:ClassType, inherit:Bool
    ):Array<ClassField> {
        var fields = product.fields.get();

        if (inherit && product.superClass != null) {
            var superClass = product.superClass.t.get();
            fields.concatenated(getAllProductFields(superClass, inherit));
        }

        return fields;
    }

    /**
     * Injects the set product field method.
     * @param field the field to inject
     * @return Array<Field>
    **/
    static function buildBuilderProductProperty(
        field:ClassField, ?setFieldMethodName:String
    ):Array<Field> {
        var fieldName = field.name;
        if (setFieldMethodName == null) {
            setFieldMethodName = fieldName;
        }
        var complexType = field.type.toComplexType();

        var newClass = macro class {
            public function $setFieldMethodName(v : $complexType) {
                @:privateAccess
                get_obj().$fieldName = v;
                return this;
            }
        }

        return newClass.fields;
    }

    static function toFunctionArg(
        arg:{value:Null<TypedExpr>, v:TVar}):FunctionArg {
        return {
            type: arg.v.t.toComplexType(),
            name: arg.v.name,
            opt: arg.value != null,
        };
    }

    /**
     * Injects the product methods
     * @param method to inject
     * @param setFieldMethodName
     * @return Array<Field>
    **/
    static function buildBuilderProductMethod(
        method:ClassField, ?setFieldMethodName:String
    ):Array<Field> {
        // turns a product field/method into a builder set method
        var methodName = method.name;
        if (setFieldMethodName == null) {
            setFieldMethodName = methodName;
        }

        // extract the method args
        var mArgs:Array<{value:Null<TypedExpr>, v:TVar}> = method.expr()
            .expr.getParameters()[0].args;

        var args = mArgs.map(toFunctionArg);

        var newClass = macro class {
            public function $setFieldMethodName(/** args defined below**/) {
                @:privateAccess
                get_obj().$methodName($a{
                    args.map(a -> macro $i{a.name})
                });
                return this;
            }
        }

        // inject the args
        switch (newClass.fields[0].kind) {
            case FFun(f):
                newClass.fields[0].kind = FFun({
                    ret: f.ret,
                    expr: f.expr,
                    args: args,
                    params: f.params
                });
            case _:
        }

        return newClass.fields;
    }

    static function buildProductMethod(prodField:ClassField):Array<Field> {
        // filters product fields to make into builder methods
        var params:ProductFieldParam = {};
        if (prodField.meta.has(fieldMetaName)) {
            var entry = prodField.meta.extract(fieldMetaName)[0];
            params = entry.extractMetadata(fieldMetaParams);
        }

        if (params.exclude) return [];

        switch (prodField.kind) {
            case FVar(_, AccNever) | FVar(_, AccCtor) |
                FVar(_, AccRequire(_, _)):
                return [];
            case FMethod(_):
                if (params.exclude == null) return [];
                return buildBuilderProductMethod(prodField, params.methodName);
            case _:
        }

        return buildBuilderProductProperty(prodField, params.methodName);
    }

    static function buildBuilderProductFields(
        prodFields:Array<ClassField>
    ):Array<Field> {
        var fields:Array<Field> = [];

        for (prodField in prodFields) {
            fields.concatenated(buildProductMethod(prodField));
        }
        return fields;
    }

    /**
     * Injects
     * ```
     *  var obj;
     *  function new() {...}
     *  function build(){...}
     * ```
     * @param prod the type to build
     * @param extending if the called class is extending anther Builder
     * @return Array<Field>
    **/
    static function buildBuilderBuildField(
        prod:ClassType, extending:Bool
    ):Array<Field> {
        var prodName = prod.module; // TODO: get correct path
        // trace(prod.module, prod.pack, prod.name);
        // if (prod.module != null && prod.module != "") {
        //     prodName = prod.module + "." + prodName;
        // }
        var complexType = Grain.safeGetType(prod.name).toComplexType();
        var typePath = prod.toTypePath();

        var mClass = macro class {
            // TODO: change to static type ($complexType)
            // dynamic doesn't work with hl and non real vars
            var obj:Dynamic;

            @:allow($i{prodName})
            public function new() {
                obj = new $typePath();
            }

            function get_obj():$complexType {
                return obj;
            }

            public function build():$complexType {
                return bglib.utils.PrimitiveTools.copy(obj);
            }
        };

        if (!extending) return mClass.fields;

        mClass = macro class {
            @:allow($i{prodName})
            public function new() {
                super();
                obj = new $typePath();
            }

            override public function build():$complexType {
                return bglib.utils.PrimitiveTools.copy(get_obj());
            }

            override function get_obj():$complexType {
                return obj;
            }
        };

        return mClass.fields;
    }

    static function makeBuilderFields(
        product:ClassType, ?useInherited:Bool = false
    ):Array<Field> {
        var prodFields = getAllProductFields(product, useInherited);
        var newFields = buildBuilderProductFields(prodFields);

        var extending = !Context.getLocalClass()
            .get()
            .interfaces.any((i) -> i.t.toString() == "bglib.oops.Builder");

        var buildFields = buildBuilderBuildField(product, extending);

        newFields = buildFields.leftJoin(newFields);

        // reposition the fields
        var contextPos = Context.getLocalClass()
            .get()
            .pos;

        newFields.iter((f) -> {
            f.pos = contextPos;
            switch (f.kind) {
                case FFun(f):
                    f.expr.rePos(contextPos);
                case _:
            }
        });

        // join the fields
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

/**
 * Generates a builder for the given class.
 * 
 * class level:
 * ```
 * @:builder(product:Class, ?useInherited:Bool = false)
 * ```
**/
@:autoBuild(bglib.oops.BuilderMacro.build())
interface Builder {}
