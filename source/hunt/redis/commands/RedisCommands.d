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
 
module hunt.redis.commands.RedisCommands;

// import hunt.redis.commands.Command;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.BitPosParams;
import hunt.redis.StreamEntryID;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Protocol;
import hunt.redis.StreamPendingEntry;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntry;
import hunt.redis.Tuple;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;

import hunt.Double;
import hunt.Long;

/**
 * Common interface for sharded and non-sharded Redis
 */
interface RedisCommands {
    string set(string key, string value);

    string set(string key, string value, SetParams params);

    string get(string key);

    bool exists(string key);

    Long persist(string key);

    string type(string key);

    const(ubyte)[] dump(string key);

    string restore(string key, int ttl, const(ubyte)[] serializedValue);

    string restoreReplace(string key, int ttl, const(ubyte)[] serializedValue);

    Long expire(string key, int seconds);

    Long pexpire(string key, long milliseconds);

    Long expireAt(string key, long unixTime);

    Long pexpireAt(string key, long millisecondsTimestamp);

    Long ttl(string key);

    Long pttl(string key);

    Long touch(string key);

    bool setbit(string key, long offset, bool value);

    bool setbit(string key, long offset, string value);

    bool getbit(string key, long offset);

    // long setrange(string key, long offset, string value);

    // string getrange(string key, long startOffset, long endOffset);

    // string getSet(string key, string value);

    // long setnx(string key, string value);

    // string setex(string key, int seconds, string value);

    // string psetex(string key, long milliseconds, string value);

    // long decrBy(string key, long decrement);

    // long decr(string key);

    // long incrBy(string key, long increment);

    // Double incrByFloat(string key, double increment);

    // long incr(string key);

    // long append(string key, string value);

    // string substr(string key, int start, int end);

    // long hset(string key, string field, string value);

    // long hset(string key, Map!(string, string) hash);

    // string hget(string key, string field);

    // long hsetnx(string key, string field, string value);

    // string hmset(string key, Map!(string, string) hash);

    // List!(string) hmget(string key, string[] fields...);

    // long hincrBy(string key, string field, long value);

    // Double hincrByFloat(string key, string field, double value);

    // bool hexists(string key, string field);

    // long hdel(string key, string[] field...);

    // long hlen(string key);

    // Set!(string) hkeys(string key);

    // List!(string) hvals(string key);

    // Map!(string, string) hgetAll(string key);

    // long rpush(string key, string[] string...);

    // long lpush(string key, string[] string...);

    // long llen(string key);

    // List!(string) lrange(string key, long start, long stop);

    // string ltrim(string key, long start, long stop);

    // string lindex(string key, long index);

    // string lset(string key, long index, string value);

    // long lrem(string key, long count, string value);

    // string lpop(string key);

    // string rpop(string key);

    // long sadd(string key, string[] member...);

    // Set!(string) smembers(string key);

    // long srem(string key, string[] member...);

    // string spop(string key);

    // Set!(string) spop(string key, long count);

    // long scard(string key);

    // bool sismember(string key, string member);

    // string srandmember(string key);

    // List!(string) srandmember(string key, int count);

    Long strlen(string key);

    // long zadd(string key, double score, string member);

    // long zadd(string key, double score, string member, ZAddParams params);

    // long zadd(string key, Map!(string, double) scoreMembers);

    // long zadd(string key, Map!(string, double) scoreMembers, ZAddParams params);

    // Set!(string) zrange(string key, long start, long stop);

    // long zrem(string key, string[] members...);

    // Double zincrby(string key, double increment, string member);

    // Double zincrby(string key, double increment, string member, ZIncrByParams params);

    // long zrank(string key, string member);

    // long zrevrank(string key, string member);

    // Set!(string) zrevrange(string key, long start, long stop);

    // Set!(Tuple) zrangeWithScores(string key, long start, long stop);

    // Set!(Tuple) zrevrangeWithScores(string key, long start, long stop);

    // long zcard(string key);

