module hunt.redis.BinaryShardedRedis;

import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.commands.BinaryRedisCommands;
import hunt.redis.commands.ProtocolCommand;
import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.Hashing;
import hunt.redis.util.Sharded;

public class BinaryShardedRedis : Sharded!(Redis, RedisShardInfo) implements
    BinaryRedisCommands {
  public BinaryShardedRedis(List!(RedisShardInfo) shards) {
    super(shards);
  }

  public BinaryShardedRedis(List!(RedisShardInfo) shards, Hashing algo) {
    super(shards, algo);
  }

  public BinaryShardedRedis(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
    super(shards, keyTagPattern);
  }

  public BinaryShardedRedis(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
    super(shards, algo, keyTagPattern);
  }

  public void disconnect() {
    foreach(Redis jedis ; getAllShards()) {
      if (jedis.isConnected()) {
        try {
          jedis.quit();
        } catch (RedisConnectionException e) {
          // ignore the exception node, so that all other normal nodes can release all connections.
        }
        try {
          jedis.disconnect();
        } catch (RedisConnectionException e) {
          // ignore the exception node, so that all other normal nodes can release all connections.
        }
      }
    }
  }

  protected Redis create(RedisShardInfo shard) {
    return new Redis(shard);
  }

  override
  public String set(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  public String set(final byte[] key, final byte[] value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  public byte[] get(final byte[] key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  public Boolean exists(final byte[] key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  public String type(final byte[] key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  public byte[] dump(final byte[] key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  public String restore(final byte[] key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  public String restoreReplace(final byte[] key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  public Long expire(final byte[] key, final int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  public Long pexpire(final byte[] key, final long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  public Long expireAt(final byte[] key, final long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  public Long pexpireAt(final byte[] key, final long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  public Long ttl(final byte[] key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  public Long pttl(final byte[] key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  public Long touch(final byte[] key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  public byte[] getSet(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  public Long setnx(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  public String setex(final byte[] key, final int seconds, final byte[] value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  public String psetex(final byte[] key, final long milliseconds, final byte[] value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  override
  public Long decrBy(final byte[] key, final long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  public Long decr(final byte[] key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  public Long del(final byte[] key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  public Long unlink(final byte[] key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  public Long incrBy(final byte[] key, final long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  public Double incrByFloat(final byte[] key, final double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  public Long incr(final byte[] key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  public Long append(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  public byte[] substr(final byte[] key, final int start, final int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  public Long hset(final byte[] key, final byte[] field, final byte[] value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  public Long hset(final byte[] key, final Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  public byte[] hget(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  public Long hsetnx(final byte[] key, final byte[] field, final byte[] value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  public String hmset(final byte[] key, final Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  public List!(byte[]) hmget(final byte[] key, final byte[]... fields) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  public Long hincrBy(final byte[] key, final byte[] field, final long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  public Double hincrByFloat(final byte[] key, final byte[] field, final double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  public Boolean hexists(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  public Long hdel(final byte[] key, final byte[]... fields) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  public Long hlen(final byte[] key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  public Set!(byte[]) hkeys(final byte[] key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  public Collection!(byte[]) hvals(final byte[] key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  public Map!(byte[], byte[]) hgetAll(final byte[] key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  public Long rpush(final byte[] key, final byte[]... strings) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  public Long lpush(final byte[] key, final byte[]... strings) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  public Long strlen(final byte[] key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  public Long lpushx(final byte[] key, final byte[]... string) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  public Long persist(final byte[] key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  public Long rpushx(final byte[] key, final byte[]... string) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  public Long llen(final byte[] key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  public List!(byte[]) lrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  public String ltrim(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  public byte[] lindex(final byte[] key, final long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  public String lset(final byte[] key, final long index, final byte[] value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  public Long lrem(final byte[] key, final long count, final byte[] value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  public byte[] lpop(final byte[] key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  public byte[] rpop(final byte[] key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  public Long sadd(final byte[] key, final byte[]... members) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  public Set!(byte[]) smembers(final byte[] key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  public Long srem(final byte[] key, final byte[]... members) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  public byte[] spop(final byte[] key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  public Set!(byte[]) spop(final byte[] key, final long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  public Long scard(final byte[] key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  public Boolean sismember(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  public byte[] srandmember(final byte[] key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  public List!(byte[]) srandmember(final byte[] key, final int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  public Long zadd(final byte[] key, final double score, final byte[] member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  public Long zadd(final byte[] key, final double score, final byte[] member, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  public Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  public Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  public Set!(byte[]) zrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  public Long zrem(final byte[] key, final byte[]... members) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  public Double zincrby(final byte[] key, final double increment, final byte[] member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  public Double zincrby(final byte[] key, final double increment, final byte[] member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  public Long zrank(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  public Long zrevrank(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  public Set!(byte[]) zrevrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  public Set!(Tuple) zrangeWithScores(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  public Set!(Tuple) zrevrangeWithScores(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  public Long zcard(final byte[] key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  public Double zscore(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  public List!(byte[]) sort(final byte[] key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  public List!(byte[]) sort(final byte[] key, SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  public Long zcount(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  public Long zcount(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  public Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  public Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  public Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  public Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  public Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  public Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max, final double min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  public Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  public Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max, final byte[] min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  public Long zremrangeByRank(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  public Long zremrangeByScore(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  public Long zremrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  public Long zlexcount(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zlexcount(key, min, max);
  }

  override
  public Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max);
  }

  override
  public Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max,
      final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max, offset, count);
  }

  override
  public Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min);
  }

  override
  public Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min, offset, count);
  }

  override
  public Long zremrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByLex(key, min, max);
  }

  override
  public Long linsert(final byte[] key, final ListPosition where, final byte[] pivot, final byte[] value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  public ShardedRedisPipeline pipelined() {
    ShardedRedisPipeline pipeline = new ShardedRedisPipeline();
    pipeline.setShardedRedis(this);
    return pipeline;
  }

  public Long objectRefcount(final byte[] key) {
    Redis j = getShard(key);
    return j.objectRefcount(key);
  }

  public byte[] objectEncoding(final byte[] key) {
    Redis j = getShard(key);
    return j.objectEncoding(key);
  }

  public Long objectIdletime(final byte[] key) {
    Redis j = getShard(key);
    return j.objectIdletime(key);
  }

  override
  public Boolean setbit(final byte[] key, final long offset, boolean value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  public Boolean setbit(final byte[] key, final long offset, final byte[] value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  public Boolean getbit(final byte[] key, final long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  public Long setrange(final byte[] key, final long offset, final byte[] value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  public byte[] getrange(final byte[] key, final long startOffset, final long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  public Long move(final byte[] key, final int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  public byte[] echo(final byte[] arg) {
    Redis j = getShard(arg);
    return j.echo(arg);
  }

  public List!(byte[]) brpop(final byte[] arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  public List!(byte[]) blpop(final byte[] arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  public Long bitcount(final byte[] key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  public Long bitcount(final byte[] key, final long start, final long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  public Long pfadd(final byte[] key, final byte[]... elements) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  public long pfcount(final byte[] key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  public Long geoadd(final byte[] key, final double longitude, final double latitude, final byte[] member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  public Long geoadd(final byte[] key, final Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  public Double geodist(final byte[] key, final byte[] member1, final byte[] member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  public Double geodist(final byte[] key, final byte[] member1, final byte[] member2, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  public List!(byte[]) geohash(final byte[] key, final byte[]... members) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  public List!(GeoCoordinate) geopos(final byte[] key, final byte[]... members) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  public List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  public ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  public ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  public ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  public ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  public ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  public ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  public List!(Long) bitfield(final byte[] key, final byte[]... arguments) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
 }

  override
  public Long hstrlen(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hstrlen(key, field);
  }

  override
  public byte[] xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, boolean approximateLength) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash, maxLen, approximateLength);
  }

  override
  public Long xlen(byte[] key) {
    Redis j = getShard(key);
    return j.xlen(key);
  }

  override
  public List!(byte[]) xrange(byte[] key, byte[] start, byte[] end, long count) {
    Redis j = getShard(key);
    return j.xrange(key, start, end, count);
  }

  override
  public List!(byte[]) xrevrange(byte[] key, byte[] end, byte[] start, int count) {
    Redis j = getShard(key);
    return j.xrevrange(key, end, start, count);
  }

  override
  public Long xack(byte[] key, byte[] group, byte[]... ids) {
    Redis j = getShard(key);
    return j.xack(key, group, ids);
  }

  override
  public String xgroupCreate(byte[] key, byte[] consumer, byte[] id, boolean makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  public String xgroupSetID(byte[] key, byte[] consumer, byte[] id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, consumer, id);
  }

  override
  public Long xgroupDestroy(byte[] key, byte[] consumer) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, consumer);
  }

  override
  public String xgroupDelConsumer(byte[] key, byte[] consumer, byte[] consumerName) {
    Redis j = getShard(key);
    return j.xgroupDelConsumer(key, consumer, consumerName);
  }

  override
  public Long xdel(byte[] key, byte[]... ids) {
    Redis j = getShard(key);
    return j.xdel(key, ids);
  }

  override
  public Long xtrim(byte[] key, long maxLen, boolean approximateLength) {
    Redis j = getShard(key);
    return j.xtrim(key, maxLen, approximateLength);
  }

  override
  public List!(byte[]) xpending(byte[] key, byte[] groupname, byte[] start, byte[] end, int count, byte[] consumername) {
    Redis j = getShard(key);
    return j.xpending(key, groupname, start, end, count, consumername);
  }

  override
  public List!(byte[]) xclaim(byte[] key, byte[] groupname, byte[] consumername, long minIdleTime, long newIdleTime,
      int retries, boolean force, byte[][] ids) {
    Redis j = getShard(key);
    return j.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
  }

  override
  public Object sendCommand(ProtocolCommand cmd, byte[]... args) {
    // default since no sample key provided in RedisCommands interface
    byte[] sampleKey = args.length > 0 ? args[0] : cmd.getRaw();
    Redis j = getShard(args[0]);
    return j.sendCommand(cmd, args);
  }

}
