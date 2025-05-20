package bglib.utils;

import haxe.Constraints.Constructible;
import haxe.ds.ArraySort;

using Lambda;
using StringTools;

/**
 * Import lambda tools.
**/
@:dox(hide)
typedef _TLambda = Lambda;

/**
 * Import string tools.
**/
@:dox(hide)
typedef _TStringTools = StringTools;

/**
 * Import date tools.
**/
@:dox(hide)
typedef _TDateTools = DateTools;

/**
 * A utility class which defines useful functions on primitives.
**/
class PrimitiveTools {
    /**
     * Repeats a string up to the given length.
     * @param str to repeat
     * @param length of the final string
     * @return String
    **/
    public static inline function repeat(str:String, length:Int):String {
        var s = "";
        while (s.length < length)
            s += str;
        return s.substr(0, length);
    }

    /**
     * Inserts a character at the given index.
     * @param str to modify
     * @param index of the character
     * @param c to insert
     * @return String
    **/
    public static inline function insertChar(
        str:String, index:Int, c:String
    ):String {
        return str.substring(0, index) + c + str.substring(index);
    }

    /**
     * Replaces a character at the given index.
     * @param str to modify
     * @param index of the character
     * @param c to replace
     * @return String
    **/
    public static inline function replaceChar(
        str:String, index:Int, c:String
    ):String {
        return str.substring(0, index) + c + str.substring(index + c.length);
    }

    /**
     * Removes a character at the given index.
     * @param str to modify
     * @param index of the character
     * @param c to remove
     * @return String
    **/
    public static inline function removeChar(str:String, index:Int):String {
        return str.substring(0, index) + str.substring(index + 1);
    }

    /**
     * Finds the maximum element in the array, based on the 
     * comparison function f.
     * @param as to filter
     * @param f (maxV, current)
     * @return T max
    **/
    public static function maxf<T>(as:Iterable<T>, f:(mv:T, c:T) -> Bool):T {
        var maxV:T = null;
        for (v in as) {
            if (maxV == null) maxV = v;
            if (f(maxV, v)) maxV = v;
        }
        return maxV;
    }

    /**
     * Finds the maximum element in the array.
     * @param as to filter
     * @return T max
    **/
    public static function max<T:Float>(as:Iterable<T>):T {
        var maxV:T = null;
        for (v in as) {
            if (maxV == null) maxV = v;
            if (maxV < v) maxV = v;
        }
        return maxV;
    }

    /**
     * Finds the minimum element in the array.
     * @param as to filter
     * @return T min
    **/
    public static function min<T:Float>(as:Iterable<T>):T {
        var minV:T = null;
        for (v in as) {
            if (minV == null) minV = v;
            if (minV > v) minV = v;
        }
        return minV;
    }

    /**
     * Binary search over the array. The array must be sorted,
     * if no value was found null is returned.
     * @param as array
     * @param f comparison function, where f(x) < 0 if x is under the goal
     * f(x) == 0 if the goal is found and f(x) > 0 if x is over the goal.
     * @return T
    **/
    public static function bsearch<T>(as:Array<T>, f:(mid:T) -> Float):T {
        var low = 0;
        var high = as.length - 1;
        var result:T = null;

        while (low <= high) {
            var mid = (low + high) >> 1;
            var cmp = f(as[mid]);
            if (cmp == 0) {
                result = as[mid];
                high = mid - 1;
            } else if (cmp < 0) low = mid + 1;
            else high = mid - 1;
        }
        return result;
    }

    /**
     * Sorts Array `a` according to the comparison function `cmp`, where
     * `cmp(x,y)` returns 0 if `x == y`, a positive Int if `x > y` and a
     * negative Int if `x < y`.
     *
     * This operation modifies Array `a` in place.
     *
     * This operation is stable: The order of equal elements is preserved.
     *
     * If `a` or `cmp` are null, the result is unspecified.
     * 
     * @param as the array to sort
     * @param cmp the comparison function
    **/
    public static inline function stableSort<T>(as:Array<T>, cmp:T->T->Int) {
        ArraySort.sort(as, cmp);
    }

    /**
     * Returns true only if any of the elements are true.
     * @param as to filter
     * @param f map
     * @return Bool
    **/
    public static inline function any<T>(as:Iterable<T>, f:T->Bool):Bool {
        return as.exists(f);
    }

    /**
     * Returns true only if all of the elements are true.
     * @param as to filter
     * @param f map
     * @return Bool
    **/
    public static inline function all<T>(as:Iterable<T>, f:T->Bool):Bool {
        return as.foreach(f);
    }

