module hunt.redis;

import hunt.collection.List;

import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.util.Hashing;
import hunt.redis.util.Pool;

public class ShardedRedisPool extends Pool<ShardedRedis> {
  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List<RedisShardInfo> shards) {
    this(poolConfig, shards, Hashing.MURMUR_HASH);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List<RedisShardInfo> shards,
      Hashing algo) {
    this(poolConfig, shards, algo, null);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List<RedisShardInfo> shards,
      Pattern keyTagPattern) {
    this(poolConfig, shards, Hashing.MURMUR_HASH, keyTagPattern);
  }

  public ShardedRedisPool(final GenericObjectPoolConfig poolConfig, List<RedisShardInfo> shards,
      Hashing algo, Pattern keyTagPattern) {
    super(poolConfig, new ShardedRedisFactory(shards, algo, keyTagPattern));
  }

  @Override
  public ShardedRedis getResource() {
    ShardedRedis jedis = super.getResource();
    jedis.setDataSource(this);
    return jedis;
  }

  @Override
  protected void returnBrokenResource(final ShardedRedis resource) {
    if (resource != null) {
      returnBrokenResourceObject(resource);
    }
  }

  @Override
  protected void returnResource(final ShardedRedis resource) {
    if (resource != null) {
      resource.resetState();
      returnResourceObject(resource);
    }
  }

  /**
   * PoolableObjectFactory custom impl.
   */
  private static class ShardedRedisFactory implements PooledObjectFactory<ShardedRedis> {
    private List<RedisShardInfo> shards;
    private Hashing algo;
    private Pattern keyTagPattern;

    public ShardedRedisFactory(List<RedisShardInfo> shards, Hashing algo, Pattern keyTagPattern) {
      this.shards = shards;
      this.algo = algo;
      this.keyTagPattern = keyTagPattern;
    }

    @Override
    public PooledObject<ShardedRedis> makeObject() throws Exception {
      ShardedRedis jedis = new ShardedRedis(shards, algo, keyTagPattern);
      return new DefaultPooledObject<ShardedRedis>(jedis);
    }

    @Override
    public void destroyObject(PooledObject<ShardedRedis> pooledShardedRedis) throws Exception {
      final ShardedRedis shardedRedis = pooledShardedRedis.getObject();
      for (Redis jedis : shardedRedis.getAllShards()) {
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

    @Override
    public boolean validateObject(PooledObject<ShardedRedis> pooledShardedRedis) {
      try {
        ShardedRedis jedis = pooledShardedRedis.getObject();
        for (Redis shard : jedis.getAllShards()) {
          if (!shard.ping().equals("PONG")) {
            return false;
          }
        }
        return true;
      } catch (Exception ex) {
        return false;
      }
    }

    @Override
    public void activateObject(PooledObject<ShardedRedis> p) throws Exception {

    }

    @Override
    public void passivateObject(PooledObject<ShardedRedis> p) throws Exception {

    }
  }
}