import bglib.oops.*;

class A {
    public var a:String;

    public function new() {
        a = "hello";
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
}

@:builder(A)
class ABuilder implements Builder {}

@:builder(B)
// @:builder(false)
// class BBuilder extends ABuilder {}
class BBuilder implements Builder {}

class NoOne implements Singleton {
    function new() {
        trace("hello there");
    }
}

class Oops implements Singleton {
    static function main() {
        var bb = new BBuilder();
        bb.setA("A").setB("B");
        trace(bb.build());

    }
}
