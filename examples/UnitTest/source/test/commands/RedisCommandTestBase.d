module test.commands.RedisCommandTestBase;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.redis.HostAndPort;
import hunt.redis.Redis;

import test.HostAndPortUtil;


abstract class RedisCommandTestBase {
    protected HostAndPort hnp;
    protected Redis redis;

    this() {
        hnp = HostAndPortUtil.getRedisServers().get(0);
    }

    @Before void setUp() {
        trace(hnp.toString());
        redis = new Redis(hnp.getHost(), hnp.getPort(), 500);
        redis.connect();
        redis.auth("foobared");
        redis.flushAll();
    }

    @After void tearDown() {
        redis.disconnect();
    }

    protected Redis createRedis() {
        Redis j = new Redis(hnp);
        j.connect();
        j.auth("foobared");
        j.flushAll();
        return j;
    }

    protected bool arrayContains(List!(byte[]) array, byte[] expected) {
        foreach (byte[] a ; array) {
            try {
                assertArrayEquals(a, expected);
                return true;
            } catch (AssertionError e) {

            }
        }
        return false;
    }

    protected bool setContains(Set!(byte[]) set, byte[] expected) {
        foreach(byte[] a ; set) {
            try {
                assertArrayEquals(a, expected);
                return true;
            } catch (AssertionError e) {

            }
        }
        return false;
    }
}
