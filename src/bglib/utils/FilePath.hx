package bglib.utils;

import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;

/**
 * The implementation of FilePath.
**/
class FilePathImp extends Path {
    /**
     * Checks if the file exists.
     * @return Bool
    **/
    public function exists():Bool {
        return FileSystem.exists(this.toString());
    }

    /**
     * Creates the directory at this path.
     **/
    public function createDirectory() {
        if (exists()) throw "File already exists: " + this.toString();
        FileSystem.createDirectory(this.toString());
    }

    /**
     * Checks if the file is a directory.
     * @return Bool
    **/
    public function isDirectory():Bool {
        if (!exists()) {
            throw "No such file or directory: " + this.toString();
        }
        return FileSystem.isDirectory(this.toString());
    }

    /**
     * Returns all the paths in the directory.
     * @return Bool
    **/
    public function readDirectory():Array<FilePath> {
        if (!isDirectory()) throw "path is not a directory: " + this.toString();
        var files = FileSystem.readDirectory(this.toString());
        files.sort((s1, s2) -> if (s1 == s2) 0 else if (s1 > s2) 1 else -1);
        return files.map((f) -> this + FilePath.fromString(f));
    }

    /**
     * Gets the file content as a string.
     * @return String
    **/
    public function getContent():String {
        if (!exists()) throw "No such file or directory: " + this.toString();
        if (isDirectory()) throw "path is a directory: " + this.toString();
        return File.getContent(this.toString());
    }

    /**
     * Saves the content to a file.
     * @param content to save
    **/
    public function saveContent(content:String) {
        File.saveContent(this.toString(), content);
    }

    /**
     * Normalizes the path name.
     * `path/././to/../file` -> `/path/file`
     * @return FilePath normalized
    **/
    public function normalized():FilePath {
        return Path.normalize(this.toString());
    }

    /**
     * Returns the configuration directory of the application.
     * @param name of the app
     * @return FilePath
    **/
    static public function configDirectory(name = "app"):FilePath {
        #if debug
        return "./config";
        #elseif sys
        var configPath = switch (Sys.systemName()) {
            case "Windows":
                Sys.getEnv("APPDATA");
            case "Mac":
                Sys.getEnv("HOME") + "/Library/Application Support";
            default: // Linux and others
                // https://specifications.freedesktop.org/basedir-spec/latest/
                var xdgVar = Sys.getEnv("XDG_CONFIG_HOME");
                if (xdgVar != null) xdgVar;
                else Sys.getEnv("HOME") + "/.config";
        }

        configPath += "/" + name;
        return configPath;
        #end
    }

    /**
     * Returns the data directory of the application.
     * @param name of the app
     * @return FilePath
    **/
    static public function dataDirectory(name = "app"):FilePath {
        #if debug
        return "./data";
        #elseif sys
        var dataPath = switch (Sys.systemName()) {
            case "Windows":
                Sys.getEnv("LOCALAPPDATA");
            case "Mac":
                Sys.getEnv("HOME") + "/Library/Application Support";
            default: // Linux and others
                // https://specifications.freedesktop.org/basedir-spec/latest/
                var xdgVar = Sys.getEnv("XDG_DATA_HOME");
                if (xdgVar != null) xdgVar;
                else Sys.getEnv("HOME") + "/.local/share";
        }

        dataPath += "/" + name;
        return dataPath;
        #end
    }
}

/**
 * A class to save, load and manipulate file paths.
**/
@:forward
@:forward.new
@:forwardStatics
abstract FilePath(FilePathImp) from FilePathImp to FilePathImp {
    /**
     * Appends the given path to the back of this path.
     * @param path to append
     * @return FilePath
    **/
    @:op(a + b)
    public inline function append(path:FilePath):FilePath {
        return Path.join([this.toString(), path]);
    }

    /**
     * Appends the given path in-front of this path.
     * @param path to append
     * @return FilePath
    **/
    @:op(a + b)
    @:commutative
    public inline function appendInv(path:FilePath):FilePath {
        return Path.join([this.toString(), path]);
    }

    /**
     * Checks if the given path is the same to this.
     * @param path to check against
     * @return Bool
    **/
    @:op(a == b)
    public function equals(path:FilePath):Bool {
        return this.normalized()
            .toString() == path.normalized()
            .toString();
    }

    /**
     * Converts a string into a file path.
     * @param string to convert
     * @return FilePath
    **/
    @:from
    public static function fromString(string:String):FilePath {
        return new FilePath(string);
    }

    @:to
    public function toString():String {
        return this.toString();
    }
}
