module hunt.redis.Client;

import hunt.redis.Protocol.toByteArray;

import hunt.collection.ArraryList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;

import hunt.redis.commands.Commands;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;

class Client : BinaryClient implements Commands {

  Client() {
    super();
  }

  Client(final String host) {
    super(host);
  }

  Client(final String host, final int port) {
    super(host, port);
  }

  Client(final String host, final int port, final bool ssl) {
    super(host, port, ssl);
  }

  Client(final String host, final int port, final bool ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    super(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  override
  void ping(final String message) {
    ping(SafeEncoder.encode(message));
  }
  
  override
  void set(final String key, final String value) {
    set(SafeEncoder.encode(key), SafeEncoder.encode(value));
  }

  override
  void set(final String key, final String value, final SetParams params) {
    set(SafeEncoder.encode(key), SafeEncoder.encode(value), params);
  }

  override
  void get(final String key) {
    get(SafeEncoder.encode(key));
  }

  override
  void exists(final String keys...) {
    exists(SafeEncoder.encodeMany(keys));
  }

  override
  void del(final String keys...) {
    del(SafeEncoder.encodeMany(keys));
  }

  override
  void unlink(final String keys...) {
    unlink(SafeEncoder.encodeMany(keys));
  }

  override
  void type(final String key) {
    type(SafeEncoder.encode(key));
  }

  override
  void keys(final String pattern) {
    keys(SafeEncoder.encode(pattern));
  }

  override
  void rename(final String oldkey, final String newkey) {
    rename(SafeEncoder.encode(oldkey), SafeEncoder.encode(newkey));
  }

  override
  void renamenx(final String oldkey, final String newkey) {
    renamenx(SafeEncoder.encode(oldkey), SafeEncoder.encode(newkey));
  }

  override
  void expire(final String key, final int seconds) {
    expire(SafeEncoder.encode(key), seconds);
  }

  override
  void expireAt(final String key, final long unixTime) {
    expireAt(SafeEncoder.encode(key), unixTime);
  }

  override
  void ttl(final String key) {
    ttl(SafeEncoder.encode(key));
  }

  override
  void touch(final String keys...) {
    touch(SafeEncoder.encodeMany(keys));
  }

  override
  void move(final String key, final int dbIndex) {
    move(SafeEncoder.encode(key), dbIndex);
  }

  override
  void getSet(final String key, final String value) {
    getSet(SafeEncoder.encode(key), SafeEncoder.encode(value));
  }

  override
  void mget(final String keys...) {
    mget(SafeEncoder.encodeMany(keys));
  }

  override
  void setnx(final String key, final String value) {
    setnx(SafeEncoder.encode(key), SafeEncoder.encode(value));
  }

  override
  void setex(final String key, final int seconds, final String value) {
    setex(SafeEncoder.encode(key), seconds, SafeEncoder.encode(value));
  }

  override
  void mset(final String keysvalues...) {
    mset(SafeEncoder.encodeMany(keysvalues));
  }

  override
  void msetnx(final String keysvalues...) {
    msetnx(SafeEncoder.encodeMany(keysvalues));
  }

  override
  void decrBy(final String key, final long decrement) {
    decrBy(SafeEncoder.encode(key), decrement);
  }

  override
  void decr(final String key) {
    decr(SafeEncoder.encode(key));
  }

  override
  void incrBy(final String key, final long increment) {
    incrBy(SafeEncoder.encode(key), increment);
  }

  override
  void incr(final String key) {
    incr(SafeEncoder.encode(key));
  }

  override
  void append(final String key, final String value) {
    append(SafeEncoder.encode(key), SafeEncoder.encode(value));
  }

  override
  void substr(final String key, final int start, final int end) {
    substr(SafeEncoder.encode(key), start, end);
  }

  override
  void hset(final String key, final String field, final String value) {
    hset(SafeEncoder.encode(key), SafeEncoder.encode(field), SafeEncoder.encode(value));
  }

  override
  void hset(final String key, final Map!(String, String) hash) {
    final Map!(byte[], byte[]) bhash = new HashMap!(byte[], byte[])(hash.size());
    foreach(Entry!(String, String) entry ; hash.entrySet()) {
      bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue()));
    }
    hset(SafeEncoder.encode(key), bhash);
  }

  override
  void hget(final String key, final String field) {
    hget(SafeEncoder.encode(key), SafeEncoder.encode(field));
  }

  override
  void hsetnx(final String key, final String field, final String value) {
    hsetnx(SafeEncoder.encode(key), SafeEncoder.encode(field), SafeEncoder.encode(value));
  }

