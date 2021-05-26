module RedisClusterDemo;

import hunt.logging.ConsoleLogger;
import hunt.util.DateTime;

import hunt.redis;
import std.conv;

enum string RedisServerHost = "10.1.23.222";
enum int RedisServerPort = 6380;
enum string RedisPassword = "foobared";
enum int DEFAULT_TIMEOUT = 2000;
enum int DEFAULT_REDIRECTIONS = 5;

class RedisClusterBenchmark {

    static void run() {

        Redis node2 = new Redis(new HostAndPort(RedisServerHost, 6381));
        node2.auth(RedisPassword);
        node2.flushAll();

        Redis node3 = new Redis(new HostAndPort(RedisServerHost, 6382));
        node3.auth(RedisPassword);
        node3.flushAll();

        // 
        RedisPoolConfig DEFAULT_CONFIG = new RedisPoolConfig();
        HostAndPort jedisClusterNode = new HostAndPort(RedisServerHost, RedisServerPort);

        RedisCluster rc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
                DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
        rc.set("foo", "bar");
        rc.set("test", "test");
        assert("bar" == node3.get("foo"));
        assert("test" == node2.get("test"));

        RedisCluster rc2 = new RedisCluster(new HostAndPort(RedisServerHost, RedisServerPort), DEFAULT_TIMEOUT,
                DEFAULT_TIMEOUT, DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
        rc2.set("foo", "bar2");
        rc2.set("test", "test2");
        assert("bar2" == node3.get("foo"));
        assert("test2" == node2.get("test"));

        info("Done.");
        rc.close();
        rc2.close();
        node2.disconnect();
        node3.disconnect();
    }
}