    /**
     * Joins two arrays into an array of pairs.
     * @param as the first array
     * @param bs the second array
     * @return Array<{a:T, b:U}>
    **/
    public static function zip<T, U>(
        as:Array<T>, bs:Array<U>
    ):Array<{a:T, b:U}> {
        var n = Utils.min(as.length, bs.length);
        var r = [];
        for (i in 0...n) {
            r.push({a: as[i], b: bs[i]});
        }
        return r;
    }

    /**
     * Concatenates two arrays into one modifying as in its place.
     * @param as the first array
     * @param bs the second array
     * @return Array<T>
    **/
    public static function concatenated<T>(as:Array<T>, bs:Array<T>):Array<T> {
        for (b in bs) {
            as.push(b);
        }
        return as;
    }

    /**
     * Shallow copy of a 2d array.
     * @param ass the matrix
     * @return Array<Array<T>>
    **/
    public static function clone<T>(ass:Array<Array<T>>):Array<Array<T>> {
        var n:Array<Array<T>> = [];
        for (y in 0...ass.length) {
            n.push([]);
            for (x in 0...ass[y].length) {
                n[y].push(ass[y][x]);
            }
        }
        return n;
    }

    /**
     * Maps the fields of the object to a new object.
     * @warning use with care.
     * @param a the object
     * @param m the mapping function
     * @return W
    **/
    @:noUsing
    public static function dynamicMap<U, V>(a:Any, m:U->V):Any {
        var d:Any = {};
        for (s in Reflect.fields(a)) {
            var f = Reflect.getProperty(a, s);
            Reflect.setField(d, s, m(f));
        }
        return d;
    }

    /**
     * Prints out a matrix with a nice styling, 
     * works best with character matrix.
     * @param ass to print
     * @param map elements
     * @param delim the spacing between elements
    **/
    public static function prettyPrint<T, S>(
        ass:Array<Array<T>>, ?map:T->S, delim = " "
    ) {
        var buffer:StringBuf = new StringBuf();
        var length = ass[0].length;
        var spacing = repeat(" ", Math.floor(Utils.logb(10, ass.length)));

        var digits = Math.floor(Utils.logb(10, length));
        for (i in 0...digits + 1) {
            var v = [
                for (j in 0...length)
                    (Math.floor(j / Math.pow(10, digits - i)) % 10)
            ];
            buffer.add(spacing);
            buffer.add("  │ \x1b[2m");
            buffer.add(v.join(delim));
            buffer.add("\x1b[0m\n");
        }
        var v = repeat("─", length * (1 + delim.length));
        var spacing = repeat("─", Math.floor(Utils.logb(10, ass.length)));

        buffer.add(spacing);
        buffer.add("──┼─");
        buffer.add(v);
        buffer.add("\n");

        for (i in 0...ass.length) {
            var l:String;
            if (map != null) {
                l = ass[i].map(map).join(delim);
            } else {
                l = ass[i].join(delim);
            }

            var spacing = repeat(
                " ",
                Math.floor(Utils.logb(10, ass.length)) - Math.floor(Utils.logb(10, i)));
            if (i == 0) spacing = repeat(
                " ", Math.floor(Utils.logb(10, ass.length)));
            buffer.add(spacing);
            buffer.add('\x1b[2m$i\x1b[0m │ $l\n');
        }

        Sys.print(buffer.toString());
    }

    /**
     * Converts the matrix into an aligned table.
     * @param ass matrix
     * @param map converts the elements into a string
     * @param delim separator
     * @param length callback to get the elements size
     * @return Array<String>
    **/
    public static function tabular<T>(
        ass:Array<Array<T>>, ?map:(T) -> String, delim = " ",
        ?length:(v:T) -> Int
    ):Array<String> {
        if (map == null) {
            map = (v) -> {
                Std.string(v);
            };
        }
        if (length == null) {
            length = (v) -> {
                map(v).length;
            };
        }

        var ms:Array<Null<Int>> = [];
        for (vs in ass) {
            for (i => v in vs) {
                if (ms[i] == null) ms[i] = length(v);
                ms[i] = Utils.max(ms[i], length(v));
            }
        }
        var ls:Array<String> = [];
        for (vs in ass) {
            var s = new StringBuf();
            for (i => v in vs) {
                var l = length(v);
                var m = ms[i];
                s.add(PrimitiveTools.repeat(" ", m - l));
                s.add(map(v));
                if (i != vs.length - 1) {
                    s.add(delim);
                }
            }
            ls.push(s.toString());
        }
        return ls;
    }

