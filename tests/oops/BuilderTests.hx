package oops;

import bglib.oops.Builder;

import tink.testrunner.Assertions;
import tink.unit.Assert.assert;

import oops.ProductAccessors.AccessorBuilder;
import oops.ProductFieldMetaArgs.FieldMetaArgsBuilder;

using bglib.utils.PrimitiveTools;

class A {
    var a:String;

    public function new() {}

    public function toString():String {
        return '/$a/';
    }

    /**
     * the builder
     * @return ABuilder
    **/
    public static function builder():ABuilder {
        return new ABuilder();
    }
}

class B extends A {
    var b:String;

    public function new() {
        super();
    }

    override public function toString():String {
        return '/$a $b/';
    }

    /**
     * the builder
     * @return BBuilder
    **/
    public static function builder():BBuilder {
        return new BBuilder();
    }
}

@:builder(A)
class ABuilder implements Builder {}

@:builder(B, true)
class BBuilder implements Builder {}

@:builder(B, false)
class ABBuilder extends ABuilder {}

@:builder(B, "customObject", "customBuild")
class CustomBuilder implements Builder {}

@:asserts
class BuilderTests {
    public function new() {}

    /**
     * Tests basic builder functionality.
     * @return Assertions
    **/
    public function builder():Assertions {
        var ab = A.builder();
        var a = ab.a("hello").build();
        return assert('$a' == "/hello/");
    }

    /**
     * tests for inheritance of the product.
     * @return Assertions
    **/
    public function productInheritance():Assertions {
        var bBFields = Type.getInstanceFields(BBuilder);
        asserts.assert(bBFields.any(f -> f == "a"));
        asserts.assert(bBFields.any(f -> f == "b"));
        var bb = B.builder();
        var b = bb.a("hello")
            .b("world")
            .build();
        asserts.assert('$b' == "/hello world/");
        return asserts.done();
    }

    /**
     * Tests for inheritance of the builder.
     * @return Assertions
    **/
    public function builderInheritance():Assertions {
        var abBFields = Type.getInstanceFields(ABBuilder);
        asserts.assert(abBFields.any(f -> f == "a"));
        asserts.assert(abBFields.any(f -> f == "b"));
        return asserts.done();
    }

    /**
     * Tests for reuse of the builder.
     * @return Assertions
    **/
    public function builderReuse():Assertions {
        var ab = A.builder();
        var a1 = ab.a("hello").build();
        var a2 = ab.build();
        var a3 = ab.a("world").build();
        asserts.assert('$a1' == "/hello/");
        asserts.assert('$a2' == "/hello/");
        asserts.assert('$a3' == "/world/");
        asserts.assert('$a1' == '$a2');
        asserts.assert('$a1' != '$a3');
        return asserts.done();
    }

    public function customMethods():Assertions {
        var fields = Type.getInstanceFields(CustomBuilder);

        asserts.assert(fields.any(f -> f == "customObject"));
        asserts.assert(fields.any(f -> f == "get_customObject"));
        asserts.assert(fields.any(f -> f == "customBuild"));
        return asserts.done();
    }

    /**
     * Tests the builder macro for metadata parameters.
     * @return Assertions
    **/
    public function fieldMetaArguments():Assertions {
        var fields = Type.getInstanceFields(FieldMetaArgsBuilder);
        asserts.assert(fields.length == 5);
        asserts.assert(fields.any(f -> f == "renamed"));
        asserts.assert(fields.all(f -> f != "exclude"));

        var builder = ProductFieldMetaArgs.builder();
        builder.include("_1").renamed("_2");
        var product = builder.build();

        asserts.assert('$product' == "/_1 _2/");
        return asserts.done();
    }

    /**
     * Tests the builder macro, for various access modifiers.
     * @return Assertions
    **/
    public function varAccessors():Assertions {
        var ab = ProductAccessors.builder();
        ab.rw("_1")
            .dn("_2")
            .nd("_3")
            .gs("_4")
            .gsReal("_5")
            .ns("_6");

        var fields = Type.getInstanceFields(AccessorBuilder);
        asserts.assert(fields.all(f -> f != "gn"));

        var a = ab.build();
        asserts.assert('$a' == "/f _1 _2 _3 _4 _5 gn/");
        return asserts.done();
    }
}
