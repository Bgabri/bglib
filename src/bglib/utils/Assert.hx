#if debug
package bglib.utils;
import bglib.tui.Trees.Bold;
import bglib.tui.Trees.Colour;

/**
 * A utility class to help check the equivalence of two expressions.
 **/
class Assert {

    public static inline function equals<T>(value:T, match:T) {
        var check:String =
            if (value == match) Bold(Colour(Green, "o"));
            else Bold(Colour(Red, "x"));
        check = "["+check+"]";

        Sys.println(check + ": " + value);
    }
}

#end