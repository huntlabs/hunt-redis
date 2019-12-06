module test.RedisPoolTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.pool;

// import org.apache.commons.pool2.PooledObject;
// import org.apache.commons.pool2.PooledObjectFactory;
// import org.apache.commons.pool2.impl.DefaultPooledObject;
// import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
// import org.junit.Test;

import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisPool;
import hunt.redis.RedisPoolConfig;
import hunt.redis.Transaction;
import hunt.redis.Exceptions;

import test.HostAndPortUtil;

import std.array;
import std.format;

class RedisPoolTest {
    private __gshared HostAndPort hnp; // = HostAndPortUtil.getRedisServers().get(0);

    shared static this() {
        hnp = HostAndPortUtil.getRedisServers().get(0);
    }

    // @Test
    // void checkConnections() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "bar");
    //     assertEquals("bar", redis.get("foo"));
    //     redis.close();
    //     pool.destroy();
    //     assertTrue(pool.isClosed());

    //     warning("done");
    // }

    // @Test
    // void checkCloseableConnections() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "bar");
    //     assertEquals("bar", redis.get("foo"));
    //     redis.close();
    //     pool.close();
    //     assertTrue(pool.isClosed());
    // }

    // @Test
    // void checkConnectionWithDefaultPort() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort());
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "bar");
    //     assertEquals("bar", redis.get("foo"));
    //     redis.close();
    //     pool.destroy();
    //     assertTrue(pool.isClosed());
    // }

    // @Test
    // void checkRedisIsReusedWhenReturned() {

    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort());
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "0");
    //     redis.close();

    //     redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.incr("foo");
    //     redis.close();
    //     pool.destroy();
    //     assertTrue(pool.isClosed());
    // }

    // @Test
    // void checkPoolRepairedWhenRedisIsBroken() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort());
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.quit();
    //     redis.close();
    //     warning("=====================");
    //     redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.incr("foo");
    //     redis.close();
    //     pool.destroy();
    //     assertTrue(pool.isClosed());
    // }

    // @Test(expected = RedisExhaustedPoolException.class)
    // void checkPoolOverflow() {
    //     GenericObjectPoolConfig config = new GenericObjectPoolConfig();
    //     config.setMaxTotal(1);
    //     config.setBlockWhenExhausted(false);
    //     RedisPool pool = new RedisPool(config, hnp.getHost(), hnp.getPort());
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "0");

    //     Redis newRedis = pool.getResource();
    //     newRedis.auth("foobared");
    //     newRedis.incr("foo");
    // }

    // @Test
    // void securePool() {
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setTestOnBorrow(true);
    //     RedisPool pool = new RedisPool(config, hnp.getHost(), hnp.getPort(), 2000, "foobared");
    //     Redis redis = pool.getResource();
    //     redis.set("foo", "bar");
    //     redis.close();
    //     pool.destroy();
    //     assertTrue(pool.isClosed());
    // }

    // @Test
    // void nonDefaultDatabase() {
    //     RedisPool pool0 = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
    //             "foobared");
    //     Redis redis0 = pool0.getResource();
    //     redis0.set("foo", "bar");
    //     assertEquals("bar", redis0.get("foo"));
    //     redis0.close();
    //     pool0.destroy();
    //     assertTrue(pool0.isClosed());

    //     RedisPool pool1 = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
    //             "foobared", 1);
    //     Redis redis1 = pool1.getResource();
    //     assertNull(redis1.get("foo"));
    //     redis1.close();
    //     pool1.destroy();
    //     assertTrue(pool1.isClosed());
    // }

    // @Test
    // void startWithUrlString() {
    //     Redis j = new Redis(hnp.getHost(), hnp.getPort());
    //     // Redis j = new Redis("127.0.0.1", 6380);
    //     j.auth("foobared");
    //     j.select(2);
    //     j.set("foo", "bar");
    //     // RedisPool pool = new RedisPool("redis://:foobared@localhost:6380/2");
    //     RedisPool pool = new RedisPool(format("redis://:foobared@%s:%d/2", hnp.getHost(), hnp.getPort() ));
    //     Redis redis = pool.getResource();
    //     assertEquals("PONG", redis.ping());
    //     assertEquals("bar", redis.get("foo"));
    //     warning("done");
    //     pool.destroy();
    // }

    // @Test
    // void startWithUrl() {
    //     Redis j = new Redis("localhost", 6380);
    //     j.auth("foobared");
    //     j.select(2);
    //     j.set("foo", "bar");
    //     RedisPool pool = new RedisPool(new URI("redis://:foobared@localhost:6380/2"));
    //     Redis redis = pool.getResource();
    //     assertEquals("PONG", redis.ping());
    //     assertEquals("bar", redis.get("foo"));
    // }

    // @Test(expected = InvalidURIException.class)
    // void shouldThrowInvalidURIExceptionForInvalidURI() {
    //     RedisPool pool = new RedisPool(new URI("localhost:6380"));
    // }

    // @Test
    // void allowUrlWithNoDBAndNoPassword() {
    //     new RedisPool("redis://localhost:6380");
    //     new RedisPool(new URI("redis://localhost:6380"));
    // }

    @Test
    void selectDatabaseOnActivation() {
        RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
                "foobared");

        Redis redis0 = pool.getResource();
        assertEquals(0, redis0.getDB());

        redis0.select(1);
        assertEquals(1, redis0.getDB());

        redis0.close();

        Redis redis1 = pool.getResource();
        assertTrue("Redis instance was not reused", redis1 == redis0);
        assertEquals(0, redis1.getDB());

        redis1.close();
        pool.destroy();
        assertTrue(pool.isClosed());
    }

    // @Test
    // void customClientName() {
    //     RedisPool pool0 = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
    //             "foobared", 0, "my_shiny_client_name");

    //     Redis redis = pool0.getResource();

    //     assertEquals("my_shiny_client_name", redis.clientGetname());

    //     redis.close();
    //     pool0.destroy();
    //     assertTrue(pool0.isClosed());
    // }

    // @Test
    // void returnResourceDestroysResourceOnException() {

    //     class CrashingRedis : Redis {
    //         override
    //         void resetState() {
    //             throw new RuntimeException();
    //         }
    //     }

    //     final AtomicInteger destroyed = new AtomicInteger(0);

    //     class CrashingRedisPooledObjectFactory : PooledObjectFactory!(Redis) {

    //         override
    //         PooledObject!(Redis) makeObject() {
    //             return new DefaultPooledObject!(Redis)(new CrashingRedis());
    //         }

    //         override
    //         void destroyObject(PooledObject!(Redis) p) {
    //             destroyed.incrementAndGet();
    //         }

    //         override
    //         boolean validateObject(PooledObject!(Redis) p) {
    //             return true;
    //         }

    //         override
    //         void activateObject(PooledObject!(Redis) p) {
    //         }

    //         override
    //         void passivateObject(PooledObject!(Redis) p) {
    //         }
    //     }

    //     GenericObjectPoolConfig config = new GenericObjectPoolConfig();
    //     config.setMaxTotal(1);
    //     RedisPool pool = new RedisPool(config, hnp.getHost(), hnp.getPort(), 2000, "foobared");
    //     pool.initPool(config, new CrashingRedisPooledObjectFactory());
    //     Redis crashingRedis = pool.getResource();

    //     try {
    //         crashingRedis.close();
    //     } catch (Exception ignored) {
    //     }

    //     assertEquals(1, destroyed.get());
    // }

    // @Test
    // void returnResourceShouldResetState() {
    //     GenericObjectPoolConfig config = new GenericObjectPoolConfig();
    //     config.setMaxTotal(1);
    //     config.setBlockWhenExhausted(false);
    //     RedisPool pool = new RedisPool(config, hnp.getHost(), hnp.getPort(), 2000, "foobared");

    //     Redis redis = pool.getResource();
    //     try {
    //         redis.set("hello", "redis");
    //         Transaction t = redis.multi();
    //         t.set("hello", "world");
    //     } finally {
    //         redis.close();
    //     }

    //     Redis redis2 = pool.getResource();
    //     try {
    //         assertTrue(redis == redis2);
    //         assertEquals("redis", redis2.get("hello"));
    //     } finally {
    //         redis2.close();
    //     }

    //     pool.destroy();
    //     assertTrue(pool.isClosed());
    // }

    // @Test
    // void checkResourceIsCloseable() {
    //     GenericObjectPoolConfig config = new GenericObjectPoolConfig();
    //     config.setMaxTotal(1);
    //     config.setBlockWhenExhausted(false);
    //     RedisPool pool = new RedisPool(config, hnp.getHost(), hnp.getPort(), 2000, "foobared");

    //     Redis redis = pool.getResource();
    //     try {
    //         redis.set("hello", "redis");
    //     } finally {
    //         redis.close();
    //     }

    //     Redis redis2 = pool.getResource();
    //     try {
    //         assertEquals(redis, redis2);
    //     } finally {
    //         redis2.close();
    //     }
    // }

    // @Test
    // void getNumActiveIsNegativeWhenPoolIsClosed() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
    //             "foobared", 0, "my_shiny_client_name");

    //     pool.destroy();
    //     assertTrue(pool.getNumActive() < 0);
    // }

    // @Test
    // void getNumActiveReturnsTheCorrectNumber() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     Redis redis = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "bar");
    //     assertEquals("bar", redis.get("foo"));

    //     assertEquals(1, pool.getNumActive());

    //     Redis redis2 = pool.getResource();
    //     redis.auth("foobared");
    //     redis.set("foo", "bar");

    //     assertEquals(2, pool.getNumActive());

    //     redis.close();
    //     assertEquals(1, pool.getNumActive());

    //     redis2.close();

    //     assertEquals(0, pool.getNumActive());

    //     pool.destroy();
    // }

    // @Test
    // void testAddObject() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     pool.addObjects(1);
    //     assertEquals(1, pool.getNumIdle());
    //     pool.destroy();
    // }

    // @Test
    // void closeResourceTwice() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     Redis j = pool.getResource();
    //     j.auth("foobared");
    //     j.ping();
    //     j.close();
    //     j.close();
    // }

    // @Test
    // void closeBrokenResourceTwice() {
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000);
    //     Redis j = pool.getResource();
    //     try {
    //         // make connection broken
    //         j.getClient().getOne();
    //         fail();
    //     } catch (Exception e) {
    //     }
    //     assertTrue(j.getClient().isBroken());
    //     j.close();
    //     j.close();
    // }

    // @Test
    // void testCloseConnectionOnMakeObject() {
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setTestOnBorrow(true);
    //     RedisPool pool = new RedisPool(new RedisPoolConfig(), hnp.getHost(), hnp.getPort(), 2000,
    //             "wrong pass");
    //     Redis redis = new Redis("redis://:foobared@localhost:6379/");
    //     int currentClientCount = getClientCount(redis.clientList());
    //     try {
    //         pool.getResource();
    //         fail("Should throw exception as password is incorrect.");
    //     } catch (Exception e) {
    //         assertEquals(currentClientCount, getClientCount(redis.clientList()));
    //     }

    // }

    private int getClientCount(string clientList) {
        return cast(int)clientList.split("\n").length;
    }

}
