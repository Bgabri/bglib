package bglib.utils;

/*
    ...
    private extern abstract Ordered<T>(T) from T to T {
    @:op("<")
    public function lt(other:Ordered<T>):Bool;

    @:op("<=")
    public function leq(other:Ordered<T>):Bool;

    @:op(">")
    public function gt(other:Ordered<T>):Bool;

    @:op(">=")
    public function geq(other:Ordered<T>):Bool;
    }

    private extern abstract Equatable<T>(T) from T to T {
    @:op("==")
    public function equiv(other:Equatable<T>):Bool;

    @:op("!=")
    public function nEquiv(other:Equatable<T>):Bool;
    }

    private abstract Accessible<T>(T) from T to T {
    @:arrayAccess
    public function get(index:Int):T;
    }
 */
/**
 * Defines a measurable type.
**/
typedef Measurable = {
    public var length(default, null):Int;
}
