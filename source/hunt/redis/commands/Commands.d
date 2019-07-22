module hunt.redis.commands.Commands;


import hunt.collection.Map;
import hunt.Double;

import hunt.redis.BitOP;
import hunt.redis.StreamEntryID;
import hunt.redis.ListPosition;
import hunt.redis.ScanParams;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.ClientKillParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;

interface Commands {

  void ping(string message);
  
  void set(string key, string value);

  void set(string key, string value, SetParams params);

  void get(string key);

  void exists(string[] keys...);

  void del(string[] keys...);

  void unlink(string[] keys...);

  void type(string key);

  void keys(string pattern);

  void rename(string oldkey, string newkey);

  void renamenx(string oldkey, string newkey);

  void expire(string key, int seconds);

  void expireAt(string key, long unixTime);

  void ttl(string key);

  void pttl(string key);

  void touch(string[] keys...);

  void setbit(string key, long offset, bool value);

  void setbit(string key, long offset, string value);

  void getbit(string key, long offset);

  void setrange(string key, long offset, string value);

  void getrange(string key, long startOffset, long endOffset);

  void move(string key, int dbIndex);

  void getSet(string key, string value);

  void mget(string[] keys...);

  void setnx(string key, string value);

  void setex(string key, int seconds, string value);

  void mset(string[] keysvalues...);

  void msetnx(string[] keysvalues...);

  void decrBy(string key, long decrement);

  void decr(string key);

  void incrBy(string key, long increment);

  void incrByFloat(string key, double increment);

  void incr(string key);

  void append(string key, string value);

  void substr(string key, int start, int end);

  void hset(string key, string field, string value);

  void hget(string key, string field);

  void hset(string key, Map!(string, string) hash);

  void hsetnx(string key, string field, string value);

  void hmset(string key, Map!(string, string) hash);

  void hmget(string key, string[] fields...);

  void hincrBy(string key, string field, long value);

  void hincrByFloat(string key, string field, double value);

  void hexists(string key, string field);

  void hdel(string key, string[] fields...);

  void hlen(string key);

  void hkeys(string key);

  void hvals(string key);

  void hgetAll(string key);

  void rpush(string key, string[] strings...);

  void lpush(string key, string[] strings...);

  void llen(string key);

  void lrange(string key, long start, long stop);

  void ltrim(string key, long start, long stop);

  void lindex(string key, long index);

  void lset(string key, long index, string value);

  void lrem(string key, long count, string value);

  void lpop(string key);

  void rpop(string key);

  void rpoplpush(string srckey, string dstkey);

  void sadd(string key, string[] members...);

  void smembers(string key);

  void srem(string key, string[] member...);

  void spop(string key);

  void spop(string key, long count);

  void smove(string srckey, string dstkey, string member);

  void scard(string key);

  void sismember(string key, string member);

  void sinter(string[] keys...);

  void sinterstore(string dstkey, string[] keys...);

  void sunion(string[] keys...);

  void sunionstore(string dstkey, string[] keys...);

  void sdiff(string[] keys...);

  void sdiffstore(string dstkey, string[] keys...);

  void srandmember(string key);

  void zadd(string key, double score, string member);

  void zadd(string key, double score, string member, ZAddParams params);

  void zadd(string key, Map!(string, double) scoreMembers);

  void zadd(string key, Map!(string, double) scoreMembers, ZAddParams params);

  void zrange(string key, long start, long stop);

  void zrem(string key, string[] members...);

  void zincrby(string key, double increment, string member);

  void zincrby(string key, double increment, string member, ZIncrByParams params);

  void zrank(string key, string member);

  void zrevrank(string key, string member);

  void zrevrange(string key, long start, long stop);

  void zrangeWithScores(string key, long start, long stop);

  void zrevrangeWithScores(string key, long start, long stop);

  void zcard(string key);

  void zscore(string key, string member);

  void watch(string[] keys...);

  void sort(string key);

  void sort(string key, SortingParams sortingParameters);

  void blpop(string[] args);

  void sort(string key, SortingParams sortingParameters, string dstkey);

  void sort(string key, string dstkey);

  void brpop(string[] args);

  void brpoplpush(string source, string destination, int timeout);

  void zcount(string key, double min, double max);

  void zcount(string key, string min, string max);

  void zrangeByScore(string key, double min, double max);

