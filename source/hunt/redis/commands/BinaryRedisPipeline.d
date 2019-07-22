module hunt.redis.commands.BinaryRedisPipeline;

import hunt.redis.Protocol;

import hunt.redis.BitPosParams;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.StreamPendingEntry;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.Tuple;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

interface BinaryRedisPipeline {
  Response!(Long) append(const(ubyte)[] key, const(ubyte)[] value);

  Response!(List!(const(ubyte)[])) blpop(const(ubyte)[] arg);

  Response!(List!(const(ubyte)[])) brpop(const(ubyte)[] arg);

  Response!(Long) decr(const(ubyte)[] key);

  Response!(Long) decrBy(const(ubyte)[] key, long decrement);

  Response!(Long) del(const(ubyte)[] keys);

  Response!(Long) unlink(const(ubyte)[] keys);

  Response!(const(ubyte)[]) echo(const(ubyte)[] string);

  Response!(Boolean) exists(const(ubyte)[] key);

  Response!(Long) expire(const(ubyte)[] key, int seconds);

  Response!(Long) pexpire(const(ubyte)[] key, long milliseconds);

  Response!(Long) expireAt(const(ubyte)[] key, long unixTime);

  Response!(Long) pexpireAt(const(ubyte)[] key, long millisecondsTimestamp);

  Response!(const(ubyte)[]) get(const(ubyte)[] key);

  Response!(Boolean) getbit(const(ubyte)[] key, long offset);

  Response!(const(ubyte)[]) getSet(const(ubyte)[] key, const(ubyte)[] value);

  Response!(const(ubyte)[]) getrange(const(ubyte)[] key, long startOffset, long endOffset);

  Response!(Long) hdel(const(ubyte)[] key, const(ubyte)[][] field...);

  Response!(Boolean) hexists(const(ubyte)[] key, const(ubyte)[] field);

  Response!(const(ubyte)[]) hget(const(ubyte)[] key, const(ubyte)[] field);

  Response!(Map!(const(ubyte)[], const(ubyte)[])) hgetAll(const(ubyte)[] key);

