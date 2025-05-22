package oops;

import bglib.oops.Builder;

/**
 * Class to test the Builder macro.
 **/
class ProductFieldMetaArgs {
    @:builderField(true)
    var exclude:String;

    @:builderField("renamed")
    var name:String;

    public function new() {}

    @:builderField(false)
    function include(a:String):String {
        return exclude = a;
    }

    public function toString():String {
        return '/$exclude $name/';
    }

    /**
     * the builder
     * @return FieldMetaArgsBuilder
     **/
    public static function builder():FieldMetaArgsBuilder {
        return new FieldMetaArgsBuilder();
    }
}

@:builder(ProductFieldMetaArgs)
class FieldMetaArgsBuilder implements Builder {}
