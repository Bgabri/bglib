
import macros.UnPackTests;

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
class Run {
    static function main() {
        Runner.run(TestBatch.make([
            new FilePathTests(),
            new TreesTests(),
            new DynamicMatch(),
            new UnPackTests(),
            new SingletonTests(),
        ])).handle(Runner.exit);
    }
}