  Response!(Long) hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value);

  Response!(Set!(const(ubyte)[])) hkeys(const(ubyte)[] key);

  Response!(Long) hlen(const(ubyte)[] key);

  Response!(List!(const(ubyte)[])) hmget(const(ubyte)[] key, const(ubyte)[][] fields...);

  Response!(string) hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

  Response!(Long) hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

  Response!(Long) hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

  Response!(Long) hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

  Response!(List!(const(ubyte)[])) hvals(const(ubyte)[] key);

  Response!(Long) incr(const(ubyte)[] key);

  Response!(Long) incrBy(const(ubyte)[] key, long increment);

  Response!(const(ubyte)[]) lindex(const(ubyte)[] key, long index);

  Response!(Long) linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot, const(ubyte)[] value);

  Response!(Long) llen(const(ubyte)[] key);

  Response!(const(ubyte)[]) lpop(const(ubyte)[] key);

  Response!(Long) lpush(const(ubyte)[] key, const(ubyte)[][] string...);

  Response!(Long) lpushx(const(ubyte)[] key, const(ubyte)[][] bytes...);

  Response!(List!(const(ubyte)[])) lrange(const(ubyte)[] key, long start, long stop);

  Response!(Long) lrem(const(ubyte)[] key, long count, const(ubyte)[] value);

  Response!(string) lset(const(ubyte)[] key, long index, const(ubyte)[] value);

  Response!(string) ltrim(const(ubyte)[] key, long start, long stop);

  Response!(Long) move(const(ubyte)[] key, int dbIndex);

  Response!(Long) persist(const(ubyte)[] key);

  Response!(const(ubyte)[]) rpop(const(ubyte)[] key);

  Response!(Long) rpush(const(ubyte)[] key, const(ubyte)[][] string...);

  Response!(Long) rpushx(const(ubyte)[] key, const(ubyte)[][] string...);

  Response!(Long) sadd(const(ubyte)[] key, const(ubyte)[][] member...);

  Response!(Long) scard(const(ubyte)[] key);

  Response!(string) set(const(ubyte)[] key, const(ubyte)[] value);

  Response!(Boolean) setbit(const(ubyte)[] key, long offset, const(ubyte)[] value);

  Response!(Long) setrange(const(ubyte)[] key, long offset, const(ubyte)[] value);

  Response!(string) setex(const(ubyte)[] key, int seconds, const(ubyte)[] value);

  Response!(Long) setnx(const(ubyte)[] key, const(ubyte)[] value);

  Response!(Long) setrange(string key, long offset, string value);

  Response!(Set!(const(ubyte)[])) smembers(const(ubyte)[] key);

  Response!(Boolean) sismember(const(ubyte)[] key, const(ubyte)[] member);

  Response!(List!(const(ubyte)[])) sort(const(ubyte)[] key);

  Response!(List!(const(ubyte)[])) sort(const(ubyte)[] key, SortingParams sortingParameters);

  Response!(const(ubyte)[]) spop(const(ubyte)[] key);

  Response!(Set!(const(ubyte)[])) spop(const(ubyte)[] key, long count);

  Response!(const(ubyte)[]) srandmember(const(ubyte)[] key);

  Response!(Long) srem(const(ubyte)[] key, const(ubyte)[][] member...);

  Response!(Long) strlen(const(ubyte)[] key);

  Response!(string) substr(const(ubyte)[] key, int start, int end);

  Response!(Long) touch(const(ubyte)[] keys);

  Response!(Long) ttl(const(ubyte)[] key);

  Response!(Long) pttl(const(ubyte)[] key);

  Response!(string) type(const(ubyte)[] key);

  Response!(Long) zadd(const(ubyte)[] key, double score, const(ubyte)[] member);

  Response!(Long) zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params);

  Response!(Long) zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers);

  Response!(Long) zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers, ZAddParams params);

  Response!(Long) zcard(const(ubyte)[] key);

  Response!(Long) zcount(const(ubyte)[] key, double min, double max);

  Response!(Long) zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Double) zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member);

  Response!(Double) zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params);

  Response!(Set!(const(ubyte)[])) zrange(const(ubyte)[] key, long start, long stop);

  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, double min, double max);

  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, double min, double max, int offset, int count);

  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max, int offset,
      int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
      int count);

  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, double max, double min);

  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, double max, double min, int offset, int count);

  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min, int offset,
      int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset,
      int count);

  Response!(Set!(Tuple)) zrangeWithScores(const(ubyte)[] key, long start, long stop);

  Response!(Long) zrank(const(ubyte)[] key, const(ubyte)[] member);

  Response!(Long) zrem(const(ubyte)[] key, const(ubyte)[][] members...);

  Response!(Long) zremrangeByRank(const(ubyte)[] key, long start, long stop);

  Response!(Long) zremrangeByScore(const(ubyte)[] key, double min, double max);

  Response!(Long) zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Set!(const(ubyte)[])) zrevrange(const(ubyte)[] key, long start, long stop);

  Response!(Set!(Tuple)) zrevrangeWithScores(const(ubyte)[] key, long start, long stop);

  Response!(Long) zrevrank(const(ubyte)[] key, const(ubyte)[] member);

  Response!(Double) zscore(const(ubyte)[] key, const(ubyte)[] member);

  Response!(Long) zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Set!(const(ubyte)[])) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Set!(const(ubyte)[])) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
      int offset, int count);

  Response!(Set!(const(ubyte)[])) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Response!(Set!(const(ubyte)[])) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
      int offset, int count);

  Response!(Long) zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Response!(Long) bitcount(const(ubyte)[] key);

  Response!(Long) bitcount(const(ubyte)[] key, long start, long end);

  Response!(Long) pfadd(const(ubyte)[] key, const(ubyte)[][] elements...);

  Response!(Long) pfcount(const(ubyte)[] key);

  Response!(const(ubyte)[]) dump(const(ubyte)[] key);

  Response!(string) restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue);

  Response!(string) restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue);

  Response!(string) migrate(string host, int port, const(ubyte)[] key, int destinationDB, int timeout);

  // Geo Commands

  Response!(Long) geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member);

  Response!(Long) geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap);

  Response!(Double) geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2);

  Response!(Double) geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit);

  Response!(List!(const(ubyte)[])) geohash(const(ubyte)[] key, const(ubyte)[][] members...);

  Response!(List!(GeoCoordinate)) geopos(const(ubyte)[] key, const(ubyte)[][] members...);

  Response!(List!(GeoRadiusResponse)) georadius(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadius(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
      GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
      GeoUnit unit);
  
  Response!(List!(GeoRadiusResponse)) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
      GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
      GeoUnit unit, GeoRadiusParam param);

  Response!(List!(Long)) bitfield(const(ubyte)[] key, const(ubyte)[][] elements...);

  Response!(Long) hstrlen(const(ubyte)[] key, const(ubyte)[] field);
  
  Response!(const(ubyte)[]) xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash);

  Response!(const(ubyte)[]) xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength);
  
  Response!(Long) xlen(const(ubyte)[] key);

  Response!(List!(const(ubyte)[])) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, int count);

  Response!(List!(const(ubyte)[])) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count);
   
  Response!(Long) xack(const(ubyte)[] key, const(ubyte)[] group,  const(ubyte)[][] ids...);
  
  Response!(string) xgroupCreate(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id, bool makeStream);
  
  Response!(string) xgroupSetID(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id);
  
  Response!(Long) xgroupDestroy(const(ubyte)[] key, const(ubyte)[] groupname);
  
  Response!(string) xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername);

  Response!(List!(StreamPendingEntry)) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername);
  
  Response!(Long) xdel(const(ubyte)[] key, const(ubyte)[][] ids...);
  
  Response!(Long) xtrim(const(ubyte)[] key, long maxLen, bool approximateLength);
 
  Response!(List!(const(ubyte)[])) xclaim(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[] consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, const(ubyte)[][] ids...);

  Response!(Long) bitpos(const(ubyte)[] key, bool value);

  Response!(Long) bitpos(const(ubyte)[] key, bool value, BitPosParams params);

  Response!(string) set(const(ubyte)[] key, const(ubyte)[] value, SetParams params);

  Response!(List!(const(ubyte)[])) srandmember(const(ubyte)[] key, int count);

  Response!(Long) objectRefcount(const(ubyte)[] key);

  Response!(const(ubyte)[]) objectEncoding(const(ubyte)[] key);

  Response!(Long) objectIdletime(const(ubyte)[] key);

  Response!(Double) incrByFloat(const(ubyte)[] key, double increment);

  Response!(string) psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value);

  Response!(Double) hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double increment);

  Response!(Object) sendCommand(ProtocolCommand cmd, const(ubyte)[][] args...);
}
