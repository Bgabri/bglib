package bglib.oops;

/**
 * TODO: can constructor vars be set?
 * TODO: buildable
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
    var ?productField:String;
    var ?buildMethod:String;
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
            type: "Class",
            pattern: "EConst(CIdent(_)) | EField(_, _, _)",
            extractValue: true,
        },
        {
            name: "useInherited",
            type: "Bool",
            pattern: "EConst(CIdent(true | false))",
            optional: true,
            extractValue: true,
        },
        {
            name: "productField",
            type: "String",
            pattern: "EConst(CString(_))",
            optional: true,
            extractValue: true,
        },
        {
            name: "buildMethod",
            type: "String",
            pattern: "EConst(CString(_))",
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
    final product:ClassType;
    final useInherited:Bool;

    final productFieldName:String;
    final buildMethodName:String;
    final getProductMethodName:String;

    final extending:Bool;
    final productFields:Array<ClassField>;

    function new(
        product:ClassType, extending:Bool, useInherited:Bool,
        productField:String = "obj", buildMethod:String = "build"
    ) {
        this.product = product;
        this.extending = extending;
        if (useInherited == null) {
            // don't inherit if extending
            useInherited = !extending;
        }
        this.useInherited = useInherited;

        this.productFieldName = productField;
        this.buildMethodName = buildMethod;
        this.getProductMethodName = "get_" + productFieldName;

        this.productFields = product.getClassFields(useInherited);
    }

    /**
     * Injects the set product field method.
     * @param field the field to inject
     * @return Array<Field>
    **/
    function buildBuilderProductProperty(
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
                $p{[getProductMethodName]}().$fieldName = v;
                return this;
            }
        }

        return newClass.fields;
    }

    function toFunctionArg(arg:{value:Null<TypedExpr>, v:TVar}):FunctionArg {
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
    function buildBuilderProductMethod(
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
                $p{[getProductMethodName]}().$methodName($a{
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

    function buildProductMethod(prodField:ClassField):Array<Field> {
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

    function buildBuilderProductFields():Array<Field> {
        var fields:Array<Field> = [];

        for (prodField in productFields) {
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
     * @return Array<Field>
    **/
    function buildBuilderBuildField():Array<Field> {
        var complexType = Grain.safeGetType(product.name).toComplexType();
        var typePath = product.toTypePath();
        var classDotPathExpr = complexType.toString()
            .split(".")
            .toFieldExpr()
            .rePos(product.pos);
        var classDotPathNoModule = product.pack.concat([product.name])
            .toFieldExpr()
            .rePos(product.pos);

        var mClass = macro class {
            // TODO: change to static type ($complexType), breaks inheritance
            // dynamic doesn't work well with hl and non real vars
            var $productFieldName:Dynamic;

            @:allow(${classDotPathExpr})
            @:allow(${classDotPathNoModule})
            function new() {
                $p{[productFieldName]} = new $typePath();
            }

            function $getProductMethodName():$complexType {
                return $p{[productFieldName]};
            }

            public function $buildMethodName():$complexType {
                return bglib.utils.PrimitiveTools.copy($p{[productFieldName]});
            }
        };

        if (!extending) return mClass.fields;

        mClass = macro class {
            @:allow(${classDotPathExpr})
            @:allow(${classDotPathNoModule})
            function new() {
                super();
                $p{[productFieldName]} = new $typePath();
            }

            override public function $buildMethodName():$complexType {
                return
                    bglib.utils.PrimitiveTools.copy($p{[getProductMethodName]}());
            }

            override function $getProductMethodName():$complexType {
                return $p{[productFieldName]};
            }
        };

        return mClass.fields;
    }

    public function buildFields():Array<Field> {
        var newFields = buildBuilderProductFields();
        var buildFields = buildBuilderBuildField();
        return buildFields.leftJoin(newFields);
    }
    #end

    static macro function build():Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: metadataName,
            doc: "singleton class options",
            params: metaParams.map((p) -> p.parseParam())
        });

        var entry:MetadataEntry = Grain.getLocalClassMetadata(metadataName, true);
        var params:BuilderBuildParams = entry.extractMetadata(metaParams);

        var extending = !Context.getLocalClass()
            .get()
            .interfaces.any((i) -> i.t.toString() == "bglib.oops.Builder");

        var b = new BuilderMacro(params.product, extending, params.useInherited, params.productField, params.buildMethod);

        var newFields = b.buildFields();

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
}

/**
 * Generates a builder for the given class.
 * 
 * class level:
 * ```
 * @:builder(
 *     product:Class, ?useInherited:Bool, 
 *     ?productField:String = "obj", ?buildMethod:String = "build"
 * )
 * ```
**/
@:autoBuild(bglib.oops.BuilderMacro.build())
interface Builder {}
