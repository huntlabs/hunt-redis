module hunt.redis.ShardedRedis;

import java.io.Closeable;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.commands.RedisCommands;
import hunt.redis.commands.ProtocolCommand;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.Hashing;

public class ShardedRedis : BinaryShardedRedis implements RedisCommands, Closeable {

  protected ShardedRedisPool dataSource = null;

  public ShardedRedis(List!(RedisShardInfo) shards) {
    super(shards);
  }

  public ShardedRedis(List!(RedisShardInfo) shards, Hashing algo) {
    super(shards, algo);
  }

  public ShardedRedis(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
    super(shards, keyTagPattern);
  }

  public ShardedRedis(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
    super(shards, algo, keyTagPattern);
  }

  override
  public String set(final String key, final String value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  public String set(final String key, final String value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  public String get(final String key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  public String echo(final String string) {
    Redis j = getShard(string);
    return j.echo(string);
  }

  override
  public Boolean exists(final String key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  public String type(final String key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  public byte[] dump(final String key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  public String restore(final String key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  public String restoreReplace(final String key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  public Long expire(final String key, final int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  public Long pexpire(final String key, final long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  public Long expireAt(final String key, final long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  public Long pexpireAt(final String key, final long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  public Long ttl(final String key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  public Long pttl(final String key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  public Boolean setbit(final String key, final long offset, boolean value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  public Boolean setbit(final String key, final long offset, final String value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  public Boolean getbit(final String key, final long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  public Long setrange(final String key, final long offset, final String value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  public String getrange(final String key, final long startOffset, final long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  public String getSet(final String key, final String value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  public Long setnx(final String key, final String value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  public String setex(final String key, final int seconds, final String value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  public String psetex(final String key, final long milliseconds, final String value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  public List!(String) blpop(final String arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  public List!(String) blpop(final int timeout, final String key) {
    Redis j = getShard(key);
    return j.blpop(timeout, key);
  }

  public List!(String) brpop(final String arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  override
  public List!(String) brpop(final int timeout, final String key) {
    Redis j = getShard(key);
    return j.brpop(timeout, key);
  }

  override
  public Long decrBy(final String key, final long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  public Long decr(final String key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  public Long incrBy(final String key, final long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  public Double incrByFloat(final String key, final double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  public Long incr(final String key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  public Long append(final String key, final String value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  public String substr(final String key, final int start, final int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  public Long hset(final String key, final String field, final String value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  public Long hset(final String key, final Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  public String hget(final String key, final String field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  public Long hsetnx(final String key, final String field, final String value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  public String hmset(final String key, final Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  public List!(String) hmget(final String key, String... fields) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  public Long hincrBy(final String key, final String field, final long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  public Double hincrByFloat(final String key, final String field, final double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  public Boolean hexists(final String key, final String field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  public Long del(final String key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  public Long unlink(final String key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  public Long hdel(final String key, String... fields) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  public Long hlen(final String key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  public Set!(String) hkeys(final String key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  public List!(String) hvals(final String key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  public Map!(String, String) hgetAll(final String key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  public Long rpush(final String key, String... strings) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  public Long lpush(final String key, String... strings) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  public Long lpushx(final String key, String... string) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  public Long strlen(final String key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  public Long move(final String key, final int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  public Long rpushx(final String key, String... string) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  public Long persist(final String key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  public Long llen(final String key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  public List!(String) lrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  public String ltrim(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  public String lindex(final String key, final long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  public String lset(final String key, final long index, final String value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  public Long lrem(final String key, final long count, final String value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  public String lpop(final String key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  public String rpop(final String key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  public Long sadd(final String key, String... members) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  public Set!(String) smembers(final String key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  public Long srem(final String key, String... members) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  public String spop(final String key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  public Set!(String) spop(final String key, final long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  public Long scard(final String key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  public Boolean sismember(final String key, final String member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  public String srandmember(final String key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  public List!(String) srandmember(final String key, final int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  public Long zadd(final String key, final double score, final String member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  public Long zadd(final String key, final double score, final String member, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  public Long zadd(final String key, final Map!(String, Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  public Long zadd(final String key, final Map!(String, Double) scoreMembers, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  public Set!(String) zrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  public Long zrem(final String key, String... members) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  public Double zincrby(final String key, final double increment, final String member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  public Double zincrby(final String key, final double increment, final String member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  public Long zrank(final String key, final String member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  public Long zrevrank(final String key, final String member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  public Set!(String) zrevrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  public Set!(Tuple) zrangeWithScores(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  public Set!(Tuple) zrevrangeWithScores(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  public Long zcard(final String key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  public Double zscore(final String key, final String member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  public List!(String) sort(final String key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  public List!(String) sort(final String key, final SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  public Long zcount(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  public Long zcount(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  public Set!(String) zrangeByScore(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  public Set!(String) zrevrangeByScore(final String key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  public Set!(String) zrangeByScore(final String key, final double min, final double max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  public Set!(String) zrevrangeByScore(final String key, final double max, final double min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final String key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final String key, final double min, final double max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final String key, final double max, final double min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  public Set!(String) zrangeByScore(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  public Set!(String) zrevrangeByScore(final String key, final String max, final String min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  public Set!(String) zrangeByScore(final String key, final String min, final String max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  public Set!(String) zrevrangeByScore(final String key, final String max, final String min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final String key, final String max, final String min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  public Set!(Tuple) zrangeByScoreWithScores(final String key, final String min, final String max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  public Set!(Tuple) zrevrangeByScoreWithScores(final String key, final String max, final String min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  public Long zremrangeByRank(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  public Long zremrangeByScore(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  public Long zremrangeByScore(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  public Long zlexcount(final String key, final String min, final String max) {
    return getShard(key).zlexcount(key, min, max);
  }

  override
  public Set!(String) zrangeByLex(final String key, final String min, final String max) {
    return getShard(key).zrangeByLex(key, min, max);
  }

  override
  public Set!(String) zrangeByLex(final String key, final String min, final String max,
      final int offset, final int count) {
    return getShard(key).zrangeByLex(key, min, max, offset, count);
  }

  override
  public Set!(String) zrevrangeByLex(final String key, final String max, final String min) {
    return getShard(key).zrevrangeByLex(key, max, min);
  }

  override
  public Set!(String) zrevrangeByLex(final String key, final String max, final String min, final int offset, final int count) {
    return getShard(key).zrevrangeByLex(key, max, min, offset, count);
  }

  override
  public Long zremrangeByLex(final String key, final String min, final String max) {
    return getShard(key).zremrangeByLex(key, min, max);
  }

  override
  public Long linsert(final String key, final ListPosition where, final String pivot, final String value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  override
  public Long bitcount(final String key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  public Long bitcount(final String key, final long start, final long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  public Long bitpos(final String key, final boolean value) {
    Redis j = getShard(key);
    return j.bitpos(key, value);
  }

  override
  public Long bitpos(final String key, boolean value, final BitPosParams params) {
    Redis j = getShard(key);
    return j.bitpos(key, value, params);
  }

  override
  public ScanResult!(Entry!(String, String)) hscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  public ScanResult!(Entry!(String, String)) hscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  public ScanResult!(String) sscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  public ScanResult!(Tuple) zscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  public ScanResult!(Tuple) zscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  public ScanResult!(String) sscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  public void close() {
    if (dataSource != null) {
      boolean broken = false;

      foreach(Redis jedis ; getAllShards()) {
        if (jedis.getClient().isBroken()) {
          broken = true;
          break;
        }
      }
      ShardedRedisPool pool = this.dataSource;
      this.dataSource = null;
      if (broken) {
        pool.returnBrokenResource(this);
      } else {
        pool.returnResource(this);
      }

    } else {
      disconnect();
    }
  }

  public void setDataSource(ShardedRedisPool shardedRedisPool) {
    this.dataSource = shardedRedisPool;
  }

  public void resetState() {
    foreach(Redis jedis ; getAllShards()) {
      jedis.resetState();
    }
  }

  override
  public Long pfadd(final String key, final String... elements) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  public long pfcount(final String key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  public Long touch(final String key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  public Long geoadd(final String key, final double longitude, final double latitude, final String member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  public Long geoadd(final String key, final Map!(String, GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  public Double geodist(final String key, final String member1, final String member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  public Double geodist(final String key, final String member1, final String member2, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  public List!(String) geohash(final String key, final String... members) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  public List!(GeoCoordinate) geopos(final String key, final String... members) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  public List!(GeoRadiusResponse) georadius(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusReadonly(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadius(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusReadonly(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMember(final String key, final String member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMemberReadonly(final String key, final String member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMember(final String key, final String member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  public List!(GeoRadiusResponse) georadiusByMemberReadonly(final String key, final String member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  public List!(Long) bitfield(final String key, final String... arguments) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
  }

  override
  public Long hstrlen(final String key, final String field) {
    Redis j = getShard(key);
    return j.hstrlen(key, field);
  }

  override
  public StreamEntryID xadd(String key, StreamEntryID id, Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash);
  }
  
  override
  public StreamEntryID xadd(String key, StreamEntryID id, Map!(String, String) hash, long maxLen, boolean approximateLength) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash, maxLen, approximateLength);
  }

  override
  public Long xlen(String key) {
    Redis j = getShard(key);
    return j.xlen(key);
  }
  
  override
  public List!(StreamEntry) xrange(String key, StreamEntryID start, StreamEntryID end, int count) {
    Redis j = getShard(key);
    return j.xrange(key, start, end, count);
  }

  override
  public long xack(String key, String group, StreamEntryID... ids) {
    Redis j = getShard(key);
    return j.xack(key, group, ids);
  }

  override
  public String xgroupCreate(String key, String consumer, StreamEntryID id, boolean makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  public String xgroupSetID(String key, String groupname, StreamEntryID id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, groupname, id);
  }

  override
  public long xgroupDestroy(String key, String groupname) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, groupname);
  }

  override
  public String xgroupDelConsumer(String key, String groupname, String consumername) {
    Redis j = getShard(key);
    return j.xgroupDelConsumer(key, groupname, consumername);
  }


  override
  public long xdel(String key, StreamEntryID... ids) {
    Redis j = getShard(key);
    return j.xdel(key, ids);
  }

  override
  public long xtrim(String key, long maxLen, boolean approximateLength) {
    Redis j = getShard(key);
    return j.xtrim(key, maxLen, approximateLength);
  }

  override
  public List!(StreamEntry) xrevrange(String key, StreamEntryID end, StreamEntryID start, int count) {
    Redis j = getShard(key);
    return j.xrevrange(key, end, start, count);
  }

  override
  public List!(StreamPendingEntry) xpending(String key, String groupname, StreamEntryID start, StreamEntryID end,
      int count, String consumername) {
    Redis j = getShard(key);
    return j.xpending(key, groupname, start, end, count, consumername);
  }

  override
  public List!(StreamEntry) xclaim(String key, String group, String consumername, long minIdleTime, long newIdleTime,
      int retries, boolean force, StreamEntryID... ids) {
    Redis j = getShard(key);
    return j.xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
  }

  override
  public Object sendCommand(ProtocolCommand cmd, String... args) {
    // default since no sample key provided in RedisCommands interface
    String sampleKey = args.length > 0 ? args[0] : cmd.toString();
    Redis j = getShard(sampleKey);
    return j.sendCommand(cmd, args);
  }
}
