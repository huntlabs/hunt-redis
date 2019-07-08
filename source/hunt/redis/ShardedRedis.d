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

class ShardedRedis : BinaryShardedRedis implements RedisCommands, Closeable {

  protected ShardedRedisPool dataSource = null;

  ShardedRedis(List!(RedisShardInfo) shards) {
    super(shards);
  }

  ShardedRedis(List!(RedisShardInfo) shards, Hashing algo) {
    super(shards, algo);
  }

  ShardedRedis(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
    super(shards, keyTagPattern);
  }

  ShardedRedis(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
    super(shards, algo, keyTagPattern);
  }

  override
  String set(final String key, final String value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  String set(final String key, final String value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  String get(final String key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  String echo(final String string) {
    Redis j = getShard(string);
    return j.echo(string);
  }

  override
  Boolean exists(final String key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  String type(final String key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  byte[] dump(final String key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  String restore(final String key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  String restoreReplace(final String key, final int ttl, final byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  Long expire(final String key, final int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  Long pexpire(final String key, final long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  Long expireAt(final String key, final long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  Long pexpireAt(final String key, final long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  Long ttl(final String key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  Long pttl(final String key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  Boolean setbit(final String key, final long offset, bool value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean setbit(final String key, final long offset, final String value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean getbit(final String key, final long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  Long setrange(final String key, final long offset, final String value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  String getrange(final String key, final long startOffset, final long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  String getSet(final String key, final String value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  Long setnx(final String key, final String value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  String setex(final String key, final int seconds, final String value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  String psetex(final String key, final long milliseconds, final String value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  List!(String) blpop(final String arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  List!(String) blpop(final int timeout, final String key) {
    Redis j = getShard(key);
    return j.blpop(timeout, key);
  }

  List!(String) brpop(final String arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  override
  List!(String) brpop(final int timeout, final String key) {
    Redis j = getShard(key);
    return j.brpop(timeout, key);
  }

  override
  Long decrBy(final String key, final long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  Long decr(final String key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  Long incrBy(final String key, final long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  Double incrByFloat(final String key, final double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  Long incr(final String key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  Long append(final String key, final String value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  String substr(final String key, final int start, final int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  Long hset(final String key, final String field, final String value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  Long hset(final String key, final Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  String hget(final String key, final String field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  Long hsetnx(final String key, final String field, final String value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  String hmset(final String key, final Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  List!(String) hmget(final String key, String fields...) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  Long hincrBy(final String key, final String field, final long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  Double hincrByFloat(final String key, final String field, final double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  Boolean hexists(final String key, final String field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  Long del(final String key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  Long unlink(final String key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  Long hdel(final String key, String fields...) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  Long hlen(final String key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  Set!(String) hkeys(final String key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  List!(String) hvals(final String key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  Map!(String, String) hgetAll(final String key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  Long rpush(final String key, String strings...) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  Long lpush(final String key, String strings...) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  Long lpushx(final String key, String string...) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  Long strlen(final String key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  Long move(final String key, final int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  Long rpushx(final String key, String string...) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  Long persist(final String key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  Long llen(final String key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  List!(String) lrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  String ltrim(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  String lindex(final String key, final long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  String lset(final String key, final long index, final String value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  Long lrem(final String key, final long count, final String value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  String lpop(final String key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  String rpop(final String key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  Long sadd(final String key, String members...) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  Set!(String) smembers(final String key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  Long srem(final String key, String members...) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  String spop(final String key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  Set!(String) spop(final String key, final long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  Long scard(final String key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  Boolean sismember(final String key, final String member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  String srandmember(final String key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  List!(String) srandmember(final String key, final int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  Long zadd(final String key, final double score, final String member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  Long zadd(final String key, final double score, final String member, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  Long zadd(final String key, final Map!(String, Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  Long zadd(final String key, final Map!(String, Double) scoreMembers, final ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  Set!(String) zrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  Long zrem(final String key, String members...) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  Double zincrby(final String key, final double increment, final String member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  Double zincrby(final String key, final double increment, final String member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  Long zrank(final String key, final String member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  Long zrevrank(final String key, final String member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  Set!(String) zrevrange(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  Set!(Tuple) zrangeWithScores(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  Set!(Tuple) zrevrangeWithScores(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  Long zcard(final String key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  Double zscore(final String key, final String member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  List!(String) sort(final String key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  List!(String) sort(final String key, final SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  Long zcount(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Long zcount(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Set!(String) zrangeByScore(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(String) zrevrangeByScore(final String key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(String) zrangeByScore(final String key, final double min, final double max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(String) zrevrangeByScore(final String key, final double max, final double min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final String key, final double max, final double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final String key, final double min, final double max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final String key, final double max, final double min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Set!(String) zrangeByScore(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(String) zrevrangeByScore(final String key, final String max, final String min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(String) zrangeByScore(final String key, final String min, final String max, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(String) zrevrangeByScore(final String key, final String max, final String min, final int offset, final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final String key, final String max, final String min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final String key, final String min, final String max, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final String key, final String max, final String min, final int offset,
      final int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Long zremrangeByRank(final String key, final long start, final long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  Long zremrangeByScore(final String key, final double min, final double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zremrangeByScore(final String key, final String min, final String max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zlexcount(final String key, final String min, final String max) {
    return getShard(key).zlexcount(key, min, max);
  }

  override
  Set!(String) zrangeByLex(final String key, final String min, final String max) {
    return getShard(key).zrangeByLex(key, min, max);
  }

  override
  Set!(String) zrangeByLex(final String key, final String min, final String max,
      final int offset, final int count) {
    return getShard(key).zrangeByLex(key, min, max, offset, count);
  }

  override
  Set!(String) zrevrangeByLex(final String key, final String max, final String min) {
    return getShard(key).zrevrangeByLex(key, max, min);
  }

  override
  Set!(String) zrevrangeByLex(final String key, final String max, final String min, final int offset, final int count) {
    return getShard(key).zrevrangeByLex(key, max, min, offset, count);
  }

  override
  Long zremrangeByLex(final String key, final String min, final String max) {
    return getShard(key).zremrangeByLex(key, min, max);
  }

  override
  Long linsert(final String key, final ListPosition where, final String pivot, final String value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  override
  Long bitcount(final String key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  Long bitcount(final String key, final long start, final long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  Long bitpos(final String key, final bool value) {
    Redis j = getShard(key);
    return j.bitpos(key, value);
  }

  override
  Long bitpos(final String key, bool value, final BitPosParams params) {
    Redis j = getShard(key);
    return j.bitpos(key, value, params);
  }

  override
  ScanResult!(Entry!(String, String)) hscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  ScanResult!(Entry!(String, String)) hscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  ScanResult!(String) sscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(final String key, final String cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  ScanResult!(String) sscan(final String key, final String cursor, final ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  void close() {
    if (dataSource != null) {
      bool broken = false;

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

  void setDataSource(ShardedRedisPool shardedRedisPool) {
    this.dataSource = shardedRedisPool;
  }

  void resetState() {
    foreach(Redis jedis ; getAllShards()) {
      jedis.resetState();
    }
  }

  override
  Long pfadd(final String key, final String elements...) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  long pfcount(final String key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  Long touch(final String key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  Long geoadd(final String key, final double longitude, final double latitude, final String member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  Long geoadd(final String key, final Map!(String, GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  Double geodist(final String key, final String member1, final String member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  Double geodist(final String key, final String member1, final String member2, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  List!(String) geohash(final String key, final String members...) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  List!(GeoCoordinate) geopos(final String key, final String members...) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  List!(GeoRadiusResponse) georadius(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadius(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final String key, final double longitude, final double latitude,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final String key, final String member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final String key, final String member, final double radius,
      final GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final String key, final String member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final String key, final String member, final double radius,
      final GeoUnit unit, final GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  List!(Long) bitfield(final String key, final String arguments...) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
  }

  override
  Long hstrlen(final String key, final String field) {
    Redis j = getShard(key);
    return j.hstrlen(key, field);
  }

  override
  StreamEntryID xadd(String key, StreamEntryID id, Map!(String, String) hash) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash);
  }
  
  override
  StreamEntryID xadd(String key, StreamEntryID id, Map!(String, String) hash, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash, maxLen, approximateLength);
  }

  override
  Long xlen(String key) {
    Redis j = getShard(key);
    return j.xlen(key);
  }
  
  override
  List!(StreamEntry) xrange(String key, StreamEntryID start, StreamEntryID end, int count) {
    Redis j = getShard(key);
    return j.xrange(key, start, end, count);
  }

  override
  long xack(String key, String group, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xack(key, group, ids);
  }

  override
  String xgroupCreate(String key, String consumer, StreamEntryID id, bool makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  String xgroupSetID(String key, String groupname, StreamEntryID id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, groupname, id);
  }

  override
  long xgroupDestroy(String key, String groupname) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, groupname);
  }

  override
  String xgroupDelConsumer(String key, String groupname, String consumername) {
    Redis j = getShard(key);
    return j.xgroupDelConsumer(key, groupname, consumername);
  }


  override
  long xdel(String key, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xdel(key, ids);
  }

  override
  long xtrim(String key, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xtrim(key, maxLen, approximateLength);
  }

  override
  List!(StreamEntry) xrevrange(String key, StreamEntryID end, StreamEntryID start, int count) {
    Redis j = getShard(key);
    return j.xrevrange(key, end, start, count);
  }

  override
  List!(StreamPendingEntry) xpending(String key, String groupname, StreamEntryID start, StreamEntryID end,
      int count, String consumername) {
    Redis j = getShard(key);
    return j.xpending(key, groupname, start, end, count, consumername);
  }

  override
  List!(StreamEntry) xclaim(String key, String group, String consumername, long minIdleTime, long newIdleTime,
      int retries, bool force, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
  }

  override
  Object sendCommand(ProtocolCommand cmd, String args...) {
    // default since no sample key provided in RedisCommands interface
    String sampleKey = args.length > 0 ? args[0] : cmd.toString();
    Redis j = getShard(sampleKey);
    return j.sendCommand(cmd, args);
  }
}
