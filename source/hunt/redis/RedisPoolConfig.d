module hunt.redis.RedisPoolConfig;

import hunt.pool.impl.GenericObjectPoolConfig;

class RedisPoolConfig : GenericObjectPoolConfig {
  RedisPoolConfig() {
    // defaults to make your life with connection pool easier :)
    setTestWhileIdle(true);
    setMinEvictableIdleTimeMillis(60000);
    setTimeBetweenEvictionRunsMillis(30000);
    setNumTestsPerEvictionRun(-1);
  }
}
