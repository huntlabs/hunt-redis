module hunt.redis.ShardedRedisPool;

import hunt.redis.BinaryRedis;
import hunt.redis.BinaryShardedRedis;
import hunt.redis.RedisShardInfo;
import hunt.redis.ShardedRedis;
import hunt.redis.ShardedRedisPool;
import hunt.redis.util.Hashing;
import hunt.redis.util.Pool;

import hunt.collection.List;

import hunt.pool.PooledObject;
import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.DefaultPooledObject;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.Boolean;


class ShardedRedisPool : Pool!(ShardedRedis) {
  this(GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards) {
    this(poolConfig, shards, Hashing.MURMUR_HASH);
  }

  this(GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Hashing algo) {
    this(poolConfig, shards, algo, null);
  }

  this(GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Pattern keyTagPattern) {
    this(poolConfig, shards, Hashing.MURMUR_HASH, keyTagPattern);
  }

  this(GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Hashing algo, Pattern keyTagPattern) {
    super(poolConfig, new ShardedRedisFactory(shards, algo, keyTagPattern));
  }

  override
  ShardedRedis getResource() {
    ShardedRedis jedis = super.getResource();
    jedis.setDataSource(this);
    return jedis;
  }

  override
  protected void returnBrokenResource(ShardedRedis resource) {
    if (resource !is null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
  protected void returnResource(ShardedRedis resource) {
    if (resource !is null) {
      resource.resetState();
      returnResourceObject(resource);
    }
  }
}


  /**
   * PoolableObjectFactory custom impl.
   */
  private class ShardedRedisFactory : PooledObjectFactory!(ShardedRedis) {
    private List!(RedisShardInfo) shards;
    private Hashing algo;
    private Pattern keyTagPattern;

    this(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
      this.shards = shards;
      this.algo = algo;
      this.keyTagPattern = keyTagPattern;
    }

    override
    PooledObject!(ShardedRedis) makeObject() {
      ShardedRedis jedis = new ShardedRedis(shards, algo, keyTagPattern);
      return new DefaultPooledObject!(ShardedRedis)(jedis);
    }

    override
    void destroyObject(PooledObject!(ShardedRedis) pooledShardedRedis) {
      ShardedRedis shardedRedis = pooledShardedRedis.getObject();
      foreach(Redis jedis ; shardedRedis.getAllShards()) {
        if (jedis.isConnected()) {
          try {
            try {
              jedis.quit();
            } catch (Exception e) {

            }
            jedis.disconnect();
          } catch (Exception e) {

          }
        }
      }
    }

    override
    bool validateObject(PooledObject!(ShardedRedis) pooledShardedRedis) {
      try {
        ShardedRedis jedis = pooledShardedRedis.getObject();
        foreach(Redis shard ; jedis.getAllShards()) {
          if (!shard.ping().equals("PONG")) {
            return false;
          }
        }
        return true;
      } catch (Exception ex) {
        return false;
      }
    }

    override
    void activateObject(PooledObject!(ShardedRedis) p) {

    }

    override
    void passivateObject(PooledObject!(ShardedRedis) p) {

    }
  }