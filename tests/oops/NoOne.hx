package oops;

import bglib.oops.Singleton;

class SubNoOne implements Singleton {
    public var field:String = "hello from sub";
}

@:singleton("chickenJockey")
class NoOne implements Singleton {
    public var field:String = "hello";
    function new() {}
}
