module hunt.redis.BinaryShardedRedis;

import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Redis;
import hunt.redis.RedisShardInfo;
import hunt.redis.ShardedRedisPipeline;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.Tuple;


import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.commands.BinaryRedisCommands;
import hunt.redis.commands.ProtocolCommand;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.Hashing;
import hunt.redis.util.Sharded;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

import std.regex;
alias Pattern = Regex!char;


class BinaryShardedRedis : Sharded!(Redis, RedisShardInfo), BinaryRedisCommands {
  this(List!(RedisShardInfo) shards) {
    super(shards);
  }

  this(List!(RedisShardInfo) shards, Hashing algo) {
    super(shards, algo);
  }

  this(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
    super(shards, keyTagPattern);
  }

  this(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
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
  string set(byte[] key, byte[] value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  string set(byte[] key, byte[] value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  byte[] get(byte[] key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  Boolean exists(byte[] key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  string type(byte[] key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  byte[] dump(byte[] key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  string restore(byte[] key, int ttl, byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  string restoreReplace(byte[] key, int ttl, byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  Long expire(byte[] key, int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  Long pexpire(byte[] key, long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  Long expireAt(byte[] key, long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  Long pexpireAt(byte[] key, long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  Long ttl(byte[] key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  Long pttl(byte[] key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  Long touch(byte[] key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  byte[] getSet(byte[] key, byte[] value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  Long setnx(byte[] key, byte[] value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  string setex(byte[] key, int seconds, byte[] value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  string psetex(byte[] key, long milliseconds, byte[] value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  override
  Long decrBy(byte[] key, long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  Long decr(byte[] key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  Long del(byte[] key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  Long unlink(byte[] key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  Long incrBy(byte[] key, long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  Double incrByFloat(byte[] key, double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  Long incr(byte[] key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  Long append(byte[] key, byte[] value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  byte[] substr(byte[] key, int start, int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  Long hset(byte[] key, byte[] field, byte[] value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  Long hset(byte[] key, Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  byte[] hget(byte[] key, byte[] field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  Long hsetnx(byte[] key, byte[] field, byte[] value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  string hmset(byte[] key, Map!(byte[], byte[]) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  List!(byte[]) hmget(byte[] key, byte[] fields...) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  Long hincrBy(byte[] key, byte[] field, long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  Double hincrByFloat(byte[] key, byte[] field, double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  Boolean hexists(byte[] key, byte[] field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  Long hdel(byte[] key, byte[] fields...) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  Long hlen(byte[] key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  Set!(byte[]) hkeys(byte[] key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  Collection!(byte[]) hvals(byte[] key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  Map!(byte[], byte[]) hgetAll(byte[] key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  Long rpush(byte[] key, byte[] strings...) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  Long lpush(byte[] key, byte[] strings...) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  Long strlen(byte[] key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  Long lpushx(byte[] key, byte[] string...) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  Long persist(byte[] key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  Long rpushx(byte[] key, byte[] string...) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  Long llen(byte[] key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  List!(byte[]) lrange(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  string ltrim(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  byte[] lindex(byte[] key, long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  string lset(byte[] key, long index, byte[] value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  Long lrem(byte[] key, long count, byte[] value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  byte[] lpop(byte[] key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  byte[] rpop(byte[] key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  Long sadd(byte[] key, byte[] members...) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  Set!(byte[]) smembers(byte[] key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  Long srem(byte[] key, byte[] members...) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  byte[] spop(byte[] key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  Set!(byte[]) spop(byte[] key, long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  Long scard(byte[] key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  Boolean sismember(byte[] key, byte[] member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  byte[] srandmember(byte[] key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  List!(byte[]) srandmember(byte[] key, int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  Long zadd(byte[] key, double score, byte[] member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  Long zadd(byte[] key, double score, byte[] member, ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  Long zadd(byte[] key, Map!(byte[], Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  Long zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  Set!(byte[]) zrange(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  Long zrem(byte[] key, byte[] members...) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  Double zincrby(byte[] key, double increment, byte[] member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  Double zincrby(byte[] key, double increment, byte[] member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  Long zrank(byte[] key, byte[] member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  Long zrevrank(byte[] key, byte[] member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  Set!(byte[]) zrevrange(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  Set!(Tuple) zrangeWithScores(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  Set!(Tuple) zrevrangeWithScores(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  Long zcard(byte[] key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  Double zscore(byte[] key, byte[] member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  List!(byte[]) sort(byte[] key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  List!(byte[]) sort(byte[] key, SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  Long zcount(byte[] key, double min, double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Long zcount(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Set!(byte[]) zrangeByScore(byte[] key, double min, double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(byte[]) zrangeByScore(byte[] key, double min, double max, int offset, int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(byte[] key, double min, double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(byte[] key, double min, double max, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrangeByScore(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrangeByScore(byte[] key, byte[] min, byte[] max, int offset, int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByScore(byte[] key, double max, double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByScore(byte[] key, double max, double min, int offset, int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, double max, double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, double max, double min, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByScore(byte[] key, byte[] max, byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByScore(byte[] key, byte[] max, byte[] min, int offset, int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Long zremrangeByRank(byte[] key, long start, long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  Long zremrangeByScore(byte[] key, double min, double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zremrangeByScore(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zlexcount(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zlexcount(key, min, max);
  }

  override
  Set!(byte[]) zrangeByLex(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max);
  }

  override
  Set!(byte[]) zrangeByLex(byte[] key, byte[] min, byte[] max,
      int offset, int count) {
    Redis j = getShard(key);
    return j.zrangeByLex(key, min, max, offset, count);
  }

  override
  Set!(byte[]) zrevrangeByLex(byte[] key, byte[] max, byte[] min) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min);
  }

  override
  Set!(byte[]) zrevrangeByLex(byte[] key, byte[] max, byte[] min, int offset, int count) {
    Redis j = getShard(key);
    return j.zrevrangeByLex(key, max, min, offset, count);
  }

  override
  Long zremrangeByLex(byte[] key, byte[] min, byte[] max) {
    Redis j = getShard(key);
    return j.zremrangeByLex(key, min, max);
  }

  override
  Long linsert(byte[] key, ListPosition where, byte[] pivot, byte[] value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  ShardedRedisPipeline pipelined() {
    ShardedRedisPipeline pipeline = new ShardedRedisPipeline();
    pipeline.setShardedRedis(this);
    return pipeline;
  }

  Long objectRefcount(byte[] key) {
    Redis j = getShard(key);
    return j.objectRefcount(key);
  }

  byte[] objectEncoding(byte[] key) {
    Redis j = getShard(key);
    return j.objectEncoding(key);
  }

  Long objectIdletime(byte[] key) {
    Redis j = getShard(key);
    return j.objectIdletime(key);
  }

  override
  Boolean setbit(byte[] key, long offset, bool value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean setbit(byte[] key, long offset, byte[] value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean getbit(byte[] key, long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  Long setrange(byte[] key, long offset, byte[] value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  byte[] getrange(byte[] key, long startOffset, long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  Long move(byte[] key, int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  byte[] echo(byte[] arg) {
    Redis j = getShard(arg);
    return j.echo(arg);
  }

  List!(byte[]) brpop(byte[] arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  List!(byte[]) blpop(byte[] arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  Long bitcount(byte[] key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  Long bitcount(byte[] key, long start, long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  Long pfadd(byte[] key, byte[] elements...) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  long pfcount(byte[] key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  Long geoadd(byte[] key, double longitude, double latitude, byte[] member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  Long geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  Double geodist(byte[] key, byte[] member1, byte[] member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  Double geodist(byte[] key, byte[] member1, byte[] member2, GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  List!(byte[]) geohash(byte[] key, byte[] members...) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  List!(GeoCoordinate) geopos(byte[] key, byte[] members...) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  List!(GeoRadiusResponse) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(byte[] key, byte[] member, double radius,
      GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(byte[] key, byte[] member, double radius,
      GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(byte[] key, byte[] member, double radius,
      GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(byte[] key, byte[] member, double radius,
      GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  ScanResult!(MapEntry!(byte[], byte[])) hscan(byte[] key, byte[] cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  ScanResult!(MapEntry!(byte[], byte[])) hscan(byte[] key, byte[] cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  ScanResult!(byte[]) sscan(byte[] key, byte[] cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  ScanResult!(byte[]) sscan(byte[] key, byte[] cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  ScanResult!(Tuple) zscan(byte[] key, byte[] cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(byte[] key, byte[] cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  List!(Long) bitfield(byte[] key, byte[] arguments...) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
 }

  override
  Long hstrlen(byte[] key, byte[] field) {
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
  string xgroupCreate(byte[] key, byte[] consumer, byte[] id, bool makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  string xgroupSetID(byte[] key, byte[] consumer, byte[] id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, consumer, id);
  }

  override
  Long xgroupDestroy(byte[] key, byte[] consumer) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, consumer);
  }

  override
  string xgroupDelConsumer(byte[] key, byte[] consumer, byte[] consumerName) {
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
