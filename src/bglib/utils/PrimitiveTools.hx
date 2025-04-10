package bglib.utils;

using Lambda;

/**
 * Import lambda tools.
**/
@:dox(hide)
typedef TLambda = Lambda;

/**
 * Import string tools.
**/
@:dox(hide)
typedef TString = StringTools;

/**
 * Import date tools.
**/
@:dox(hide)
typedef TDate = DateTools;

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
    public static inline function insert(
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
    public static inline function replace(
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
    public static inline function remove(str:String, index:Int):String {
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
    public static function toYearMonth(month:String):Int {
        @:privateAccess
        var i = DateTools.MONTH_SHORT_NAMES.findIndex((d) -> d == month);
        if (i != -1) return i + 1;
        @:privateAccess
        var i = DateTools.MONTH_NAMES.findIndex((d) -> d == month);
        if (i != -1) return i + 1;

        throw 'Invalid month name: $month';
    }
}
