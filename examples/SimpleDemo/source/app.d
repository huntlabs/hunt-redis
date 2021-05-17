import std.stdio;
import hunt.net.NetUtil;
import hunt.net.EventLoopPool;

import RedisDemo;
import RedisClusterDemo;
import RedisLockDemo;

/**
    "versions": [
		"HUNT_DEBUG", "HUNT_NET_DEBUG"
	],
*/

void main()
{
    import hunt.logging.ConsoleLogger;
    for(int i=0; i< 5; i++) {
        RedisBenchmark.run();
    }

    warning("done");

    // RedisClusterBenchmark.run();
    // RedisLockDemo.run();
    getchar();
    shutdownEventLoopPool();
}
