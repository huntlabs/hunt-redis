module hunt.redis.BinaryClient;

import hunt.redis.AbstractClient;
import hunt.redis.BitOP;
import hunt.redis.BitPosParams;
import hunt.redis.ListPosition;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoUnit;
import hunt.redis.Protocol;
import hunt.redis.ScanParams;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;

// import hunt.redis.Protocol.Keyword;
import hunt.redis.params.ClientKillParams;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Double;

import std.conv;

alias Keyword = Protocol.Keyword;
alias Command = Protocol.Command;
alias toByteArray = Protocol.toByteArray;

class BinaryClient : AbstractClient { 

    private bool _isInMulti;

    private string password;

    private int db;

    private bool _isInWatch;

    this() {
        super();
    }

    this(string host) {
        super(host);
    }

    this(string host, int port) {
        super(host, port);
    }

    this(string host, int port, bool ssl) {
        super(host, port, ssl);
    }

    // this(string host, int port, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    bool isInMulti() {
        return _isInMulti;
    }

    bool isInWatch() {
        return _isInWatch;
    }

    private byte[][] joinParameters(byte[] first, byte[][] rest) {
        byte[][] result = new byte[][rest.length + 1];
        result[0] = first;
        // System.arraycopy(rest, 0, result, 1, rest.length);
        result[1 .. $] = rest[0 .. $];
        return result;
    }

    private byte[][] joinParameters(byte[] first, byte[] second, byte[][] rest) {
        byte[][] result = new byte[][rest.length + 2];
        result[0] = first;
        result[1] = second;
        // System.arraycopy(rest, 0, result, 2, rest.length);
        result[2 .. $] = rest[0 .. $];
        return result;
    }

    void setPassword(string password) {
        this.password = password;
    }

    void setDb(int db) {
        this.db = db;
    }

    override
    void connect() {
        if (!isConnected()) {
            super.connect();
            if (password !is null) {
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
        sendCommand(Command.PING);
    }

    void ping(byte[] message) {
        sendCommand(Command.PING, message);
    }

    void set(byte[] key, byte[] value) {
        sendCommand(Command.SET, key, value);
    }

    void set(byte[] key, byte[] value, SetParams params) {
        sendCommand(Command.SET, params.getByteParams(key, value));
    }

    void get(byte[] key) {
        sendCommand(Command.GET, key);
    }

    void quit() {
        db = 0;
        sendCommand(Command.QUIT);
    }

    void exists(byte[][] keys...) {
        sendCommand(Command.EXISTS, keys);
    }

    void del(byte[][] keys...) {
        sendCommand(Command.DEL, keys);
    }

    void unlink(byte[][] keys...) {
        sendCommand(Command.UNLINK, keys);
    }

    void type(byte[] key) {
        sendCommand(Command.TYPE, key);
    }

    void flushDB() {
        sendCommand(Command.FLUSHDB);
    }

    void keys(byte[] pattern) {
        sendCommand(Command.KEYS, pattern);
    }

    void randomKey() {
        sendCommand(Command.RANDOMKEY);
    }

    void rename(byte[] oldkey, byte[] newkey) {
        sendCommand(Command.RENAME, oldkey, newkey);
    }

    void renamenx(byte[] oldkey, byte[] newkey) {
        sendCommand(Command.RENAMENX, oldkey, newkey);
    }

    void dbSize() {
        sendCommand(Command.DBSIZE);
    }

    void expire(byte[] key, int seconds) {
        sendCommand(Command.EXPIRE, key, toByteArray(seconds));
    }

    void expireAt(byte[] key, long unixTime) {
        sendCommand(Command.EXPIREAT, key, toByteArray(unixTime));
    }

    void ttl(byte[] key) {
        sendCommand(Command.TTL, key);
    }

    void touch(byte[][] keys...) {
        sendCommand(Command.TOUCH, keys);
    }

    void select(int index) {
        sendCommand(Command.SELECT, toByteArray(index));
    }

    void swapDB(int index1, int index2) {
        sendCommand(Command.SWAPDB, toByteArray(index1), toByteArray(index2));
    }

    void move(byte[] key, int dbIndex) {
        sendCommand(Command.MOVE, key, toByteArray(dbIndex));
    }

    void flushAll() {
        sendCommand(Command.FLUSHALL);
    }

    void getSet(byte[] key, byte[] value) {
        sendCommand(Command.GETSET, key, value);
    }

    void mget(byte[][] keys...) {
        sendCommand(Command.MGET, keys);
    }

    void setnx(byte[] key, byte[] value) {
        sendCommand(Command.SETNX, key, value);
    }

    void setex(byte[] key, int seconds, byte[] value) {
        sendCommand(Command.SETEX, key, toByteArray(seconds), value);
    }

    void mset(byte[][] keysvalues...) {
        sendCommand(Command.MSET, keysvalues);
    }

    void msetnx(byte[][] keysvalues...) {
        sendCommand(Command.MSETNX, keysvalues);
    }

    void decrBy(byte[] key, long decrement) {
        sendCommand(Command.DECRBY, key, toByteArray(decrement));
    }

    void decr(byte[] key) {
        sendCommand(Command.DECR, key);
    }

    void incrBy(byte[] key, long increment) {
        sendCommand(Command.INCRBY, key, toByteArray(increment));
    }

    void incrByFloat(byte[] key, double increment) {
        sendCommand(Command.INCRBYFLOAT, key, toByteArray(increment));
    }

    void incr(byte[] key) {
        sendCommand(Command.INCR, key);
    }

    void append(byte[] key, byte[] value) {
        sendCommand(Command.APPEND, key, value);
    }

    void substr(byte[] key, int start, int end) {
        sendCommand(Command.SUBSTR, key, toByteArray(start), toByteArray(end));
    }

    void hset(byte[] key, byte[] field, byte[] value) {
        sendCommand(Command.HSET, key, field, value);
    }

    void hset(byte[] key, Map!(byte[], byte[]) hash) {
        byte[][] params = new byte[][1 + hash.size() * 2];

        int index = 0;
        params[index++] = key;
        foreach (byte[] key, byte[] value; hash) {
            params[index++] = key;
            params[index++] = value;
        }
        sendCommand(Command.HSET, params);
    }

    void hget(byte[] key, byte[] field) {
        sendCommand(Command.HGET, key, field);
    }

    void hsetnx(byte[] key, byte[] field, byte[] value) {
        sendCommand(Command.HSETNX, key, field, value);
    }

    void hmset(byte[] key, Map!(byte[], byte[]) hash) {
        List!(byte[]) params = new ArrayList!(byte[])();
        params.add(key);

        foreach(byte[] key, byte[] value ; hash) {
            params.add(key);
            params.add(value);
        }
        sendCommand(Command.HMSET, params.toArray());
    }

    void hmget(byte[] key, byte[][] fields...) {
        sendCommand(Command.HMGET, joinParameters(key, fields));
    }

    void hincrBy(byte[] key, byte[] field, long value) {
        sendCommand(Command.HINCRBY, key, field, toByteArray(value));
    }

    void hexists(byte[] key, byte[] field) {
        sendCommand(Command.HEXISTS, key, field);
    }

    void hdel(byte[] key, byte[][] fields...) {
        sendCommand(Command.HDEL, joinParameters(key, fields));
    }

    void hlen(byte[] key) {
        sendCommand(Command.HLEN, key);
    }

    void hkeys(byte[] key) {
        sendCommand(Command.HKEYS, key);
    }

    void hvals(byte[] key) {
        sendCommand(Command.HVALS, key);
    }

    void hgetAll(byte[] key) {
        sendCommand(Command.HGETALL, key);
    }

    void rpush(byte[] key, byte[][] strings...) {
        sendCommand(Command.RPUSH, joinParameters(key, strings));
    }

    void lpush(byte[] key, byte[][] strings...) {
        sendCommand(Command.LPUSH, joinParameters(key, strings));
    }

    void llen(byte[] key) {
        sendCommand(Command.LLEN, key);
    }

    void lrange(byte[] key, long start, long stop) {
        sendCommand(Command.LRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void ltrim(byte[] key, long start, long stop) {
        sendCommand(Command.LTRIM, key, toByteArray(start), toByteArray(stop));
    }

    void lindex(byte[] key, long index) {
        sendCommand(Command.LINDEX, key, toByteArray(index));
    }

    void lset(byte[] key, long index, byte[] value) {
        sendCommand(Command.LSET, key, toByteArray(index), value);
    }

    void lrem(byte[] key, long count, byte[] value) {
        sendCommand(Command.LREM, key, toByteArray(count), value);
    }

    void lpop(byte[] key) {
        sendCommand(Command.LPOP, key);
    }

    void rpop(byte[] key) {
        sendCommand(Command.RPOP, key);
    }

    void rpoplpush(byte[] srckey, byte[] dstkey) {
        sendCommand(Command.RPOPLPUSH, srckey, dstkey);
    }

    void sadd(byte[] key, byte[][] members...) {
        sendCommand(Command.SADD, joinParameters(key, members));
    }

    void smembers(byte[] key) {
        sendCommand(Command.SMEMBERS, key);
    }

    void srem(byte[] key, byte[][] members...) {
        sendCommand(Command.SREM, joinParameters(key, members));
    }

    void spop(byte[] key) {
        sendCommand(Command.SPOP, key);
    }

    void spop(byte[] key, long count) {
        sendCommand(Command.SPOP, key, toByteArray(count));
    }

    void smove(byte[] srckey, byte[] dstkey, byte[] member) {
        sendCommand(Command.SMOVE, srckey, dstkey, member);
    }

    void scard(byte[] key) {
        sendCommand(Command.SCARD, key);
    }

    void sismember(byte[] key, byte[] member) {
        sendCommand(Command.SISMEMBER, key, member);
    }

    void sinter(byte[][] keys...) {
        sendCommand(Command.SINTER, keys);
    }

    void sinterstore(byte[] dstkey, byte[][] keys...) {
        sendCommand(Command.SINTERSTORE, joinParameters(dstkey, keys));
    }

    void sunion(byte[][] keys...) {
        sendCommand(Command.SUNION, keys);
    }

    void sunionstore(byte[] dstkey, byte[][] keys...) {
        sendCommand(Command.SUNIONSTORE, joinParameters(dstkey, keys));
    }

    void sdiff(byte[][] keys...) {
        sendCommand(Command.SDIFF, keys);
    }

    void sdiffstore(byte[] dstkey, byte[][] keys...) {
        sendCommand(Command.SDIFFSTORE, joinParameters(dstkey, keys));
    }

    void srandmember(byte[] key) {
        sendCommand(Command.SRANDMEMBER, key);
    }

    void zadd(byte[] key, double score, byte[] member) {
        sendCommand(Command.ZADD, key, toByteArray(score), member);
    }

    void zadd(byte[] key, double score, byte[] member,
            ZAddParams params) {
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(score), member));
    }

    void zadd(byte[] key, Map!(byte[], Double) scoreMembers) {
        ArrayList!(byte[]) args = new ArrayList!(byte[])(scoreMembers.size() * 2 + 1);
        args.add(key);
        args.addAll(convertScoreMembersToByteArrays(scoreMembers));

        byte[][] argsArray = args.toArray();

        sendCommand(Command.ZADD, argsArray);
    }

    void zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params) {
        ArrayList!(byte[]) args = convertScoreMembersToByteArrays(scoreMembers);
        byte[][] argsArray = args.toArray();

        sendCommand(Command.ZADD, params.getByteParams(key, argsArray));
    }

    void zrange(byte[] key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrem(byte[] key, byte[][] members...) {
        sendCommand(Command.ZREM, joinParameters(key, members));
    }

    void zincrby(byte[] key, double increment, byte[] member) {
        sendCommand(Command.ZINCRBY, key, toByteArray(increment), member);
    }

    void zincrby(byte[] key, double increment, byte[] member,
            ZIncrByParams params) {
        // Note that it actually calls ZADD with INCR option, so it requires Redis 3.0.2 or upper.
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(increment), member));
    }

    void zrank(byte[] key, byte[] member) {
        sendCommand(Command.ZRANK, key, member);
    }

    void zrevrank(byte[] key, byte[] member) {
        sendCommand(Command.ZREVRANK, key, member);
    }

    void zrevrange(byte[] key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrangeWithScores(byte[] key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeWithScores(byte[] key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zcard(byte[] key) {
        sendCommand(Command.ZCARD, key);
    }

    void zscore(byte[] key, byte[] member) {
        sendCommand(Command.ZSCORE, key, member);
    }

    void multi() {
        sendCommand(Command.MULTI);
        _isInMulti = true;
    }

    void discard() {
        sendCommand(Command.DISCARD);
        _isInMulti = false;
        _isInWatch = false;
    }

    void exec() {
        sendCommand(Command.EXEC);
        _isInMulti = false;
        _isInWatch = false;
    }

    void watch(byte[][] keys...) {
        sendCommand(Command.WATCH, keys);
        _isInWatch = true;
    }

    void unwatch() {
        sendCommand(Command.UNWATCH);
        _isInWatch = false;
    }

    void sort(byte[] key) {
        sendCommand(Command.SORT, key);
    }

    void sort(byte[] key, SortingParams sortingParameters) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        sendCommand(Command.SORT, args.toArray());
    }

    void blpop(byte[][] args) {
        sendCommand(Command.BLPOP, args);
    }

    void blpop(int timeout, byte[][] keys...) {
        List!(byte[]) args = new ArrayList!(byte[])();
        foreach(byte[] arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        blpop(args.toArray());
    }

    void sort(byte[] key, SortingParams sortingParameters, byte[] dstkey) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        args.add(cast(byte[])to!string(Keyword.STORE));
        args.add(dstkey);
        sendCommand(Command.SORT, args.toArray());
    }

    void sort(byte[] key, byte[] dstkey) {
        sendCommand(Command.SORT, key, cast(byte[])to!string(Keyword.STORE), dstkey);
    }

    void brpop(byte[][] args) {
        sendCommand(Command.BRPOP, args);
    }

    void brpop(int timeout, byte[][] keys...) {
        List!(byte[]) args = new ArrayList!(byte[])();
        foreach(byte[] arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        brpop(args.toArray());
    }

    void auth(string password) {
        setPassword(password);
        sendCommand(Command.AUTH, password);
    }

    void subscribe(byte[][] channels...) {
        sendCommand(Command.SUBSCRIBE, channels);
    }

    void publish(byte[] channel, byte[] message) {
        sendCommand(Command.PUBLISH, channel, message);
    }

    void unsubscribe() {
        sendCommand(Command.UNSUBSCRIBE);
    }

    void unsubscribe(byte[][] channels...) {
        sendCommand(Command.UNSUBSCRIBE, channels);
    }

    void psubscribe(byte[][] patterns...) {
        sendCommand(Command.PSUBSCRIBE, patterns);
    }

    void punsubscribe() {
        sendCommand(Command.PUNSUBSCRIBE);
    }

    void punsubscribe(byte[][] patterns...) {
        sendCommand(Command.PUNSUBSCRIBE, patterns);
    }

    void pubsub(byte[][] args...) {
        sendCommand(Command.PUBSUB, args);
    }

    void zcount(byte[] key, double min, double max) {
        sendCommand(Command.ZCOUNT, key, toByteArray(min), toByteArray(max));
    }

    void zcount(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZCOUNT, key, min, max);
    }

    void zrangeByScore(byte[] key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zrangeByScore(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max);
    }

    void zrevrangeByScore(byte[] key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min));
    }

    void zrevrangeByScore(byte[] key, byte[] max, byte[] min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min);
    }

    void zrangeByScore(byte[] key, double min, double max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrevrangeByScore(byte[] key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrangeByScoreWithScores(byte[] key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(byte[] key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(byte[] key, double min, double max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(byte[] key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScore(byte[] key, byte[] min, byte[] max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByScore(byte[] key, byte[] max, byte[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count),
            cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(byte[])to!string(Keyword.WITHSCORES));
    }

    void zremrangeByRank(byte[] key, long start, long stop) {
        sendCommand(Command.ZREMRANGEBYRANK, key, toByteArray(start), toByteArray(stop));
    }

    void zremrangeByScore(byte[] key, double min, double max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zremrangeByScore(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, min, max);
    }

    void zunionstore(byte[] dstkey, byte[][] sets...) {
        sendCommand(Command.ZUNIONSTORE, joinParameters(dstkey, toByteArray(sets.length), sets));
    }

    void zunionstore(byte[] dstkey, ZParams params, byte[][] sets...) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(byte[] set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZUNIONSTORE, args.toArray());
    }

    void zinterstore(byte[] dstkey, byte[][] sets...) {
        sendCommand(Command.ZINTERSTORE, joinParameters(dstkey, Protocol.toByteArray(sets.length), sets));
    }

    void zinterstore(byte[] dstkey, ZParams params, byte[][] sets...) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(byte[] set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZINTERSTORE, args.toArray());
    }

    void zlexcount(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZLEXCOUNT, key, min, max);
    }

    void zrangeByLex(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max);
    }

    void zrangeByLex(byte[] key, byte[] min, byte[] max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByLex(byte[] key, byte[] max, byte[] min) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min);
    }

    void zrevrangeByLex(byte[] key, byte[] max, byte[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min, cast(byte[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zremrangeByLex(byte[] key, byte[] min, byte[] max) {
        sendCommand(Command.ZREMRANGEBYLEX, key, min, max);
    }

    void save() {
        sendCommand(Command.SAVE);
    }

    void bgsave() {
        sendCommand(Command.BGSAVE);
    }

    void bgrewriteaof() {
        sendCommand(Command.BGREWRITEAOF);
    }

    void lastsave() {
        sendCommand(Command.LASTSAVE);
    }

    void shutdown() {
        sendCommand(Command.SHUTDOWN);
    }

    void info() {
        sendCommand(Command.INFO);
    }

    void info(string section) {
        sendCommand(Command.INFO, section);
    }

    void monitor() {
        sendCommand(Command.MONITOR);
    }

    void slaveof(string host, int port) {
        sendCommand(Command.SLAVEOF, host, port.to!string);
    }

    void slaveofNoOne() {
        sendCommand(Command.SLAVEOF, cast(byte[])to!string(Keyword.NO), cast(byte[])to!string(Keyword.ONE));
    }

    void configGet(byte[] pattern) {
        sendCommand(Command.CONFIG, cast(byte[])to!string(Keyword.GET), pattern);
    }

    void configSet(byte[] parameter, byte[] value) {
        sendCommand(Command.CONFIG, cast(byte[])to!string(Keyword.SET), parameter, value);
    }

    void strlen(byte[] key) {
        sendCommand(Command.STRLEN, key);
    }

    void sync() {
        sendCommand(Command.SYNC);
    }

    void lpushx(byte[] key, byte[][] strings...) {
        sendCommand(Command.LPUSHX, joinParameters(key, strings));
    }

    void persist(byte[] key) {
        sendCommand(Command.PERSIST, key);
    }

    void rpushx(byte[] key, byte[][] strings...) {
        sendCommand(Command.RPUSHX, joinParameters(key, strings));
    }

    void echo(byte[] strings) {
        sendCommand(Command.ECHO, strings);
    }

    void linsert(byte[] key, ListPosition where, byte[] pivot,
            byte[] value) {
        sendCommand(Command.LINSERT, key, cast(byte[])to!string(where), pivot, value);
    }

    // void debug(DebugParams params) {
    //   sendCommand(Command.DEBUG, params.getCommand());
    // }

    void brpoplpush(byte[] source, byte[] destination, int timeout) {
        sendCommand(Command.BRPOPLPUSH, source, destination, toByteArray(timeout));
    }

    void configResetStat() {
        sendCommand(Command.CONFIG, cast(byte[])to!string(Keyword.RESETSTAT));
    }

    void configRewrite() {
        sendCommand(Command.CONFIG, cast(byte[])to!string(Keyword.REWRITE));
    }

    void setbit(byte[] key, long offset, byte[] value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), value);
    }

    void setbit(byte[] key, long offset, bool value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), toByteArray(value));
    }

    void getbit(byte[] key, long offset) {
        sendCommand(Command.GETBIT, key, toByteArray(offset));
    }

    void bitpos(byte[] key, bool value, BitPosParams params) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.add(toByteArray(value));
        args.addAll(params.getParams());
        sendCommand(Command.BITPOS, args.toArray());
    }

    void setrange(byte[] key, long offset, byte[] value) {
        sendCommand(Command.SETRANGE, key, toByteArray(offset), value);
    }

    void getrange(byte[] key, long startOffset, long endOffset) {
        sendCommand(Command.GETRANGE, key, toByteArray(startOffset), toByteArray(endOffset));
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
        sendCommand(Command.EVAL, joinParameters(script, keyCount, params));
    }

    void eval(byte[] script, int keyCount, byte[][] params...) {
        sendCommand(Command.EVAL, joinParameters(script, toByteArray(keyCount), params));
    }

    void evalsha(byte[] sha1, byte[] keyCount, byte[][] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, keyCount, params));
    }

    void evalsha(byte[] sha1, int keyCount, byte[][] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, toByteArray(keyCount), params));
    }

    void scriptFlush() {
        sendCommand(Command.SCRIPT, cast(byte[])to!string(Keyword.FLUSH));
    }

    void scriptExists(byte[][] sha1...) {
        sendCommand(Command.SCRIPT, joinParameters(cast(byte[])to!string(Keyword.EXISTS), sha1));
    }

    void scriptLoad(byte[] script) {
        sendCommand(Command.SCRIPT, cast(byte[])to!string(Keyword.LOAD), script);
    }

    void scriptKill() {
        sendCommand(Command.SCRIPT, cast(byte[])to!string(Keyword.KILL));
    }

    void slowlogGet() {
        sendCommand(Command.SLOWLOG, cast(byte[])to!string(Keyword.GET));
    }

    void slowlogGet(long entries) {
        sendCommand(Command.SLOWLOG, cast(byte[])to!string(Keyword.GET), toByteArray(entries));
    }

    void slowlogReset() {
        sendCommand(Command.SLOWLOG, cast(byte[])to!string(Keyword.RESET));
    }

    void slowlogLen() {
        sendCommand(Command.SLOWLOG, cast(byte[])to!string(Keyword.LEN));
    }

    void objectRefcount(byte[] key) {
        sendCommand(Command.OBJECT, cast(byte[])to!string(Keyword.REFCOUNT), key);
    }

    void objectIdletime(byte[] key) {
        sendCommand(Command.OBJECT, cast(byte[])to!string(Keyword.IDLETIME), key);
    }

    void objectEncoding(byte[] key) {
        sendCommand(Command.OBJECT, cast(byte[])to!string(Keyword.ENCODING), key);
    }

    void bitcount(byte[] key) {
        sendCommand(Command.BITCOUNT, key);
    }

    void bitcount(byte[] key, long start, long end) {
        sendCommand(Command.BITCOUNT, key, toByteArray(start), toByteArray(end));
    }

    void bitop(BitOP op, byte[] destKey, byte[][] srcKeys...) {
        sendCommand(Command.BITOP, joinParameters(cast(byte[])to!string(op), destKey, srcKeys));
    }

    void sentinel(byte[][] args...) {
        sendCommand(Command.SENTINEL, args);
    }

    void dump(byte[] key) {
        sendCommand(Command.DUMP, key);
    }

    void restore(byte[] key, int ttl, byte[] serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue);
    }

    void restoreReplace(byte[] key, int ttl, byte[] serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue, cast(byte[])to!string(Keyword.REPLACE));
    }

    void pexpire(byte[] key, long milliseconds) {
        sendCommand(Command.PEXPIRE, key, toByteArray(milliseconds));
    }

    void pexpireAt(byte[] key, long millisecondsTimestamp) {
        sendCommand(Command.PEXPIREAT, key, toByteArray(millisecondsTimestamp));
    }

    void pttl(byte[] key) {
        sendCommand(Command.PTTL, key);
    }

    void psetex(byte[] key, long milliseconds, byte[] value) {
        sendCommand(Command.PSETEX, key, toByteArray(milliseconds), value);
    }

    void srandmember(byte[] key, int count) {
        sendCommand(Command.SRANDMEMBER, key, toByteArray(count));
    }

    void memoryDoctor() {
        sendCommand(Command.MEMORY, cast(byte[])to!string(Keyword.DOCTOR));
    }

    void clientKill(byte[] ipPort) {
        sendCommand(Command.CLIENT, cast(byte[])to!string(Keyword.KILL), ipPort);
    }

    void clientKill(string ip, int port) {
        sendCommand(Command.CLIENT, Keyword.KILL.to!string(), ip ~ ":" ~ port.to!string);
    }

    void clientKill(ClientKillParams params) {
        sendCommand(Command.CLIENT, joinParameters(cast(byte[])to!string(Keyword.KILL), params.getByteParams()));
    }

    void clientGetname() {
        sendCommand(Command.CLIENT, cast(byte[])to!string(Keyword.GETNAME));
    }

    void clientList() {
        sendCommand(Command.CLIENT, cast(byte[])to!string(Keyword.LIST));
    }

    void clientSetname(byte[] name) {
        sendCommand(Command.CLIENT, cast(byte[])to!string(Keyword.SETNAME), name);
    }

    void clientPause(long timeout) {
        sendCommand(Command.CLIENT, cast(byte[])to!string(Keyword.PAUSE), toByteArray(timeout));
    }

    void time() {
        sendCommand(Command.TIME);
    }

    void migrate(string host, int port, byte[] key, int destinationDb,
            int timeout) {
        sendCommand(Command.MIGRATE, SafeEncoder.encode(host), toByteArray(port), key,
                toByteArray(destinationDb), toByteArray(timeout));
    }

    void migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, byte[][] keys...) {
        byte[][] bparams = params.getByteParams();
        int len = cast(int)(5 + bparams.length + 1 + keys.length);
        byte[][] args = new byte[][len];
        int i = 0;
        args[i++] = SafeEncoder.encode(host);
        args[i++] = toByteArray(port);
        args[i++] = new byte[0];
        args[i++] = toByteArray(destinationDB);
        args[i++] = toByteArray(timeout);
        // System.arraycopy(bparams, 0, args, i, bparams.length);
        args[i .. i+bparams.length] = bparams[0 .. $];
        i += bparams.length;
        args[i++] = cast(byte[])to!string(Keyword.KEYS);
        // System.arraycopy(keys, 0, args, i, keys.length);
        args[i .. i+keys.length] = keys[0 .. $];
        sendCommand(Command.MIGRATE, args);
    }

    void hincrByFloat(byte[] key, byte[] field, double increment) {
        sendCommand(Command.HINCRBYFLOAT, key, field, toByteArray(increment));
    }

    void scan(byte[] cursor, ScanParams params) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SCAN, args.toArray());
    }

    void hscan(byte[] key, byte[] cursor, ScanParams params) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.HSCAN, args.toArray());
    }

    void sscan(byte[] key, byte[] cursor, ScanParams params) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SSCAN, args.toArray());
    }

    void zscan(byte[] key, byte[] cursor, ScanParams params) {
        List!(byte[]) args = new ArrayList!(byte[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.ZSCAN, args.toArray());
    }

    void waitReplicas(int replicas, long timeout) {
        sendCommand(Command.WAIT, toByteArray(replicas), toByteArray(timeout));
    }

    void cluster(byte[][] args...) {
        sendCommand(Command.CLUSTER, args);
    }

    void asking() {
        sendCommand(Command.ASKING);
    }

    void pfadd(byte[] key, byte[][] elements...) {
        sendCommand(Command.PFADD, joinParameters(key, elements));
    }

    void pfcount(byte[] key) {
        sendCommand(Command.PFCOUNT, key);
    }

    void pfcount(byte[][] keys...) {
        sendCommand(Command.PFCOUNT, keys);
    }

    void pfmerge(byte[] destkey, byte[][] sourcekeys...) {
        sendCommand(Command.PFMERGE, joinParameters(destkey, sourcekeys));
    }

    void readonly() {
        sendCommand(Command.READONLY);
    }

    void geoadd(byte[] key, double longitude, double latitude, byte[] member) {
        sendCommand(Command.GEOADD, key, toByteArray(longitude), toByteArray(latitude), member);
    }

    void geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap) {
        List!(byte[]) args = new ArrayList!(byte[])(memberCoordinateMap.size() * 3 + 1);
        args.add(key);
        args.addAll(convertGeoCoordinateMapToByteArrays(memberCoordinateMap));

        byte[][] argsArray = args.toArray();

        sendCommand(Command.GEOADD, argsArray);
    }

    void geodist(byte[] key, byte[] member1, byte[] member2) {
        sendCommand(Command.GEODIST, key, member1, member2);
    }

    void geodist(byte[] key, byte[] member1, byte[] member2, GeoUnit unit) {
        sendCommand(Command.GEODIST, key, member1, member2, cast(byte[])to!string(unit));
    }

    void geohash(byte[] key, byte[][] members...) {
        sendCommand(Command.GEOHASH, joinParameters(key, members));
    }

    void geopos(byte[] key, byte[][] members) {
        sendCommand(Command.GEOPOS, joinParameters(key, members));
    }

    void georadius(byte[] key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(byte[])to!string(unit));
    }

    void georadiusReadonly(byte[] key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS_RO, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(byte[])to!string(unit));
    }

    void georadius(byte[] key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(byte[])to!string(unit)));
    }

    void georadiusReadonly(byte[] key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS_RO, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(byte[])to!string(unit)));
    }

    void georadiusByMember(byte[] key, byte[] member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER, key, member, toByteArray(radius), cast(byte[])to!string(unit));
    }

    void georadiusByMemberReadonly(byte[] key, byte[] member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, key, member, toByteArray(radius), cast(byte[])to!string(unit));
    }

    void georadiusByMember(byte[] key, byte[] member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER, param.getByteParams(key, member, toByteArray(radius), cast(byte[])to!string(unit)));
    }

    void georadiusByMemberReadonly(byte[] key, byte[] member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, param.getByteParams(key, member, toByteArray(radius), cast(byte[])to!string(unit)));
    }

    void moduleLoad(byte[] path) {
        sendCommand(Command.MODULE, cast(byte[])to!string(Keyword.LOAD), path);
    }

    void moduleList() {
        sendCommand(Command.MODULE, cast(byte[])to!string(Keyword.LIST));
    }

    void moduleUnload(byte[] name) {
        sendCommand(Command.MODULE, cast(byte[])to!string(Keyword.UNLOAD), name);
    }

    private ArrayList!(byte[]) convertScoreMembersToByteArrays(Map!(byte[], Double) scoreMembers) {
        ArrayList!(byte[]) args = new ArrayList!(byte[])(scoreMembers.size() * 2);

        foreach(byte[] key, Double value ; scoreMembers) {
            args.add(toByteArray(value.value()));
            args.add(key);
        }

        return args;
    }

    private List!(byte[]) convertGeoCoordinateMapToByteArrays(
            Map!(byte[], GeoCoordinate) memberCoordinateMap) {
        List!(byte[]) args = new ArrayList!(byte[])(memberCoordinateMap.size() * 3);

        foreach(byte[] key, GeoCoordinate coordinate ; memberCoordinateMap) {
            args.add(toByteArray(coordinate.getLongitude()));
            args.add(toByteArray(coordinate.getLatitude()));
            args.add(key);
        }

        return args;
    }

    void bitfield(byte[] key, byte[][] value...) {
        sendCommand(Command.BITFIELD, joinParameters(key, value));
    }

    void hstrlen(byte[] key, byte[] field) {
        sendCommand(Command.HSTRLEN, key, field);
    }
    
    void xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength) {
            int maxLexArgs = 0;
            if(maxLen < long.max) { // optional arguments
                if(approximateLength) {
                    maxLexArgs = 3; // e.g. MAXLEN ~ 1000 
                } else {
                    maxLexArgs = 2; // e.g. MAXLEN 1000
                }
            }
        
        byte[][] params = new byte[][2 + maxLexArgs + hash.size() * 2];
        int index = 0;
        params[index++] = key;
        if(maxLen < long.max) {
            params[index++] = cast(byte[])to!string(Keyword.MAXLEN);
            if(approximateLength) {
                params[index++] = Protocol.BYTES_TILDE;
            }
            params[index++] = toByteArray(maxLen);
        }
        
        params[index++] = id;
        foreach(byte[] key, byte[] value ; hash) {
            params[index++] = key;
            params[index++] = value;
        }
        sendCommand(Command.XADD, params);
    }
    
    void xlen(byte[] key) {
         sendCommand(Command.XLEN, key);
    }
    
    void xrange(byte[] key, byte[] start, byte[] end, long count) { 
         sendCommand(Command.XRANGE, key, start, end, cast(byte[])to!string(Keyword.COUNT), toByteArray(count));
    }
    
    void xrevrange(byte[] key, byte[] end, byte[] start, int count) {
        sendCommand(Command.XREVRANGE, key, end, start, cast(byte[])to!string(Keyword.COUNT), toByteArray(count));
    }

    void xread(int count, long block, Map!(byte[], byte[]) streams) {
        byte[][] params = new byte[][3 + streams.size() * 2 + (block > 0 ? 2 : 0)];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(byte[])to!string(Keyword.COUNT);
        params[streamsIndex++] = toByteArray(count);
        if(block > 0) {
            params[streamsIndex++] = cast(byte[])to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        
        params[streamsIndex++] = cast(byte[])to!string(Keyword.STREAMS);
        int idsIndex = streamsIndex + streams.size();

        foreach(byte[] key, byte[] value; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREAD, params);
 }
    
    void xack(byte[] key, byte[] group, byte[][] ids...) {
        byte[][] params = new byte[][2 + ids.length];
        int index = 0;
        params[index++] = key;
        params[index++] = group;
        foreach(byte[] id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XACK, params);
    }
     
    void xgroupCreate(byte[] key, byte[] groupname, byte[] id, bool makeStream) {
        if(makeStream) {
            sendCommand(Command.XGROUP, cast(byte[])to!string(Keyword.CREATE), key, groupname, id, cast(byte[])to!string(Keyword.MKSTREAM));  
        } else {
            sendCommand(Command.XGROUP, cast(byte[])to!string(Keyword.CREATE), key, groupname, id);  
        }
    }

    void xgroupSetID(byte[] key, byte[] groupname, byte[] id) {
        sendCommand(Command.XGROUP, cast(byte[])to!string(Keyword.SETID), key, groupname, id);    
    }

    void xgroupDestroy(byte[] key, byte[] groupname) {
        sendCommand(Command.XGROUP, cast(byte[])to!string(Keyword.DESTROY), key, groupname);    
    }

    void xgroupDelConsumer(byte[] key, byte[] groupname, byte[] consumerName) {
        sendCommand(Command.XGROUP, cast(byte[])to!string(Keyword.DELCONSUMER), key, groupname, consumerName);    
    }
     
    void xdel(byte[] key, byte[][] ids...) {
        byte[][] params = new byte[][1 + ids.length];
        int index = 0;
        params[index++] = key;
        foreach(byte[] id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XDEL, params);
    }
    
    void xtrim(byte[] key, long maxLen, bool approximateLength) {
        if(approximateLength) {
            sendCommand(Command.XTRIM, key, cast(byte[])to!string(Keyword.MAXLEN), Protocol.BYTES_TILDE ,toByteArray(maxLen));
        } else {
            sendCommand(Command.XTRIM, key, cast(byte[])to!string(Keyword.MAXLEN), toByteArray(maxLen));
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
        
        
        byte[][] params = new byte[][4 + optional + streams.size() * 2];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(byte[])to!string(Keyword.GROUP);
        params[streamsIndex++] = groupname;
        params[streamsIndex++] = consumer;
        if(count>0) {
            params[streamsIndex++] = cast(byte[])to!string(Keyword.COUNT);
            params[streamsIndex++] = toByteArray(count);
        }
        if(block > 0) {
            params[streamsIndex++] = cast(byte[])to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        if(noAck) {
            params[streamsIndex++] = cast(byte[])to!string(Keyword.NOACK);
        }
        params[streamsIndex++] = cast(byte[])to!string(Keyword.STREAMS);
        
        int idsIndex = streamsIndex + streams.size();
        foreach(byte[] key, byte[] value ; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREADGROUP, params);
    }

    
    void xpending(byte[] key, byte[] groupname, byte[] start, 
                                byte[] end, int count, byte[] consumername) {
        if(consumername is null) {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count));
        } else {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count), consumername);
        }
    }

    void xclaim(byte[] key, byte[] groupname, byte[] consumername, long minIdleTime, 
                            long newIdleTime, int retries, bool force, byte[][] ids) {
            
            ArrayList!(byte[]) arguments = new ArrayList!(byte[])(cast(int)(10 + ids.length));

            arguments.add(key);
            arguments.add(groupname);
            arguments.add(consumername);
            arguments.add(toByteArray(minIdleTime));
            
            foreach(byte[] id ; ids) {
                arguments.add(id);  
            }
            if(newIdleTime > 0) {
                arguments.add(cast(byte[])to!string(Keyword.IDLE));
                arguments.add(toByteArray(newIdleTime));
            }
            if(retries > 0) {
                arguments.add(cast(byte[])to!string(Keyword.RETRYCOUNT));
                arguments.add(toByteArray(retries));        
            }
            if(force) {
                arguments.add(cast(byte[])to!string(Keyword.FORCE));        
            }
            sendCommand(Command.XCLAIM, arguments.toArray());
    }

}
