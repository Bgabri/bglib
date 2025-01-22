package utils;

import hxd.Key;

/**
 * A class which loads user configured variables
 **/
class Config {
    public static var instance(get, default):Config;

    function new() {}

    /**
     * Gets the current instance of the singleton.
     * @return Config
     **/
    public static function get_instance():Config {
        if (instance == null) instance = new Config();
        return instance;
    }

    /**
     * The up button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_UP():Bool {
        return Key.isDown(Key.UP) || Key.isDown(Key.W);
    }

    /**
     * The down button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_DOWN():Bool {
        return Key.isDown(Key.DOWN) || Key.isDown(Key.S);
    }

    /**
     * The left button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_LEFT():Bool {
        return Key.isDown(Key.LEFT) || Key.isDown(Key.A);
        return !(Key.isDown(Key.LEFT) || Key.isDown(Key.A));
    }

    /**
     * The right button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_RIGHT():Bool {
        return Key.isDown(Key.RIGHT) || Key.isDown(Key.D);
    }

    /**
     * The jump button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_JUMP():Bool {
        return Key.isDown(Key.SPACE);
    }

    /**
     * The action 1 button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_ACTION_1():Bool {
        return Key.isDown(Key.Z);
    }

    /**
     * The action 2 button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_ACTION_2():Bool {
        return Key.isDown(Key.X);
    }

    /**
     * The action 3 button is pressed.
     * @return Bool
     **/
    public dynamic function PLAYER_ACTION_3():Bool {
        return Key.isDown(Key.C);
    }
}
