module hunt.redis.ShardedRedis;

import hunt.util.Common;
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
  string set(string key, string value) {
    Redis j = getShard(key);
    return j.set(key, value);
  }

  override
  string set(string key, string value, SetParams params) {
    Redis j = getShard(key);
    return j.set(key, value, params);
  }

  override
  string get(string key) {
    Redis j = getShard(key);
    return j.get(key);
  }

  override
  string echo(string string) {
    Redis j = getShard(string);
    return j.echo(string);
  }

  override
  Boolean exists(string key) {
    Redis j = getShard(key);
    return j.exists(key);
  }

  override
  string type(string key) {
    Redis j = getShard(key);
    return j.type(key);
  }

  override
  byte[] dump(string key) {
    Redis j = getShard(key);
    return j.dump(key);
  }

  override
  string restore(string key, int ttl, byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restore(key, ttl, serializedValue);
  }

  override
  string restoreReplace(string key, int ttl, byte[] serializedValue) {
    Redis j = getShard(key);
    return j.restoreReplace(key, ttl, serializedValue);
  }

  override
  Long expire(string key, int seconds) {
    Redis j = getShard(key);
    return j.expire(key, seconds);
  }

  override
  Long pexpire(string key, long milliseconds) {
    Redis j = getShard(key);
    return j.pexpire(key, milliseconds);
  }

  override
  Long expireAt(string key, long unixTime) {
    Redis j = getShard(key);
    return j.expireAt(key, unixTime);
  }

  override
  Long pexpireAt(string key, long millisecondsTimestamp) {
    Redis j = getShard(key);
    return j.pexpireAt(key, millisecondsTimestamp);
  }

  override
  Long ttl(string key) {
    Redis j = getShard(key);
    return j.ttl(key);
  }

  override
  Long pttl(string key) {
    Redis j = getShard(key);
    return j.pttl(key);
  }

  override
  Boolean setbit(string key, long offset, bool value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean setbit(string key, long offset, string value) {
    Redis j = getShard(key);
    return j.setbit(key, offset, value);
  }

  override
  Boolean getbit(string key, long offset) {
    Redis j = getShard(key);
    return j.getbit(key, offset);
  }

  override
  Long setrange(string key, long offset, string value) {
    Redis j = getShard(key);
    return j.setrange(key, offset, value);
  }

  override
  string getrange(string key, long startOffset, long endOffset) {
    Redis j = getShard(key);
    return j.getrange(key, startOffset, endOffset);
  }

  override
  string getSet(string key, string value) {
    Redis j = getShard(key);
    return j.getSet(key, value);
  }

  override
  Long setnx(string key, string value) {
    Redis j = getShard(key);
    return j.setnx(key, value);
  }

  override
  string setex(string key, int seconds, string value) {
    Redis j = getShard(key);
    return j.setex(key, seconds, value);
  }

  override
  string psetex(string key, long milliseconds, string value) {
    Redis j = getShard(key);
    return j.psetex(key, milliseconds, value);
  }

  List!(string) blpop(string arg) {
    Redis j = getShard(arg);
    return j.blpop(arg);
  }

  override
  List!(string) blpop(int timeout, string key) {
    Redis j = getShard(key);
    return j.blpop(timeout, key);
  }

  List!(string) brpop(string arg) {
    Redis j = getShard(arg);
    return j.brpop(arg);
  }

  override
  List!(string) brpop(int timeout, string key) {
    Redis j = getShard(key);
    return j.brpop(timeout, key);
  }

  override
  Long decrBy(string key, long decrement) {
    Redis j = getShard(key);
    return j.decrBy(key, decrement);
  }

  override
  Long decr(string key) {
    Redis j = getShard(key);
    return j.decr(key);
  }

  override
  Long incrBy(string key, long increment) {
    Redis j = getShard(key);
    return j.incrBy(key, increment);
  }

  override
  Double incrByFloat(string key, double increment) {
    Redis j = getShard(key);
    return j.incrByFloat(key, increment);
  }

  override
  Long incr(string key) {
    Redis j = getShard(key);
    return j.incr(key);
  }

  override
  Long append(string key, string value) {
    Redis j = getShard(key);
    return j.append(key, value);
  }

  override
  string substr(string key, int start, int end) {
    Redis j = getShard(key);
    return j.substr(key, start, end);
  }

  override
  Long hset(string key, string field, string value) {
    Redis j = getShard(key);
    return j.hset(key, field, value);
  }

  override
  Long hset(string key, Map!(string, string) hash) {
    Redis j = getShard(key);
    return j.hset(key, hash);
  }

  override
  string hget(string key, string field) {
    Redis j = getShard(key);
    return j.hget(key, field);
  }

  override
  Long hsetnx(string key, string field, string value) {
    Redis j = getShard(key);
    return j.hsetnx(key, field, value);
  }

  override
  string hmset(string key, Map!(string, string) hash) {
    Redis j = getShard(key);
    return j.hmset(key, hash);
  }

  override
  List!(string) hmget(string key, string fields...) {
    Redis j = getShard(key);
    return j.hmget(key, fields);
  }

  override
  Long hincrBy(string key, string field, long value) {
    Redis j = getShard(key);
    return j.hincrBy(key, field, value);
  }

  override
  Double hincrByFloat(string key, string field, double value) {
    Redis j = getShard(key);
    return j.hincrByFloat(key, field, value);
  }

  override
  Boolean hexists(string key, string field) {
    Redis j = getShard(key);
    return j.hexists(key, field);
  }

  override
  Long del(string key) {
    Redis j = getShard(key);
    return j.del(key);
  }

  override
  Long unlink(string key) {
    Redis j = getShard(key);
    return j.unlink(key);
  }

  override
  Long hdel(string key, string fields...) {
    Redis j = getShard(key);
    return j.hdel(key, fields);
  }

  override
  Long hlen(string key) {
    Redis j = getShard(key);
    return j.hlen(key);
  }

  override
  Set!(string) hkeys(string key) {
    Redis j = getShard(key);
    return j.hkeys(key);
  }

  override
  List!(string) hvals(string key) {
    Redis j = getShard(key);
    return j.hvals(key);
  }

  override
  Map!(string, string) hgetAll(string key) {
    Redis j = getShard(key);
    return j.hgetAll(key);
  }

  override
  Long rpush(string key, string strings...) {
    Redis j = getShard(key);
    return j.rpush(key, strings);
  }

  override
  Long lpush(string key, string strings...) {
    Redis j = getShard(key);
    return j.lpush(key, strings);
  }

  override
  Long lpushx(string key, string string...) {
    Redis j = getShard(key);
    return j.lpushx(key, string);
  }

  override
  Long strlen(string key) {
    Redis j = getShard(key);
    return j.strlen(key);
  }

  override
  Long move(string key, int dbIndex) {
    Redis j = getShard(key);
    return j.move(key, dbIndex);
  }

  override
  Long rpushx(string key, string string...) {
    Redis j = getShard(key);
    return j.rpushx(key, string);
  }

  override
  Long persist(string key) {
    Redis j = getShard(key);
    return j.persist(key);
  }

  override
  Long llen(string key) {
    Redis j = getShard(key);
    return j.llen(key);
  }

  override
  List!(string) lrange(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.lrange(key, start, stop);
  }

  override
  string ltrim(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.ltrim(key, start, stop);
  }

  override
  string lindex(string key, long index) {
    Redis j = getShard(key);
    return j.lindex(key, index);
  }

  override
  string lset(string key, long index, string value) {
    Redis j = getShard(key);
    return j.lset(key, index, value);
  }

  override
  Long lrem(string key, long count, string value) {
    Redis j = getShard(key);
    return j.lrem(key, count, value);
  }

  override
  string lpop(string key) {
    Redis j = getShard(key);
    return j.lpop(key);
  }

  override
  string rpop(string key) {
    Redis j = getShard(key);
    return j.rpop(key);
  }

  override
  Long sadd(string key, string members...) {
    Redis j = getShard(key);
    return j.sadd(key, members);
  }

  override
  Set!(string) smembers(string key) {
    Redis j = getShard(key);
    return j.smembers(key);
  }

  override
  Long srem(string key, string members...) {
    Redis j = getShard(key);
    return j.srem(key, members);
  }

  override
  string spop(string key) {
    Redis j = getShard(key);
    return j.spop(key);
  }

  override
  Set!(string) spop(string key, long count) {
    Redis j = getShard(key);
    return j.spop(key, count);
  }

  override
  Long scard(string key) {
    Redis j = getShard(key);
    return j.scard(key);
  }

  override
  Boolean sismember(string key, string member) {
    Redis j = getShard(key);
    return j.sismember(key, member);
  }

  override
  string srandmember(string key) {
    Redis j = getShard(key);
    return j.srandmember(key);
  }

  override
  List!(string) srandmember(string key, int count) {
    Redis j = getShard(key);
    return j.srandmember(key, count);
  }

  override
  Long zadd(string key, double score, string member) {
    Redis j = getShard(key);
    return j.zadd(key, score, member);
  }

  override
  Long zadd(string key, double score, string member, ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, score, member, params);
  }

  override
  Long zadd(string key, Map!(string, Double) scoreMembers) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers);
  }

  override
  Long zadd(string key, Map!(string, Double) scoreMembers, ZAddParams params) {
    Redis j = getShard(key);
    return j.zadd(key, scoreMembers, params);
  }

  override
  Set!(string) zrange(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrange(key, start, stop);
  }

  override
  Long zrem(string key, string members...) {
    Redis j = getShard(key);
    return j.zrem(key, members);
  }

  override
  Double zincrby(string key, double increment, string member) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member);
  }

  override
  Double zincrby(string key, double increment, string member, ZIncrByParams params) {
    Redis j = getShard(key);
    return j.zincrby(key, increment, member, params);
  }

  override
  Long zrank(string key, string member) {
    Redis j = getShard(key);
    return j.zrank(key, member);
  }

  override
  Long zrevrank(string key, string member) {
    Redis j = getShard(key);
    return j.zrevrank(key, member);
  }

  override
  Set!(string) zrevrange(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrevrange(key, start, stop);
  }

  override
  Set!(Tuple) zrangeWithScores(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrangeWithScores(key, start, stop);
  }

  override
  Set!(Tuple) zrevrangeWithScores(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.zrevrangeWithScores(key, start, stop);
  }

  override
  Long zcard(string key) {
    Redis j = getShard(key);
    return j.zcard(key);
  }

  override
  Double zscore(string key, string member) {
    Redis j = getShard(key);
    return j.zscore(key, member);
  }

  override
  List!(string) sort(string key) {
    Redis j = getShard(key);
    return j.sort(key);
  }

  override
  List!(string) sort(string key, SortingParams sortingParameters) {
    Redis j = getShard(key);
    return j.sort(key, sortingParameters);
  }

  override
  Long zcount(string key, double min, double max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Long zcount(string key, string min, string max) {
    Redis j = getShard(key);
    return j.zcount(key, min, max);
  }

  override
  Set!(string) zrangeByScore(string key, double min, double max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(string) zrevrangeByScore(string key, double max, double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(string) zrangeByScore(string key, double min, double max, int offset, int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(string) zrevrangeByScore(string key, double max, double min, int offset, int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Set!(string) zrangeByScore(string key, string min, string max) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max);
  }

  override
  Set!(string) zrevrangeByScore(string key, string max, string min) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min);
  }

  override
  Set!(string) zrangeByScore(string key, string min, string max, int offset, int count) {
    Redis j = getShard(key);
    return j.zrangeByScore(key, min, max, offset, count);
  }

  override
  Set!(string) zrevrangeByScore(string key, string max, string min, int offset, int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScore(key, max, min, offset, count);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrangeByScoreWithScores(key, min, max, offset, count);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min, int offset,
      int count) {
    Redis j = getShard(key);
    return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
  }

  override
  Long zremrangeByRank(string key, long start, long stop) {
    Redis j = getShard(key);
    return j.zremrangeByRank(key, start, stop);
  }

  override
  Long zremrangeByScore(string key, double min, double max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zremrangeByScore(string key, string min, string max) {
    Redis j = getShard(key);
    return j.zremrangeByScore(key, min, max);
  }

  override
  Long zlexcount(string key, string min, string max) {
    return getShard(key).zlexcount(key, min, max);
  }

  override
  Set!(string) zrangeByLex(string key, string min, string max) {
    return getShard(key).zrangeByLex(key, min, max);
  }

  override
  Set!(string) zrangeByLex(string key, string min, string max,
      int offset, int count) {
    return getShard(key).zrangeByLex(key, min, max, offset, count);
  }

  override
  Set!(string) zrevrangeByLex(string key, string max, string min) {
    return getShard(key).zrevrangeByLex(key, max, min);
  }

  override
  Set!(string) zrevrangeByLex(string key, string max, string min, int offset, int count) {
    return getShard(key).zrevrangeByLex(key, max, min, offset, count);
  }

  override
  Long zremrangeByLex(string key, string min, string max) {
    return getShard(key).zremrangeByLex(key, min, max);
  }

  override
  Long linsert(string key, ListPosition where, string pivot, string value) {
    Redis j = getShard(key);
    return j.linsert(key, where, pivot, value);
  }

  override
  Long bitcount(string key) {
    Redis j = getShard(key);
    return j.bitcount(key);
  }

  override
  Long bitcount(string key, long start, long end) {
    Redis j = getShard(key);
    return j.bitcount(key, start, end);
  }

  override
  Long bitpos(string key, bool value) {
    Redis j = getShard(key);
    return j.bitpos(key, value);
  }

  override
  Long bitpos(string key, bool value, BitPosParams params) {
    Redis j = getShard(key);
    return j.bitpos(key, value, params);
  }

  override
  ScanResult!(Entry!(string, string)) hscan(string key, string cursor) {
    Redis j = getShard(key);
    return j.hscan(key, cursor);
  }

  override
  ScanResult!(Entry!(string, string)) hscan(string key, string cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.hscan(key, cursor, params);
  }

  override
  ScanResult!(string) sscan(string key, string cursor) {
    Redis j = getShard(key);
    return j.sscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(string key, string cursor) {
    Redis j = getShard(key);
    return j.zscan(key, cursor);
  }

  override
  ScanResult!(Tuple) zscan(string key, string cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.zscan(key, cursor, params);
  }

  override
  ScanResult!(string) sscan(string key, string cursor, ScanParams params) {
    Redis j = getShard(key);
    return j.sscan(key, cursor, params);
  }

  override
  void close() {
    if (dataSource !is null) {
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
  Long pfadd(string key, string elements...) {
    Redis j = getShard(key);
    return j.pfadd(key, elements);
  }

  override
  long pfcount(string key) {
    Redis j = getShard(key);
    return j.pfcount(key);
  }

  override
  Long touch(string key) {
    Redis j = getShard(key);
    return j.touch(key);
  }

  override
  Long geoadd(string key, double longitude, double latitude, string member) {
    Redis j = getShard(key);
    return j.geoadd(key, longitude, latitude, member);
  }

  override
  Long geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
    Redis j = getShard(key);
    return j.geoadd(key, memberCoordinateMap);
  }

  override
  Double geodist(string key, string member1, string member2) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2);
  }

  override
  Double geodist(string key, string member1, string member2, GeoUnit unit) {
    Redis j = getShard(key);
    return j.geodist(key, member1, member2, unit);
  }

  override
  List!(string) geohash(string key, string members...) {
    Redis j = getShard(key);
    return j.geohash(key, members);
  }

  override
  List!(GeoCoordinate) geopos(string key, string members...) {
    Redis j = getShard(key);
    return j.geopos(key, members);
  }

  override
  List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadius(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius,
      GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius,
      GeoUnit unit) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius,
      GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMember(key, member, radius, unit, param);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius,
      GeoUnit unit, GeoRadiusParam param) {
    Redis j = getShard(key);
    return j.georadiusByMemberReadonly(key, member, radius, unit, param);
  }

  override
  List!(Long) bitfield(string key, string arguments...) {
    Redis j = getShard(key);
    return j.bitfield(key, arguments);
  }

  override
  Long hstrlen(string key, string field) {
    Redis j = getShard(key);
    return j.hstrlen(key, field);
  }

  override
  StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash);
  }
  
  override
  StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xadd(key, id, hash, maxLen, approximateLength);
  }

  override
  Long xlen(string key) {
    Redis j = getShard(key);
    return j.xlen(key);
  }
  
  override
  List!(StreamEntry) xrange(string key, StreamEntryID start, StreamEntryID end, int count) {
    Redis j = getShard(key);
    return j.xrange(key, start, end, count);
  }

  override
  long xack(string key, string group, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xack(key, group, ids);
  }

  override
  string xgroupCreate(string key, string consumer, StreamEntryID id, bool makeStream) {
    Redis j = getShard(key);
    return j.xgroupCreate(key, consumer, id, makeStream);
  }

  override
  string xgroupSetID(string key, string groupname, StreamEntryID id) {
    Redis j = getShard(key);
    return j.xgroupSetID(key, groupname, id);
  }

  override
  long xgroupDestroy(string key, string groupname) {
    Redis j = getShard(key);
    return j.xgroupDestroy(key, groupname);
  }

  override
  string xgroupDelConsumer(string key, string groupname, string consumername) {
    Redis j = getShard(key);
    return j.xgroupDelConsumer(key, groupname, consumername);
  }


  override
  long xdel(string key, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xdel(key, ids);
  }

  override
  long xtrim(string key, long maxLen, bool approximateLength) {
    Redis j = getShard(key);
    return j.xtrim(key, maxLen, approximateLength);
  }

  override
  List!(StreamEntry) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count) {
    Redis j = getShard(key);
    return j.xrevrange(key, end, start, count);
  }

  override
  List!(StreamPendingEntry) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end,
      int count, string consumername) {
    Redis j = getShard(key);
    return j.xpending(key, groupname, start, end, count, consumername);
  }

  override
  List!(StreamEntry) xclaim(string key, string group, string consumername, long minIdleTime, long newIdleTime,
      int retries, bool force, StreamEntryID ids...) {
    Redis j = getShard(key);
    return j.xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
  }

  override
  Object sendCommand(ProtocolCommand cmd, string args...) {
    // default since no sample key provided in RedisCommands interface
    string sampleKey = args.length > 0 ? args[0] : cmd.toString();
    Redis j = getShard(sampleKey);
    return j.sendCommand(cmd, args);
  }
}
