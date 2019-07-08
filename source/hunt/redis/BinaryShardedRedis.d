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

class BinaryShardedRedis : Sharded!(Redis, RedisShardInfo) implements
    BinaryRedisCommands {
  BinaryShardedRedis(List!(RedisShardInfo) shards) {
    super(shards);
  }

  BinaryShardedRedis(List!(RedisShardInfo) shards, Hashing algo) {
    super(shards, algo);
  }

  BinaryShardedRedis(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
    super(shards, keyTagPattern);
  }

  BinaryShardedRedis(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
    super(shards, algo, keyTagPattern);
  }

  void disconnect() {
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
  String set(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  String set(final byte[] key, final byte[] value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  byte[] get(final byte[] key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  Boolean exists(final byte[] key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  String type(final byte[] key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  byte[] dump(final byte[] key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  String restore(final byte[] key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  String restoreReplace(final byte[] key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  Long expire(final byte[] key, final int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  Long pexpire(final byte[] key, final long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  Long expireAt(final byte[] key, final long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  Long pexpireAt(final byte[] key, final long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  Long ttl(final byte[] key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  Long pttl(final byte[] key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  Long touch(final byte[] key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  byte[] getSet(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  Long setnx(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  String setex(final byte[] key, final int seconds, final byte[] value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  String psetex(final byte[] key, final long milliseconds, final byte[] value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  override
  Long decrBy(final byte[] key, final long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  Long decr(final byte[] key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  Long del(final byte[] key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  Long unlink(final byte[] key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  Long incrBy(final byte[] key, final long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  Double incrByFloat(final byte[] key, final double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  Long incr(final byte[] key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  Long append(final byte[] key, final byte[] value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  byte[] substr(final byte[] key, final int start, final int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  Long hset(final byte[] key, final byte[] field, final byte[] value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  Long hset(final byte[] key, final Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  byte[] hget(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  Long hsetnx(final byte[] key, final byte[] field, final byte[] value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  String hmset(final byte[] key, final Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  List!(byte[]) hmget(final byte[] key, final byte[] fields...) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  Long hincrBy(final byte[] key, final byte[] field, final long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  Double hincrByFloat(final byte[] key, final byte[] field, final double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  Boolean hexists(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  Long hdel(final byte[] key, final byte[] fields...) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  Long hlen(final byte[] key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  Set!(byte[]) hkeys(final byte[] key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  Collection!(byte[]) hvals(final byte[] key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  Map!(byte[], byte[]) hgetAll(final byte[] key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  Long rpush(final byte[] key, final byte[] strings...) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  Long lpush(final byte[] key, final byte[] strings...) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  Long strlen(final byte[] key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  Long lpushx(final byte[] key, final byte[] string...) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  Long persist(final byte[] key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  Long rpushx(final byte[] key, final byte[] string...) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  Long llen(final byte[] key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  List!(byte[]) lrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  String ltrim(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  byte[] lindex(final byte[] key, final long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  String lset(final byte[] key, final long index, final byte[] value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  Long lrem(final byte[] key, final long count, final byte[] value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  byte[] lpop(final byte[] key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  byte[] rpop(final byte[] key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  Long sadd(final byte[] key, final byte[] members...) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  Set!(byte[]) smembers(final byte[] key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  Long srem(final byte[] key, final byte[] members...) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  byte[] spop(final byte[] key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  Set!(byte[]) spop(final byte[] key, final long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  Long scard(final byte[] key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  Boolean sismember(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  byte[] srandmember(final byte[] key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  List!(byte[]) srandmember(final byte[] key, final int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  Long zadd(final byte[] key, final double score, final byte[] member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  Long zadd(final byte[] key, final double score, final byte[] member, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  Set!(byte[]) zrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  Long zrem(final byte[] key, final byte[] members...) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  Double zincrby(final byte[] key, final double increment, final byte[] member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  Double zincrby(final byte[] key, final double increment, final byte[] member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  Long zrank(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  Long zrevrank(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  Set!(byte[]) zrevrange(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  Set!(Tuple) zrangeWithScores(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  Set!(Tuple) zrevrangeWithScores(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  Long zcard(final byte[] key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  Double zscore(final byte[] key, final byte[] member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  List!(byte[]) sort(final byte[] key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  List!(byte[]) sort(final byte[] key, SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  Long zcount(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Long zcount(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max, final double min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max, final byte[] min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Long zremrangeByRank(final byte[] key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  Long zremrangeByScore(final byte[] key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zremrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zlexcount(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zlexcount(key, min, max);
  }

  override
  Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max);
  }

  override
  Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max,
      final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min, offset, count);
  }

  override
  Long zremrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByLex(key, min, max);
  }

  override
  Long linsert(final byte[] key, final ListPosition where, final byte[] pivot, final byte[] value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  ShardedRedisPipeline pipelined() {
    ShardedRedisPipeline pipeline = new ShardedRedisPipeline();
    pipeline.setShardedRedis(this);
    return pipeline;
  }

  Long objectRefcount(final byte[] key) {
    Redis j = getShard(key);
    return j.objectRefcount(key);
  }

  byte[] objectEncoding(final byte[] key) {
    Redis j = getShard(key);
    return j.objectEncoding(key);
  }

  Long objectIdletime(final byte[] key) {
    Redis j = getShard(key);
    return j.objectIdletime(key);
  }

  override
  Boolean setbit(final byte[] key, final long offset, bool value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean setbit(final byte[] key, final long offset, final byte[] value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean getbit(final byte[] key, final long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  Long setrange(final byte[] key, final long offset, final byte[] value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  byte[] getrange(final byte[] key, final long startOffset, final long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  Long move(final byte[] key, final int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  byte[] echo(final byte[] arg) {
    Redis j = getShard(arg);
    return j.echo(arg);
  }

  List!(byte[]) brpop(final byte[] arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  List!(byte[]) blpop(final byte[] arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  Long bitcount(final byte[] key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  Long bitcount(final byte[] key, final long start, final long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  Long pfadd(final byte[] key, final byte[] elements...) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  long pfcount(final byte[] key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  Long geoadd(final byte[] key, final double longitude, final double latitude, final byte[] member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  Long geoadd(final byte[] key, final Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  Double geodist(final byte[] key, final byte[] member1, final byte[] member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  Double geodist(final byte[] key, final byte[] member1, final byte[] member2, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  List!(byte[]) geohash(final byte[] key, final byte[] members...) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  List!(GeoCoordinate) geopos(final byte[] key, final byte[] members...) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  List!(Long) bitfield(final byte[] key, final byte[] arguments...) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
 }

  override
  Long hstrlen(final byte[] key, final byte[] field) {
    Redis j = getShard(key);
    return j.hstrlen(key, field);
  }

  override
  byte[] xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash, maxLen, approximateLength);
  }

  override
  Long xlen(byte[] key) {
    Redis j = getShard(key);
    return j.xlen(key);
  }

  override
  List!(byte[]) xrange(byte[] key, byte[] start, byte[] end, long count) {
    Redis j = getShard(key);
    return j.xrange(key, start, end, count);
  }

  override
  List!(byte[]) xrevrange(byte[] key, byte[] end, byte[] start, int count) {
    Redis j = getShard(key);
    return j.xrevrange(key, end, start, count);
  }

  override
  Long xack(byte[] key, byte[] group, byte[] ids...) {
    Redis j = getShard(key);
    return j.xack(key, group, ids);
  }

  override
  String xgroupCreate(byte[] key, byte[] consumer, byte[] id, bool makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  String xgroupSetID(byte[] key, byte[] consumer, byte[] id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, consumer, id);
  }

  override
  Long xgroupDestroy(byte[] key, byte[] consumer) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, consumer);
  }

  override
  String xgroupDelConsumer(byte[] key, byte[] consumer, byte[] consumerName) {
    Redis j = getShard(key);
    return j.xgroupDelConsumer(key, consumer, consumerName);
  }

  override
  Long xdel(byte[] key, byte[] ids...) {
    Redis j = getShard(key);
    return j.xdel(key, ids);
  }

  override
  Long xtrim(byte[] key, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xtrim(key, maxLen, approximateLength);
  }

  override
  List!(byte[]) xpending(byte[] key, byte[] groupname, byte[] start, byte[] end, int count, byte[] consumername) {
    Redis j = getShard(key);
    return j.xpending(key, groupname, start, end, count, consumername);
  }

  override
  List!(byte[]) xclaim(byte[] key, byte[] groupname, byte[] consumername, long minIdleTime, long newIdleTime,
      int retries, bool force, byte[][] ids) {
    Redis j = getShard(key);
    return j.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
  }

  override
  Object sendCommand(ProtocolCommand cmd, byte[] args...) {
    // default since no sample key provided in RedisCommands interface
    byte[] sampleKey = args.length > 0 ? args[0] : cmd.getRaw();
    Redis j = getShard(args[0]);
    return j.sendCommand(cmd, args);
  }

}
