module hunt.redis;

import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.util.Pool;

public class RedisPoolAbstract extends Pool<Redis> {

  public RedisPoolAbstract() {
    super();
  }

  public RedisPoolAbstract(GenericObjectPoolConfig poolConfig, PooledObjectFactory<Redis> factory) {
    super(poolConfig, factory);
  }

  @Override
  protected void returnBrokenResource(Redis resource) {
    super.returnBrokenResource(resource);
  }

  @Override
  protected void returnResource(Redis resource) {
    super.returnResource(resource);
  }
}
