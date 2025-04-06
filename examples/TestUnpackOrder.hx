using Lambda;
using StringTools;

// using bglib.utils.PrimitiveTools;
class TestUnpackOrder {
    public static function main() {
        var optStr = "xooxxoxox";
        var optStr = "oxxoxoo";
        var opts = optStr.split("").map((c) -> c == "o");

        opts.reverse();
        // trace(opts);
        var numOpts = 0;
        var numNonOpts = 0;

        var rolling = [];
        for (op in opts) {
            if (!op) {
                numNonOpts++;
                rolling.push(0);
            } else rolling.push(numNonOpts);
        }
        rolling.reverse();

        Sys.println("    " + rolling.join(" "));
        Sys.println("    " + optStr.split("").join(" "));
        for (i in 0...rolling.length) {
            var ids:Dynamic = [];
            var n = i + 1;
            var pos = 0;
            var nonPos = n;
            for (j in 0...rolling.length) {
                var r = rolling[j];
                if (r < n) {
                    ids.push('\x1b[35m${pos++}\x1b[0m');
                    n--;
                } else {
                    ids.push('\x1b[30m${nonPos++}\x1b[0m');
                }
            }

            Sys.println(i + 1 + " : " + ids.join(" "));
        }
    }
}
