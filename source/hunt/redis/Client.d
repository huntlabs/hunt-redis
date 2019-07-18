module hunt.redis.Client;

import hunt.redis.AbstractClient;
import hunt.redis.BitOP;
import hunt.redis.BitPosParams;
import hunt.redis.ListPosition;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoUnit;
import hunt.redis.Protocol;
import hunt.redis.ScanParams;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntryID;
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

class Client : AbstractClient { 

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

    private string[] joinParameters(string first, string[] rest) {
        string[] result = new string[rest.length + 1];
        result[0] = first;
        // System.arraycopy(rest, 0, result, 1, rest.length);
        result[1 .. $] = rest[0 .. $];
        return result;
    }

    private string[] joinParameters(string first, string second, string[] rest) {
        string[] result = new string[rest.length + 2];
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

    void ping(string message) {
        sendCommand(Command.PING, message);
    }

    void set(string key, string value) {
        sendCommand(Command.SET, key, value);
    }

    void set(string key, string value, SetParams params) {
        sendCommand(Command.SET, params.getByteParams(key, value));
    }

    void get(string key) {
        sendCommand(Command.GET, key);
    }

    void quit() {
        db = 0;
        sendCommand(Command.QUIT);
    }

    void exists(string[] keys...) {
        sendCommand(Command.EXISTS, keys);
    }

    void del(string[] keys...) {
        sendCommand(Command.DEL, keys);
    }

    void unlink(string[] keys...) {
        sendCommand(Command.UNLINK, keys);
    }

    void type(string key) {
        sendCommand(Command.TYPE, key);
    }

    void flushDB() {
        sendCommand(Command.FLUSHDB);
    }

    void keys(string pattern) {
        sendCommand(Command.KEYS, pattern);
    }

    void randomKey() {
        sendCommand(Command.RANDOMKEY);
    }

    void rename(string oldkey, string newkey) {
        sendCommand(Command.RENAME, oldkey, newkey);
    }

    void renamenx(string oldkey, string newkey) {
        sendCommand(Command.RENAMENX, oldkey, newkey);
    }

    void dbSize() {
        sendCommand(Command.DBSIZE);
    }

    void expire(string key, int seconds) {
        sendCommand(Command.EXPIRE, key, toByteArray(seconds));
    }

    void expireAt(string key, long unixTime) {
        sendCommand(Command.EXPIREAT, key, toByteArray(unixTime));
    }

    void ttl(string key) {
        sendCommand(Command.TTL, key);
    }

    void touch(string[] keys...) {
        sendCommand(Command.TOUCH, keys);
    }

    void select(int index) {
        sendCommand(Command.SELECT, toByteArray(index));
    }

    void swapDB(int index1, int index2) {
        sendCommand(Command.SWAPDB, toByteArray(index1), toByteArray(index2));
    }

    void move(string key, int dbIndex) {
        sendCommand(Command.MOVE, key, toByteArray(dbIndex));
    }

    void flushAll() {
        sendCommand(Command.FLUSHALL);
    }

    void getSet(string key, string value) {
        sendCommand(Command.GETSET, key, value);
    }

    void mget(string[] keys...) {
        sendCommand(Command.MGET, keys);
    }

    void setnx(string key, string value) {
        sendCommand(Command.SETNX, key, value);
    }

    void setex(string key, int seconds, string value) {
        sendCommand(Command.SETEX, key, toByteArray(seconds), value);
    }

    void mset(string[] keysvalues...) {
        sendCommand(Command.MSET, keysvalues);
    }

    void msetnx(string[] keysvalues...) {
        sendCommand(Command.MSETNX, keysvalues);
    }

    void decrBy(string key, long decrement) {
        sendCommand(Command.DECRBY, key, toByteArray(decrement));
    }

    void decr(string key) {
        sendCommand(Command.DECR, key);
    }

    void incrBy(string key, long increment) {
        sendCommand(Command.INCRBY, key, toByteArray(increment));
    }

    void incrByFloat(string key, double increment) {
        sendCommand(Command.INCRBYFLOAT, key, toByteArray(increment));
    }

    void incr(string key) {
        sendCommand(Command.INCR, key);
    }

    void append(string key, string value) {
        sendCommand(Command.APPEND, key, value);
    }

    void substr(string key, int start, int end) {
        sendCommand(Command.SUBSTR, key, toByteArray(start), toByteArray(end));
    }

    void hset(string key, string field, string value) {
        sendCommand(Command.HSET, key, field, value);
    }

    void hset(string key, Map!(string, string) hash) {
        string[] params = new string[1 + hash.size() * 2];

        int index = 0;
        params[index++] = key;
        foreach (string key, string value; hash) {
            params[index++] = key;
            params[index++] = value;
        }
        sendCommand(Command.HSET, params);
    }

    void hget(string key, string field) {
        sendCommand(Command.HGET, key, field);
    }

    void hsetnx(string key, string field, string value) {
        sendCommand(Command.HSETNX, key, field, value);
    }

    void hmset(string key, Map!(string, string) hash) {
        List!(string) params = new ArrayList!(string)();
        params.add(key);

        foreach(string key, string value ; hash) {
            params.add(key);
            params.add(value);
        }
        sendCommand(Command.HMSET, params.toArray());
    }

    void hmget(string key, string[] fields...) {
        sendCommand(Command.HMGET, joinParameters(key, fields));
    }

    void hincrBy(string key, string field, long value) {
        sendCommand(Command.HINCRBY, key, field, toByteArray(value));
    }

    void hexists(string key, string field) {
        sendCommand(Command.HEXISTS, key, field);
    }

    void hdel(string key, string[] fields...) {
        sendCommand(Command.HDEL, joinParameters(key, fields));
    }

    void hlen(string key) {
        sendCommand(Command.HLEN, key);
    }

    void hkeys(string key) {
        sendCommand(Command.HKEYS, key);
    }

    void hvals(string key) {
        sendCommand(Command.HVALS, key);
    }

    void hgetAll(string key) {
        sendCommand(Command.HGETALL, key);
    }

    void rpush(string key, string[] strings...) {
        sendCommand(Command.RPUSH, joinParameters(key, strings));
    }

    void lpush(string key, string[] strings...) {
        sendCommand(Command.LPUSH, joinParameters(key, strings));
    }

    void llen(string key) {
        sendCommand(Command.LLEN, key);
    }

    void lrange(string key, long start, long stop) {
        sendCommand(Command.LRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void ltrim(string key, long start, long stop) {
        sendCommand(Command.LTRIM, key, toByteArray(start), toByteArray(stop));
    }

    void lindex(string key, long index) {
        sendCommand(Command.LINDEX, key, toByteArray(index));
    }

    void lset(string key, long index, string value) {
        sendCommand(Command.LSET, key, toByteArray(index), value);
    }

    void lrem(string key, long count, string value) {
        sendCommand(Command.LREM, key, toByteArray(count), value);
    }

    void lpop(string key) {
        sendCommand(Command.LPOP, key);
    }

    void rpop(string key) {
        sendCommand(Command.RPOP, key);
    }

    void rpoplpush(string srckey, string dstkey) {
        sendCommand(Command.RPOPLPUSH, srckey, dstkey);
    }

    void sadd(string key, string[] members...) {
        sendCommand(Command.SADD, joinParameters(key, members));
    }

    void smembers(string key) {
        sendCommand(Command.SMEMBERS, key);
    }

    void srem(string key, string[] members...) {
        sendCommand(Command.SREM, joinParameters(key, members));
    }

    void spop(string key) {
        sendCommand(Command.SPOP, key);
    }

    void spop(string key, long count) {
        sendCommand(Command.SPOP, key, toByteArray(count));
    }

    void smove(string srckey, string dstkey, string member) {
        sendCommand(Command.SMOVE, srckey, dstkey, member);
    }

    void scard(string key) {
        sendCommand(Command.SCARD, key);
    }

    void sismember(string key, string member) {
        sendCommand(Command.SISMEMBER, key, member);
    }

    void sinter(string[] keys...) {
        sendCommand(Command.SINTER, keys);
    }

    void sinterstore(string dstkey, string[] keys...) {
        sendCommand(Command.SINTERSTORE, joinParameters(dstkey, keys));
    }

    void sunion(string[] keys...) {
        sendCommand(Command.SUNION, keys);
    }

    void sunionstore(string dstkey, string[] keys...) {
        sendCommand(Command.SUNIONSTORE, joinParameters(dstkey, keys));
    }

    void sdiff(string[] keys...) {
        sendCommand(Command.SDIFF, keys);
    }

    void sdiffstore(string dstkey, string[] keys...) {
        sendCommand(Command.SDIFFSTORE, joinParameters(dstkey, keys));
    }

    void srandmember(string key) {
        sendCommand(Command.SRANDMEMBER, key);
    }

    void zadd(string key, double score, string member) {
        sendCommand(Command.ZADD, key, toByteArray(score), member);
    }

    void zadd(string key, double score, string member,
            ZAddParams params) {
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(score), member));
    }

    void zadd(string key, Map!(string, Double) scoreMembers) {
        ArrayList!(string) args = new ArrayList!(string)(scoreMembers.size() * 2 + 1);
        args.add(key);
        args.addAll(convertScoreMembersToByteArrays(scoreMembers));

        string[] argsArray = args.toArray();

        sendCommand(Command.ZADD, argsArray);
    }

    void zadd(string key, Map!(string, Double) scoreMembers, ZAddParams params) {
        ArrayList!(string) args = convertScoreMembersToByteArrays(scoreMembers);
        string[] argsArray = args.toArray();

        sendCommand(Command.ZADD, params.getByteParams(key, argsArray));
    }

    void zrange(string key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrem(string key, string[] members...) {
        sendCommand(Command.ZREM, joinParameters(key, members));
    }

    void zincrby(string key, double increment, string member) {
        sendCommand(Command.ZINCRBY, key, toByteArray(increment), member);
    }

    void zincrby(string key, double increment, string member,
            ZIncrByParams params) {
        // Note that it actually calls ZADD with INCR option, so it requires Redis 3.0.2 or upper.
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(increment), member));
    }

