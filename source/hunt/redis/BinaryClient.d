module hunt.redis.BinaryClient;

import hunt.redis.Protocol;

// import hunt.redis.Protocol.toByteArray;
// import hunt.redis.Protocol.Command;
// import hunt.redis.Protocol.Keyword.ENCODING;
// import hunt.redis.Protocol.Keyword.IDLETIME;
// import hunt.redis.Protocol.Keyword.LEN;
// import hunt.redis.Protocol.Keyword.LIMIT;
// import hunt.redis.Protocol.Keyword.NO;
// import hunt.redis.Protocol.Keyword.ONE;
// import hunt.redis.Protocol.Keyword.REFCOUNT;
// import hunt.redis.Protocol.Keyword.RESET;
// import hunt.redis.Protocol.Keyword.STORE;
// import hunt.redis.Protocol.Keyword.WITHSCORES;

import hunt.collection.ArraryList;
import hunt.collection.List;
import hunt.collection.Map;

// import hunt.redis.Protocol.Keyword;
import hunt.redis.params.ClientKillParams;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;

class BinaryClient : Connection {

  private bool isInMulti;

  private String password;

  private int db;

  private bool isInWatch;

  this() {
    super();
  }

  this(String host) {
    super(host);
  }

  this(String host, int port) {
    super(host, port);
  }

  this(String host, int port, bool ssl) {
    super(host, port, ssl);
  }

