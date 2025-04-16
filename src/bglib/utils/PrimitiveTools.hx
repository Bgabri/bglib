package bglib.utils;

import haxe.Exception;

using Lambda;
using StringTools;

/**
 * Import lambda tools.
**/
@:dox(hide)
typedef TLambda = Lambda;

/**
 * Import string tools.
**/
@:dox(hide)
typedef TStringTools = StringTools;

/**
 * Import date tools.
**/
@:dox(hide)
typedef TDateTools = DateTools;

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
     * Finds the maximum element in the array.
     * @param arr to filter
     * @return T max
    **/
    public static function max<T:Float>(arr:Array<T>):T {
        var maxV:T = arr[0];
        for (v in arr) {
            if (maxV < v) maxV = v;
        }
        return maxV;
    }

    /**
     * Finds the minimum element in the array.
     * @param arr to filter
     * @return T min
    **/
    public static function min<T:Float>(arr:Array<T>):T {
        var minV:T = arr[0];
        for (v in arr) {
            if (minV > v) minV = v;
        }
        return minV;
    }

    /**
     * Returns true only if any of the elements are true.
     * @param arr to filter
     * @param f map
     * @return Bool
    **/
    public static function any<T>(arr:Array<T>, f:T->Bool):Bool {
        return arr.exists(f);
    }

    /**
     * Returns true only if all of the elements are true.
     * @param arr to filter
     * @param f map
     * @return Bool
    **/
    public static function all<T>(arr:Array<T>, f:T->Bool):Bool {
        return arr.foreach(f);
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
     * Shallow copy of a 2d array.
     * @param a the matrix
     * @return Array<Array<T>>
    **/
    public static function clone<T>(a:Array<Array<T>>):Array<Array<T>> {
        var n:Array<Array<T>> = [];
        for (y in 0...a.length) {
            n.push([]);
            for (x in 0...a[y].length) {
                n[y].push(a[y][x]);
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
     * @param arr to print
     * @param map elements
     * @param delim = " " the spacing between elements
    **/
    public static function prettyPrint<T, S>(
        arr:Array<Array<T>>, ?map:T->S, delim = " "
    ) {
        var buffer:StringBuf = new StringBuf();
        var length = arr[0].length;
        var spacing = repeat(" ", Math.floor(Utils.logb(10, arr.length)));

        var digits = Math.floor(Utils.logb(10, length));
        for (i in 0...digits + 1) {
            var v = [
                for (j in 0...length)
                    (Math.floor(j / Math.pow(10, digits - i)) % 10)
            ];
            // var l = v.map(n -> n == 0 ? " " : '$n');
            buffer.add(spacing);
            buffer.add("  │ \x1b[2m");
            buffer.add(v.join(delim));
            buffer.add("\x1b[0m\n");
        }
        var v = repeat("─", length * (1 + delim.length));
        var spacing = repeat("─", Math.floor(Utils.logb(10, arr.length)));

        buffer.add(spacing);
        buffer.add("──┼─");
        buffer.add(v);
        buffer.add("\n");

        for (i in 0...arr.length) {
            var l:String;
            if (map != null) {
                l = arr[i].map(map).join(delim);
            } else {
                l = arr[i].join(delim);
            }

            var spacing = repeat(
                " ",
                Math.floor(Utils.logb(10, arr.length)) - Math.floor(Utils.logb(10, i)));
            if (i == 0) spacing = repeat(
                " ", Math.floor(Utils.logb(10, arr.length)));
            buffer.add(spacing);
            buffer.add('\x1b[2m$i\x1b[0m │ $l\n');
        }

        Sys.print(buffer.toString());
    }

    public static function tabular<T>(
        arr:Array<Array<T>>, ?map:(T) -> String, delim = " ",
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
        for (vs in arr) {
            for (i => v in vs) {
                if (ms[i] == null) ms[i] = length(v);
                ms[i] = Utils.max(ms[i], length(v));
            }
        }
        var ls:Array<String> = [];
        for (vs in arr) {
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

        var out = d.days == 0 ? '' : '${d.days}d ';
        out += (d.hours < 10 ? '0' : '') + d.hours;
        out += ":" + (d.minutes < 10 ? '0' : '') + d.minutes;
        out += ":" + (d.seconds < 10 ? '0' : '') + d.seconds;
        if (ms) {
            var m = Std.int(d.ms / 10);
            out += "." + (m < 10 ? '0' : '') + m;
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
}

/**
 * Exception when parsing.
**/
class ParseException extends Exception {
    public function new(message:String) {
        super(message);
    }
}
