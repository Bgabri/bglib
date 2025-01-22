package utils;

class PrimitiveTools {

    public static inline function repeat(str:String, length:Int):String {
        var s = "";
        while (s.length < length) s += str;
        return s.substr(0, length);
    }

    public static inline function insert(
        str:String, index:Int, c:String
    ):String {
        return str.substring(0, index) + c + str.substring(index);
    }

    public static inline function replace(
        str:String, index:Int, c:String
    ):String {
        return str.substring(0, index) + c + str.substring(index+c.length);
    }

    public static inline function remove(str:String, index:Int):String {
        return str.substring(0, index) + str.substring(index+1);
    }

    // public static inline function flatten(arr:Array<String>):String {
    //     var s = "";
    //     for (v in arr) s += v;
    //     return s;
    // }

    public static function max<T:Float>(arr:Array<T>):T {
        var maxV:T = arr[0];
        for (v in arr) {
            if (maxV < v) maxV = v;
        }
        return maxV;
    }

    public static function min<T:Float>(arr:Array<T>):T {
        var minV:T = arr[0];
        for (v in arr) {
            if (minV > v) minV = v;
        }
        return minV;
    }

    public static function any<T>(arr:Array<T>, f:T -> Bool):Bool {
        for (v in arr) if (f(v)) return true;
        return false;
    }

    public static function all<T>(arr:Array<T>, f:T -> Bool):Bool {
        for (v in arr) if (!f(v)) return false;
        return true;
    }

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


    public static function prettyPrint<T, S>(arr:Array<Array<T>>, ?map: T -> S , delim = " ") {

        var buffer:StringBuf = new StringBuf();
        var length = arr[0].length;
        var spacing = repeat(" ", Math.floor(Utils.logb(10, arr.length)));

        var digits = Math.floor(Utils.logb(10, length));
        for (i in 0...digits+1) {
            var v = [for (j in 0...length) (Math.floor(j/Math.pow(10, digits-i))%10)];
            // var l = v.map(n -> n == 0 ? " " : '$n');
            buffer.add(spacing);
            buffer.add("  │ \x1b[2m");
            buffer.add(v.join(delim));
            buffer.add("\x1b[0m\n");
        }
        var v = repeat("─", length*(1+delim.length));
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

            var spacing = repeat(" ", Math.floor(Utils.logb(10, arr.length)) - Math.floor(Utils.logb(10, i)));
            if (i == 0) spacing = repeat(" ", Math.floor(Utils.logb(10, arr.length)));
            buffer.add(spacing);
            buffer.add('\x1b[2m$i\x1b[0m │ $l\n');
        }

        Sys.print(buffer.toString());
    }
}