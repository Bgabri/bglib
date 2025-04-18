
import macros.UnPackTests;

import oops.SingletonTests;

import tink.testrunner.Runner;
import tink.unit.TestBatch;

import tui.TreesTests;

import utils.DynamicMatch;

using tink.CoreApi;

/**
 * Entry point of the test suite.
 **/
class Run {
    static function main() {
        Runner.run(TestBatch.make([
            new TreesTests(),
            new DynamicMatch(),
            new UnPackTests(),
            new SingletonTests(),
        ])).handle(Runner.exit);
    }
}
