module hunt.redis.RedisPoolAbstract;

import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.util.Pool;

class RedisPoolAbstract : Pool!(Redis) {

  RedisPoolAbstract() {
    super();
  }

  RedisPoolAbstract(GenericObjectPoolConfig poolConfig, PooledObjectFactory!(Redis) factory) {
    super(poolConfig, factory);
  }

  override
  protected void returnBrokenResource(Redis resource) {
    super.returnBrokenResource(resource);
  }

  override
  protected void returnResource(Redis resource) {
    super.returnResource(resource);
  }
}
