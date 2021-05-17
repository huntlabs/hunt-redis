import std.stdio;

import hunt.util.UnitTest;
import hunt.logging.ConsoleLogger;

import test.HostAndPortTest;
import test.RedisTest;
import test.RedisClusterTest;
import test.RedisPoolTest;
import test.utils.RedisURIHelperTest;

import test.commands.GeoCommandsTest;
import test.commands.SortedSetCommandsTest;
import test.commands.StreamsCommandsTest;

import hunt.net.EventLoopPool;

void main() {

    // testUnits!(HostAndPortTest);
    // testUnits!(RedisTest);
    // testUnits!(RedisClusterTest);
    // testUnits!(RedisPoolTest);

    // testUnits!(RedisURIHelperTest);

    // testUnits!(GeoCommandsTest);
    // testUnits!(SortedSetCommandsTest);
    testUnits!(StreamsCommandsTest);

    getchar();
    shutdownEventLoopPool();
}
