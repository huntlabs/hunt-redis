module hunt.redis.commands.RedisCommands;

// import hunt.redis.commands.Command;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.Boolean;
import hunt.Double;
import hunt.Long;

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


/**
 * Common interface for sharded and non-sharded Redis
 */
interface RedisCommands {
  string set(string key, string value);

  string set(string key, string value, SetParams params);

  string get(string key);

  Boolean exists(string key);

  Long persist(string key);

  string type(string key);

  byte[] dump(string key);

  string restore(string key, int ttl, byte[] serializedValue);

  string restoreReplace(string key, int ttl, byte[] serializedValue);

  Long expire(string key, int seconds);

  Long pexpire(string key, long milliseconds);

  Long expireAt(string key, long unixTime);

  Long pexpireAt(string key, long millisecondsTimestamp);

  Long ttl(string key);

  Long pttl(string key);

  Long touch(string key);

  Boolean setbit(string key, long offset, bool value);

  Boolean setbit(string key, long offset, string value);

  Boolean getbit(string key, long offset);

  Long setrange(string key, long offset, string value);

  string getrange(string key, long startOffset, long endOffset);

  string getSet(string key, string value);

  Long setnx(string key, string value);

  string setex(string key, int seconds, string value);

  string psetex(string key, long milliseconds, string value);

  Long decrBy(string key, long decrement);

  Long decr(string key);

  Long incrBy(string key, long increment);

  Double incrByFloat(string key, double increment);

  Long incr(string key);

  Long append(string key, string value);

  string substr(string key, int start, int end);

  Long hset(string key, string field, string value);

  Long hset(string key, Map!(string, string) hash);

  string hget(string key, string field);

  Long hsetnx(string key, string field, string value);

  string hmset(string key, Map!(string, string) hash);

  List!(string) hmget(string key, string[] fields...);

  Long hincrBy(string key, string field, long value);

  Double hincrByFloat(string key, string field, double value);

  Boolean hexists(string key, string field);

  Long hdel(string key, string[] field...);

  Long hlen(string key);

  Set!(string) hkeys(string key);

  List!(string) hvals(string key);

  Map!(string, string) hgetAll(string key);

  Long rpush(string key, string[] string...);

  Long lpush(string key, string[] string...);

  Long llen(string key);

  List!(string) lrange(string key, long start, long stop);

  string ltrim(string key, long start, long stop);

  string lindex(string key, long index);

  string lset(string key, long index, string value);

  Long lrem(string key, long count, string value);

  string lpop(string key);

  string rpop(string key);

  Long sadd(string key, string[] member...);

  Set!(string) smembers(string key);

  Long srem(string key, string[] member...);

  string spop(string key);

  Set!(string) spop(string key, long count);

  Long scard(string key);

  Boolean sismember(string key, string member);

  string srandmember(string key);

  List!(string) srandmember(string key, int count);

  Long strlen(string key);

  Long zadd(string key, double score, string member);

  Long zadd(string key, double score, string member, ZAddParams params);

  Long zadd(string key, Map!(string, Double) scoreMembers);

  Long zadd(string key, Map!(string, Double) scoreMembers, ZAddParams params);

  Set!(string) zrange(string key, long start, long stop);

  Long zrem(string key, string[] members...);

  Double zincrby(string key, double increment, string member);

  Double zincrby(string key, double increment, string member, ZIncrByParams params);

  Long zrank(string key, string member);

  Long zrevrank(string key, string member);

  Set!(string) zrevrange(string key, long start, long stop);

  Set!(Tuple) zrangeWithScores(string key, long start, long stop);

  Set!(Tuple) zrevrangeWithScores(string key, long start, long stop);

  Long zcard(string key);

  Double zscore(string key, string member);

  List!(string) sort(string key);

  List!(string) sort(string key, SortingParams sortingParameters);

  Long zcount(string key, double min, double max);

  Long zcount(string key, string min, string max);

  Set!(string) zrangeByScore(string key, double min, double max);

  Set!(string) zrangeByScore(string key, string min, string max);

  Set!(string) zrevrangeByScore(string key, double max, double min);

  Set!(string) zrangeByScore(string key, double min, double max, int offset, int count);

  Set!(string) zrevrangeByScore(string key, string max, string min);

  Set!(string) zrangeByScore(string key, string min, string max, int offset, int count);