  this(String host, int port, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    super(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  bool isInMulti() {
    return isInMulti;
  }

  bool isInWatch() {
    return isInWatch;
  }

  private byte[][] joinParameters(byte[] first, byte[][] rest) {
    byte[][] result = new byte[rest.length + 1][];
    result[0] = first;
    System.arraycopy(rest, 0, result, 1, rest.length);
    return result;
  }

  private byte[][] joinParameters(byte[] first, byte[] second, byte[][] rest) {
    byte[][] result = new byte[rest.length + 2][];
    result[0] = first;
    result[1] = second;
    System.arraycopy(rest, 0, result, 2, rest.length);
    return result;
  }

  void setPassword(String password) {
    this.password = password;
  }

  void setDb(int db) {
    this.db = db;
  }

  override
  void connect() {
    if (!isConnected()) {
      super.connect();
      if (password != null) {
        auth(password);
        getStatusCodeReply();
      }
      if (db > 0) {
        select(db);
        getStatusCodeReply();
      }
    }
  }

  void ping() {
    sendCommand(PING);
  }

  void ping(byte[] message) {
    sendCommand(PING, message);
  }

  void set(byte[] key, byte[] value) {
    sendCommand(SET, key, value);
  }

  void set(byte[] key, byte[] value, SetParams params) {
    sendCommand(SET, params.getByteParams(key, value));
  }

  void get(byte[] key) {
    sendCommand(GET, key);
  }

  void quit() {
    db = 0;
    sendCommand(QUIT);
  }

  void exists(byte[] keys...) {
    sendCommand(EXISTS, keys);
  }

  void del(byte[] keys...) {
    sendCommand(DEL, keys);
  }

  void unlink(byte[] keys...) {
    sendCommand(UNLINK, keys);
  }

  void type(byte[] key) {
    sendCommand(TYPE, key);
  }

  void flushDB() {
    sendCommand(FLUSHDB);
  }

  void keys(byte[] pattern) {
    sendCommand(KEYS, pattern);
  }

  void randomKey() {
    sendCommand(RANDOMKEY);
  }

  void rename(byte[] oldkey, byte[] newkey) {
    sendCommand(RENAME, oldkey, newkey);
  }

  void renamenx(byte[] oldkey, byte[] newkey) {
    sendCommand(RENAMENX, oldkey, newkey);
  }

  void dbSize() {
    sendCommand(DBSIZE);
  }

  void expire(byte[] key, int seconds) {
    sendCommand(EXPIRE, key, toByteArray(seconds));
  }

  void expireAt(byte[] key, long unixTime) {
    sendCommand(EXPIREAT, key, toByteArray(unixTime));
  }

  void ttl(byte[] key) {
    sendCommand(TTL, key);
  }

  void touch(byte[] keys...) {
    sendCommand(TOUCH, keys);
  }

  void select(int index) {
    sendCommand(SELECT, toByteArray(index));
  }

  void swapDB(int index1, int index2) {
    sendCommand(SWAPDB, toByteArray(index1), toByteArray(index2));
  }

  void move(byte[] key, int dbIndex) {
    sendCommand(MOVE, key, toByteArray(dbIndex));
  }

  void flushAll() {
    sendCommand(FLUSHALL);
  }

  void getSet(byte[] key, byte[] value) {
    sendCommand(GETSET, key, value);
  }

  void mget(byte[] keys...) {
    sendCommand(MGET, keys);
  }

  void setnx(byte[] key, byte[] value) {
    sendCommand(SETNX, key, value);
  }

  void setex(byte[] key, int seconds, byte[] value) {
    sendCommand(SETEX, key, toByteArray(seconds), value);
  }

  void mset(byte[] keysvalues...) {
    sendCommand(MSET, keysvalues);
  }

  void msetnx(byte[] keysvalues...) {
    sendCommand(MSETNX, keysvalues);
  }

  void decrBy(byte[] key, long decrement) {
    sendCommand(DECRBY, key, toByteArray(decrement));
  }

  void decr(byte[] key) {
    sendCommand(DECR, key);
  }

  void incrBy(byte[] key, long increment) {
    sendCommand(INCRBY, key, toByteArray(increment));
  }

  void incrByFloat(byte[] key, double increment) {
    sendCommand(INCRBYFLOAT, key, toByteArray(increment));
  }

  void incr(byte[] key) {
    sendCommand(INCR, key);
  }

  void append(byte[] key, byte[] value) {
    sendCommand(APPEND, key, value);
  }

  void substr(byte[] key, int start, int end) {
    sendCommand(SUBSTR, key, toByteArray(start), toByteArray(end));
  }

  void hset(byte[] key, byte[] field, byte[] value) {
    sendCommand(HSET, key, field, value);
  }

  // void hset(byte[] key, Map!(byte[], byte[]) hash) {
  //   byte[][] params = new byte[1 + hash.size() * 2][];

  //   int index = 0;
  //   params[index++] = key;
  //   foreach (Entry!(byte[], byte[]) entry ; hash.entrySet()) {
  //     params[index++] = entry.getKey();
  //     params[index++] = entry.getValue();
  //   }
  //   sendCommand(HSET, params);
  // }

  void hget(byte[] key, byte[] field) {
    sendCommand(HGET, key, field);
  }

  void hsetnx(byte[] key, byte[] field, byte[] value) {
    sendCommand(HSETNX, key, field, value);
  }

  // void hmset(byte[] key, Map!(byte[], byte[]) hash) {
  //   List!(byte[]) params = new ArrayList!(byte[])();
  //   params.add(key);

  //   foreach(Entry!(byte[], byte[]) entry ; hash.entrySet()) {
  //     params.add(entry.getKey());
  //     params.add(entry.getValue());
  //   }
  //   sendCommand(HMSET, params.toArray(new byte[params.size()][]));
  // }

  void hmget(byte[] key, byte[] fields...) {
    sendCommand(HMGET, joinParameters(key, fields));
  }

  void hincrBy(byte[] key, byte[] field, long value) {
    sendCommand(HINCRBY, key, field, toByteArray(value));
  }

  void hexists(byte[] key, byte[] field) {
    sendCommand(HEXISTS, key, field);
  }

  void hdel(byte[] key, byte[] fields...) {
    sendCommand(HDEL, joinParameters(key, fields));
  }

  void hlen(byte[] key) {
    sendCommand(HLEN, key);
  }

  void hkeys(byte[] key) {
    sendCommand(HKEYS, key);
  }

  void hvals(byte[] key) {
    sendCommand(HVALS, key);
  }

  void hgetAll(byte[] key) {
    sendCommand(HGETALL, key);
  }

  void rpush(byte[] key, byte[] strings...) {
    sendCommand(RPUSH, joinParameters(key, strings));
  }

  void lpush(byte[] key, byte[] strings...) {
    sendCommand(LPUSH, joinParameters(key, strings));
  }

  void llen(byte[] key) {
    sendCommand(LLEN, key);
  }

  void lrange(byte[] key, long start, long stop) {
    sendCommand(LRANGE, key, toByteArray(start), toByteArray(stop));
  }

  void ltrim(byte[] key, long start, long stop) {
    sendCommand(LTRIM, key, toByteArray(start), toByteArray(stop));
  }

  void lindex(byte[] key, long index) {
    sendCommand(LINDEX, key, toByteArray(index));
  }

  void lset(byte[] key, long index, byte[] value) {
    sendCommand(LSET, key, toByteArray(index), value);
  }

  void lrem(byte[] key, long count, byte[] value) {
    sendCommand(LREM, key, toByteArray(count), value);
  }

  void lpop(byte[] key) {
    sendCommand(LPOP, key);
  }

  void rpop(byte[] key) {
    sendCommand(RPOP, key);
  }

  void rpoplpush(byte[] srckey, byte[] dstkey) {
    sendCommand(RPOPLPUSH, srckey, dstkey);
  }

  void sadd(byte[] key, byte[] members...) {
    sendCommand(SADD, joinParameters(key, members));
  }

  void smembers(byte[] key) {
    sendCommand(SMEMBERS, key);
  }

  void srem(byte[] key, byte[] members...) {
    sendCommand(SREM, joinParameters(key, members));
  }

  void spop(byte[] key) {
    sendCommand(SPOP, key);
  }

  void spop(byte[] key, long count) {
    sendCommand(SPOP, key, toByteArray(count));
  }

  void smove(byte[] srckey, byte[] dstkey, byte[] member) {
    sendCommand(SMOVE, srckey, dstkey, member);
  }

  void scard(byte[] key) {
    sendCommand(SCARD, key);
  }

  void sismember(byte[] key, byte[] member) {
    sendCommand(SISMEMBER, key, member);
  }

  void sinter(byte[] keys...) {
    sendCommand(SINTER, keys);
  }

  void sinterstore(byte[] dstkey, byte[] keys...) {
    sendCommand(SINTERSTORE, joinParameters(dstkey, keys));
  }

  void sunion(byte[] keys...) {
    sendCommand(SUNION, keys);
  }

  void sunionstore(byte[] dstkey, byte[] keys...) {
    sendCommand(SUNIONSTORE, joinParameters(dstkey, keys));
  }

  void sdiff(byte[] keys...) {
    sendCommand(SDIFF, keys);
  }

  void sdiffstore(byte[] dstkey, byte[] keys...) {
    sendCommand(SDIFFSTORE, joinParameters(dstkey, keys));
  }

  void srandmember(byte[] key) {
    sendCommand(SRANDMEMBER, key);
  }

  void zadd(byte[] key, double score, byte[] member) {
    sendCommand(ZADD, key, toByteArray(score), member);
  }

  void zadd(byte[] key, double score, byte[] member,
      ZAddParams params) {
    sendCommand(ZADD, params.getByteParams(key, toByteArray(score), member));
  }

  void zadd(byte[] key, Map!(byte[], Double) scoreMembers) {
    ArrayList!(byte[]) args = new ArrayList!(byte[])(scoreMembers.size() * 2 + 1);
    args.add(key);
    args.addAll(convertScoreMembersToByteArrays(scoreMembers));

    byte[][] argsArray = new byte[args.size()][];
    args.toArray(argsArray);

    sendCommand(ZADD, argsArray);
  }

  void zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params) {
    ArrayList!(byte[]) args = convertScoreMembersToByteArrays(scoreMembers);
    byte[][] argsArray = new byte[args.size()][];
    args.toArray(argsArray);

    sendCommand(ZADD, params.getByteParams(key, argsArray));
  }

  void zrange(byte[] key, long start, long stop) {
    sendCommand(ZRANGE, key, toByteArray(start), toByteArray(stop));
  }

  void zrem(byte[] key, byte[] members...) {
    sendCommand(ZREM, joinParameters(key, members));
  }

  void zincrby(byte[] key, double increment, byte[] member) {
    sendCommand(ZINCRBY, key, toByteArray(increment), member);
  }

  void zincrby(byte[] key, double increment, byte[] member,
      ZIncrByParams params) {
    // Note that it actually calls ZADD with INCR option, so it requires Redis 3.0.2 or upper.
    sendCommand(ZADD, params.getByteParams(key, toByteArray(increment), member));
  }

  void zrank(byte[] key, byte[] member) {
    sendCommand(ZRANK, key, member);
  }

  void zrevrank(byte[] key, byte[] member) {
    sendCommand(ZREVRANK, key, member);
  }

  void zrevrange(byte[] key, long start, long stop) {
    sendCommand(ZREVRANGE, key, toByteArray(start), toByteArray(stop));
  }

  void zrangeWithScores(byte[] key, long start, long stop) {
    sendCommand(ZRANGE, key, toByteArray(start), toByteArray(stop), WITHSCORES.raw);
  }

  void zrevrangeWithScores(byte[] key, long start, long stop) {
    sendCommand(ZREVRANGE, key, toByteArray(start), toByteArray(stop), WITHSCORES.raw);
  }

  void zcard(byte[] key) {
    sendCommand(ZCARD, key);
  }

  void zscore(byte[] key, byte[] member) {
    sendCommand(ZSCORE, key, member);
  }

  void multi() {
    sendCommand(MULTI);
    isInMulti = true;
  }

  void discard() {
    sendCommand(DISCARD);
    isInMulti = false;
    isInWatch = false;
  }

  void exec() {
    sendCommand(EXEC);
    isInMulti = false;
    isInWatch = false;
  }

  void watch(byte[] keys...) {
    sendCommand(WATCH, keys);
    isInWatch = true;
  }

  void unwatch() {
    sendCommand(UNWATCH);
    isInWatch = false;
  }

  void sort(byte[] key) {
    sendCommand(SORT, key);
  }

  void sort(byte[] key, SortingParams sortingParameters) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.addAll(sortingParameters.getParams());
    sendCommand(SORT, args.toArray(new byte[args.size()][]));
  }

