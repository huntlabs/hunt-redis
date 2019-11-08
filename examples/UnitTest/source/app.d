import std.stdio;

import hunt.util.UnitTest;
import hunt.logging.ConsoleLogger;

import test.HostAndPortTest;
import test.RedisTest;
import test.RedisClusterTest;
import test.utils.RedisURIHelperTest;

void main() {

    // testUnits!(HostAndPortTest);
    // testUnits!(RedisTest);
    testUnits!(RedisClusterTest);

    // testUnits!(RedisURIHelperTest);
}
