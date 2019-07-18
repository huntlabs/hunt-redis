module hunt.redis.commands.RedisPipeline;

import hunt.redis.Protocol;

import hunt.redis.StreamEntryID;
import hunt.redis.BitPosParams;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.StreamPendingEntry;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntry;
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


interface RedisPipeline {
  Response!(Long) append(string key, string value);

  Response!(List!(string)) blpop(string arg);

  Response!(List!(string)) brpop(string arg);

  Response!(Long) decr(string key);

  Response!(Long) decrBy(string key, long decrement);

  Response!(Long) del(string key);

  Response!(Long) unlink(string key);

  Response!(string) echo(string string);

  Response!(Boolean) exists(string key);

  Response!(Long) expire(string key, int seconds);

  Response!(Long) pexpire(string key, long milliseconds);

  Response!(Long) expireAt(string key, long unixTime);

  Response!(Long) pexpireAt(string key, long millisecondsTimestamp);

  Response!(string) get(string key);

  Response!(Boolean) getbit(string key, long offset);

  Response!(string) getrange(string key, long startOffset, long endOffset);

  Response!(string) getSet(string key, string value);

  Response!(Long) hdel(string key, string[] field...);

  Response!(Boolean) hexists(string key, string field);

  Response!(string) hget(string key, string field);

  Response!(Map!(string, string)) hgetAll(string key);

  Response!(Long) hincrBy(string key, string field, long value);

  Response!(Set!(string)) hkeys(string key);

  Response!(Long) hlen(string key);

  Response!(List!(string)) hmget(string key, string[] fields...);

  Response!(string) hmset(string key, Map!(string, string) hash);

  Response!(Long) hset(string key, string field, string value);

  Response!(Long) hset(string key, Map!(string, string) hash);

  Response!(Long) hsetnx(string key, string field, string value);

  Response!(List!(string)) hvals(string key);

  Response!(Long) incr(string key);

  Response!(Long) incrBy(string key, long increment);

  Response!(string) lindex(string key, long index);

  Response!(Long) linsert(string key, ListPosition where, string pivot, string value);

  Response!(Long) llen(string key);

  Response!(string) lpop(string key);

  Response!(Long) lpush(string key, string[] string...);

  Response!(Long) lpushx(string key, string[] string...);

  Response!(List!(string)) lrange(string key, long start, long stop);

  Response!(Long) lrem(string key, long count, string value);

  Response!(string) lset(string key, long index, string value);

  Response!(string) ltrim(string key, long start, long stop);

  Response!(Long) move(string key, int dbIndex);

  Response!(Long) persist(string key);

  Response!(string) rpop(string key);

  Response!(Long) rpush(string key, string[] string...);

  Response!(Long) rpushx(string key, string[] string...);

  Response!(Long) sadd(string key, string[] member...);

  Response!(Long) scard(string key);

  Response!(Boolean) sismember(string key, string member);

  Response!(string) set(string key, string value);

  Response!(Boolean) setbit(string key, long offset, bool value);

  Response!(string) setex(string key, int seconds, string value);

  Response!(Long) setnx(string key, string value);

  Response!(Long) setrange(string key, long offset, string value);

  Response!(Set!(string)) smembers(string key);

  Response!(List!(string)) sort(string key);

  Response!(List!(string)) sort(string key, SortingParams sortingParameters);

  Response!(string) spop(string key);

  Response!(Set!(string)) spop(string key, long count);

  Response!(string) srandmember(string key);

  Response!(Long) srem(string key, string[] member...);

  Response!(Long) strlen(string key);

  Response!(string) substr(string key, int start, int end);

  Response!(Long) touch(string key);

  Response!(Long) ttl(string key);

  Response!(Long) pttl(string key);

  Response!(string) type(string key);

  Response!(Long) zadd(string key, double score, string member);

  Response!(Long) zadd(string key, double score, string member, ZAddParams params);

  Response!(Long) zadd(string key, Map!(string, double) scoreMembers);

  Response!(Long) zadd(string key, Map!(string, double) scoreMembers, ZAddParams params);

  Response!(Long) zcard(string key);

  Response!(Long) zcount(string key, double min, double max);

  Response!(Long) zcount(string key, string min, string max);

  Response!(Double) zincrby(string key, double increment, string member);

  Response!(Double) zincrby(string key, double increment, string member, ZIncrByParams params);

  Response!(Set!(string)) zrange(string key, long start, long stop);

