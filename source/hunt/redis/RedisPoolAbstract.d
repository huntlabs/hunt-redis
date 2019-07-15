module hunt.redis.RedisPoolAbstract;

import hunt.redis.Redis;

import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.redis.util.Pool;

class RedisPoolAbstract : Pool!(Redis) {

  this() {
    super();
  }

  this(GenericObjectPoolConfig poolConfig, PooledObjectFactory!(Redis) factory) {
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
