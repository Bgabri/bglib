
import macros.UnPackTests;

import oops.BuilderTests;
import oops.SingletonTests;

import tink.testrunner.Runner;
import tink.unit.TestBatch;

import tui.TreesTests;

import utils.DynamicMatch;
import utils.FilePathTests;

using tink.CoreApi;

/**
 * Entry point of the test suite.
 **/
class RunTests {
    static function main() {
        Runner.run(TestBatch.make([
            new FilePathTests(),
            new TreesTests(),
            new DynamicMatch(),
            new UnPackTests(),
            new SingletonTests(),
            new BuilderTests(),
        ])).handle(Runner.exit);
    }
}
