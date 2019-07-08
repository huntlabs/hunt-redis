module hunt.redis.RedisPoolAbstract;

import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.GenericObjectPoolConfig;

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