    // Double zscore(string key, string member);

    // List!(string) sort(string key);

    // List!(string) sort(string key, SortingParams sortingParameters);

    // long zcount(string key, double min, double max);

    // long zcount(string key, string min, string max);

    // Set!(string) zrangeByScore(string key, double min, double max);

    // Set!(string) zrangeByScore(string key, string min, string max);

    // Set!(string) zrevrangeByScore(string key, double max, double min);

    // Set!(string) zrangeByScore(string key, double min, double max, int offset, int count);

    // Set!(string) zrevrangeByScore(string key, string max, string min);

    // Set!(string) zrangeByScore(string key, string min, string max, int offset, int count);

    // Set!(string) zrevrangeByScore(string key, double max, double min, int offset, int count);

    // Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max);

    // Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min);

    // Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max, int offset, int count);

    // Set!(string) zrevrangeByScore(string key, string max, string min, int offset, int count);

    // Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max);

    // Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min);

    // Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max, int offset, int count);

    // Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min, int offset, int count);

    // Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min, int offset, int count);

    // long zremrangeByRank(string key, long start, long stop);

    // long zremrangeByScore(string key, double min, double max);

    // long zremrangeByScore(string key, string min, string max);

    // long zlexcount(string key, string min, string max);

    // Set!(string) zrangeByLex(string key, string min, string max);

    // Set!(string) zrangeByLex(string key, string min, string max, int offset,
    //     int count);

    // Set!(string) zrevrangeByLex(string key, string max, string min);

    // Set!(string) zrevrangeByLex(string key, string max, string min,
    //     int offset, int count);

    // long zremrangeByLex(string key, string min, string max);

    // long linsert(string key, ListPosition where, string pivot, string value);

    // long lpushx(string key, string[] string...);

    // long rpushx(string key, string[] string...);

    // List!(string) blpop(int timeout, string key);

    // List!(string) brpop(int timeout, string key);

    Long del(string key);

    Long unlink(string key);

    string echo(string string);

    Long move(string key, int dbIndex);

    Long bitcount(string key);

    Long bitcount(string key, long start, long end);

    // long bitpos(string key, bool value);

    // long bitpos(string key, bool value, BitPosParams params);

    // ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor);

    // ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor,
    //     ScanParams params);

    // ScanResult!(string) sscan(string key, string cursor);

    // ScanResult!(Tuple) zscan(string key, string cursor);

    // ScanResult!(Tuple) zscan(string key, string cursor, ScanParams params);

    // ScanResult!(string) sscan(string key, string cursor, ScanParams params);

    Long pfadd(string key, string[] elements...);

    Long pfcount(string key);

    // // Geo Commands

    // long geoadd(string key, double longitude, double latitude, string member);

    // long geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap);

    // Double geodist(string key, string member1, string member2);

    // Double geodist(string key, string member1, string member2, GeoUnit unit);

    // List!(string) geohash(string key, string[] members...);

    // List!(GeoCoordinate) geopos(string key, string[] members...);

    // List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude, double radius,
    //     GeoUnit unit);

    // List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude, double radius,
    //     GeoUnit unit);

    // List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude, double radius,
    //     GeoUnit unit, GeoRadiusParam param);

    // List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude, double radius,
    //     GeoUnit unit, GeoRadiusParam param);

    // List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius, GeoUnit unit);

    // List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit);

    // List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius, GeoUnit unit,
    //     GeoRadiusParam param);

    // List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit,
    //     GeoRadiusParam param);

    // /**
    //  * Executes BITFIELD Redis command
    //  * @param key
    //  * @param arguments
    //  * @return 
    //  */
    // List!(long) bitfield(string key, string[] arguments...);

    // /**
    //  * Used for HSTRLEN Redis command
    //  * @param key 
    //  * @param field
    //  * @return length of the value for key
    //  */
    // long hstrlen(string key, string field);

