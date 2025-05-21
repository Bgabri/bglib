package bglib.macros;

import haxe.Exception;
import haxe.ds.Vector;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using StringTools;

using haxe.macro.Tools;

using bglib.utils.PrimitiveTools;

/**
 * Macro utils.
**/
class Grain {
    #if macro
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

    /**
     * Converts a base type into its type path.
     * @param bType the base type
     * @return TypePath
    **/
    public static function toTypePath(bType:BaseType):TypePath {
        // TODO: check if this is correct
        var p = bType.module.split(".");
        // pack.Module.Type
        // name = "Module"
        // sub = "Type"
        return {
            pack: bType.pack,
            name: p.pop(),
            sub: bType.name
        };
    }

    /**
     * Safely resolves the type from its name.
     * @param name of the type
     * @return Type
    **/
    @:noUsing
    public static function safeGetType(name:String):Type {
        var type = null;
        Context.onAfterInitMacros(() -> {
            type = Context.getType(name);
        });
        return type;
    }

    /**
     * Joins the fields, duplicates on the left are prioritized.
     * @param as array
     * @param bs array
     * @return Array<Field>
    **/
    public static function leftJoin(
        as:Array<Field>, bs:Array<Field>
    ):Array<Field> {
        for (b in bs) {
            var found = as.any(a -> a.name == b.name);
            if (!found) as.push(b);
        }
        return as;
    }

    /**
     * Gets the metadata entry from the top of local class.
     * @param name of the metadata
     * @return MetadataEntry
    **/
    @:noUsing
    public static function getLocalClassMetadata(
        name:String, required:Bool = false
    ):MetadataEntry {
        var localType = Context.getLocalClass().get();
        var classMetadata:Array<MetadataEntry> = localType.meta.get();
        var entry = null;
        for (i => m in classMetadata) {
            if (m.name == name) {
                if (entry == null) entry = m;
                else {
                    entry.params = entry.params.concat(m.params);
                }
            }
        }

        if (required && entry == null) {
            var pos = Context.getLocalClass()
                .get()
                .pos;
            Context.error("Missing metadata entry: @" + name, pos);
        }
        return entry;
    }

    static function setMetaExtractField(d:Any, f:MetaParam, p:Expr):Void {
        if (f.extractValue == null || f.extractValue == false) {
            Reflect.setField(d, f.name, p);
            return;
        }
        try {
            if (f.type != "Class") {
                Reflect.setField(d, f.name, p.getValue());
                return;
            }
            switch (p.expr) {
                case EConst(CIdent(v)):
                    var cType = Context.getType(v).getClass();
                    Reflect.setField(d, f.name, cType);
                case _:
                    throw "";
            }
        } catch (e) {
            Context.error("Invalid param, expected: " + parseParam(f), p.pos);
        }
    }

    static function strictMetaExtract(
        entry:MetadataEntry, defFields:Array<MetaParam>, matched:Vector<Bool>
    ):Any {
        var d:Any = {};

        for (i => p in entry.params) {
            var f = defFields[i];
            if (i >= defFields.length) Context.error("Unexpected param", p.pos);
            #if (debug >= 3)
            @SuppressWarning("checkstyle:Trace")
            trace(f.pattern, p.expr);
            #end
            if (!p.expr.dynamicMatch(f.pattern)) {
                Context.error(
                    "Invalid param, expected: " + parseParam(f), p.pos
                );
            }
            setMetaExtractField(d, f, p);
            matched[i] = true;
        }
        return d;
    }

    static function unStrictMetaExtract(
        entry:MetadataEntry, defFields:Array<MetaParam>, matched:Vector<Bool>
    ):Any {
        var d:Any = {};

        for (i => p in entry.params) {
            var found = false;
            for (j => f in defFields) {
                if (matched[j]) continue;
                if (!p.expr.dynamicMatch(f.pattern)) continue;
                setMetaExtractField(d, f, p);
                matched[j] = true;
                found = true;
                break;
            }
            if (found) continue;
            Context.error("Unexpected param", p.pos);
        }

        return d;
    }

    /**
     * Extracts the parameters from the given metadata entry. Matches
     * the parameters using the defined fields.
     * parameter fields.
     * @param entry the metadata entry
     * @param defFields the defined fields
     * @param strict When true, parameters are matched at their index.
     * When false the first matching parameter is used.
     * @return Any
    **/
    public static function extractMetadata(
        entry:MetadataEntry, defFields:Array<MetaParam>, strict:Bool = false
    ):Any {
        var d:Any = {};
        var matched:Vector<Bool> = new Vector(defFields.length, false);
        if (strict) {
            d = strictMetaExtract(entry, defFields, matched);
        } else {
            d = unStrictMetaExtract(entry, defFields, matched);
        }

        for (i => f in defFields) {
            if (matched[i]) continue;
            if (f.optional != null && f.optional == true) continue;
            Context.error(
                "Unmatched param, expected: " + parseParam(f), entry.pos
            );
        }

        return d;
    }

    /**
     * Parses the MetaParam as a string.
     * @param param to parse
     * @return String
    **/
    public static function parseParam(param:MetaParam):String {
        var s = "";
        if (param.optional != null && param.optional == true) s += "?";
        s += param.name;
        if (param.type != null && param.type != "") s += ":" + param.type;
        return s;
    }
    #end
}

/**
 * Metadata parameter, for extracting fields from the metadata.
**/
typedef MetaParam = {
    var name:String;

    /**
     * The pattern of the ExprDef to match.
     * Check bglib.utils.PrimitiveTools for usage.
    **/
    var pattern:String;

    /**
     * The type of the parameter, mostly used for error reporting.
     * Except for the type `Class`.
    **/
    var type:String;

    var ?optional:Bool;
    var ?extractValue:Bool;
}
