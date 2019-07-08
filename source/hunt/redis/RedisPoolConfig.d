module hunt.redis.RedisPoolConfig;

import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

public class RedisPoolConfig extends GenericObjectPoolConfig {
  public RedisPoolConfig() {
    // defaults to make your life with connection pool easier :)
    setTestWhileIdle(true);
    setMinEvictableIdleTimeMillis(60000);
    setTimeBetweenEvictionRunsMillis(30000);
    setNumTestsPerEvictionRun(-1);
  }
}
