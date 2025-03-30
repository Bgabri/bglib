using utils.PrimitiveTools;

using Lambda;

/**
 * tests formatter
**/
class Formatest {
    function new() {}

    function one(bean:Int):Int {
        var beeeeeeeeeaaaaaaaaaaaaaaannnnnnnnnsssss = 10;
        if (beeeeeeeeeaaaaaaaaaaaaaaannnnnnnnnsssss == beeeeeeeeeaaaaaaaaaaaaaaannnnnnnnnsssss) {
            return bean;
        }

        if (
            bean <= bean ||
            (bean == bean && bean > 10) ||
            bean > 10 ||
            bean > 10
        ) {
            return bean;
        }

        return 1 + bean;
    }

    function lotsOfParameters(
        a__:Int, b__:Int, c__ = 1000, d__ = 205, e__ = "something longer"
    ) {
        Sys.print(e__);
        Sys.print(a__ + b__ + c__ + d__);

        var s = "h";

        s = s.repeat(5)
            .charAt(1)
            .remove(1);

        s = s.repeat(5)
            .charAt(1)
            .toUpperCase()
            .repeat(4)
            .toLowerCase()
            .replace(2, "3")
            .repeat(2);
    }

    function tooManyParameters(
        a__:Int,
        b__:Int,
        c__:Int,
        d__:Int,
        e__:Int,
        f__:Int,
        g__:Int,
        h:Int
    ) {
        Sys.print(e__);
        Sys.print(a__ + b__ + c__ + d__);
    }

    function longParametersWithLongFunctionName(
        firstLongParameter:String, secondLongParameter:String
    ) {}
}
