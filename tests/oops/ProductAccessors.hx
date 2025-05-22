package oops;

import bglib.oops.Builder;

/**
 * Class to test the Builder macro.
**/
class ProductAccessors {
    final f:String;
    var rw:String;
    var dn(default, null):String;
    var nd(null, default):String;

    var gsValue:String;
    var gs(get, set):String;
    @:isVar
    var gsReal(get, set):String;
    var gn(get, never):String;
    var ns(never, default):String;

    public function new() {
        f = "f";
    }

    public function toString():String {
        return '/$f $rw $dn $nd $gs $gsReal $gn/';
    }

    function set_gs(value:String):String {
        return gsValue = value;
    }

    function get_gs():String {
        return gsValue;
    }

    function get_gn():String {
        return "gn";
    }

    function set_gsReal(value:String):String {
        return gsReal = value;
    }

    function get_gsReal():String {
        return gsReal;
    }

    /**
     * the builder
     * @return AccessorBuilder
     **/
    public static function builder():AccessorBuilder {
        return new AccessorBuilder();
    }
}

@:builder(ProductAccessors)
class AccessorBuilder implements Builder {}
