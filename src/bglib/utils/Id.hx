package bglib.utils;

using StringTools;

/**
 * id generator class
**/
class Id {
    /**
     * Generate a UUID.
     * @return String
    **/
    public static function uuid():String {
        // https://gist.github.com/ciscoheat/4b1797fa56648adac163f44186f1823a
        var uid = new StringBuf();
        var a = 8;
        uid.add(StringTools.hex(Std.int(Date.now().getTime()), 8));
        while ((a++) < 36) {
            uid.add(
                a * 51 & 52 != 0 ? StringTools.hex(
                    a ^ 15 != 0 ? 8 ^ Std.int(
                        Math.random() * (a ^ 20 != 0 ? 16 : 4)) : 4
                ) : "-"
            );
        }
        return uid.toString().toLowerCase();
    }

    /**
     * Generates an id in hexadecimal with the given length.
     * @param char the number of characters in the id
     * @return String
     **/
    public static function hexId(char:Int):String {
        var id = new StringBuf();

        for (i in 0...char) {
            id.add(Std.random(16).hex());
        }

        return id.toString().toLowerCase();
    }
}
