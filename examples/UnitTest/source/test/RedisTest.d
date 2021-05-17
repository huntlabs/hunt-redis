module test.RedisTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.redis.BinaryRedis;
import hunt.redis.Redis;
import hunt.redis.RedisShardInfo;
import hunt.redis.Protocol;
import hunt.redis.Exceptions;
import hunt.redis.util.SafeEncoder;

import test.commands.RedisCommandTestBase;

// enum RedisHost = "localhost";
enum RedisHost = "10.1.11.114";

class RedisTest : RedisCommandTestBase {
    // @Test void useWithoutConnecting() {
    //     Redis redis = new Redis(RedisHost);
    //     redis.auth("foobared");
    //     redis.dbSize();
    // }

    @Test void checkBinaryData() {
        // ubyte[] bigdata = new ubyte[1777];
        // // ubyte[] bigdata = new ubyte[7];
        // for (int b = 0; b < bigdata.length; b++) {
        //     bigdata[b] = cast(ubyte)(cast(ubyte) b % 255);
        // }
        // Map!(string, string) hash = new HashMap!(string, string)();
        // hash.put("data", SafeEncoder.encode(bigdata));

        // string status = redis.hmset("foo", hash);
        // assertEquals("OK", status);
        // Map!(string, string) hash2 = redis.hgetAll("foo");
        // assertEquals(hash, redis.hgetAll("foo"));


        Map!(string, string) hash = new HashMap!(string, string)();
        hash.put("data", "123");
        string status = redis.hmset("foo", hash);
        warning(status);
    }

    // @Test void checkBinaryData2() {
    //     ubyte[] bigdata = new ubyte[1777];
    //     // ubyte[] bigdata = new ubyte[7];
    //     for (int b = 0; b < bigdata.length; b++) {
    //         bigdata[b] = cast(ubyte)(cast(ubyte) b % 255);
    //     }
    //     // Map!(string, string) hash = new HashMap!(string, string)();
    //     // hash.put("data", SafeEncoder.encode(bigdata));

    //     Map!(const(ubyte)[], const(ubyte)[]) hash = new HashMap!(const(ubyte)[], const(ubyte)[])();
    //     hash.put(cast(const(ubyte)[])"data", bigdata);

    //     string status = redis.hmset(cast(const(ubyte)[])"foo", hash);
    //     assertEquals("OK", status);
    //     Map!(string, string) hash2 = redis.hgetAll("foo");
    //     assertEquals(hash, redis.hgetAll(cast(const(ubyte)[])"foo"));
    // }

    // @Test void connectWithShardInfo() {
    //     RedisShardInfo shardInfo = new RedisShardInfo(RedisHost, Protocol.DEFAULT_PORT);
    //     shardInfo.setPassword("foobared");
    //     Redis redis = new Redis(shardInfo);
    //     redis.get("foo");
    // }

    // @Test void timeoutConnection() {
    //     Redis redis = new Redis("localhost", 6379, 15000);
    //     redis.auth("foobared");
    //     string timeout = redis.configGet("timeout").get(1);
    //     redis.configSet("timeout", "1");
    //     Thread.sleep(2000);
    //     try {
    //         redis.hmget("foobar", "foo");
    //         fail("Operation should throw RedisConnectionException");
    //     } catch (RedisConnectionException jce) {
    //         // expected
    //     }
    //     redis.close();

    //     // reset config
    //     redis = new Redis("localhost", 6379);
    //     redis.auth("foobared");
    //     redis.configSet("timeout", timeout);
    //     redis.close();
    // }

    // @Test void timeoutConnectionWithURI() {
    //     Redis redis = new Redis(new URI("redis://:foobared@localhost:6380/2"), 15000);
    //     string timeout = redis.configGet("timeout").get(1);
    //     redis.configSet("timeout", "1");
    //     Thread.sleep(2000);
    //     try {
    //         redis.hmget("foobar", "foo");
    //         fail("Operation should throw RedisConnectionException");
    //     } catch (RedisConnectionException jce) {
    //         // expected
    //     }
    //     redis.close();

    //     // reset config
    //     redis = new Redis(new URI("redis://:foobared@localhost:6380/2"));
    //     redis.configSet("timeout", timeout);
    //     redis.close();
    // }

    // @TestWith!RedisDataException
    // void failWhenSendingNullValues() {
    //     redis.set("foo", null);
    // }

    // @TestWith!(InvalidURIException)
    // void shouldThrowInvalidURIExceptionForInvalidURI() {
    //     Redis j = new Redis(new URI("localhost:6380"));
    //     j.ping();
    // }

    // @Test void shouldReconnectToSameDB() {
    //     redis.select(1);
    //     redis.set("foo", "bar");
    //     redis.getClient().getSocket().shutdownInput();
    //     redis.getClient().getSocket().shutdownOutput();
    //     assertEquals("bar", redis.get("foo"));
    // }

    // @Test void startWithUrlString() {
    //     Redis j = new Redis("localhost", 6380);
    //     j.auth("foobared");
    //     j.select(2);
    //     j.set("foo", "bar");
    //     Redis redis = new Redis("redis://:foobared@localhost:6380/2");
    //     assertEquals("PONG", redis.ping());
    //     assertEquals("bar", redis.get("foo"));
    // }

    // @Test void startWithUrl() {
    //     Redis j = new Redis("localhost", 6380);
    //     j.auth("foobared");
    //     j.select(2);
    //     j.set("foo", "bar");
    //     Redis redis = new Redis(new URI("redis://:foobared@localhost:6380/2"));
    //     assertEquals("PONG", redis.ping());
    //     assertEquals("bar", redis.get("foo"));
    // }

    // @Test void shouldNotUpdateDbIndexIfSelectFails() {
    //     int currentDb = redis.getDB();
    //     try {
    //         int invalidDb = -1;
    //         redis.select(invalidDb);

    //         fail("Should throw an exception if tried to select invalid db");
    //     } catch (RedisException e) {
    //         assertEquals(currentDb, redis.getDB());
    //     }
    // }

    // @Test void allowUrlWithNoDBAndNoPassword() {
    //     Redis redis = new Redis("redis://localhost:6380");
    //     redis.auth("foobared");
    //     assertEquals("localhost", redis.getClient().getHost());
    //     assertEquals(6380, redis.getClient().getPort());
    //     assertEquals(0, redis.getDB());

    //     redis = new Redis("redis://localhost:6380/");
    //     redis.auth("foobared");
    //     assertEquals("localhost", redis.getClient().getHost());
    //     assertEquals(6380, redis.getClient().getPort());
    //     assertEquals(0, redis.getDB());
    // }

    // @Test void checkCloseable() {
    //     redis.close();
    //     BinaryRedis bj = new BinaryRedis("localhost");
    //     bj.connect();
    //     bj.close();
    // }

    // @Test void checkDisconnectOnQuit() {
    //     redis.quit();
    //     assertFalse(redis.getClient().isConnected());
    // }

}
