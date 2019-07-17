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

  override void returnBrokenResource(Redis resource) {
    super.returnBrokenResource(resource);
  }

  override void returnResource(Redis resource) {
    super.returnResource(resource);
  }
}
