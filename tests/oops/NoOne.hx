package oops;

import bglib.oops.Singleton;

/**
 * basic singleton class in as a submodule.
 **/
class SubNoOne implements Singleton {
    public var field:String = "hello from sub";
}

/**
 * Singleton class, with chickenJockey as the singleton accessor field.
 **/
@:singleton("chickenJockey")
class NoOne implements Singleton {
    public var field:String = "hello";
    function new() {}
}
