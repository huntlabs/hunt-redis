module RedisClusterDemo;

import hunt.redis.RedisPoolOptions;

import hunt.logging.ConsoleLogger;
import hunt.util.DateTime;

import hunt.redis;
import std.conv;

enum string RedisServerHost = "10.1.11.115";
enum int RedisServerPort = 6379;
// enum string RedisPassword = "foobared";
enum int DEFAULT_TIMEOUT = 2000;
enum int DEFAULT_REDIRECTIONS = 5;

class RedisClusterBenchmark {

    static void run() {

        Redis node2 = new Redis(new HostAndPort(RedisServerHost, 6380));
        // node2.auth(RedisPassword);
        node2.flushAll();

        Redis node3 = new Redis(new HostAndPort(RedisServerHost, 6381));
        // node3.auth(RedisPassword);
        node3.flushAll();

        // 
        RedisPoolOptions DEFAULT_CONFIG = new RedisPoolOptions();
        // DEFAULT_CONFIG.password = RedisPassword;
        DEFAULT_CONFIG.clientName = "cluster-demo";
        DEFAULT_CONFIG.connectionTimeout = DEFAULT_TIMEOUT;
        DEFAULT_CONFIG.soTimeout = DEFAULT_TIMEOUT;

        HostAndPort jedisClusterNode = new HostAndPort(RedisServerHost, RedisServerPort);

        RedisCluster rc = new RedisCluster(jedisClusterNode, DEFAULT_CONFIG);
        rc.set("foo", "bar");
        rc.set("test", "test");
        assert("bar" == node3.get("foo"));
        assert("test" == node2.get("test"));

        RedisCluster rc2 = new RedisCluster(jedisClusterNode, DEFAULT_CONFIG);
        rc2.set("foo", "bar2");
        rc2.set("test", "test2");

        string foo = node3.get("foo");
        warningf("foo=> %s", foo);
        assert("bar2" == foo);
        
        string test = node2.get("test");
        warningf("test=> %s", test);
        assert("test2" == test);

        info("Done.");
        rc.close();
        rc2.close();
        node2.close();
        node3.close();
    }
}
