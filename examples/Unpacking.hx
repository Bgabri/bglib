import haxe.Rest;

using bglib.macros.UnPack;

class Unpacking {
    static function multiply(a:Int, b:Int):Int {
        return a * b;
    }

    static function multiply3(a:Int, ?b:Int, c:Int = 10):Int {
        if (b == null) b = 4;
        return a * b * c;
    }

    static function varMultiply(...args:Int):Int {
        var result = 1;
        for (arg in args) {
            result *= arg;
        }
        return result;
    }

    static function main() {
        var as:Array<Int> = [2, 5, 7];
        trace(multiply.unpack(as));
        var as:haxe.ds.Vector<Int> = new haxe.ds.Vector(2, 2);
        trace(UnPack.unpack(multiply, as));
        var as = {
            a: 3,
            b: 5
        };
        trace(UnPack.unpack(multiply, as));
        var as = [1];
        trace(multiply3.unpack(as));
        trace(multiply.unpack(as)); // exception
    }
}