    // /**
    //  * XADD key ID field string [field string ...]
    //  * 
    //  * @param key
    //  * @param id
    //  * @param hash
    //  * @return the ID of the added entry
    //  */
    // StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash);

    // /**
    //  * XADD key MAXLEN ~ LEN ID field string [field string ...]
    //  * 
    //  * @param key
    //  * @param id
    //  * @param hash
    //  * @param maxLen
    //  * @param approximateLength
    //  * @return
    //  */
    // StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength);

    // /**
    //  * XLEN key
    //  * 
    //  * @param key
    //  * @return
    //  */
    // long xlen(string key);

    // /**
    //  * XRANGE key start end [COUNT count]
    //  * 
    //  * @param key
    //  * @param start minimum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate minimum ID possible in the stream  
    //  * @param end maximum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate maximum ID possible in the stream
    //  * @param count maximum number of entries returned 
    //  * @return The entries with IDs matching the specified range. 
    //  */
    // List!(StreamEntry) xrange(string key, StreamEntryID start, StreamEntryID end, int count);

    // /**
    //  * XREVRANGE key end start [COUNT <n>]
    //  * 
    //  * @param key
    //  * @param start minimum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate minimum ID possible in the stream  
    //  * @param end maximum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate maximum ID possible in the stream
    //  * @param count The entries with IDs matching the specified range. 
    //  * @return the entries with IDs matching the specified range, from the higher ID to the lower ID matching.
    //  */
    // List!(StreamEntry) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count);
        
    // /**
    //  * XACK key group ID [ID ...]
    //  * 
    //  * @param key
    //  * @param group
    //  * @param ids
    //  * @return
    //  */
    // long xack(string key, string group,  StreamEntryID[] ids...);

    // /**
    //  * XGROUP CREATE <key> <groupname> <id or $>
    //  * 
    //  * @param key
    //  * @param groupname
    //  * @param id
    //  * @param makeStream
    //  * @return
    //  */
    // string xgroupCreate( string key, string groupname, StreamEntryID id, bool makeStream);

    // /**
    //  * XGROUP SETID <key> <groupname> <id or $>
    //  * 
    //  * @param key
    //  * @param groupname
    //  * @param id
    //  * @return
    //  */
    // string xgroupSetID( string key, string groupname, StreamEntryID id);

    // /**
    //  * XGROUP DESTROY <key> <groupname>
    //  * 
    //  * @param key
    //  * @param groupname
    //  * @return
    //  */
    // long xgroupDestroy( string key, string groupname);

    // /**
    //  * XGROUP DELCONSUMER <key> <groupname> <consumername> 
    //  * @param key
    //  * @param groupname
    //  * @param consumername
    //  * @return
    //  */
    // string xgroupDelConsumer( string key, string groupname, string consumername);

    // /**
    //  * XPENDING key group [start end count] [consumer]
    //  * 
    //  * @param key
    //  * @param groupname
    //  * @param start
    //  * @param end
    //  * @param count
    //  * @param consumername
    //  * @return
    //  */
    // List!(StreamPendingEntry) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername);

    // /**
    //  * XDEL key ID [ID ...]
    //  * @param key
    //  * @param ids
    //  * @return
    //  */
    // long xdel( string key, StreamEntryID[] ids...);

    // /**
    //  * XTRIM key MAXLEN [~] count
    //  * @param key
    //  * @param maxLen
    //  * @param approximate
    //  * @return
    //  */
    // long xtrim( string key, long maxLen, bool approximate);

    // /**
    //  *  XCLAIM <key> <group> <consumer> <min-idle-time> <ID-1> <ID-2>
    //  *        [IDLE <milliseconds>] [TIME <mstime>] [RETRYCOUNT <count>]
    //  *        [FORCE] [JUSTID]
    //  */        
    // List!(StreamEntry) xclaim( string key, string group, string consumername, long minIdleTime, 
    //     Long newIdleTime, int retries, bool force, StreamEntryID[] ids...);


    // Object sendCommand(ProtocolCommand cmd, string[] args...);
}