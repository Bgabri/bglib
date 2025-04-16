using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

using bglib.utils.PrimitiveTools;

enum B {
    singleS(a:String);
    doubleS(a:String, b:String);
    singleI(a:Int);
    doubleI(a:Int, b:Int);
    singleA(a:A);
    doubleA(a:A, b:A);
}

enum A {
    singleS(a:String);
    doubleS(a:String, b:String);
    singleI(a:Int);
    doubleI(a:Int, b:Int);
    singleB(a:B);
    doubleB(a:B, b:B);
    C(c:C);
}

class C {
    public function new() {}
}

typedef ETest = {
    var e:EnumValue;
    var pattern:String;
}

class EnumMatch<T> {
    public static function main() {
        var tests:Array<ETest> = [
            {
                e: B.singleS("a"),
                pattern: "singleS(_)"
            },
            {
                e: B.singleA(A.doubleI(43, 29)),
                pattern: "singleA(_)"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(_), doubleS(_, _))"
            },
            {
                e: B.doubleA(A.singleI(42), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(_), _)"
            },
            {
                e: B.doubleA(A.singleI(null), A.doubleS("a", "b")),
                pattern: "doubleA(singleI(null), _)"
            },
            {
                e: B.singleI(42),
                pattern: "singleI(4)|singleI(42)"
            },
            {
                e: B.singleI(3),
                pattern: "singleI(4)|singleI(95)|singleI(42)"
            },
            {
                e: B.singleI(42),
                pattern: "singleI(4|42)"
            },
            {
                e: B.doubleA(A.singleI(null), A.singleS("c")),
                pattern: "doubleA(_, doubleS(a, b)|singleS(a|b))"
            }
        ];

        for (t in tests) {
            var e = t.e;
            var pattern = t.pattern;
            trace('Testing ${e.getName()} with pattern ${pattern}');
            if (e.dynamicMatch(pattern)) trace("Matched!");
            else trace("Not matched!");
        }
    }
}
