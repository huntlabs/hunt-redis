module RedisDemo;

import hunt.logging.ConsoleLogger;
import hunt.util.DateTime;

import hunt.redis;
import std.conv;

class RedisBenchmark {
    //   private enum int TOTAL_OPERATIONS = 100000;
    private enum int TOTAL_OPERATIONS = 1;

    static void run() {
        // HostAndPort hnp = HostAndPortUtil.getRedisServers().get(0);
        // Redis redis = new Redis(hnp);
        // Redis redis = new Redis("10.1.11.115", 6379);
        // Redis redis = new Redis("10.1.23.222", 6379);
        Redis redis = new Redis("10.1.11.114", 6379);
        
        redis.connect();
        // redis.auth("foobared");
        redis.flushAll();

        long begin = DateTime.currentTimeMillis();

        for (int n = 0; n < TOTAL_OPERATIONS; n++) {
            string key = "foo" ~ n.to!string();
            redis.set(key, "bar" ~ n.to!string());
            string v = redis.get(key);
            tracef("key=%s, value=%s", key, v);
        }

        long elapsed = DateTime.currentTimeMillis() - begin;

        redis.disconnect();

        if(elapsed > 0)
        trace(((1000 * 2 * TOTAL_OPERATIONS) / elapsed).to!string() ~ " ops");
    }
}