  void zrangeByScore(string key, string min, string max);

  void zrangeByScore(string key, double min, double max, int offset,
      int count);

  void zrangeByScore(string key, string min, string max, int offset, int count);

  void zrangeByScoreWithScores(string key, double min, double max);

  void zrangeByScoreWithScores(string key, double min, double max,
      int offset, int count);

  void zrangeByScoreWithScores(string key, string min, string max);

  void zrangeByScoreWithScores(string key, string min, string max,
      int offset, int count);

  void zrevrangeByScore(string key, double max, double min);

  void zrevrangeByScore(string key, string max, string min);

  void zrevrangeByScore(string key, double max, double min, int offset,
      int count);

  void zrevrangeByScore(string key, string max, string min, int offset, int count);

  void zrevrangeByScoreWithScores(string key, double max, double min);

  void zrevrangeByScoreWithScores(string key, double max, double min,
      int offset, int count);

  void zrevrangeByScoreWithScores(string key, string max, string min);

  void zrevrangeByScoreWithScores(string key, string max, string min,
      int offset, int count);

  void zremrangeByRank(string key, long start, long stop);

  void zremrangeByScore(string key, double min, double max);

  void zremrangeByScore(string key, string min, string max);

  void zunionstore(string dstkey, string[] sets...);

  void zunionstore(string dstkey, ZParams params, string[] sets...);

  void zinterstore(string dstkey, string[] sets...);

  void zinterstore(string dstkey, ZParams params, string[] sets...);

  void strlen(string key);

  void lpushx(string key, string[] string...);

  void persist(string key);

  void rpushx(string key, string[] string...);

  void echo(string string);

  void linsert(string key, ListPosition where, string pivot, string value);

  void bgrewriteaof();

  void bgsave();

  void lastsave();

  void save();

  void configSet(string parameter, string value);

  void configGet(string pattern);

  void configResetStat();

  void multi();

  void exec();

  void discard();

  void objectRefcount(string key);

  void objectIdletime(string key);

  void objectEncoding(string key);

  void bitcount(string key);

  void bitcount(string key, long start, long end);

  void bitop(BitOP op, string destKey, string[] srcKeys...);

  void dump(string key);

  void restore(string key, int ttl, const(ubyte)[] serializedValue);

  void restoreReplace(string key, int ttl, const(ubyte)[] serializedValue);

  void scan(string cursor, ScanParams params);

  void hscan(string key, string cursor, ScanParams params);

  void sscan(string key, string cursor, ScanParams params);

  void zscan(string key, string cursor, ScanParams params);

  void waitReplicas(int replicas, long timeout);

  /**
   * Used for BITFIELD Redis command
   * @param key
   * @param arguments
   */
  void bitfield(string key, string[] arguments...);

  /**
   * Used for HSTRLEN Redis command
   * @param key
   * @param field
   */
  void hstrlen(string key, string field);

  void migrate(string host, int port, string key, int destinationDB, int timeout);

  void migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, string[] keys...);

  void clientKill(string ipPort);

  void clientKill(string ip, int port);

  void clientKill(ClientKillParams params);

  void clientGetname();

  void clientList();

  void clientSetname(string name);

  void memoryDoctor();

  void xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength);
  
  void xlen(string key);

  void xrange(string key, StreamEntryID start, StreamEntryID end, long count);
  
  void xrevrange(string key, StreamEntryID end, StreamEntryID start, int count);
  
  void xread(int count, long block, MapEntry!(string, StreamEntryID)[] streams...);
  
  void xack(string key, string group, StreamEntryID[] ids...);
  
  void xgroupCreate(string key, string consumer, StreamEntryID id, bool makeStream);

  void xgroupSetID(string key, string consumer, StreamEntryID id);

  void xgroupDestroy(string key, string consumer);

  void xgroupDelConsumer(string key, string consumer, string consumerName);

  void xdel(string key, StreamEntryID[] ids...);

  void xtrim(string key, long maxLen, bool approximateLength);

  void xreadGroup(string groupname, string consumer, int count, long block, bool noAck, MapEntry!(string, StreamEntryID)[] streams...);

  void xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername);

  void xclaim(string key, string group, string consumername, long minIdleTime, long newIdleTime, int retries,
      bool force, StreamEntryID[] ids...);
}