    void zrank(string key, string member) {
        sendCommand(Command.ZRANK, key, member);
    }

    void zrevrank(string key, string member) {
        sendCommand(Command.ZREVRANK, key, member);
    }

    void zrevrange(string key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrangeWithScores(string key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrevrangeWithScores(string key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zcard(string key) {
        sendCommand(Command.ZCARD, key);
    }

    void zscore(string key, string member) {
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

    void watch(string[] keys...) {
        sendCommand(Command.WATCH, keys);
        _isInWatch = true;
    }

    void unwatch() {
        sendCommand(Command.UNWATCH);
        _isInWatch = false;
    }

    void sort(string key) {
        sendCommand(Command.SORT, key);
    }

    void sort(string key, SortingParams sortingParameters) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        sendCommand(Command.SORT, args.toArray());
    }

    void blpop(string[] args) {
        sendCommand(Command.BLPOP, args);
    }

    void blpop(int timeout, string[] keys...) {
        List!(string) args = new ArrayList!(string)();
        foreach(string arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        blpop(args.toArray());
    }

    void sort(string key, SortingParams sortingParameters, string dstkey) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        args.add(cast(string)to!string(Keyword.STORE));
        args.add(dstkey);
        sendCommand(Command.SORT, args.toArray());
    }

    void sort(string key, string dstkey) {
        sendCommand(Command.SORT, key, cast(string)to!string(Keyword.STORE), dstkey);
    }

    void brpop(string[] args) {
        sendCommand(Command.BRPOP, args);
    }

    void brpop(int timeout, string[] keys...) {
        List!(string) args = new ArrayList!(string)();
        foreach(string arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        brpop(args.toArray());
    }

    void auth(string password) {
        setPassword(password);
        sendCommand(Command.AUTH, password);
    }

    void subscribe(string[] channels...) {
        sendCommand(Command.SUBSCRIBE, channels);
    }

    void publish(string channel, string message) {
        sendCommand(Command.PUBLISH, channel, message);
    }

    void unsubscribe() {
        sendCommand(Command.UNSUBSCRIBE);
    }

    void unsubscribe(string[] channels...) {
        sendCommand(Command.UNSUBSCRIBE, channels);
    }

    void psubscribe(string[] patterns...) {
        sendCommand(Command.PSUBSCRIBE, patterns);
    }

    void punsubscribe() {
        sendCommand(Command.PUNSUBSCRIBE);
    }

    void punsubscribe(string[] patterns...) {
        sendCommand(Command.PUNSUBSCRIBE, patterns);
    }

    void pubsub(string[] args...) {
        sendCommand(Command.PUBSUB, args);
    }

    void zcount(string key, double min, double max) {
        sendCommand(Command.ZCOUNT, key, toByteArray(min), toByteArray(max));
    }

    void zcount(string key, string min, string max) {
        sendCommand(Command.ZCOUNT, key, min, max);
    }

    void zrangeByScore(string key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zrangeByScore(string key, string min, string max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max);
    }

    void zrevrangeByScore(string key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min));
    }

    void zrevrangeByScore(string key, string max, string min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min);
    }

    void zrangeByScore(string key, double min, double max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(string)to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrevrangeByScore(string key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(string)to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrangeByScoreWithScores(string key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(string key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(string key, double min, double max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(string)to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(string key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(string)to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrangeByScore(string key, string min, string max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(string)to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByScore(string key, string max, string min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(string)to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrangeByScoreWithScores(string key, string min, string max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(string key, string max, string min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(string key, string min, string max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(string)to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count),
            cast(string)to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(string key, string max, string min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(string)to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(string)to!string(Keyword.WITHSCORES));
    }

    void zremrangeByRank(string key, long start, long stop) {
        sendCommand(Command.ZREMRANGEBYRANK, key, toByteArray(start), toByteArray(stop));
    }

    void zremrangeByScore(string key, double min, double max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zremrangeByScore(string key, string min, string max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, min, max);
    }

    void zunionstore(string dstkey, string[] sets...) {
        sendCommand(Command.ZUNIONSTORE, joinParameters(dstkey, toByteArray(sets.length), sets));
    }

    void zunionstore(string dstkey, ZParams params, string[] sets...) {
        List!(string) args = new ArrayList!(string)();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(string set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZUNIONSTORE, args.toArray());
    }

    void zinterstore(string dstkey, string[] sets...) {
        sendCommand(Command.ZINTERSTORE, joinParameters(dstkey, Protocol.toByteArray(sets.length), sets));
    }

    void zinterstore(string dstkey, ZParams params, string[] sets...) {
        List!(string) args = new ArrayList!(string)();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(string set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZINTERSTORE, args.toArray());
    }

    void zlexcount(string key, string min, string max) {
        sendCommand(Command.ZLEXCOUNT, key, min, max);
    }

    void zrangeByLex(string key, string min, string max) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max);
    }

    void zrangeByLex(string key, string min, string max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max, cast(string)to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByLex(string key, string max, string min) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min);
    }

    void zrevrangeByLex(string key, string max, string min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min, cast(string)to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zremrangeByLex(string key, string min, string max) {
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
        sendCommand(Command.SLAVEOF, cast(string)to!string(Keyword.NO), cast(string)to!string(Keyword.ONE));
    }

    void configGet(string pattern) {
        sendCommand(Command.CONFIG, cast(string)to!string(Keyword.GET), pattern);
    }

    void configSet(string parameter, string value) {
        sendCommand(Command.CONFIG, cast(string)to!string(Keyword.SET), parameter, value);
    }

    void strlen(string key) {
        sendCommand(Command.STRLEN, key);
    }

    void sync() {
        sendCommand(Command.SYNC);
    }

    void lpushx(string key, string[] strings...) {
        sendCommand(Command.LPUSHX, joinParameters(key, strings));
    }

    void persist(string key) {
        sendCommand(Command.PERSIST, key);
    }

    void rpushx(string key, string[] strings...) {
        sendCommand(Command.RPUSHX, joinParameters(key, strings));
    }

    void echo(string strings) {
        sendCommand(Command.ECHO, strings);
    }

    void linsert(string key, ListPosition where, string pivot,
            string value) {
        sendCommand(Command.LINSERT, key, cast(string)to!string(where), pivot, value);
    }

    // void debug(DebugParams params) {
    //   sendCommand(Command.DEBUG, params.getCommand());
    // }

    void brpoplpush(string source, string destination, int timeout) {
        sendCommand(Command.BRPOPLPUSH, source, destination, toByteArray(timeout));
    }

    void configResetStat() {
        sendCommand(Command.CONFIG, cast(string)to!string(Keyword.RESETSTAT));
    }

    void configRewrite() {
        sendCommand(Command.CONFIG, cast(string)to!string(Keyword.REWRITE));
    }

    void setbit(string key, long offset, string value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), value);
    }

    void setbit(string key, long offset, bool value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), toByteArray(value));
    }

    void getbit(string key, long offset) {
        sendCommand(Command.GETBIT, key, toByteArray(offset));
    }

    void bitpos(string key, bool value, BitPosParams params) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.add(toByteArray(value));
        args.addAll(params.getParams());
        sendCommand(Command.BITPOS, args.toArray());
    }

    void setrange(string key, long offset, string value) {
        sendCommand(Command.SETRANGE, key, toByteArray(offset), value);
    }

    void getrange(string key, long startOffset, long endOffset) {
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

    void eval(string script, string keyCount, string[] params) {
        sendCommand(Command.EVAL, joinParameters(script, keyCount, params));
    }

    void eval(string script, int keyCount, string[] params...) {
        sendCommand(Command.EVAL, joinParameters(script, toByteArray(keyCount), params));
    }

    void evalsha(string sha1, string keyCount, string[] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, keyCount, params));
    }

    void evalsha(string sha1, int keyCount, string[] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, toByteArray(keyCount), params));
    }

