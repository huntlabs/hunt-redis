module hunt.redis.ShardedRedisPool;

import hunt.collection.List;

import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.util.Hashing;
import hunt.redis.util.Pool;

public class ShardedRedisPool : Pool!(ShardedRedis) {
  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards) {
    this(poolConfig, shards, Hashing.MURMUR_HASH);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Hashing algo) {
    this(poolConfig, shards, algo, null);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Pattern keyTagPattern) {
    this(poolConfig, shards, Hashing.MURMUR_HASH, keyTagPattern);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List!(RedisShardInfo) shards,
      Hashing algo, Pattern keyTagPattern) {
    super(poolConfig, new ShardedRedisFactory(shards, algo, keyTagPattern));
  }

  override
  public ShardedRedis getResource() {
    ShardedRedis jedis = super.getResource();
    jedis.setDataSource(this);
    return jedis;
  }

  override
  protected void returnBrokenResource(final ShardedRedis resource) {
    if (resource != null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
  protected void returnResource(final ShardedRedis resource) {
    if (resource != null) {
      resource.resetState();
      returnResourceObject(resource);
    }
  }

  /**
   * PoolableObjectFactory custom impl.
   */
  private static class ShardedRedisFactory : PooledObjectFactory!(ShardedRedis) {
    private List!(RedisShardInfo) shards;
    private Hashing algo;
    private Pattern keyTagPattern;

    public ShardedRedisFactory(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
      this.shards = shards;
      this.algo = algo;
      this.keyTagPattern = keyTagPattern;
    }

    override
    public PooledObject!(ShardedRedis) makeObject() throws Exception {
      ShardedRedis jedis = new ShardedRedis(shards, algo, keyTagPattern);
      return new DefaultPooledObject!(ShardedRedis)(jedis);
    }

    override
    public void destroyObject(PooledObject!(ShardedRedis) pooledShardedRedis) throws Exception {
      final ShardedRedis shardedRedis = pooledShardedRedis.getObject();
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
    public boolean validateObject(PooledObject!(ShardedRedis) pooledShardedRedis) {
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
    public void activateObject(PooledObject!(ShardedRedis) p) throws Exception {

    }

    override
    public void passivateObject(PooledObject!(ShardedRedis) p) throws Exception {

    }
  }
}