  override
  void hmset(final String key, final Map!(String, String) hash) {
    final Map!(byte[], byte[]) bhash = new HashMap!(byte[], byte[])(hash.size());
    foreach(Entry!(String, String) entry ; hash.entrySet()) {
      bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue()));
    }
    hmset(SafeEncoder.encode(key), bhash);
  }

  override
  void hmget(final String key, final String fields...) {
    hmget(SafeEncoder.encode(key), SafeEncoder.encodeMany(fields));
  }

  override
  void hincrBy(final String key, final String field, final long value) {
    hincrBy(SafeEncoder.encode(key), SafeEncoder.encode(field), value);
  }

  override
  void hexists(final String key, final String field) {
    hexists(SafeEncoder.encode(key), SafeEncoder.encode(field));
  }

  override
  void hdel(final String key, final String fields...) {
    hdel(SafeEncoder.encode(key), SafeEncoder.encodeMany(fields));
  }

  override
  void hlen(final String key) {
    hlen(SafeEncoder.encode(key));
  }

  override
  void hkeys(final String key) {
    hkeys(SafeEncoder.encode(key));
  }

  override
  void hvals(final String key) {
    hvals(SafeEncoder.encode(key));
  }

  override
  void hgetAll(final String key) {
    hgetAll(SafeEncoder.encode(key));
  }

  override
  void rpush(final String key, final String string...) {
    rpush(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
  }

  override
  void lpush(final String key, final String string...) {
    lpush(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
  }

  override
  void llen(final String key) {
    llen(SafeEncoder.encode(key));
  }

  override
  void lrange(final String key, final long start, final long stop) {
    lrange(SafeEncoder.encode(key), start, stop);
  }

  override
  void ltrim(final String key, final long start, final long stop) {
    ltrim(SafeEncoder.encode(key), start, stop);
  }

  override
  void lindex(final String key, final long index) {
    lindex(SafeEncoder.encode(key), index);
  }

  override
  void lset(final String key, final long index, final String value) {
    lset(SafeEncoder.encode(key), index, SafeEncoder.encode(value));
  }

  override
  void lrem(final String key, final long count, final String value) {
    lrem(SafeEncoder.encode(key), count, SafeEncoder.encode(value));
  }

  override
  void lpop(final String key) {
    lpop(SafeEncoder.encode(key));
  }

  override
  void rpop(final String key) {
    rpop(SafeEncoder.encode(key));
  }

  override
  void rpoplpush(final String srckey, final String dstkey) {
    rpoplpush(SafeEncoder.encode(srckey), SafeEncoder.encode(dstkey));
  }

  override
  void sadd(final String key, final String members...) {
    sadd(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
  }

  override
  void smembers(final String key) {
    smembers(SafeEncoder.encode(key));
  }

  override
  void srem(final String key, final String members...) {
    srem(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
  }

  override
  void spop(final String key) {
    spop(SafeEncoder.encode(key));
  }

  override
  void spop(final String key, final long count) {
    spop(SafeEncoder.encode(key), count);
  }

  override
  void smove(final String srckey, final String dstkey, final String member) {
    smove(SafeEncoder.encode(srckey), SafeEncoder.encode(dstkey), SafeEncoder.encode(member));
  }

  override
  void scard(final String key) {
    scard(SafeEncoder.encode(key));
  }

  override
  void sismember(final String key, final String member) {
    sismember(SafeEncoder.encode(key), SafeEncoder.encode(member));
  }

  override
  void sinter(final String keys...) {
    sinter(SafeEncoder.encodeMany(keys));
  }

  override
  void sinterstore(final String dstkey, final String keys...) {
    sinterstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
  }

  override
  void sunion(final String keys...) {
    sunion(SafeEncoder.encodeMany(keys));
  }

  override
  void sunionstore(final String dstkey, final String keys...) {
    sunionstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
  }

  override
  void sdiff(final String keys...) {
    sdiff(SafeEncoder.encodeMany(keys));
  }

  override
  void sdiffstore(final String dstkey, final String keys...) {
    sdiffstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
  }

  override
  void srandmember(final String key) {
    srandmember(SafeEncoder.encode(key));
  }

  override
  void zadd(final String key, final double score, final String member) {
    zadd(SafeEncoder.encode(key), score, SafeEncoder.encode(member));
  }

  override
  void zadd(final String key, final double score, final String member,
      final ZAddParams params) {
    zadd(SafeEncoder.encode(key), score, SafeEncoder.encode(member), params);
  }

  override
  void zadd(final String key, final Map!(String, Double) scoreMembers) {
    HashMap!(byte[], Double) binaryScoreMembers = convertScoreMembersToBinary(scoreMembers);
    zadd(SafeEncoder.encode(key), binaryScoreMembers);
  }

  override
  void zadd(final String key, final Map!(String, Double) scoreMembers, final ZAddParams params) {
    HashMap!(byte[], Double) binaryScoreMembers = convertScoreMembersToBinary(scoreMembers);
    zadd(SafeEncoder.encode(key), binaryScoreMembers, params);
  }

  override
  void zrange(final String key, final long start, final long stop) {
    zrange(SafeEncoder.encode(key), start, stop);
  }

  override
  void zrem(final String key, final String members...) {
    zrem(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
  }

  override
  void zincrby(final String key, final double increment, final String member) {
    zincrby(SafeEncoder.encode(key), increment, SafeEncoder.encode(member));
  }

  override
  void zincrby(final String key, final double increment, final String member, final ZIncrByParams params) {
    zincrby(SafeEncoder.encode(key), increment, SafeEncoder.encode(member), params);
  }

  override
  void zrank(final String key, final String member) {
    zrank(SafeEncoder.encode(key), SafeEncoder.encode(member));
  }

  override
  void zrevrank(final String key, final String member) {
    zrevrank(SafeEncoder.encode(key), SafeEncoder.encode(member));
  }

  override
  void zrevrange(final String key, final long start, final long stop) {
    zrevrange(SafeEncoder.encode(key), start, stop);
  }

  override
  void zrangeWithScores(final String key, final long start, final long stop) {
    zrangeWithScores(SafeEncoder.encode(key), start, stop);
  }

  override
  void zrevrangeWithScores(final String key, final long start, final long stop) {
    zrevrangeWithScores(SafeEncoder.encode(key), start, stop);
  }

  override
  void zcard(final String key) {
    zcard(SafeEncoder.encode(key));
  }

  override
  void zscore(final String key, final String member) {
    zscore(SafeEncoder.encode(key), SafeEncoder.encode(member));
  }

  override
  void watch(final String keys...) {
    watch(SafeEncoder.encodeMany(keys));
  }

  override
  void sort(final String key) {
    sort(SafeEncoder.encode(key));
  }

  override
  void sort(final String key, final SortingParams sortingParameters) {
    sort(SafeEncoder.encode(key), sortingParameters);
  }

  override
  void blpop(final String[] args) {
    blpop(SafeEncoder.encodeMany(args));
  }

  void blpop(final int timeout, final String keys...) {
    final int size = keys.length + 1;
    List!(String) args = new ArrayList!(String)(size);
    foreach(String arg ; keys) {
      args.add(arg);
    }
    args.add(String.valueOf(timeout));
    blpop(args.toArray(new String[size]));
  }

  override
  void sort(final String key, final SortingParams sortingParameters, final String dstkey) {
    sort(SafeEncoder.encode(key), sortingParameters, SafeEncoder.encode(dstkey));
  }

  override
  void sort(final String key, final String dstkey) {
    sort(SafeEncoder.encode(key), SafeEncoder.encode(dstkey));
  }

  override
  void brpop(final String[] args) {
    brpop(SafeEncoder.encodeMany(args));
  }

  void brpop(final int timeout, final String keys...) {
    final int size = keys.length + 1;
    List!(String) args = new ArrayList!(String)(size);
    foreach(String arg ; keys) {
      args.add(arg);
    }
    args.add(String.valueOf(timeout));
    brpop(args.toArray(new String[size]));
  }

  override
  void zcount(final String key, final double min, final double max) {
    zcount(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
  }

  override
  void zcount(final String key, final String min, final String max) {
    zcount(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  override
  void zrangeByScore(final String key, final double min, final double max) {
    zrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
  }

  override
  void zrangeByScore(final String key, final String min, final String max) {
    zrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  override
  void zrangeByScore(final String key, final double min, final double max, final int offset,
      final int count) {
    zrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max), offset, count);
  }

  override
  void zrangeByScoreWithScores(final String key, final double min, final double max) {
    zrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
  }

  override
  void zrangeByScoreWithScores(final String key, final double min, final double max,
      final int offset, final int count) {
    zrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(min), toByteArray(max), offset,
      count);
  }

  override
  void zrevrangeByScore(final String key, final double max, final double min) {
    zrevrangeByScore(SafeEncoder.encode(key), toByteArray(max), toByteArray(min));
  }

  override
  void zrangeByScore(final String key, final String min, final String max, final int offset,
      final int count) {
    zrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max),
      offset, count);
  }

  override
  void zrangeByScoreWithScores(final String key, final String min, final String max) {
    zrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(min),
      SafeEncoder.encode(max));
  }

  override
  void zrangeByScoreWithScores(final String key, final String min, final String max,
      final int offset, final int count) {
    zrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(min),
      SafeEncoder.encode(max), offset, count);
  }

  override
  void zrevrangeByScore(final String key, final String max, final String min) {
    zrevrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min));
  }

  override
  void zrevrangeByScore(final String key, final double max, final double min,
      final int offset, final int count) {
    zrevrangeByScore(SafeEncoder.encode(key), toByteArray(max), toByteArray(min), offset, count);
  }

  override
  void zrevrangeByScore(final String key, final String max, final String min,
      final int offset, final int count) {
    zrevrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min),
      offset, count);
  }

  override
  void zrevrangeByScoreWithScores(final String key, final double max, final double min) {
    zrevrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(max), toByteArray(min));
  }

  override
  void zrevrangeByScoreWithScores(final String key, final String max, final String min) {
    zrevrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(max),
      SafeEncoder.encode(min));
  }

  override
  void zrevrangeByScoreWithScores(final String key, final double max, final double min,
      final int offset, final int count) {
    zrevrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(max), toByteArray(min), offset,
      count);
  }

  override
  void zrevrangeByScoreWithScores(final String key, final String max, final String min,
      final int offset, final int count) {
    zrevrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(max),
      SafeEncoder.encode(min), offset, count);
  }

  override
  void zremrangeByRank(final String key, final long start, final long stop) {
    zremrangeByRank(SafeEncoder.encode(key), start, stop);
  }

  override
  void zremrangeByScore(final String key, final double min, final double max) {
    zremrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
  }

  override
  void zremrangeByScore(final String key, final String min, final String max) {
    zremrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  override
  void zunionstore(final String dstkey, final String sets...) {
    zunionstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(sets));
  }

  override
  void zunionstore(final String dstkey, final ZParams params, final String sets...) {
    zunionstore(SafeEncoder.encode(dstkey), params, SafeEncoder.encodeMany(sets));
  }

  override
  void zinterstore(final String dstkey, final String sets...) {
    zinterstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(sets));
  }

  override
  void zinterstore(final String dstkey, final ZParams params, final String sets...) {
    zinterstore(SafeEncoder.encode(dstkey), params, SafeEncoder.encodeMany(sets));
  }

  void zlexcount(final String key, final String min, final String max) {
    zlexcount(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  void zrangeByLex(final String key, final String min, final String max) {
    zrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  void zrangeByLex(final String key, final String min, final String max, final int offset,
      final int count) {
    zrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max), offset,
      count);
  }

  void zrevrangeByLex(final String key, final String max, final String min) {
    zrevrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min));
  }

  void zrevrangeByLex(final String key, final String max, final String min, final int offset, final int count) {
    zrevrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min),
      offset, count);
  }

  void zremrangeByLex(final String key, final String min, final String max) {
    zremrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
  }

  override
  void strlen(final String key) {
    strlen(SafeEncoder.encode(key));
  }

  override
  void lpushx(final String key, final String string...) {
    lpushx(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
  }

  override
  void persist(final String key) {
    persist(SafeEncoder.encode(key));
  }

  override
  void rpushx(final String key, final String string...) {
    rpushx(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
  }

  override
  void echo(final String string) {
    echo(SafeEncoder.encode(string));
  }

  override
  void linsert(final String key, final ListPosition where, final String pivot,
      final String value) {
    linsert(SafeEncoder.encode(key), where, SafeEncoder.encode(pivot), SafeEncoder.encode(value));
  }

  override
  void brpoplpush(final String source, final String destination, final int timeout) {
    brpoplpush(SafeEncoder.encode(source), SafeEncoder.encode(destination), timeout);
  }

  override
  void setbit(final String key, final long offset, final bool value) {
    setbit(SafeEncoder.encode(key), offset, value);
  }

  override
  void setbit(final String key, final long offset, final String value) {
    setbit(SafeEncoder.encode(key), offset, SafeEncoder.encode(value));
  }

  override
  void getbit(final String key, final long offset) {
    getbit(SafeEncoder.encode(key), offset);
  }

  void bitpos(final String key, final bool value, final BitPosParams params) {
    bitpos(SafeEncoder.encode(key), value, params);
  }

  override
  void setrange(final String key, final long offset, final String value) {
    setrange(SafeEncoder.encode(key), offset, SafeEncoder.encode(value));
  }

  override
  void getrange(final String key, final long startOffset, final long endOffset) {
    getrange(SafeEncoder.encode(key), startOffset, endOffset);
  }

  void publish(final String channel, final String message) {
    publish(SafeEncoder.encode(channel), SafeEncoder.encode(message));
  }

  void unsubscribe(final String channels...) {
    unsubscribe(SafeEncoder.encodeMany(channels));
  }

  void psubscribe(final String patterns...) {
    psubscribe(SafeEncoder.encodeMany(patterns));
  }

  void punsubscribe(final String patterns...) {
    punsubscribe(SafeEncoder.encodeMany(patterns));
  }

  void subscribe(final String channels...) {
    subscribe(SafeEncoder.encodeMany(channels));
  }

  void pubsubChannels(final String pattern) {
    pubsub(Protocol.PUBSUB_CHANNELS, pattern);
  }

  void pubsubNumPat() {
    pubsub(Protocol.PUBSUB_NUM_PAT);
  }

  void pubsubNumSub(final String channels...) {
    pubsub(Protocol.PUBSUB_NUMSUB, channels);
  }

  override
  void configSet(final String parameter, final String value) {
    configSet(SafeEncoder.encode(parameter), SafeEncoder.encode(value));
  }

  override
  void configGet(final String pattern) {
    configGet(SafeEncoder.encode(pattern));
  }

  void eval(final String script, final int keyCount, final String params...) {
    eval(SafeEncoder.encode(script), toByteArray(keyCount), SafeEncoder.encodeMany(params));
  }

  void evalsha(final String sha1, final int keyCount, final String params...) {
    evalsha(SafeEncoder.encode(sha1), toByteArray(keyCount), SafeEncoder.encodeMany(params));
  }

  void scriptExists(final String sha1...) {
    scriptExists(SafeEncoder.encodeMany(sha1));
  }

  void scriptLoad(final String script) {
    scriptLoad(SafeEncoder.encode(script));
  }

  override
  void objectRefcount(final String key) {
    objectRefcount(SafeEncoder.encode(key));
  }

  override
  void objectIdletime(final String key) {
    objectIdletime(SafeEncoder.encode(key));
  }

  override
  void objectEncoding(final String key) {
    objectEncoding(SafeEncoder.encode(key));
  }

  override
  void bitcount(final String key) {
    bitcount(SafeEncoder.encode(key));
  }

  override
  void bitcount(final String key, final long start, final long end) {
    bitcount(SafeEncoder.encode(key), start, end);
  }

  override
  void bitop(final BitOP op, final String destKey, final String srcKeys...) {
    bitop(op, SafeEncoder.encode(destKey), SafeEncoder.encodeMany(srcKeys));
  }

  void sentinel(final String args...) {
    sentinel(SafeEncoder.encodeMany(args));
  }

  override
  void dump(final String key) {
    dump(SafeEncoder.encode(key));
  }

  override
  void restore(final String key, final int ttl, final byte[] serializedValue) {
    restore(SafeEncoder.encode(key), ttl, serializedValue);
  }

  override
  void restoreReplace(final String key, final int ttl, final byte[] serializedValue) {
    restoreReplace(SafeEncoder.encode(key), ttl, serializedValue);
  }

  void pexpire(final String key, final long milliseconds) {
    pexpire(SafeEncoder.encode(key), milliseconds);
  }

  void pexpireAt(final String key, final long millisecondsTimestamp) {
    pexpireAt(SafeEncoder.encode(key), millisecondsTimestamp);
  }

  override
  void pttl(final String key) {
    pttl(SafeEncoder.encode(key));
  }

  override
  void incrByFloat(final String key, final double increment) {
    incrByFloat(SafeEncoder.encode(key), increment);
  }

  void psetex(final String key, final long milliseconds, final String value) {
    psetex(SafeEncoder.encode(key), milliseconds, SafeEncoder.encode(value));
  }

  void srandmember(final String key, final int count) {
    srandmember(SafeEncoder.encode(key), count);
  }

  void clientKill(final String ipPort) {
    clientKill(SafeEncoder.encode(ipPort));
  }

  void clientSetname(final String name) {
    clientSetname(SafeEncoder.encode(name));
  }

  override
  void migrate(final String host, final int port, final String key,
      final int destinationDb, final int timeout) {
    migrate(host, port, SafeEncoder.encode(key), destinationDb, timeout);
  }

  override
  void migrate(final String host, final int port, final int destinationDB,
      final int timeout, final MigrateParams params, String keys...) {
    migrate(host, port, destinationDB, timeout, params, SafeEncoder.encodeMany(keys));
  }

  override
  void hincrByFloat(final String key, final String field, final double increment) {
    hincrByFloat(SafeEncoder.encode(key), SafeEncoder.encode(field), increment);
  }

  override
  void scan(final String cursor, final ScanParams params) {
    scan(SafeEncoder.encode(cursor), params);
  }

  override
  void hscan(final String key, final String cursor, final ScanParams params) {
    hscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
  }

  override
  void sscan(final String key, final String cursor, final ScanParams params) {
    sscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
  }

  override
  void zscan(final String key, final String cursor, final ScanParams params) {
    zscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
  }

  void cluster(final String subcommand, final int args...) {
    final byte[][] arg = new byte[args.length + 1][];
    for (int i = 1; i < arg.length; i++) {
      arg[i] = toByteArray(args[i - 1]);
    }
    arg[0] = SafeEncoder.encode(subcommand);
    cluster(arg);
  }

  void pubsub(final String subcommand, final String args...) {
    final byte[][] arg = new byte[args.length + 1][];
    for (int i = 1; i < arg.length; i++) {
      arg[i] = SafeEncoder.encode(args[i - 1]);
    }
    arg[0] = SafeEncoder.encode(subcommand);
    pubsub(arg);
  }

  void cluster(final String subcommand, final String args...) {
    final byte[][] arg = new byte[args.length + 1][];
    for (int i = 1; i < arg.length; i++) {
      arg[i] = SafeEncoder.encode(args[i - 1]);
    }
    arg[0] = SafeEncoder.encode(subcommand);
    cluster(arg);
  }

  void cluster(final String subcommand) {
    final byte[][] arg = new byte[1][];
    arg[0] = SafeEncoder.encode(subcommand);
    cluster(arg);
  }

  void clusterNodes() {
    cluster(Protocol.CLUSTER_NODES);
  }

  void clusterMeet(final String ip, final int port) {
    cluster(Protocol.CLUSTER_MEET, ip, String.valueOf(port));
  }

  void clusterReset(final ClusterReset resetType) {
    cluster(Protocol.CLUSTER_RESET, resetType.name());
  }

  void clusterAddSlots(final int slots...) {
    cluster(Protocol.CLUSTER_ADDSLOTS, slots);
  }

  void clusterDelSlots(final int slots...) {
    cluster(Protocol.CLUSTER_DELSLOTS, slots);
  }

  void clusterInfo() {
    cluster(Protocol.CLUSTER_INFO);
  }

  void clusterGetKeysInSlot(final int slot, final int count) {
    final int[] args = new int[] { slot, count };
    cluster(Protocol.CLUSTER_GETKEYSINSLOT, args);
  }

  void clusterSetSlotNode(final int slot, final String nodeId) {
    cluster(Protocol.CLUSTER_SETSLOT, String.valueOf(slot), Protocol.CLUSTER_SETSLOT_NODE, nodeId);
  }

  void clusterSetSlotMigrating(final int slot, final String nodeId) {
    cluster(Protocol.CLUSTER_SETSLOT, String.valueOf(slot), Protocol.CLUSTER_SETSLOT_MIGRATING,
      nodeId);
  }

  void clusterSetSlotImporting(final int slot, final String nodeId) {
    cluster(Protocol.CLUSTER_SETSLOT, String.valueOf(slot), Protocol.CLUSTER_SETSLOT_IMPORTING,
      nodeId);
  }

  void pfadd(final String key, final String elements...) {
    pfadd(SafeEncoder.encode(key), SafeEncoder.encodeMany(elements));
  }

  void pfcount(final String key) {
    pfcount(SafeEncoder.encode(key));
  }

  void pfcount(final String keys...) {
    pfcount(SafeEncoder.encodeMany(keys));
  }

  void pfmerge(final String destkey, final String sourcekeys...) {
    pfmerge(SafeEncoder.encode(destkey), SafeEncoder.encodeMany(sourcekeys));
  }

  void clusterSetSlotStable(final int slot) {
    cluster(Protocol.CLUSTER_SETSLOT, String.valueOf(slot), Protocol.CLUSTER_SETSLOT_STABLE);
  }

  void clusterForget(final String nodeId) {
    cluster(Protocol.CLUSTER_FORGET, nodeId);
  }

  void clusterFlushSlots() {
    cluster(Protocol.CLUSTER_FLUSHSLOT);
  }

  void clusterKeySlot(final String key) {
    cluster(Protocol.CLUSTER_KEYSLOT, key);
  }

  void clusterCountKeysInSlot(final int slot) {
    cluster(Protocol.CLUSTER_COUNTKEYINSLOT, String.valueOf(slot));
  }

  void clusterSaveConfig() {
    cluster(Protocol.CLUSTER_SAVECONFIG);
  }

  void clusterReplicate(final String nodeId) {
    cluster(Protocol.CLUSTER_REPLICATE, nodeId);
  }

  void clusterSlaves(final String nodeId) {
    cluster(Protocol.CLUSTER_SLAVES, nodeId);
  }

  void clusterFailover() {
    cluster(Protocol.CLUSTER_FAILOVER);
  }

  void clusterSlots() {
    cluster(Protocol.CLUSTER_SLOTS);
  }

  void geoadd(final String key, final double longitude, final double latitude, final String member) {
    geoadd(SafeEncoder.encode(key), longitude, latitude, SafeEncoder.encode(member));
  }

  void geoadd(final String key, final Map!(String, GeoCoordinate) memberCoordinateMap) {
    geoadd(SafeEncoder.encode(key), convertMemberCoordinateMapToBinary(memberCoordinateMap));
  }

  void geodist(final String key, final String member1, final String member2) {
    geodist(SafeEncoder.encode(key), SafeEncoder.encode(member1), SafeEncoder.encode(member2));
  }

  void geodist(final String key, final String member1, final String member2, final GeoUnit unit) {
    geodist(SafeEncoder.encode(key), SafeEncoder.encode(member1), SafeEncoder.encode(member2), unit);
  }

  void geohash(final String key, final String members...) {
    geohash(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
  }

  void geopos(final String key, final String[] members) {
    geopos(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
  }

  void georadius(final String key, final double longitude, final double latitude, final double radius, final GeoUnit unit) {
    georadius(SafeEncoder.encode(key), longitude, latitude, radius, unit);
  }

  void georadiusReadonly(final String key, final double longitude, final double latitude, final double radius, final GeoUnit unit) {
    georadiusReadonly(SafeEncoder.encode(key), longitude, latitude, radius, unit);
  }

  void georadius(final String key, final double longitude, final double latitude, final double radius, final GeoUnit unit,
      final GeoRadiusParam param) {
    georadius(SafeEncoder.encode(key), longitude, latitude, radius, unit, param);
  }

  void georadiusReadonly(final String key, final double longitude, final double latitude, final double radius, final GeoUnit unit,
      final GeoRadiusParam param) {
    georadiusReadonly(SafeEncoder.encode(key), longitude, latitude, radius, unit, param);
  }

  void georadiusByMember(final String key, final String member, final double radius, final GeoUnit unit) {
    georadiusByMember(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit);
  }

  void georadiusByMemberReadonly(final String key, final String member, final double radius, final GeoUnit unit) {
    georadiusByMemberReadonly(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit);
  }

  void georadiusByMember(final String key, final String member, final double radius, final GeoUnit unit,
      final GeoRadiusParam param) {
    georadiusByMember(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit, param);
  }

  void georadiusByMemberReadonly(final String key, final String member, final double radius, final GeoUnit unit,
      final GeoRadiusParam param) {
    georadiusByMemberReadonly(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit, param);
  }

  void moduleLoad(final String path) {
    moduleLoad(SafeEncoder.encode(path));
  }

  void moduleUnload(final String name) {
    moduleUnload(SafeEncoder.encode(name));
  }

  private HashMap!(byte[], Double) convertScoreMembersToBinary(final Map!(String, Double) scoreMembers) {
    HashMap!(byte[], Double) binaryScoreMembers = new HashMap!(byte[], Double)();
    foreach(Entry!(String, Double) entry ; scoreMembers.entrySet()) {
      binaryScoreMembers.put(SafeEncoder.encode(entry.getKey()), entry.getValue());
    }
    return binaryScoreMembers;
  }

  private HashMap!(byte[], GeoCoordinate) convertMemberCoordinateMapToBinary(
      final Map!(String, GeoCoordinate) memberCoordinateMap) {
    HashMap!(byte[], GeoCoordinate) binaryMemberCoordinateMap = new HashMap!(byte[], GeoCoordinate)();
    foreach(Entry!(String, GeoCoordinate) entry ; memberCoordinateMap.entrySet()) {
      binaryMemberCoordinateMap.put(SafeEncoder.encode(entry.getKey()), entry.getValue());
    }
    return binaryMemberCoordinateMap;
  }

  override
  void bitfield(final String key, final String arguments...) {
    bitfield(SafeEncoder.encode(key), SafeEncoder.encodeMany(arguments));
  }

  override
  void hstrlen(final String key, final String field) {
    hstrlen(SafeEncoder.encode(key), SafeEncoder.encode(field));
  }

  override
  void xadd(final String key, final  StreamEntryID id, final Map!(String, String) hash, long maxLen, bool approximateLength) {
    final Map!(byte[], byte[]) bhash = new HashMap<>(hash.size());
    foreach(Entry!(String, String) entry ; hash.entrySet()) {
      bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue()));
    }
    xadd(SafeEncoder.encode(key), SafeEncoder.encode(id==null ? "*" : id.toString()), bhash, maxLen, approximateLength);
  }
  
  override
  void xlen(final String key) {
	  xlen(SafeEncoder.encode(key));
  }
  
  override
  void xrange(final String key, final StreamEntryID start, final  StreamEntryID end, final long count) {
	  xrange(SafeEncoder.encode(key), SafeEncoder.encode(start==null ? "-" : start.toString()), SafeEncoder.encode(end==null ? "+" : end.toString()), count);
  }
  
  override
  void xrevrange(String key, StreamEntryID end, StreamEntryID start, int count) {
    xrevrange(SafeEncoder.encode(key), SafeEncoder.encode(end==null ? "+" : end.toString()), SafeEncoder.encode(start==null ? "-" : start.toString()), count);
  }
  
  override
  void xread(final int count, final long block, final Entry!(String, StreamEntryID) streams...) {
    final Map!(byte[], byte[]) bhash = new HashMap!(byte[], byte[])(streams.length);
    foreach(Entry!(String, StreamEntryID) entry ; streams) {
      bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue()==null ? "0-0" : entry.getValue().toString()));
    }
    xread(count, block, bhash);
  }
  
  override
  void xack(final String key, final String group, final StreamEntryID ids...) {
    final byte[][] bids = new byte[ids.length][];
    for (int i=0 ; i< ids.length; ++i ) {
      StreamEntryID id = ids[i];
      bids[i] = SafeEncoder.encode(id==null ? "0-0" : id.toString()); 
    }
    xack(SafeEncoder.encode(key), SafeEncoder.encode(group), bids);
  }
  
  override
  void xgroupCreate(String key, String groupname, StreamEntryID id, bool makeStream) {
    xgroupCreate(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(id==null ? "0-0" : id.toString()), makeStream);
  }

  override
  void xgroupSetID(String key, String groupname, StreamEntryID id) {
    xgroupSetID(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(id==null ? "0-0" : id.toString()));    
  }

  override
  void xgroupDestroy(String key, String groupname) {
    xgroupDestroy(SafeEncoder.encode(key), SafeEncoder.encode(groupname));    
  }

  override
  void xgroupDelConsumer(String key, String groupname, String consumerName) {
    xgroupDelConsumer(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(consumerName));    
  }

  override
  void xdel(final String key, final StreamEntryID ids...) {
    final byte[][] bids = new byte[ids.length][];
    for (int i=0 ; i< ids.length; ++i ) {
      StreamEntryID id = ids[i];
      bids[i] = SafeEncoder.encode(id==null ? "0-0" : id.toString()); 
    }
    xdel(SafeEncoder.encode(key), bids);    
  }

  override
  void xtrim(String key, long maxLen, bool approximateLength) {
    xtrim(SafeEncoder.encode(key), maxLen, approximateLength);    
  }

  override
  void xreadGroup(String groupname, String consumer, int count, long block, bool noAck, Entry!(String, StreamEntryID) streams...) {
    final Map!(byte[], byte[]) bhash = new HashMap<>(streams.length);
    foreach(Entry!(String, StreamEntryID) entry ; streams) {
      bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue()==null ? ">" : entry.getValue().toString()));
    }
    xreadGroup(SafeEncoder.encode(groupname), SafeEncoder.encode(consumer), count, block, noAck, bhash);    
  }

  override
  void xpending(String key, String groupname, StreamEntryID start, StreamEntryID end, int count, String consumername) {
    xpending(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(start==null ? "-" : start.toString()),
        SafeEncoder.encode(end==null ? "+" : end.toString()), count, consumername == null? null : SafeEncoder.encode(consumername));    
  }

  override
  void xclaim(String key, String group, String consumername, long minIdleTime, long newIdleTime, int retries,
      bool force, StreamEntryID ids...) {
    
    final byte[][] bids = new byte[ids.length][];
    for (int i = 0; i < ids.length; i++) {
      bids[i] = SafeEncoder.encode(ids[i].toString());
    }
    xclaim(SafeEncoder.encode(key), SafeEncoder.encode(group), SafeEncoder.encode(consumername), minIdleTime, newIdleTime, retries, force, bids);    
  }

 
}