    void scriptFlush() {
        sendCommand(Command.SCRIPT, cast(string)to!string(Keyword.FLUSH));
    }

    void scriptExists(string[] sha1...) {
        sendCommand(Command.SCRIPT, joinParameters(cast(string)to!string(Keyword.EXISTS), sha1));
    }

    void scriptLoad(string script) {
        sendCommand(Command.SCRIPT, cast(string)to!string(Keyword.LOAD), script);
    }

    void scriptKill() {
        sendCommand(Command.SCRIPT, cast(string)to!string(Keyword.KILL));
    }

    void slowlogGet() {
        sendCommand(Command.SLOWLOG, cast(string)to!string(Keyword.GET));
    }

    void slowlogGet(long entries) {
        sendCommand(Command.SLOWLOG, cast(string)to!string(Keyword.GET), toByteArray(entries));
    }

    void slowlogReset() {
        sendCommand(Command.SLOWLOG, cast(string)to!string(Keyword.RESET));
    }

    void slowlogLen() {
        sendCommand(Command.SLOWLOG, cast(string)to!string(Keyword.LEN));
    }

    void objectRefcount(string key) {
        sendCommand(Command.OBJECT, cast(string)to!string(Keyword.REFCOUNT), key);
    }

    void objectIdletime(string key) {
        sendCommand(Command.OBJECT, cast(string)to!string(Keyword.IDLETIME), key);
    }

