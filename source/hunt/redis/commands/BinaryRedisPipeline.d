module hunt.redis.commands.BinaryRedisPipeline;

import hunt.redis.commands.ProtocolCommand;

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
  Response!(Long) append(byte[] key, byte[] value);

  Response!(List!(byte[])) blpop(byte[] arg);

  Response!(List!(byte[])) brpop(byte[] arg);

  Response!(Long) decr(byte[] key);

  Response!(Long) decrBy(byte[] key, long decrement);

  Response!(Long) del(byte[] keys);

  Response!(Long) unlink(byte[] keys);

  Response!(byte[]) echo(byte[] string);

  Response!(Boolean) exists(byte[] key);

  Response!(Long) expire(byte[] key, int seconds);

  Response!(Long) pexpire(byte[] key, long milliseconds);

  Response!(Long) expireAt(byte[] key, long unixTime);

  Response!(Long) pexpireAt(byte[] key, long millisecondsTimestamp);

  Response!(byte[]) get(byte[] key);

  Response!(Boolean) getbit(byte[] key, long offset);

  Response!(byte[]) getSet(byte[] key, byte[] value);

  Response!(byte[]) getrange(byte[] key, long startOffset, long endOffset);

  Response!(Long) hdel(byte[] key, byte[] field...);

  Response!(Boolean) hexists(byte[] key, byte[] field);

  Response!(byte[]) hget(byte[] key, byte[] field);

  Response!(Map!(byte[], byte[])) hgetAll(byte[] key);

  Response!(Long) hincrBy(byte[] key, byte[] field, long value);

  Response!(Set!(byte[])) hkeys(byte[] key);

  Response!(Long) hlen(byte[] key);

  Response!(List!(byte[])) hmget(byte[] key, byte[] fields...);

  Response!(string) hmset(byte[] key, Map!(byte[], byte[]) hash);

  Response!(Long) hset(byte[] key, byte[] field, byte[] value);

  Response!(Long) hset(byte[] key, Map!(byte[], byte[]) hash);

  Response!(Long) hsetnx(byte[] key, byte[] field, byte[] value);

  Response!(List!(byte[])) hvals(byte[] key);

  Response!(Long) incr(byte[] key);

  Response!(Long) incrBy(byte[] key, long increment);

  Response!(byte[]) lindex(byte[] key, long index);

  Response!(Long) linsert(byte[] key, ListPosition where, byte[] pivot, byte[] value);

  Response!(Long) llen(byte[] key);

  Response!(byte[]) lpop(byte[] key);

  Response!(Long) lpush(byte[] key, byte[] string...);

  Response!(Long) lpushx(byte[] key, byte[] bytes...);

  Response!(List!(byte[])) lrange(byte[] key, long start, long stop);

  Response!(Long) lrem(byte[] key, long count, byte[] value);

  Response!(string) lset(byte[] key, long index, byte[] value);

  Response!(string) ltrim(byte[] key, long start, long stop);

  Response!(Long) move(byte[] key, int dbIndex);

  Response!(Long) persist(byte[] key);

  Response!(byte[]) rpop(byte[] key);

  Response!(Long) rpush(byte[] key, byte[] string...);

  Response!(Long) rpushx(byte[] key, byte[] string...);

  Response!(Long) sadd(byte[] key, byte[] member...);

  Response!(Long) scard(byte[] key);

  Response!(string) set(byte[] key, byte[] value);

  Response!(Boolean) setbit(byte[] key, long offset, byte[] value);

  Response!(Long) setrange(byte[] key, long offset, byte[] value);

  Response!(string) setex(byte[] key, int seconds, byte[] value);

  Response!(Long) setnx(byte[] key, byte[] value);

  Response!(Long) setrange(string key, long offset, string value);

  Response!(Set!(byte[])) smembers(byte[] key);

  Response!(Boolean) sismember(byte[] key, byte[] member);

  Response!(List!(byte[])) sort(byte[] key);

  Response!(List!(byte[])) sort(byte[] key, SortingParams sortingParameters);

  Response!(byte[]) spop(byte[] key);

  Response!(Set!(byte[])) spop(byte[] key, long count);

  Response!(byte[]) srandmember(byte[] key);

  Response!(Long) srem(byte[] key, byte[] member...);

  Response!(Long) strlen(byte[] key);

  Response!(string) substr(byte[] key, int start, int end);

  Response!(Long) touch(byte[] keys);

  Response!(Long) ttl(byte[] key);

  Response!(Long) pttl(byte[] key);

  Response!(string) type(byte[] key);

  Response!(Long) zadd(byte[] key, double score, byte[] member);

  Response!(Long) zadd(byte[] key, double score, byte[] member, ZAddParams params);

  Response!(Long) zadd(byte[] key, Map!(byte[], Double) scoreMembers);

  Response!(Long) zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params);

  Response!(Long) zcard(byte[] key);

  Response!(Long) zcount(byte[] key, double min, double max);

  Response!(Long) zcount(byte[] key, byte[] min, byte[] max);

  Response!(Double) zincrby(byte[] key, double increment, byte[] member);

  Response!(Double) zincrby(byte[] key, double increment, byte[] member, ZIncrByParams params);

  Response!(Set!(byte[])) zrange(byte[] key, long start, long stop);

  Response!(Set!(byte[])) zrangeByScore(byte[] key, double min, double max);

  Response!(Set!(byte[])) zrangeByScore(byte[] key, byte[] min, byte[] max);

  Response!(Set!(byte[])) zrangeByScore(byte[] key, double min, double max, int offset, int count);

  Response!(Set!(byte[])) zrangeByScore(byte[] key, byte[] min, byte[] max, int offset, int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, double min, double max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, double min, double max, int offset,
      int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max, int offset,
      int count);

  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, double max, double min);

  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, byte[] max, byte[] min);

  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, double max, double min, int offset, int count);

  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, byte[] max, byte[] min, int offset, int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, double max, double min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, double max, double min, int offset,
      int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min, int offset,
      int count);

  Response!(Set!(Tuple)) zrangeWithScores(byte[] key, long start, long stop);

  Response!(Long) zrank(byte[] key, byte[] member);

  Response!(Long) zrem(byte[] key, byte[] members...);

  Response!(Long) zremrangeByRank(byte[] key, long start, long stop);

  Response!(Long) zremrangeByScore(byte[] key, double min, double max);

  Response!(Long) zremrangeByScore(byte[] key, byte[] min, byte[] max);

  Response!(Set!(byte[])) zrevrange(byte[] key, long start, long stop);

  Response!(Set!(Tuple)) zrevrangeWithScores(byte[] key, long start, long stop);

  Response!(Long) zrevrank(byte[] key, byte[] member);

  Response!(Double) zscore(byte[] key, byte[] member);

  Response!(Long) zlexcount(byte[] key, byte[] min, byte[] max);

  Response!(Set!(byte[])) zrangeByLex(byte[] key, byte[] min, byte[] max);

  Response!(Set!(byte[])) zrangeByLex(byte[] key, byte[] min, byte[] max,
      int offset, int count);

  Response!(Set!(byte[])) zrevrangeByLex(byte[] key, byte[] max, byte[] min);

  Response!(Set!(byte[])) zrevrangeByLex(byte[] key, byte[] max, byte[] min,
      int offset, int count);

  Response!(Long) zremrangeByLex(byte[] key, byte[] min, byte[] max);

  Response!(Long) bitcount(byte[] key);

  Response!(Long) bitcount(byte[] key, long start, long end);

  Response!(Long) pfadd(byte[] key, byte[] elements...);

  Response!(Long) pfcount(byte[] key);

  Response!(byte[]) dump(byte[] key);

  Response!(string) restore(byte[] key, int ttl, byte[] serializedValue);

  Response!(string) restoreReplace(byte[] key, int ttl, byte[] serializedValue);

  Response!(string) migrate(string host, int port, byte[] key, int destinationDB, int timeout);

  // Geo Commands

  Response!(Long) geoadd(byte[] key, double longitude, double latitude, byte[] member);

  Response!(Long) geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap);

  Response!(Double) geodist(byte[] key, byte[] member1, byte[] member2);

  Response!(Double) geodist(byte[] key, byte[] member1, byte[] member2, GeoUnit unit);

  Response!(List!(byte[])) geohash(byte[] key, byte[] members...);

  Response!(List!(GeoCoordinate)) geopos(byte[] key, byte[] members...);

  Response!(List!(GeoRadiusResponse)) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMember(byte[] key, byte[] member, double radius,
      GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(byte[] key, byte[] member, double radius,
      GeoUnit unit);
  
  Response!(List!(GeoRadiusResponse)) georadiusByMember(byte[] key, byte[] member, double radius,
      GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(byte[] key, byte[] member, double radius,
      GeoUnit unit, GeoRadiusParam param);

  Response!(List!(Long)) bitfield(byte[] key, byte[] elements...);

  Response!(Long) hstrlen(byte[] key, byte[] field);
  
  Response!(byte[]) xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash);

  Response!(byte[]) xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength);
  
  Response!(Long) xlen(byte[] key);

  Response!(List!(byte[])) xrange(byte[] key, byte[] start, byte[] end, int count);

  Response!(List!(byte[])) xrevrange(byte[] key, byte[] end, byte[] start, int count);
   
  Response!(Long) xack(byte[] key, byte[] group,  byte[] ids...);
  
  Response!(string) xgroupCreate(byte[] key, byte[] groupname, byte[] id, bool makeStream);
  
  Response!(string) xgroupSetID(byte[] key, byte[] groupname, byte[] id);
  
  Response!(Long) xgroupDestroy(byte[] key, byte[] groupname);
  
  Response!(string) xgroupDelConsumer(byte[] key, byte[] groupname, byte[] consumername);

  Response!(List!(StreamPendingEntry)) xpending(byte[] key, byte[] groupname, byte[] start, byte[] end, int count, byte[] consumername);
  
  Response!(Long) xdel(byte[] key, byte[] ids...);
  
  Response!(Long) xtrim(byte[] key, long maxLen, bool approximateLength);
 
  Response!(List!(byte[])) xclaim(byte[] key, byte[] group, byte[] consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, byte[] ids...);

  Response!(Long) bitpos(byte[] key, bool value);

  Response!(Long) bitpos(byte[] key, bool value, BitPosParams params);

  Response!(string) set(byte[] key, byte[] value, SetParams params);

  Response!(List!(byte[])) srandmember(byte[] key, int count);

  Response!(Long) objectRefcount(byte[] key);

  Response!(byte[]) objectEncoding(byte[] key);

  Response!(Long) objectIdletime(byte[] key);

  Response!(Double) incrByFloat(byte[] key, double increment);

  Response!(string) psetex(byte[] key, long milliseconds, byte[] value);

  Response!(Double) hincrByFloat(byte[] key, byte[] field, double increment);

  Response!(Object) sendCommand(ProtocolCommand cmd, byte[] args...);
}
