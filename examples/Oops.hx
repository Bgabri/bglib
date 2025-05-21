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
    public var b:String;

    public function new() {
        b = "world";
        super();
    }

    public function toString():String {
        return a + " " + b;
    }

    public static function builder():BBuilder {
        return new BBuilder();
    }
}

@:builder(A)
class ABuilder implements Builder {}

@:builder(B)
class BBuilder extends ABuilder {}

class NoOne implements Singleton {
    function new() {
        trace("hello there");
    }
}

class Oops implements Singleton {
    static function main() {
        var bb = B.builder();
        // bb.setA("A").setB("B");
        bb.b("1");
        var b1 = bb.build();
        bb.a("banana");
        bb.b("2");
        var b2 = bb.build();
        trace(b1);
        trace(b2);
    }
}