    /**
     * stringify the date as a time stamp.
     * @param stamp to stringify
     * @param ms include milliseconds
     * @return String
    **/
    public static function dt(stamp:Date, ms:Bool = false):String {
        var t = stamp.getTime();
        var d = DateTools.parse(t);

        var out = d.days == 0 ? "" : '${d.days}d ';
        out += (d.hours < 10 ? "0" : "") + d.hours;
        out += ":" + (d.minutes < 10 ? "0" : "") + d.minutes;
        out += ":" + (d.seconds < 10 ? "0" : "") + d.seconds;
        if (ms) {
            var m = Std.int(d.ms / 10);
            out += "." + (m < 10 ? "0" : "") + m;
        }
        return out;
    }

    /**
     * Converts a string to its corresponding day number.
     * @param day of the week
     * @return Int
    **/
    @:noUsing
    public static function toWeekDay(day:String):Int {
        @:privateAccess
        var i = DateTools.DAY_SHORT_NAMES.findIndex((d) -> d == day);
        if (i != -1) return i + 1;
        @:privateAccess
        var i = DateTools.DAY_NAMES.findIndex((d) -> d == day);
        if (i != -1) return i + 1;

        throw 'Invalid day name: $day';
    }

    /**
     * Converts a string to its corresponding month number.
     * @param month of the year
     * @return Int
    **/
    @:noUsing
    public static function toYearMonth(month:String):Int {
        @:privateAccess
        var i = DateTools.MONTH_SHORT_NAMES.findIndex((d) -> d == month);
        if (i != -1) return i + 1;
        @:privateAccess
        var i = DateTools.MONTH_NAMES.findIndex((d) -> d == month);
        if (i != -1) return i + 1;

        throw 'Invalid month name: $month';
    }

    static function splitArgs(args:String, delim:Int = ",".code):Array<String> {
        var result = [];
        var depth = 0;
        var current = "";
        for (c in args) {
            if (c == delim && depth == 0) {
                result.push(current);
                current = "";
                continue;
            }
            switch (c) {
                case "(".code:
                    depth++;
                case ")".code:
                    depth--;
                case _:
            }
            current += String.fromCharCode(c);
        }
        if (current != "") result.push(current);
        if (depth != 0) {
            throw new ParseException("Unmatched parentheses in : " + args);
        }
        return result;
    }

    /**
     * Checks if the enum value matches the pattern. Use _ as wildcards.
     * Supports basic type matching.
     * 
     * dynamicMatch(haxe.ds.Either.Left(182), "Left(182|23)|Right(_)")
     * dynamicMatch(haxe.ds.Option.Some(451), "Left(451)")
     * 
     * @param e enum value to match
     * @param pattern to match against
     * @return Bool
    **/
    public static function dynamicMatch(e:EnumValue, pattern:String):Bool {
        var ws = ~/\s+/g;
        pattern = ws.replace(pattern, "");
        if (pattern == "_") return true;
        var patterns = splitArgs(pattern, "|".code);
        if (patterns.length > 1) {
            return patterns.exists((p) -> dynamicMatch(e, p));
        }
        switch (Type.typeof(e)) {
            case TNull | TBool | TInt | TFloat:
                return Std.string(e) == pattern;
            case TClass(String):
                return Std.string(e) == pattern;
            case TEnum(_):
            case t:
                throw new ParseException(
                    'Unsupported pattern: $pattern with type: $t '
                );
        }

        var ematch = ~/(\w*)\((.*)\)/g;
        if (!ematch.match(pattern)) throw new ParseException(
            "Invalid pattern: " +
            pattern
        );

        var id = ematch.matched(1);
        var args = splitArgs(ematch.matched(2));
        if (e.getName() != id) return false;

        var eArgs = e.getParameters();
        return all(zip(eArgs, args), (p) -> dynamicMatch(p.a, p.b));
    }

    /**
     * Creates a copy of the object, using reflection.
     * Does not call the constructor.
     * @param a to copy
     * @return T
    **/
    public static function copy<T>(a:T):T {
        var cls:Class<T> = Type.getClass(a);
        var b:T = Type.createEmptyInstance(cls);
        var fields = Type.getInstanceFields(cls); 
        for (field in fields) {
            var val:Dynamic = Reflect.field(a, field);
            if (!Reflect.isFunction(val)) {
                Reflect.setField(b, field, val);
            }
        }
        return b;
    }
}
