
import tink.unit.TestBatch;
import tink.testrunner.Runner;

import tui.TreesTests;
import utils.DynamicMatch;
import macros.UnPackTests;
import oops.SingletonTests;

using tink.CoreApi;

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
