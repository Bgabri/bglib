package bglib.utils;

/**
 * Defines utilities 
 **/
class Utils {
    /**
     * Integer Division.
     * @param a float or int
     * @param b float or int
     * @return Int
     **/
    public static inline function div<T:Float>(a:T, b:T):Int {
        return Std.int(a/b);
    }

    /**
     * Integer min.
     * @param a float or int
     * @param b float or int
     * @return Int
     **/
    public static inline function min<T:Float>(a:T, b:T):T {
        return (a < b) ? a : b;
    }

    /**
     * Integer max.
     * @param a float or int
     * @param b float or int
     * @return Int
     **/
    public static inline function max<T:Float>(a:T, b:T):T {
        return (a > b) ? a : b;
    }

    /**
     * Consistent type clamping.
     * @param x to clamp
     * @param lower float or int
     * @param higher float or int
     * @return T
     **/
    public static inline function clamp<T:Float>(x:T, lower:T, higher:T):T {
        return min(higher, max(lower, x));
    }

    /**
     * Consistent type clamping.
     * @param a float or int
     * @return T
     **/
    public static inline function abs<T:Float>(a:T):T {
        if (a < 0) return -a;
        return a;
    }

    /**
     * Log base.
     * @param base float
     * @param v float
     * @return Float
     **/
    public static inline function logb(base:Float, v:Float):Float {
        return Math.log(v)/Math.log(base);
    }
}