  void blpop(byte[][] args) {
    sendCommand(BLPOP, args);
  }

  void blpop(int timeout, byte[] keys...) {
    List!(byte[]) args = new ArrayList!(byte[])();
    foreach(byte[] arg ; keys) {
      args.add(arg);
    }
    args.add(Protocol.toByteArray(timeout));
    blpop(args.toArray(new byte[args.size()][]));
  }

  void sort(byte[] key, SortingParams sortingParameters, byte[] dstkey) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.addAll(sortingParameters.getParams());
    args.add(STORE.raw);
    args.add(dstkey);
    sendCommand(SORT, args.toArray(new byte[args.size()][]));
  }

  void sort(byte[] key, byte[] dstkey) {
    sendCommand(SORT, key, STORE.raw, dstkey);
  }

  void brpop(byte[][] args) {
    sendCommand(BRPOP, args);
  }

  void brpop(int timeout, byte[] keys...) {
    List!(byte[]) args = new ArrayList!(byte[])();
    foreach(byte[] arg ; keys) {
      args.add(arg);
    }
    args.add(Protocol.toByteArray(timeout));
    brpop(args.toArray(new byte[args.size()][]));
  }

  void auth(String password) {
    setPassword(password);
    sendCommand(AUTH, password);
  }

  void subscribe(byte[] channels...) {
    sendCommand(SUBSCRIBE, channels);
  }

  void publish(byte[] channel, byte[] message) {
    sendCommand(PUBLISH, channel, message);
  }

  void unsubscribe() {
    sendCommand(UNSUBSCRIBE);
  }

  void unsubscribe(byte[] channels...) {
    sendCommand(UNSUBSCRIBE, channels);
  }

  void psubscribe(byte[] patterns...) {
    sendCommand(PSUBSCRIBE, patterns);
  }

  void punsubscribe() {
    sendCommand(PUNSUBSCRIBE);
  }

  void punsubscribe(byte[] patterns...) {
    sendCommand(PUNSUBSCRIBE, patterns);
  }

  void pubsub(byte[] args...) {
    sendCommand(PUBSUB, args);
  }

  void zcount(byte[] key, double min, double max) {
    sendCommand(ZCOUNT, key, toByteArray(min), toByteArray(max));
  }

  void zcount(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZCOUNT, key, min, max);
  }

  void zrangeByScore(byte[] key, double min, double max) {
    sendCommand(ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
  }

  void zrangeByScore(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZRANGEBYSCORE, key, min, max);
  }

  void zrevrangeByScore(byte[] key, double max, double min) {
    sendCommand(ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min));
  }

  void zrevrangeByScore(byte[] key, byte[] max, byte[] min) {
    sendCommand(ZREVRANGEBYSCORE, key, max, min);
  }

  void zrangeByScore(byte[] key, double min, double max, int offset,
      int count) {
    sendCommand(ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), LIMIT.raw, toByteArray(offset),
      toByteArray(count));
  }

  void zrevrangeByScore(byte[] key, double max, double min,
      int offset, int count) {
    sendCommand(ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), LIMIT.raw, toByteArray(offset),
      toByteArray(count));
  }

  void zrangeByScoreWithScores(byte[] key, double min, double max) {
    sendCommand(ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), WITHSCORES.raw);
  }

  void zrevrangeByScoreWithScores(byte[] key, double max, double min) {
    sendCommand(ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), WITHSCORES.raw);
  }

  void zrangeByScoreWithScores(byte[] key, double min, double max,
      int offset, int count) {
    sendCommand(ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), LIMIT.raw, toByteArray(offset),
      toByteArray(count), WITHSCORES.raw);
  }

  void zrevrangeByScoreWithScores(byte[] key, double max, double min,
      int offset, int count) {
    sendCommand(ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), LIMIT.raw, toByteArray(offset),
      toByteArray(count), WITHSCORES.raw);
  }

  void zrangeByScore(byte[] key, byte[] min, byte[] max, int offset,
      int count) {
    sendCommand(ZRANGEBYSCORE, key, min, max, LIMIT.raw, toByteArray(offset), toByteArray(count));
  }

  void zrevrangeByScore(byte[] key, byte[] max, byte[] min,
      int offset, int count) {
    sendCommand(ZREVRANGEBYSCORE, key, max, min, LIMIT.raw, toByteArray(offset), toByteArray(count));
  }

  void zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZRANGEBYSCORE, key, min, max, WITHSCORES.raw);
  }

  void zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min) {
    sendCommand(ZREVRANGEBYSCORE, key, max, min, WITHSCORES.raw);
  }

  void zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max,
      int offset, int count) {
    sendCommand(ZRANGEBYSCORE, key, min, max, LIMIT.raw, toByteArray(offset), toByteArray(count),
      WITHSCORES.raw);
  }

  void zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min,
      int offset, int count) {
    sendCommand(ZREVRANGEBYSCORE, key, max, min, LIMIT.raw, toByteArray(offset),
      toByteArray(count), WITHSCORES.raw);
  }

  void zremrangeByRank(byte[] key, long start, long stop) {
    sendCommand(ZREMRANGEBYRANK, key, toByteArray(start), toByteArray(stop));
  }

  void zremrangeByScore(byte[] key, double min, double max) {
    sendCommand(ZREMRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
  }

  void zremrangeByScore(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZREMRANGEBYSCORE, key, min, max);
  }

  void zunionstore(byte[] dstkey, byte[] sets...) {
    sendCommand(ZUNIONSTORE, joinParameters(dstkey, toByteArray(sets.length), sets));
  }

  void zunionstore(byte[] dstkey, ZParams params, byte[] sets...) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(dstkey);
    args.add(Protocol.toByteArray(sets.length));
    foreach(byte[] set ; sets) {
      args.add(set);
    }
    args.addAll(params.getParams());
    sendCommand(ZUNIONSTORE, args.toArray(new byte[args.size()][]));
  }

  void zinterstore(byte[] dstkey, byte[] sets...) {
    sendCommand(ZINTERSTORE, joinParameters(dstkey, Protocol.toByteArray(sets.length), sets));
  }

  void zinterstore(byte[] dstkey, ZParams params, byte[] sets...) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(dstkey);
    args.add(Protocol.toByteArray(sets.length));
    foreach(byte[] set ; sets) {
      args.add(set);
    }
    args.addAll(params.getParams());
    sendCommand(ZINTERSTORE, args.toArray(new byte[args.size()][]));
  }

  void zlexcount(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZLEXCOUNT, key, min, max);
  }

  void zrangeByLex(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZRANGEBYLEX, key, min, max);
  }

  void zrangeByLex(byte[] key, byte[] min, byte[] max, int offset,
      int count) {
    sendCommand(ZRANGEBYLEX, key, min, max, LIMIT.raw, toByteArray(offset), toByteArray(count));
  }

  void zrevrangeByLex(byte[] key, byte[] max, byte[] min) {
    sendCommand(ZREVRANGEBYLEX, key, max, min);
  }

  void zrevrangeByLex(byte[] key, byte[] max, byte[] min,
      int offset, int count) {
    sendCommand(ZREVRANGEBYLEX, key, max, min, LIMIT.raw, toByteArray(offset), toByteArray(count));
  }

  void zremrangeByLex(byte[] key, byte[] min, byte[] max) {
    sendCommand(ZREMRANGEBYLEX, key, min, max);
  }

  void save() {
    sendCommand(SAVE);
  }

  void bgsave() {
    sendCommand(BGSAVE);
  }

  void bgrewriteaof() {
    sendCommand(BGREWRITEAOF);
  }

  void lastsave() {
    sendCommand(LASTSAVE);
  }

  void shutdown() {
    sendCommand(SHUTDOWN);
  }

  void info() {
    sendCommand(INFO);
  }

  void info(String section) {
    sendCommand(INFO, section);
  }

  void monitor() {
    sendCommand(MONITOR);
  }

  void slaveof(String host, int port) {
    sendCommand(SLAVEOF, host, String.valueOf(port));
  }

  void slaveofNoOne() {
    sendCommand(SLAVEOF, NO.raw, ONE.raw);
  }

  void configGet(byte[] pattern) {
    sendCommand(CONFIG, Keyword.GET.raw, pattern);
  }

  void configSet(byte[] parameter, byte[] value) {
    sendCommand(CONFIG, Keyword.SET.raw, parameter, value);
  }

  void strlen(byte[] key) {
    sendCommand(STRLEN, key);
  }

  void sync() {
    sendCommand(SYNC);
  }

  void lpushx(byte[] key, byte[] string...) {
    sendCommand(LPUSHX, joinParameters(key, string));
  }

  void persist(byte[] key) {
    sendCommand(PERSIST, key);
  }

  void rpushx(byte[] key, byte[] string...) {
    sendCommand(RPUSHX, joinParameters(key, string));
  }

  void echo(byte[] string) {
    sendCommand(ECHO, string);
  }

  void linsert(byte[] key, ListPosition where, byte[] pivot,
      byte[] value) {
    sendCommand(LINSERT, key, where.raw, pivot, value);
  }

  // void debug(DebugParams params) {
  //   sendCommand(DEBUG, params.getCommand());
  // }

  void brpoplpush(byte[] source, byte[] destination, int timeout) {
    sendCommand(BRPOPLPUSH, source, destination, toByteArray(timeout));
  }

  void configResetStat() {
    sendCommand(CONFIG, Keyword.RESETSTAT.raw);
  }

  void configRewrite() {
    sendCommand(CONFIG, Keyword.REWRITE.raw);
  }

  void setbit(byte[] key, long offset, byte[] value) {
    sendCommand(SETBIT, key, toByteArray(offset), value);
  }

  void setbit(byte[] key, long offset, bool value) {
    sendCommand(SETBIT, key, toByteArray(offset), toByteArray(value));
  }

  void getbit(byte[] key, long offset) {
    sendCommand(GETBIT, key, toByteArray(offset));
  }

  void bitpos(byte[] key, bool value, BitPosParams params) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.add(toByteArray(value));
    args.addAll(params.getParams());
    sendCommand(BITPOS, args.toArray(new byte[args.size()][]));
  }

  void setrange(byte[] key, long offset, byte[] value) {
    sendCommand(SETRANGE, key, toByteArray(offset), value);
  }

  void getrange(byte[] key, long startOffset, long endOffset) {
    sendCommand(GETRANGE, key, toByteArray(startOffset), toByteArray(endOffset));
  }

  int getDB() {
    return db;
  }

  override
  void disconnect() {
    db = 0;
    super.disconnect();
  }

  override
  void close() {
    db = 0;
    super.close();
  }

  void resetState() {
    if (isInWatch()) {
      unwatch();
      getStatusCodeReply();
    }
  }

  void eval(byte[] script, byte[] keyCount, byte[][] params) {
    sendCommand(EVAL, joinParameters(script, keyCount, params));
  }

  void eval(byte[] script, int keyCount, byte[] params...) {
    sendCommand(EVAL, joinParameters(script, toByteArray(keyCount), params));
  }

  void evalsha(byte[] sha1, byte[] keyCount, byte[] params...) {
    sendCommand(EVALSHA, joinParameters(sha1, keyCount, params));
  }

  void evalsha(byte[] sha1, int keyCount, byte[] params...) {
    sendCommand(EVALSHA, joinParameters(sha1, toByteArray(keyCount), params));
  }

  void scriptFlush() {
    sendCommand(SCRIPT, Keyword.FLUSH.raw);
  }

  void scriptExists(byte[] sha1...) {
    sendCommand(SCRIPT, joinParameters(Keyword.EXISTS.raw, sha1));
  }

  void scriptLoad(byte[] script) {
    sendCommand(SCRIPT, Keyword.LOAD.raw, script);
  }

  void scriptKill() {
    sendCommand(SCRIPT, Keyword.KILL.raw);
  }

  void slowlogGet() {
    sendCommand(SLOWLOG, Keyword.GET.raw);
  }

  void slowlogGet(long entries) {
    sendCommand(SLOWLOG, Keyword.GET.raw, toByteArray(entries));
  }

  void slowlogReset() {
    sendCommand(SLOWLOG, RESET.raw);
  }

  void slowlogLen() {
    sendCommand(SLOWLOG, LEN.raw);
  }

  void objectRefcount(byte[] key) {
    sendCommand(OBJECT, REFCOUNT.raw, key);
  }

  void objectIdletime(byte[] key) {
    sendCommand(OBJECT, IDLETIME.raw, key);
  }

  void objectEncoding(byte[] key) {
    sendCommand(OBJECT, ENCODING.raw, key);
  }

  void bitcount(byte[] key) {
    sendCommand(BITCOUNT, key);
  }

  void bitcount(byte[] key, long start, long end) {
    sendCommand(BITCOUNT, key, toByteArray(start), toByteArray(end));
  }

  void bitop(BitOP op, byte[] destKey, byte[] srcKeys...) {
    sendCommand(BITOP, joinParameters(op.raw, destKey, srcKeys));
  }

  void sentinel(byte[] args...) {
    sendCommand(SENTINEL, args);
  }

  void dump(byte[] key) {
    sendCommand(DUMP, key);
  }

  void restore(byte[] key, int ttl, byte[] serializedValue) {
    sendCommand(RESTORE, key, toByteArray(ttl), serializedValue);
  }

  void restoreReplace(byte[] key, int ttl, byte[] serializedValue) {
    sendCommand(RESTORE, key, toByteArray(ttl), serializedValue, Keyword.REPLACE.raw);
  }

  void pexpire(byte[] key, long milliseconds) {
    sendCommand(PEXPIRE, key, toByteArray(milliseconds));
  }

  void pexpireAt(byte[] key, long millisecondsTimestamp) {
    sendCommand(PEXPIREAT, key, toByteArray(millisecondsTimestamp));
  }

  void pttl(byte[] key) {
    sendCommand(PTTL, key);
  }

  void psetex(byte[] key, long milliseconds, byte[] value) {
    sendCommand(PSETEX, key, toByteArray(milliseconds), value);
  }

  void srandmember(byte[] key, int count) {
    sendCommand(SRANDMEMBER, key, toByteArray(count));
  }

  void memoryDoctor() {
    sendCommand(MEMORY, Keyword.DOCTOR.raw);
  }

  void clientKill(byte[] ipPort) {
    sendCommand(CLIENT, Keyword.KILL.raw, ipPort);
  }

  void clientKill(String ip, int port) {
    sendCommand(CLIENT, Keyword.KILL.name(), ip + ':' + port);
  }

  void clientKill(ClientKillParams params) {
    sendCommand(CLIENT, joinParameters(Keyword.KILL.raw, params.getByteParams()));
  }

  void clientGetname() {
    sendCommand(CLIENT, Keyword.GETNAME.raw);
  }

  void clientList() {
    sendCommand(CLIENT, Keyword.LIST.raw);
  }

  void clientSetname(byte[] name) {
    sendCommand(CLIENT, Keyword.SETNAME.raw, name);
  }

  void clientPause(long timeout) {
    sendCommand(CLIENT, Keyword.PAUSE.raw, toByteArray(timeout));
  }

  void time() {
    sendCommand(TIME);
  }

  void migrate(String host, int port, byte[] key, int destinationDb,
      int timeout) {
    sendCommand(MIGRATE, SafeEncoder.encode(host), toByteArray(port), key,
        toByteArray(destinationDb), toByteArray(timeout));
  }

  void migrate(String host, int port, int destinationDB,
      int timeout, MigrateParams params, byte[] keys...) {
    byte[][] bparams = params.getByteParams();
    int len = 5 + bparams.length + 1 + keys.length;
    byte[][] args = new byte[len][];
    int i = 0;
    args[i++] = SafeEncoder.encode(host);
    args[i++] = toByteArray(port);
    args[i++] = new byte[0];
    args[i++] = toByteArray(destinationDB);
    args[i++] = toByteArray(timeout);
    System.arraycopy(bparams, 0, args, i, bparams.length);
    i += bparams.length;
    args[i++] = Keyword.KEYS.raw;
    System.arraycopy(keys, 0, args, i, keys.length);
    sendCommand(MIGRATE, args);
  }

  void hincrByFloat(byte[] key, byte[] field, double increment) {
    sendCommand(HINCRBYFLOAT, key, field, toByteArray(increment));
  }

  void scan(byte[] cursor, ScanParams params) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(cursor);
    args.addAll(params.getParams());
    sendCommand(SCAN, args.toArray(new byte[args.size()][]));
  }

  void hscan(byte[] key, byte[] cursor, ScanParams params) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.add(cursor);
    args.addAll(params.getParams());
    sendCommand(HSCAN, args.toArray(new byte[args.size()][]));
  }

  void sscan(byte[] key, byte[] cursor, ScanParams params) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.add(cursor);
    args.addAll(params.getParams());
    sendCommand(SSCAN, args.toArray(new byte[args.size()][]));
  }

  void zscan(byte[] key, byte[] cursor, ScanParams params) {
    List!(byte[]) args = new ArrayList!(byte[])();
    args.add(key);
    args.add(cursor);
    args.addAll(params.getParams());
    sendCommand(ZSCAN, args.toArray(new byte[args.size()][]));
  }

  void waitReplicas(int replicas, long timeout) {
    sendCommand(WAIT, toByteArray(replicas), toByteArray(timeout));
  }

  void cluster(byte[] args...) {
    sendCommand(CLUSTER, args);
  }

  void asking() {
    sendCommand(ASKING);
  }

  void pfadd(byte[] key, byte[] elements...) {
    sendCommand(PFADD, joinParameters(key, elements));
  }

  void pfcount(byte[] key) {
    sendCommand(PFCOUNT, key);
  }

  void pfcount(byte[] keys...) {
    sendCommand(PFCOUNT, keys);
  }

  void pfmerge(byte[] destkey, byte[] sourcekeys...) {
    sendCommand(PFMERGE, joinParameters(destkey, sourcekeys));
  }

  void readonly() {
    sendCommand(READONLY);
  }

  void geoadd(byte[] key, double longitude, double latitude, byte[] member) {
    sendCommand(GEOADD, key, toByteArray(longitude), toByteArray(latitude), member);
  }

  void geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    List!(byte[]) args = new ArrayList!(byte[])(memberCoordinateMap.size() * 3 + 1);
    args.add(key);
    args.addAll(convertGeoCoordinateMapToByteArrays(memberCoordinateMap));

    byte[][] argsArray = new byte[args.size()][];
    args.toArray(argsArray);

    sendCommand(GEOADD, argsArray);
  }

  void geodist(byte[] key, byte[] member1, byte[] member2) {
    sendCommand(GEODIST, key, member1, member2);
  }

  void geodist(byte[] key, byte[] member1, byte[] member2, GeoUnit unit) {
    sendCommand(GEODIST, key, member1, member2, unit.raw);
  }

  void geohash(byte[] key, byte[] members...) {
    sendCommand(GEOHASH, joinParameters(key, members));
  }

  void geopos(byte[] key, byte[][] members) {
    sendCommand(GEOPOS, joinParameters(key, members));
  }

  void georadius(byte[] key, double longitude, double latitude, double radius, GeoUnit unit) {
    sendCommand(GEORADIUS, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
      unit.raw);
  }

  void georadiusReadonly(byte[] key, double longitude, double latitude, double radius, GeoUnit unit) {
    sendCommand(GEORADIUS_RO, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
      unit.raw);
  }

  void georadius(byte[] key, double longitude, double latitude, double radius, GeoUnit unit,
      GeoRadiusParam param) {
    sendCommand(GEORADIUS, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
      toByteArray(radius), unit.raw));
  }

  void georadiusReadonly(byte[] key, double longitude, double latitude, double radius, GeoUnit unit,
      GeoRadiusParam param) {
    sendCommand(GEORADIUS_RO, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
      toByteArray(radius), unit.raw));
  }

  void georadiusByMember(byte[] key, byte[] member, double radius, GeoUnit unit) {
    sendCommand(GEORADIUSBYMEMBER, key, member, toByteArray(radius), unit.raw);
  }

  void georadiusByMemberReadonly(byte[] key, byte[] member, double radius, GeoUnit unit) {
    sendCommand(GEORADIUSBYMEMBER_RO, key, member, toByteArray(radius), unit.raw);
  }

  void georadiusByMember(byte[] key, byte[] member, double radius, GeoUnit unit,
      GeoRadiusParam param) {
    sendCommand(GEORADIUSBYMEMBER, param.getByteParams(key, member, toByteArray(radius), unit.raw));
  }

  void georadiusByMemberReadonly(byte[] key, byte[] member, double radius, GeoUnit unit,
      GeoRadiusParam param) {
    sendCommand(GEORADIUSBYMEMBER_RO, param.getByteParams(key, member, toByteArray(radius), unit.raw));
  }

  void moduleLoad(byte[] path) {
    sendCommand(MODULE, Keyword.LOAD.raw, path);
  }

  void moduleList() {
    sendCommand(MODULE, Keyword.LIST.raw);
  }

  void moduleUnload(byte[] name) {
    sendCommand(MODULE, Keyword.UNLOAD.raw, name);
  }

  private ArrayList!(byte[]) convertScoreMembersToByteArrays(Map!(byte[], Double) scoreMembers) {
    ArrayList!(byte[]) args = new ArrayList!(byte[])(scoreMembers.size() * 2);

    foreach(Map.Entry!(byte[], Double) entry ; scoreMembers.entrySet()) {
      args.add(toByteArray(entry.getValue()));
      args.add(entry.getKey());
    }

    return args;
  }

  private List!(byte[]) convertGeoCoordinateMapToByteArrays(
      Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    List!(byte[]) args = new ArrayList!(byte[])(memberCoordinateMap.size() * 3);

    foreach(Entry!(byte[], GeoCoordinate) entry ; memberCoordinateMap.entrySet()) {
      GeoCoordinate coordinate = entry.getValue();
      args.add(toByteArray(coordinate.getLongitude()));
      args.add(toByteArray(coordinate.getLatitude()));
      args.add(entry.getKey());
    }

    return args;
  }

  void bitfield(byte[] key, byte[] value...) {
    sendCommand(BITFIELD, joinParameters(key, value));
  }

  void hstrlen(byte[] key, byte[] field) {
    sendCommand(HSTRLEN, key, field);
  }
  
  void xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength) {
      int maxLexArgs = 0;
      if(maxLen < Long.MAX_VALUE) { // optional arguments
        if(approximateLength) {
          maxLexArgs = 3; // e.g. MAXLEN ~ 1000 
        } else {
          maxLexArgs = 2; // e.g. MAXLEN 1000
        }
      }
    
	  byte[][] params = new byte[2 + maxLexArgs + hash.size() * 2][];
	  int index = 0;
	  params[index++] = key;
	  if(maxLen < Long.MAX_VALUE) {
	    params[index++] = Keyword.MAXLEN.raw;
	    if(approximateLength) {
	      params[index++] = Protocol.BYTES_TILDE;
	    }
	    params[index++] = toByteArray(maxLen);
	  }
	  
	  params[index++] = id;
	  foreach(Entry!(byte[], byte[]) entry ; hash.entrySet()) {
	    params[index++] = entry.getKey();
	    params[index++] = entry.getValue();
	  }
	  sendCommand(XADD, params);
  }
  
  void xlen(byte[] key) {
     sendCommand(XLEN, key);
  }
  
  void xrange(byte[] key, byte[] start, byte[] end, long count) { 
     sendCommand(XRANGE, key, start, end, Keyword.COUNT.raw, toByteArray(count));
  }
  
  void xrevrange(byte[] key, byte[] end, byte[] start, int count) {
    sendCommand(XREVRANGE, key, end, start, Keyword.COUNT.raw, toByteArray(count));
  }

  void xread(int count, long block, Map!(byte[], byte[]) streams) {
    byte[][] params = new byte[3 + streams.size() * 2 + (block > 0 ? 2 : 0)][];

    int streamsIndex = 0;
    params[streamsIndex++] = Keyword.COUNT.raw;
    params[streamsIndex++] = toByteArray(count);
    if(block > 0) {
      params[streamsIndex++] = Keyword.BLOCK.raw;
      params[streamsIndex++] = toByteArray(block);
    }
    
    params[streamsIndex++] = Keyword.STREAMS.raw;
    int idsIndex = streamsIndex + streams.size();

    foreach(Entry!(byte[], byte[]) entry ; streams.entrySet()) {
      params[streamsIndex++] = entry.getKey();
      params[idsIndex++] = entry.getValue();
    }
    
    sendCommand(XREAD, params);
 }
  
  void xack(byte[] key, byte[] group, byte[] ids...) {
    byte[][] params = new byte[2 + ids.length][];
    int index = 0;
    params[index++] = key;
    params[index++] = group;
    foreach(byte[] id ; ids) {
      params[index++] = id;
    }
    sendCommand(XACK, params);
  }
   
  void xgroupCreate(byte[] key, byte[] groupname, byte[] id, bool makeStream) {
    if(makeStream) {
      sendCommand(XGROUP, Keyword.CREATE.raw, key, groupname, id, Keyword.MKSTREAM.raw);  
    } else {
      sendCommand(XGROUP, Keyword.CREATE.raw, key, groupname, id);  
    }
  }

  void xgroupSetID(byte[] key, byte[] groupname, byte[] id) {
    sendCommand(XGROUP, Keyword.SETID.raw, key, groupname, id);    
  }

  void xgroupDestroy(byte[] key, byte[] groupname) {
    sendCommand(XGROUP, Keyword.DESTROY.raw, key, groupname);    
  }

  void xgroupDelConsumer(byte[] key, byte[] groupname, byte[] consumerName) {
    sendCommand(XGROUP, Keyword.DELCONSUMER.raw, key, groupname, consumerName);    
  }
   
  void xdel(byte[] key, byte[] ids...) {
    byte[][] params = new byte[1 + ids.length][];
    int index = 0;
    params[index++] = key;
    foreach(byte[] id ; ids) {
      params[index++] = id;
    }
    sendCommand(XDEL, params);
  }
  
  void xtrim(byte[] key, long maxLen, bool approximateLength) {
    if(approximateLength) {
      sendCommand(XTRIM, key, Keyword.MAXLEN.raw, Protocol.BYTES_TILDE ,toByteArray(maxLen));
    } else {
      sendCommand(XTRIM, key, Keyword.MAXLEN.raw, toByteArray(maxLen));
    }
  }
  
  void xreadGroup(byte[] groupname, byte[] consumer, int count, long block, bool noAck, Map!(byte[], byte[]) streams) {
    
    int optional = 0;
    if(count>0) {
      optional += 2;
    }
    if(block > 0) {
      optional += 2;
    }
    if(noAck) {
      optional += 1;
    }
    
    
    byte[][] params = new byte[4 + optional + streams.size() * 2][];

    int streamsIndex = 0;
    params[streamsIndex++] = Keyword.GROUP.raw;
    params[streamsIndex++] = groupname;
    params[streamsIndex++] = consumer;
    if(count>0) {
      params[streamsIndex++] = Keyword.COUNT.raw;
      params[streamsIndex++] = toByteArray(count);
    }
    if(block > 0) {
      params[streamsIndex++] = Keyword.BLOCK.raw;
      params[streamsIndex++] = toByteArray(block);
    }
    if(noAck) {
      params[streamsIndex++] = Keyword.NOACK.raw;
    }
    params[streamsIndex++] = Keyword.STREAMS.raw;
    
    int idsIndex = streamsIndex + streams.size();
    foreach(Entry!(byte[], byte[]) entry ; streams.entrySet()) {
      params[streamsIndex++] = entry.getKey();
      params[idsIndex++] = entry.getValue();
    }
    
    sendCommand(XREADGROUP, params);
  }

  
  void xpending(byte[] key, byte[] groupname, byte[] start, 
                byte[] end, int count, byte[] consumername) {
    if(consumername == null) {
      sendCommand(XPENDING, key, groupname, start, end, toByteArray(count));
    } else {
      sendCommand(XPENDING, key, groupname, start, end, toByteArray(count), consumername);
    }
  }

  void xclaim(byte[] key, byte[] groupname, byte[] consumername, long minIdleTime, 
              long newIdleTime, int retries, bool force, byte[][] ids) {
      
      ArrayList!(byte[]) arguments = new ArrayList!(byte[])(10 + ids.length);

      arguments.add(key);
      arguments.add(groupname);
      arguments.add(consumername);
      arguments.add(toByteArray(minIdleTime));
      
      foreach(byte[] id ; ids) {
        arguments.add(id);  
      }
      if(newIdleTime > 0) {
        arguments.add(Keyword.IDLE.raw);
        arguments.add(toByteArray(newIdleTime));
      }
      if(retries > 0) {
        arguments.add(Keyword.RETRYCOUNT.raw);
        arguments.add(toByteArray(retries));        
      }
      if(force) {
        arguments.add(Keyword.FORCE.raw);        
      }
      sendCommand(XCLAIM, arguments.toArray(new byte[arguments.size()][]));
  }

}