  Set!(string) zrevrangeByScore(string key, double max, double min, int offset, int count);

  Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max);

  Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min);

  Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max, int offset, int count);

  Set!(string) zrevrangeByScore(string key, string max, string min, int offset, int count);

  Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max);

  Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min);

  Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max, int offset, int count);

  Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min, int offset, int count);

  Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min, int offset, int count);

  Long zremrangeByRank(string key, long start, long stop);

  Long zremrangeByScore(string key, double min, double max);

  Long zremrangeByScore(string key, string min, string max);

  Long zlexcount(string key, string min, string max);

  Set!(string) zrangeByLex(string key, string min, string max);

  Set!(string) zrangeByLex(string key, string min, string max, int offset,
      int count);

  Set!(string) zrevrangeByLex(string key, string max, string min);

  Set!(string) zrevrangeByLex(string key, string max, string min,
      int offset, int count);

  Long zremrangeByLex(string key, string min, string max);

  Long linsert(string key, ListPosition where, string pivot, string value);

  Long lpushx(string key, string[] string...);

  Long rpushx(string key, string[] string...);

  List!(string) blpop(int timeout, string key);

  List!(string) brpop(int timeout, string key);

  Long del(string key);

  Long unlink(string key);

  string echo(string string);

  Long move(string key, int dbIndex);

  Long bitcount(string key);

  Long bitcount(string key, long start, long end);

  Long bitpos(string key, bool value);

  Long bitpos(string key, bool value, BitPosParams params);

  ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor);

  ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor,
      ScanParams params);

  ScanResult!(string) sscan(string key, string cursor);

  ScanResult!(Tuple) zscan(string key, string cursor);

  ScanResult!(Tuple) zscan(string key, string cursor, ScanParams params);

  ScanResult!(string) sscan(string key, string cursor, ScanParams params);

  Long pfadd(string key, string[] elements...);

  long pfcount(string key);

  // Geo Commands

  Long geoadd(string key, double longitude, double latitude, string member);

  Long geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap);

  Double geodist(string key, string member1, string member2);

  Double geodist(string key, string member1, string member2, GeoUnit unit);

  List!(string) geohash(string key, string[] members...);

  List!(GeoCoordinate) geopos(string key, string[] members...);

  List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude, double radius,
      GeoUnit unit);

  List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude, double radius,
      GeoUnit unit);

  List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude, double radius,
      GeoUnit unit, GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude, double radius,
      GeoUnit unit, GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius, GeoUnit unit);

  List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit);

  List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius, GeoUnit unit,
      GeoRadiusParam param);

  List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit,
      GeoRadiusParam param);

  /**
   * Executes BITFIELD Redis command
   * @param key
   * @param arguments
   * @return 
   */
  List!(Long) bitfield(string key, string[] arguments...);

  /**
   * Used for HSTRLEN Redis command
   * @param key 
   * @param field
   * @return length of the value for key
   */
  Long hstrlen(string key, string field);

  /**
   * XADD key ID field string [field string ...]
   * 
   * @param key
   * @param id
   * @param hash
   * @return the ID of the added entry
   */
  StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash);

  /**
   * XADD key MAXLEN ~ LEN ID field string [field string ...]
   * 
   * @param key
   * @param id
   * @param hash
   * @param maxLen
   * @param approximateLength
   * @return
   */
  StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength);
  
  /**
   * XLEN key
   * 
   * @param key
   * @return
   */
  Long xlen(string key);

  /**
   * XRANGE key start end [COUNT count]
   * 
   * @param key
   * @param start minimum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate minimum ID possible in the stream  
   * @param end maximum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate maximum ID possible in the stream
   * @param count maximum number of entries returned 
   * @return The entries with IDs matching the specified range. 
   */
  List!(StreamEntry) xrange(string key, StreamEntryID start, StreamEntryID end, int count);

  /**
   * XREVRANGE key end start [COUNT <n>]
   * 
   * @param key
   * @param start minimum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate minimum ID possible in the stream  
   * @param end maximum {@link StreamEntryID} for the retrieved range, passing <code>null</code> will indicate maximum ID possible in the stream
   * @param count The entries with IDs matching the specified range. 
   * @return the entries with IDs matching the specified range, from the higher ID to the lower ID matching.
   */
  List!(StreamEntry) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count);
    
  /**
   * XACK key group ID [ID ...]
   * 
   * @param key
   * @param group
   * @param ids
   * @return
   */
  long xack(string key, string group,  StreamEntryID[] ids...);
  
  /**
   * XGROUP CREATE <key> <groupname> <id or $>
   * 
   * @param key
   * @param groupname
   * @param id
   * @param makeStream
   * @return
   */
  string xgroupCreate( string key, string groupname, StreamEntryID id, bool makeStream);
  
  /**
   * XGROUP SETID <key> <groupname> <id or $>
   * 
   * @param key
   * @param groupname
   * @param id
   * @return
   */
  string xgroupSetID( string key, string groupname, StreamEntryID id);
  
  /**
   * XGROUP DESTROY <key> <groupname>
   * 
   * @param key
   * @param groupname
   * @return
   */
  long xgroupDestroy( string key, string groupname);
  
  /**
   * XGROUP DELCONSUMER <key> <groupname> <consumername> 
   * @param key
   * @param groupname
   * @param consumername
   * @return
   */
  string xgroupDelConsumer( string key, string groupname, string consumername);

  /**
   * XPENDING key group [start end count] [consumer]
   * 
   * @param key
   * @param groupname
   * @param start
   * @param end
   * @param count
   * @param consumername
   * @return
   */
  List!(StreamPendingEntry) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername);
  
  /**
   * XDEL key ID [ID ...]
   * @param key
   * @param ids
   * @return
   */
  long xdel( string key, StreamEntryID[] ids...);
  
  /**
   * XTRIM key MAXLEN [~] count
   * @param key
   * @param maxLen
   * @param approximate
   * @return
   */
  long xtrim( string key, long maxLen, bool approximate);
 
  /**
   *  XCLAIM <key> <group> <consumer> <min-idle-time> <ID-1> <ID-2>
   *        [IDLE <milliseconds>] [TIME <mstime>] [RETRYCOUNT <count>]
   *        [FORCE] [JUSTID]
   */        
  List!(StreamEntry) xclaim( string key, string group, string consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, StreamEntryID[] ids...);


  Object sendCommand(ProtocolCommand cmd, string[] args...);
}
