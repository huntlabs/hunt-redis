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
 
module hunt.redis.commands.BinaryRedisCommands;

import hunt.redis.Protocol;

import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

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

import hunt.Double;

/**
 * Common interface for sharded and non-sharded BinaryRedis
 */
interface BinaryRedisCommands {
  string set(const(ubyte)[] key, const(ubyte)[] value);

  string set(const(ubyte)[] key, const(ubyte)[] value, SetParams params);

  const(ubyte)[] get(const(ubyte)[] key);

  bool exists(const(ubyte)[] key);

  long persist(const(ubyte)[] key);

  string type(const(ubyte)[] key);

  const(ubyte)[] dump(const(ubyte)[] key);

  string restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue);

  string restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue);

  long expire(const(ubyte)[] key, int seconds);

  long pexpire(const(ubyte)[] key, long milliseconds);

  long expireAt(const(ubyte)[] key, long unixTime);

  long pexpireAt(const(ubyte)[] key, long millisecondsTimestamp);

  long ttl(const(ubyte)[] key);

  long pttl(const(ubyte)[] key);

  long touch(const(ubyte)[] key);

  bool setbit(const(ubyte)[] key, long offset, bool value);

  bool setbit(const(ubyte)[] key, long offset, const(ubyte)[] value);

  bool getbit(const(ubyte)[] key, long offset);

  long setrange(const(ubyte)[] key, long offset, const(ubyte)[] value);

  const(ubyte)[] getrange(const(ubyte)[] key, long startOffset, long endOffset);

  const(ubyte)[] getSet(const(ubyte)[] key, const(ubyte)[] value);

  long setnx(const(ubyte)[] key, const(ubyte)[] value);

  string setex(const(ubyte)[] key, int seconds, const(ubyte)[] value);

  string psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value);

  long decrBy(const(ubyte)[] key, long decrement);

  long decr(const(ubyte)[] key);

  long incrBy(const(ubyte)[] key, long increment);

  Double incrByFloat(const(ubyte)[] key, double increment);

  long incr(const(ubyte)[] key);

  long append(const(ubyte)[] key, const(ubyte)[] value);

  const(ubyte)[] substr(const(ubyte)[] key, int start, int end);

  long hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

  long hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

  const(ubyte)[] hget(const(ubyte)[] key, const(ubyte)[] field);

  long hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value);

  string hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash);

  List!(const(ubyte)[]) hmget(const(ubyte)[] key, const(ubyte)[][] fields...);

  long hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value);

  Double hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double value);

  bool hexists(const(ubyte)[] key, const(ubyte)[] field);

  long hdel(const(ubyte)[] key, const(ubyte)[][] field...);

  long hlen(const(ubyte)[] key);

  Set!(const(ubyte)[]) hkeys(const(ubyte)[] key);

  Collection!(const(ubyte)[]) hvals(const(ubyte)[] key);

  Map!(const(ubyte)[], const(ubyte)[]) hgetAll(const(ubyte)[] key);

  long rpush(const(ubyte)[] key, const(ubyte)[][] args...);

  long lpush(const(ubyte)[] key, const(ubyte)[][] args...);

  long llen(const(ubyte)[] key);

  List!(const(ubyte)[]) lrange(const(ubyte)[] key, long start, long stop);

  string ltrim(const(ubyte)[] key, long start, long stop);

  const(ubyte)[] lindex(const(ubyte)[] key, long index);

  string lset(const(ubyte)[] key, long index, const(ubyte)[] value);

  long lrem(const(ubyte)[] key, long count, const(ubyte)[] value);

  const(ubyte)[] lpop(const(ubyte)[] key);

  const(ubyte)[] rpop(const(ubyte)[] key);

  long sadd(const(ubyte)[] key, const(ubyte)[][] member...);

  Set!(const(ubyte)[]) smembers(const(ubyte)[] key);

  long srem(const(ubyte)[] key, const(ubyte)[][] member...);

  const(ubyte)[] spop(const(ubyte)[] key);

  Set!(const(ubyte)[]) spop(const(ubyte)[] key, long count);

  long scard(const(ubyte)[] key);

  bool sismember(const(ubyte)[] key, const(ubyte)[] member);

  const(ubyte)[] srandmember(const(ubyte)[] key);

  List!(const(ubyte)[]) srandmember(const(ubyte)[] key, int count);

  long strlen(const(ubyte)[] key);

  long zadd(const(ubyte)[] key, double score, const(ubyte)[] member);

  long zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params);

  long zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers);

  long zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers, ZAddParams params);

  Set!(const(ubyte)[]) zrange(const(ubyte)[] key, long start, long stop);

  long zrem(const(ubyte)[] key, const(ubyte)[][] members...);

  Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member);

  Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params);

  long zrank(const(ubyte)[] key, const(ubyte)[] member);

  long zrevrank(const(ubyte)[] key, const(ubyte)[] member);

  Set!(const(ubyte)[]) zrevrange(const(ubyte)[] key, long start, long stop);

  Set!(Tuple) zrangeWithScores(const(ubyte)[] key, long start, long stop);

  Set!(Tuple) zrevrangeWithScores(const(ubyte)[] key, long start, long stop);

  long zcard(const(ubyte)[] key);

  Double zscore(const(ubyte)[] key, const(ubyte)[] member);

  List!(const(ubyte)[]) sort(const(ubyte)[] key);

  List!(const(ubyte)[]) sort(const(ubyte)[] key, SortingParams sortingParameters);

  long zcount(const(ubyte)[] key, double min, double max);

  long zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max);

  Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min);

  Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max, int offset, int count);

  Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count);

  Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min, int offset, int count);

  Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max);

  Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min);

  Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max, int offset, int count);

  Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count);

  Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count);

  Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min, int offset, int count);

  Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count);

  long zremrangeByRank(const(ubyte)[] key, long start, long stop);

  long zremrangeByScore(const(ubyte)[] key, double min, double max);

  long zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  long zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
      int count);

  Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min);

  Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset,
      int count);

  long zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max);

  long linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot, const(ubyte)[] value);

  long lpushx(const(ubyte)[] key, const(ubyte)[][] arg...);

  long rpushx(const(ubyte)[] key, const(ubyte)[][] arg...);

  long del(const(ubyte)[] key);

  long unlink(const(ubyte)[] key);

  const(ubyte)[] echo(const(ubyte)[] arg);

  long move(const(ubyte)[] key, int dbIndex);

  long bitcount(const(ubyte)[] key);

  long bitcount(const(ubyte)[] key, long start, long end);

  long pfadd(const(ubyte)[] key, const(ubyte)[][] elements...);

  long pfcount(const(ubyte)[] key);

  // Geo Commands

  long geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member);

  long geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap);

  Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2);

  Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit);

  List!(const(ubyte)[]) geohash(const(ubyte)[] key, const(ubyte)[][] members...);

  List!(GeoCoordinate) geopos(const(ubyte)[] key, const(ubyte)[][] members...);

  List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude, double radius,
      GeoUnit unit);

  List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius,
      GeoUnit unit);

  List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude, double radius,
      GeoUnit unit, GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius,
      GeoUnit unit, GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit);

  List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit);

  List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
      GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
      GeoRadiusParam param);

  ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor);

  ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

  ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor);

  ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

  ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor);

  ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params);

  /**
   * Executes BITFIELD Redis command
   * @param key
   * @param arguments
   * @return 
   */
  List!(long) bitfield(const(ubyte)[] key, const(ubyte)[][] arguments...);
  
  /**
   * Used for HSTRLEN Redis command
   * @param key 
   * @param field
   * @return lenth of the value for key
   */
  long hstrlen(const(ubyte)[] key, const(ubyte)[] field);
  
  
  const(ubyte)[] xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength);

  long xlen(const(ubyte)[] key);
 
  List!(const(ubyte)[]) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count);

  List!(const(ubyte)[]) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count);

  long xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...);
 
  string xgroupCreate(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id, bool makeStream);

  string xgroupSetID(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id);

  long xgroupDestroy(const(ubyte)[] key, const(ubyte)[] consumer);

  string xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] consumerName);
 
  long xdel(const(ubyte)[] key, const(ubyte)[][] ids...);

  long xtrim(const(ubyte)[] key, long maxLen, bool approximateLength);

  List!(const(ubyte)[]) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername);

  List!(const(ubyte)[]) xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, long minIdleTime, long newIdleTime, int retries, bool force, const(ubyte)[][] ids);

  Object sendCommand(ProtocolCommand cmd, const(ubyte)[][] args...);
}
