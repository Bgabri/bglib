import bglib.oops.*;

// class A implements Buildable {
class A {
    public var a:String;

    public function new() {
        a = "hello";
    }

    public static function builder():ABuilder {
        return new ABuilder();
    }
}

class B extends A {
    public var c:String;
    public var b:String;

    public function new() {
        b = "world";
        super();
    }

    @:builderField(false)
    public function ssss(a:A, ?b:Int, s:String = "ssss"):String {
        trace(a, b, s);
        return s;
    }

    public function toString():String {
        return a + " " + b + " " + c;
    }

    public static function builder():ABBuilder {
        return new ABBuilder();
    }
}

@:builder(A)
class ABuilder implements Builder {}

@:builder(B)
class ABBuilder extends ABuilder {}

@:builder(B, "pppp", "llll")
class C implements Builder {}

class NoOne implements Singleton {
    function new() {
        trace("hello there");
    }
}

class Oops implements Singleton {
    static function main() {
        var fields = Type.getInstanceFields(C);
        trace(fields);

        var bb = B.builder();
        bb.b("1");
        var b1 = bb.build();
        bb.a("banana");
        bb.b("2");
        var b2 = bb.build();
        trace(b1);
        trace(b2);
    }
}
