package utils;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

/**
 * The implementation of FilePath.
 **/
class FilePathImp extends Path {

    public function exists():Bool {
        return FileSystem.exists(this.toString());
    }

    public function isDirectory():Bool {
        if (!exists()) throw "No such file or directory";
        return FileSystem.isDirectory(this.toString());
    }

    public function readDirectory():Array<FilePath> {
        if (!isDirectory()) throw  "path is not a directory";
        var files = FileSystem.readDirectory(this.toString());
        files.sort((s1, s2) -> if (s1 == s2) 0 else if (s1 > s2) 1 else -1);
        // return files.map((f) -> FilePath.fromString(f));
        return files.map((f) -> this + FilePath.fromString(f));
    }

    public function getContent():String {
        if (!exists()) throw "No such file or directory";
        if (isDirectory()) throw  "path is a directory";
        return File.getContent(this.toString());
    }

    public function saveContent(content:String) {
        File.saveContent(this.toString(), content);
    }


    public function normalized():FilePath {
        return Path.normalize(this.toString());
    }

    static var appName:String = "dailies";

    static public function configDirectory() {
        #if debug
        return new FilePath("./config");
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

        configPath += "/" + appName;
        return new FilePath(configPath);
        #end
    }

    static public function dataDirectory() {
        #if debug
        return new FilePath("./data");
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

        dataPath += "/" + appName;
        return new FilePath(dataPath);
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

    // public function new(path:String) {
    //     this = new FilePathImp(path);
    // }

    @:op(a+b)
    public inline function append(file:FilePath):FilePath {
        return Path.join([this.toString(), file]);
    }

    @:op(a+b)
    @:commutative
    public inline function appendInv(file:FilePath):FilePath {
        return Path.join([this.toString(), file]);
    }


    @:op(a==b)
    public function equals(file:FilePath):Bool {
        return this.normalized().toString() == file.normalized().toString();
    }

    @:from
    public static function fromString(string:String):FilePath {
        return new FilePath(string);
    }

    @:to
    public function toString():String {
        return this.toString();
    }
}
