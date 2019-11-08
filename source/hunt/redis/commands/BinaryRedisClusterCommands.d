/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.redis.commands.BinaryRedisClusterCommands;

import hunt.redis.Protocol;

import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.Tuple;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;

import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Double;
import hunt.Long;

interface BinaryRedisClusterCommands {
  string set(const(ubyte)[] key, const(ubyte)[] value);

  string set(const(ubyte)[] key, const(ubyte)[] value, SetParams params);

  const(ubyte)[] get(const(ubyte)[] key);

  // bool exists(const(ubyte)[] key);

  long persist(const(ubyte)[] key);

  string type(const(ubyte)[] key);

  // const(ubyte)[] dump(const(ubyte)[] key);

  // string restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue);

  // Long expire(const(ubyte)[] key, int seconds);

//   Long pexpire(const(ubyte)[] key, long milliseconds);

//   Long expireAt(const(ubyte)[] key, long unixTime);

//   Long pexpireAt(const(ubyte)[] key, long millisecondsTimestamp);

//   Long ttl(const(ubyte)[] key);

//   Long pttl(const(ubyte)[] key);

//   Long touch(const(ubyte)[] key);

//   bool setbit(const(ubyte)[] key, long offset, bool value);

//   bool setbit(const(ubyte)[] key, long offset, const(ubyte)[] value);

//   bool getbit(const(ubyte)[] key, long offset);

//   Long setrange(const(ubyte)[] key, long offset, const(ubyte)[] value);

//   const(ubyte)[] getrange(const(ubyte)[] key, long startOffset, long endOffset);

//   const(ubyte)[] getSet(const(ubyte)[] key, const(ubyte)[] value);

//   Long setnx(const(ubyte)[] key, const(ubyte)[] value);

//   string setex(const(ubyte)[] key, int seconds, const(ubyte)[] value);

//   string psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value);

//   Long decrBy(const(ubyte)[] key, long decrement);

//   Long decr(const(ubyte)[] key);

//   Long incrBy(const(ubyte)[] key, long increment);

//   Double incrByFloat(const(ubyte)[] key, double increment);

//   Long incr(const(ubyte)[] key);

//   Long append(const(ubyte)[] key, const(ubyte)[] value);

//   const(ubyte)[] substr(const(ubyte)[] key, int start, int end);

//   Long hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

//   Long hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

//   const(ubyte)[] hget(const(ubyte)[] key, const(ubyte)[] field);

//   Long hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

//   string hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

//   List!(const(ubyte)[]) hmget(const(ubyte)[] key, const(ubyte)[][] fields...);

//   Long hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value);

//   Double hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double value);

//   bool hexists(const(ubyte)[] key, const(ubyte)[] field);

//   Long hdel(const(ubyte)[] key, const(ubyte)[][] field...);

//   Long hlen(const(ubyte)[] key);

//   Set!(const(ubyte)[]) hkeys(const(ubyte)[] key);

//   Collection!(const(ubyte)[]) hvals(const(ubyte)[] key);

//   Map!(const(ubyte)[], const(ubyte)[]) hgetAll(const(ubyte)[] key);

//   Long rpush(const(ubyte)[] key, const(ubyte)[][] args...);

//   Long lpush(const(ubyte)[] key, const(ubyte)[][] args...);

//   Long llen(const(ubyte)[] key);

//   List!(const(ubyte)[]) lrange(const(ubyte)[] key, long start, long stop);

//   string ltrim(const(ubyte)[] key, long start, long stop);

//   const(ubyte)[] lindex(const(ubyte)[] key, long index);

//   string lset(const(ubyte)[] key, long index, const(ubyte)[] value);

//   Long lrem(const(ubyte)[] key, long count, const(ubyte)[] value);

//   const(ubyte)[] lpop(const(ubyte)[] key);

//   const(ubyte)[] rpop(const(ubyte)[] key);

//   Long sadd(const(ubyte)[] key, const(ubyte)[][] member...);

//   Set!(const(ubyte)[]) smembers(const(ubyte)[] key);

//   Long srem(const(ubyte)[] key, const(ubyte)[][] member...);

//   const(ubyte)[] spop(const(ubyte)[] key);

//   Set!(const(ubyte)[]) spop(const(ubyte)[] key, long count);

//   Long scard(const(ubyte)[] key);

//   bool sismember(const(ubyte)[] key, const(ubyte)[] member);

//   const(ubyte)[] srandmember(const(ubyte)[] key);

//   List!(const(ubyte)[]) srandmember(const(ubyte)[] key, int count);

//   Long strlen(const(ubyte)[] key);

//   Long zadd(const(ubyte)[] key, double score, const(ubyte)[] member);

//   Long zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params);

//   Long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers);

//   Long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers, ZAddParams params);

//   Set!(const(ubyte)[]) zrange(const(ubyte)[] key, long start, long stop);

//   Long zrem(const(ubyte)[] key, const(ubyte)[][] members...);

//   Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member);

//   Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params);

//   Long zrank(const(ubyte)[] key, const(ubyte)[] member);

//   Long zrevrank(const(ubyte)[] key, const(ubyte)[] member);

//   Set!(const(ubyte)[]) zrevrange(const(ubyte)[] key, long start, long stop);

//   Set!(Tuple) zrangeWithScores(const(ubyte)[] key, long start, long stop);

//   Set!(Tuple) zrevrangeWithScores(const(ubyte)[] key, long start, long stop);

//   Long zcard(const(ubyte)[] key);

//   Double zscore(const(ubyte)[] key, const(ubyte)[] member);

//   List!(const(ubyte)[]) sort(const(ubyte)[] key);

//   List!(const(ubyte)[]) sort(const(ubyte)[] key, SortingParams sortingParameters);

//   Long zcount(const(ubyte)[] key, double min, double max);

//   Long zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max);

//   Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min);

//   Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max, int offset, int count);

//   Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

//   Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count);

//   Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min, int offset, int count);

//   Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max);

//   Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min);

//   Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max, int offset, int count);

//   Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count);

//   Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

//   Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count);

//   Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min, int offset, int count);

//   Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count);

//   Long zremrangeByRank(const(ubyte)[] key, long start, long stop);

//   Long zremrangeByScore(const(ubyte)[] key, double min, double max);

//   Long zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Long zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
//       int count);

//   Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

//   Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset,
//       int count);

//   Long zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

//   Long linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot, const(ubyte)[] value);

//   Long lpushx(const(ubyte)[] key, const(ubyte)[][] arg...);

//   Long rpushx(const(ubyte)[] key, const(ubyte)[][] arg...);

//   Long del(const(ubyte)[] key);

//   Long unlink(const(ubyte)[] key);

//   const(ubyte)[] echo(const(ubyte)[] arg);

//   Long bitcount(const(ubyte)[] key);

//   Long bitcount(const(ubyte)[] key, long start, long end);

//   Long pfadd(const(ubyte)[] key, const(ubyte)[][] elements...);

//   long pfcount(const(ubyte)[] key);

//   // Geo Commands

//   Long geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member);

//   Long geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap);

//   Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2);

//   Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit);

//   List!(const(ubyte)[]) geohash(const(ubyte)[] key, const(ubyte)[][] members...);

//   List!(GeoCoordinate) geopos(const(ubyte)[] key, const(ubyte)[][] members...);

//   List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude, double radius,
//       GeoUnit unit);

//   List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius,
//       GeoUnit unit);

//   List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude, double radius,
//       GeoUnit unit, GeoRadiusParam param);

//   List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius,
//       GeoUnit unit, GeoRadiusParam param);

//   List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit);

//   List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit);

//   List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
//       GeoRadiusParam param);

//   List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
//       GeoRadiusParam param);

//   ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor);

//   ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

//   ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor);

//   ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

//   ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor);

//   ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

//   /**
//    * Executes BITFIELD Redis command
//    * @param key
//    * @param arguments
//    * @return 
//    */
//   List!(Long) bitfield(const(ubyte)[] key, const(ubyte)[][] arguments...);
  
//   /**
//    * Used for HSTRLEN Redis command
//    * @param key 
//    * @param field
//    * @return 
//    */
//   Long hstrlen(const(ubyte)[] key, const(ubyte)[] field);
  
//   const(ubyte)[] xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength);

//   Long xlen(const(ubyte)[] key);
 
//   List!(const(ubyte)[]) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count);

//   List!(const(ubyte)[]) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count);

//   Long xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...);
 
//   string xgroupCreate(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id, bool makeStream);

//   string xgroupSetID(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id);

//   Long xgroupDestroy(const(ubyte)[] key, const(ubyte)[] consumer);

//   string xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] consumerName);
 
//   Long xdel(const(ubyte)[] key, const(ubyte)[][] ids...);

//   Long xtrim(const(ubyte)[] key, long maxLen, bool approximateLength);

//   List!(const(ubyte)[]) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername);

//   List!(const(ubyte)[]) xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, long minIdleTime, long newIdleTime, int retries, bool force, const(ubyte)[][] ids);

//   Long waitReplicas(const(ubyte)[] key, int replicas, long timeout);

//   Object sendCommand(const(ubyte)[] sampleKey, ProtocolCommand cmd, const(ubyte)[][] args...);
}