  Response!(Set!(string)) zrangeByScore(string key, double min, double max);

  Response!(Set!(string)) zrangeByScore(string key, string min, string max);

  Response!(Set!(string)) zrangeByScore(string key, double min, double max, int offset, int count);

  Response!(Set!(string)) zrangeByScore(string key, string min, string max, int offset, int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max, int offset,
      int count);

  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min);

  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min);

  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min, int offset, int count);

  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min, int offset, int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min, int offset,
      int count);

  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min, int offset,
      int count);

  Response!(Set!(Tuple)) zrangeWithScores(string key, long start, long stop);

  Response!(Long) zrank(string key, string member);

  Response!(Long) zrem(string key, string[] members...);

  Response!(Long) zremrangeByRank(string key, long start, long stop);

  Response!(Long) zremrangeByScore(string key, double min, double max);

  Response!(Long) zremrangeByScore(string key, string min, string max);

  Response!(Set!(string)) zrevrange(string key, long start, long stop);

  Response!(Set!(Tuple)) zrevrangeWithScores(string key, long start, long stop);

  Response!(Long) zrevrank(string key, string member);

  Response!(Double) zscore(string key, string member);

  Response!(Long) zlexcount(string key, string min, string max);

  Response!(Set!(string)) zrangeByLex(string key, string min, string max);

  Response!(Set!(string)) zrangeByLex(string key, string min, string max,
      int offset, int count);

  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min);

  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min,
      int offset, int count);

  Response!(Long) zremrangeByLex(string key, string min, string max);

  Response!(Long) bitcount(string key);

  Response!(Long) bitcount(string key, long start, long end);

  Response!(Long) pfadd(string key, string[] elements...);

  Response!(Long) pfcount(string key);
  
  Response!(List!(Long)) bitfield(string key, string[] arguments...);
  
  Response!(Long) hstrlen(string key, string field);

  Response!(string) dump(string key);

  Response!(string) restore(string key, int ttl, string serializedValue);

  Response!(string) restoreReplace(string key, int ttl, string serializedValue);

  Response!(string) migrate(string host, int port, string key, int destinationDB, int timeout);

  // Geo Commands

  Response!(Long) geoadd(string key, double longitude, double latitude, string member);

  Response!(Long) geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap);

  Response!(Double) geodist(string key, string member1, string member2);

  Response!(Double) geodist(string key, string member1, string member2, GeoUnit unit);

  Response!(List!(string)) geohash(string key, string[] members...);

  Response!(List!(GeoCoordinate)) geopos(string key, string[] members...);

  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member, double radius,
      GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member, double radius,
      GeoUnit unit);

  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member, double radius,
      GeoUnit unit, GeoRadiusParam param);

  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member, double radius,
      GeoUnit unit, GeoRadiusParam param);
  
  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash);

  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength);
  
  Response!(Long) xlen(string key);

  Response!(List!(StreamEntry)) xrange(string key, StreamEntryID start, StreamEntryID end, int count);

  Response!(List!(StreamEntry)) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count);
   
  Response!(Long) xack(string key, string group,  StreamEntryID[] ids...);
  
  Response!(string) xgroupCreate( string key, string groupname, StreamEntryID id, bool makeStream);
  
  Response!(string) xgroupSetID( string key, string groupname, StreamEntryID id);
  
  Response!(Long) xgroupDestroy( string key, string groupname);
  
  Response!(string) xgroupDelConsumer( string key, string groupname, string consumername);

  Response!(List!(StreamPendingEntry)) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername);
  
  Response!(Long) xdel( string key, StreamEntryID[] ids...);
  
  Response!(Long) xtrim( string key, long maxLen, bool approximateLength);
 
  Response!(List!(StreamEntry)) xclaim( string key, string group, string consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, StreamEntryID[] ids...);

  Response!(Long) bitpos(string key, bool value);

  Response!(Long) bitpos(string key, bool value, BitPosParams params);

  Response!(string) set(string key, string value, SetParams params);

  Response!(List!(string)) srandmember(string key, int count);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max);

  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max, int offset,
      int count);

  Response!(Long) objectRefcount(string key);

  Response!(string) objectEncoding(string key);

  Response!(Long) objectIdletime(string key);

  Response!(Double) incrByFloat(string key, double increment);

  Response!(string) psetex(string key, long milliseconds, string value);

  Response!(Double) hincrByFloat(string key, string field, double increment);

  Response!(Object) sendCommand(ProtocolCommand cmd, string[] args...);
}