    void objectEncoding(string key) {
        sendCommand(Command.OBJECT, cast(string)to!string(Keyword.ENCODING), key);
    }

    void bitcount(string key) {
        sendCommand(Command.BITCOUNT, key);
    }

    void bitcount(string key, long start, long end) {
        sendCommand(Command.BITCOUNT, key, toByteArray(start), toByteArray(end));
    }

    void bitop(BitOP op, string destKey, string[] srcKeys...) {
        sendCommand(Command.BITOP, joinParameters(cast(string)to!string(op), destKey, srcKeys));
    }

    void sentinel(string[] args...) {
        sendCommand(Command.SENTINEL, args);
    }

    void dump(string key) {
        sendCommand(Command.DUMP, key);
    }

    void restore(string key, int ttl, string serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue);
    }

    void restoreReplace(string key, int ttl, string serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue, cast(string)to!string(Keyword.REPLACE));
    }

    void pexpire(string key, long milliseconds) {
        sendCommand(Command.PEXPIRE, key, toByteArray(milliseconds));
    }

    void pexpireAt(string key, long millisecondsTimestamp) {
        sendCommand(Command.PEXPIREAT, key, toByteArray(millisecondsTimestamp));
    }

    void pttl(string key) {
        sendCommand(Command.PTTL, key);
    }

    void psetex(string key, long milliseconds, string value) {
        sendCommand(Command.PSETEX, key, toByteArray(milliseconds), value);
    }

    void srandmember(string key, int count) {
        sendCommand(Command.SRANDMEMBER, key, toByteArray(count));
    }

    void memoryDoctor() {
        sendCommand(Command.MEMORY, cast(string)to!string(Keyword.DOCTOR));
    }

    void clientKill(string ipPort) {
        sendCommand(Command.CLIENT, cast(string)to!string(Keyword.KILL), ipPort);
    }

    void clientKill(string ip, int port) {
        sendCommand(Command.CLIENT, Keyword.KILL.to!string(), ip ~ ":" ~ port.to!string);
    }

    void clientKill(ClientKillParams params) {
        sendCommand(Command.CLIENT, joinParameters(cast(string)to!string(Keyword.KILL), params.getByteParams()));
    }

    void clientGetname() {
        sendCommand(Command.CLIENT, cast(string)to!string(Keyword.GETNAME));
    }

    void clientList() {
        sendCommand(Command.CLIENT, cast(string)to!string(Keyword.LIST));
    }

    void clientSetname(string name) {
        sendCommand(Command.CLIENT, cast(string)to!string(Keyword.SETNAME), name);
    }

    void clientPause(long timeout) {
        sendCommand(Command.CLIENT, cast(string)to!string(Keyword.PAUSE), toByteArray(timeout));
    }

    void time() {
        sendCommand(Command.TIME);
    }

    void migrate(string host, int port, string key, int destinationDb,
            int timeout) {
        sendCommand(Command.MIGRATE, SafeEncoder.encode(host), toByteArray(port), key,
                toByteArray(destinationDb), toByteArray(timeout));
    }

    void migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, string[] keys...) {
        string[] bparams = params.getByteParams();
        int len = cast(int)(5 + bparams.length + 1 + keys.length);
        string[] args = new string[len];
        int i = 0;
        args[i++] = SafeEncoder.encode(host);
        args[i++] = toByteArray(port);
        args[i++] = "";
        args[i++] = toByteArray(destinationDB);
        args[i++] = toByteArray(timeout);
        // System.arraycopy(bparams, 0, args, i, bparams.length);
        args[i .. i+bparams.length] = bparams[0 .. $];
        i += bparams.length;
        args[i++] = cast(string)to!string(Keyword.KEYS);
        // System.arraycopy(keys, 0, args, i, keys.length);
        args[i .. i+keys.length] = keys[0 .. $];
        sendCommand(Command.MIGRATE, args);
    }

    void hincrByFloat(string key, string field, double increment) {
        sendCommand(Command.HINCRBYFLOAT, key, field, toByteArray(increment));
    }

    void scan(string cursor, ScanParams params) {
        List!(string) args = new ArrayList!(string)();
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SCAN, args.toArray());
    }

    void hscan(string key, string cursor, ScanParams params) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.HSCAN, args.toArray());
    }

    void sscan(string key, string cursor, ScanParams params) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SSCAN, args.toArray());
    }

    void zscan(string key, string cursor, ScanParams params) {
        List!(string) args = new ArrayList!(string)();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.ZSCAN, args.toArray());
    }

    void waitReplicas(int replicas, long timeout) {
        sendCommand(Command.WAIT, toByteArray(replicas), toByteArray(timeout));
    }

    void cluster(string[] args...) {
        sendCommand(Command.CLUSTER, args);
    }

    void asking() {
        sendCommand(Command.ASKING);
    }

    void pfadd(string key, string[] elements...) {
        sendCommand(Command.PFADD, joinParameters(key, elements));
    }

    void pfcount(string key) {
        sendCommand(Command.PFCOUNT, key);
    }

    void pfcount(string[] keys...) {
        sendCommand(Command.PFCOUNT, keys);
    }

    void pfmerge(string destkey, string[] sourcekeys...) {
        sendCommand(Command.PFMERGE, joinParameters(destkey, sourcekeys));
    }

    void readonly() {
        sendCommand(Command.READONLY);
    }

    void geoadd(string key, double longitude, double latitude, string member) {
        sendCommand(Command.GEOADD, key, toByteArray(longitude), toByteArray(latitude), member);
    }

    void geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
        List!(string) args = new ArrayList!(string)(memberCoordinateMap.size() * 3 + 1);
        args.add(key);
        args.addAll(convertGeoCoordinateMapToByteArrays(memberCoordinateMap));

        string[] argsArray = args.toArray();

        sendCommand(Command.GEOADD, argsArray);
    }

    void geodist(string key, string member1, string member2) {
        sendCommand(Command.GEODIST, key, member1, member2);
    }

    void geodist(string key, string member1, string member2, GeoUnit unit) {
        sendCommand(Command.GEODIST, key, member1, member2, cast(string)to!string(unit));
    }

    void geohash(string key, string[] members...) {
        sendCommand(Command.GEOHASH, joinParameters(key, members));
    }

    void geopos(string key, string[] members) {
        sendCommand(Command.GEOPOS, joinParameters(key, members));
    }

    void georadius(string key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(string)to!string(unit));
    }

    void georadiusReadonly(string key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS_RO, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(string)to!string(unit));
    }

    void georadius(string key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(string)to!string(unit)));
    }

    void georadiusReadonly(string key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS_RO, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(string)to!string(unit)));
    }

    void georadiusByMember(string key, string member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER, key, member, toByteArray(radius), cast(string)to!string(unit));
    }

    void georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, key, member, toByteArray(radius), cast(string)to!string(unit));
    }

    void georadiusByMember(string key, string member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER, param.getByteParams(key, member, toByteArray(radius), cast(string)to!string(unit)));
    }

    void georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, param.getByteParams(key, member, toByteArray(radius), cast(string)to!string(unit)));
    }

    void moduleLoad(string path) {
        sendCommand(Command.MODULE, cast(string)to!string(Keyword.LOAD), path);
    }

    void moduleList() {
        sendCommand(Command.MODULE, cast(string)to!string(Keyword.LIST));
    }

    void moduleUnload(string name) {
        sendCommand(Command.MODULE, cast(string)to!string(Keyword.UNLOAD), name);
    }

    private ArrayList!(string) convertScoreMembersToByteArrays(Map!(string, Double) scoreMembers) {
        ArrayList!(string) args = new ArrayList!(string)(scoreMembers.size() * 2);

        foreach(string key, Double value ; scoreMembers) {
            args.add(toByteArray(value.value()));
            args.add(key);
        }

        return args;
    }

    private List!(string) convertGeoCoordinateMapToByteArrays(
            Map!(string, GeoCoordinate) memberCoordinateMap) {
        List!(string) args = new ArrayList!(string)(memberCoordinateMap.size() * 3);

        foreach(string key, GeoCoordinate coordinate ; memberCoordinateMap) {
            args.add(toByteArray(coordinate.getLongitude()));
            args.add(toByteArray(coordinate.getLatitude()));
            args.add(key);
        }

        return args;
    }

    void bitfield(string key, string[] value...) {
        sendCommand(Command.BITFIELD, joinParameters(key, value));
    }

    void hstrlen(string key, string field) {
        sendCommand(Command.HSTRLEN, key, field);
    }
    
    void xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength) {
            int maxLexArgs = 0;
            if(maxLen < long.max) { // optional arguments
                if(approximateLength) {
                    maxLexArgs = 3; // e.g. MAXLEN ~ 1000 
                } else {
                    maxLexArgs = 2; // e.g. MAXLEN 1000
                }
            }
        
        string[] params = new string[2 + maxLexArgs + hash.size() * 2];
        int index = 0;
        params[index++] = key;
        if(maxLen < long.max) {
            params[index++] = cast(string)to!string(Keyword.MAXLEN);
            if(approximateLength) {
                params[index++] = Protocol.BYTES_TILDE;
            }
            params[index++] = toByteArray(maxLen);
        }
        
        params[index++] = id.toString();
        foreach(string key, string value ; hash) {
            params[index++] = key;
            params[index++] = value;
        }
        sendCommand(Command.XADD, params);
    }
    
    void xlen(string key) {
         sendCommand(Command.XLEN, key);
    }
    
    void xrange(string key, string start, string end, long count) { 
         sendCommand(Command.XRANGE, key, start, end, cast(string)to!string(Keyword.COUNT), toByteArray(count));
    }
    
    void xrevrange(string key, string end, string start, int count) {
        sendCommand(Command.XREVRANGE, key, end, start, cast(string)to!string(Keyword.COUNT), toByteArray(count));
    }

    void xread(int count, long block, Map!(string, string) streams) {
        string[] params = new string[3 + streams.size() * 2 + (block > 0 ? 2 : 0)];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(string)to!string(Keyword.COUNT);
        params[streamsIndex++] = toByteArray(count);
        if(block > 0) {
            params[streamsIndex++] = cast(string)to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        
        params[streamsIndex++] = cast(string)to!string(Keyword.STREAMS);
        int idsIndex = streamsIndex + streams.size();

        foreach(string key, string value; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREAD, params);
 }
    
    void xack(string key, string group, string[] ids...) {
        string[] params = new string[2 + ids.length];
        int index = 0;
        params[index++] = key;
        params[index++] = group;
        foreach(string id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XACK, params);
    }
     
    void xgroupCreate(string key, string groupname, string id, bool makeStream) {
        if(makeStream) {
            sendCommand(Command.XGROUP, cast(string)to!string(Keyword.CREATE), key, groupname, id, cast(string)to!string(Keyword.MKSTREAM));  
        } else {
            sendCommand(Command.XGROUP, cast(string)to!string(Keyword.CREATE), key, groupname, id);  
        }
    }

    void xgroupSetID(string key, string groupname, string id) {
        sendCommand(Command.XGROUP, cast(string)to!string(Keyword.SETID), key, groupname, id);    
    }

    void xgroupDestroy(string key, string groupname) {
        sendCommand(Command.XGROUP, cast(string)to!string(Keyword.DESTROY), key, groupname);    
    }

    void xgroupDelConsumer(string key, string groupname, string consumerName) {
        sendCommand(Command.XGROUP, cast(string)to!string(Keyword.DELCONSUMER), key, groupname, consumerName);    
    }
     
    void xdel(string key, string[] ids...) {
        string[] params = new string[1 + ids.length];
        int index = 0;
        params[index++] = key;
        foreach(string id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XDEL, params);
    }
    
    void xtrim(string key, long maxLen, bool approximateLength) {
        if(approximateLength) {
            sendCommand(Command.XTRIM, key, cast(string)to!string(Keyword.MAXLEN), Protocol.BYTES_TILDE ,toByteArray(maxLen));
        } else {
            sendCommand(Command.XTRIM, key, cast(string)to!string(Keyword.MAXLEN), toByteArray(maxLen));
        }
    }
    
    void xreadGroup(string groupname, string consumer, int count, long block, bool noAck, Map!(string, string) streams) {
        
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
        
        
        string[] params = new string[4 + optional + streams.size() * 2];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(string)to!string(Keyword.GROUP);
        params[streamsIndex++] = groupname;
        params[streamsIndex++] = consumer;
        if(count>0) {
            params[streamsIndex++] = cast(string)to!string(Keyword.COUNT);
            params[streamsIndex++] = toByteArray(count);
        }
        if(block > 0) {
            params[streamsIndex++] = cast(string)to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        if(noAck) {
            params[streamsIndex++] = cast(string)to!string(Keyword.NOACK);
        }
        params[streamsIndex++] = cast(string)to!string(Keyword.STREAMS);
        
        int idsIndex = streamsIndex + streams.size();
        foreach(string key, string value ; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREADGROUP, params);
    }

    
    void xpending(string key, string groupname, string start, 
                                string end, int count, string consumername) {
        if(consumername is null) {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count));
        } else {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count), consumername);
        }
    }

    void xclaim(string key, string groupname, string consumername, long minIdleTime, 
                            long newIdleTime, int retries, bool force, string[] ids) {
            
            ArrayList!(string) arguments = new ArrayList!(string)(cast(int)(10 + ids.length));

            arguments.add(key);
            arguments.add(groupname);
            arguments.add(consumername);
            arguments.add(toByteArray(minIdleTime));
            
            foreach(string id ; ids) {
                arguments.add(id);  
            }
            if(newIdleTime > 0) {
                arguments.add(cast(string)to!string(Keyword.IDLE));
                arguments.add(toByteArray(newIdleTime));
            }
            if(retries > 0) {
                arguments.add(cast(string)to!string(Keyword.RETRYCOUNT));
                arguments.add(toByteArray(retries));        
            }
            if(force) {
                arguments.add(cast(string)to!string(Keyword.FORCE));        
            }
            sendCommand(Command.XCLAIM, arguments.toArray());
    }

}
