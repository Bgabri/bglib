package utils;

import tink.testrunner.Assertions;
import tink.unit.AssertionBuffer;

using bglib.utils.FilePath;

@:asserts
class FilePathTests {
    public function new() {}

    public function equality():Assertions {
        var path:FilePath = "path/file";
        var empty:FilePath = "path////file";
        var dots:FilePath = "././path/././to/../file/.";
        var trailing:FilePath = "path/file/";
        var leading:FilePath = "./path/file";

        asserts.assert(path == "path/file");
        asserts.assert(empty == "path/file");
        asserts.assert(dots == "path/file");
        asserts.assert(trailing == "path/file");
        asserts.assert(leading == "path/file");

        return asserts.done();
    }

    public function concatenation():Assertions {
        var str1 = "str-1";
        var abs1:FilePath = "abs-1";

        var abs2:FilePath = "abs-2";

        asserts.assert(str1 + abs1 == "str-1/abs-1");
        asserts.assert(abs1 + str1 == "abs-1/str-1");
        asserts.assert(abs1 + abs2 == "abs-1/abs-2");
        return asserts.done();
    }
}
