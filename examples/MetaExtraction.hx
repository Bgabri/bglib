import haxe.macro.Expr;
import haxe.macro.Context;

import bglib.macros.Grain;

import Reflect;
import Type;

import bglib.macros.Grain;

using haxe.macro.Tools;

using bglib.utils.PrimitiveTools;

class Macro {
    #if macro
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();

        var classMetadata:Array<MetadataEntry> = [];
        switch (Grain.safeGetType(localClass.name)) {
            case TInst(t, params):
                classMetadata = t.get().meta.get();
            case _:
        }

        var meta = fields.find(
            f -> f.meta.find(e -> e.name == ":metaTest") != null
        )
            .meta.find(e -> e.name == ":metaTest");

        var defFields:Array<MetaParam> = [
            {
                name: "hihi",
                pattern: "EConst(CString(_))",
                type: "String"
            },
            {
                name: "bigNum",
                pattern: "EConst(CInt(_))",
                type: "Int"
            },
            {
                name: "arr",
                pattern: "EArrayDecl(_)",
                type: "Array<String>"
            },
            {
                name: "opts",
                pattern: "EConst(CIdent(_))",
                optional: true,
                type: "String"
            }
        ];

        var param = Grain.extractMetadata(meta, defFields);
        trace(param);

        var metas = fields.find(
            f -> f.meta.find(e -> e.name == ":metaOpts") != null
        );

        var defFields = [
            {
                name: "opt0",
                pattern: "EConst(CString(_))",
                type: "String",
            },
            {
                name: "opt1",
                pattern: "EConst(CString(_))",
                type: "String",
                optional: true
            },
            {
                name: "opt2",
                pattern: "EConst(CInt(_))",
                type: "Int",
            }
        ];
        for (i => meta in metas.meta) {
            if (meta.name == ":metaOpts") {
                var param = Grain.extractMetadata(meta, defFields, false);
                trace(param);
            }
        }

        return fields;
    }
    #end
}

#if !macro
@:build(Macro.build())
class MetaExtraction {
    @:metaTest("asdf", 10, [10])
    @:metaOpts("asdf", "a", 19)
    @:metaOpts("asdf", 10)
    @:metaOpts(10, "asdf")
    @:metaOpts(10, "asdf", "a")
    // @:metaOpts()
    // @:metaOpts
    static function oFunc(arr:Array<Int>, ?optional:String) {}

    public static function main() {
        trace("hi");
    }
}
#end
