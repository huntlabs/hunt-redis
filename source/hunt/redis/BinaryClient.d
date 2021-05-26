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

    private const(ubyte)[][] joinParameters(const(ubyte)[] first, const(ubyte)[][] rest) {
        const(ubyte)[][] result = new const(ubyte)[][rest.length + 1];
        result[0] = first;
        // System.arraycopy(rest, 0, result, 1, rest.length);
        result[1 .. $] = rest[0 .. $];
        return result;
    }

    private const(ubyte)[][] joinParameters(const(ubyte)[] first, const(ubyte)[] second, const(ubyte)[][] rest) {
        const(ubyte)[][] result = new const(ubyte)[][rest.length + 2];
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

    void ping(const(ubyte)[] message) {
        sendCommand(Command.PING, [message]);
    }

    void set(const(ubyte)[] key, const(ubyte)[] value) {
        sendCommand(Command.SET, key, value);
    }

    void set(const(ubyte)[] key, const(ubyte)[] value, SetParams params) {
        sendCommand(Command.SET, params.getByteParams(key, value));
    }

    void get(const(ubyte)[] key) {
        sendCommand(Command.GET, key);
    }

    void quit() {
        db = 0;
        sendCommand(Command.QUIT);
    }

    void exists(const(ubyte)[][] keys...) {
        sendCommand(Command.EXISTS, keys);
    }

    void del(const(ubyte)[][] keys...) {
        sendCommand(Command.DEL, keys);
    }

    void unlink(const(ubyte)[][] keys...) {
        sendCommand(Command.UNLINK, keys);
    }

    void type(const(ubyte)[] key) {
        sendCommand(Command.TYPE, key);
    }

    void flushDB() {
        sendCommand(Command.FLUSHDB);
    }

    void keys(const(ubyte)[] pattern) {
        sendCommand(Command.KEYS, pattern);
    }

    void randomKey() {
        sendCommand(Command.RANDOMKEY);
    }

    void rename(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        sendCommand(Command.RENAME, oldkey, newkey);
    }

    void renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        sendCommand(Command.RENAMENX, oldkey, newkey);
    }

    void dbSize() {
        sendCommand(Command.DBSIZE);
    }

    void expire(const(ubyte)[] key, int seconds) {
        sendCommand(Command.EXPIRE, key, toByteArray(seconds));
    }

    void expireAt(const(ubyte)[] key, long unixTime) {
        sendCommand(Command.EXPIREAT, key, toByteArray(unixTime));
    }

    void ttl(const(ubyte)[] key) {
        sendCommand(Command.TTL, key);
    }

    void touch(const(ubyte)[][] keys...) {
        sendCommand(Command.TOUCH, keys);
    }

    void select(int index) {
        sendCommand(Command.SELECT, toByteArray(index));
    }

    void swapDB(int index1, int index2) {
        sendCommand(Command.SWAPDB, toByteArray(index1), toByteArray(index2));
    }

    void move(const(ubyte)[] key, int dbIndex) {
        sendCommand(Command.MOVE, key, toByteArray(dbIndex));
    }

    void flushAll() {
        sendCommand(Command.FLUSHALL);
    }

    void getSet(const(ubyte)[] key, const(ubyte)[] value) {
        sendCommand(Command.GETSET, key, value);
    }

    void mget(const(ubyte)[][] keys...) {
        sendCommand(Command.MGET, keys);
    }

    void setnx(const(ubyte)[] key, const(ubyte)[] value) {
        sendCommand(Command.SETNX, key, value);
    }

    void setex(const(ubyte)[] key, int seconds, const(ubyte)[] value) {
        sendCommand(Command.SETEX, key, toByteArray(seconds), value);
    }

    void mset(const(ubyte)[][] keysvalues...) {
        sendCommand(Command.MSET, keysvalues);
    }

    void msetnx(const(ubyte)[][] keysvalues...) {
        sendCommand(Command.MSETNX, keysvalues);
    }

    void decrBy(const(ubyte)[] key, long decrement) {
        sendCommand(Command.DECRBY, key, toByteArray(decrement));
    }

    void decr(const(ubyte)[] key) {
        sendCommand(Command.DECR, key);
    }

    void incrBy(const(ubyte)[] key, long increment) {
        sendCommand(Command.INCRBY, key, toByteArray(increment));
    }

    void incrByFloat(const(ubyte)[] key, double increment) {
        sendCommand(Command.INCRBYFLOAT, key, toByteArray(increment));
    }

    void incr(const(ubyte)[] key) {
        sendCommand(Command.INCR, key);
    }

    void append(const(ubyte)[] key, const(ubyte)[] value) {
        sendCommand(Command.APPEND, key, value);
    }

    void substr(const(ubyte)[] key, int start, int end) {
        sendCommand(Command.SUBSTR, key, toByteArray(start), toByteArray(end));
    }

    void hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
        sendCommand(Command.HSET, key, field, value);
    }

    void hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
        const(ubyte)[][] params = new const(ubyte)[][1 + hash.size() * 2];

        int index = 0;
        params[index++] = key;
        foreach (const(ubyte)[] k, const(ubyte)[] value; hash) {
            params[index++] = k;
            params[index++] = value;
        }
        sendCommand(Command.HSET, params);
    }

    void hget(const(ubyte)[] key, const(ubyte)[] field) {
        sendCommand(Command.HGET, key, field);
    }

    void hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
        sendCommand(Command.HSETNX, key, field, value);
    }

    void hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
        List!(const(ubyte)[]) params = new ArrayList!(const(ubyte)[])();
        params.add(key);

        foreach(const(ubyte)[] k, const(ubyte)[] value ; hash) {
            params.add(k);
            params.add(value);
        }
        sendCommand(Command.HMSET, params.toArray());
    }

    void hmget(const(ubyte)[] key, const(ubyte)[][] fields...) {
        sendCommand(Command.HMGET, joinParameters(key, fields));
    }

    void hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value) {
        sendCommand(Command.HINCRBY, key, field, toByteArray(value));
    }

    void hexists(const(ubyte)[] key, const(ubyte)[] field) {
        sendCommand(Command.HEXISTS, key, field);
    }

    void hdel(const(ubyte)[] key, const(ubyte)[][] fields...) {
        sendCommand(Command.HDEL, joinParameters(key, fields));
    }

    void hlen(const(ubyte)[] key) {
        sendCommand(Command.HLEN, key);
    }

    void hkeys(const(ubyte)[] key) {
        sendCommand(Command.HKEYS, key);
    }

    void hvals(const(ubyte)[] key) {
        sendCommand(Command.HVALS, key);
    }

    void hgetAll(const(ubyte)[] key) {
        sendCommand(Command.HGETALL, key);
    }

    void rpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
        sendCommand(Command.RPUSH, joinParameters(key, strings));
    }

    void lpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
        sendCommand(Command.LPUSH, joinParameters(key, strings));
    }

    void llen(const(ubyte)[] key) {
        sendCommand(Command.LLEN, key);
    }

    void lrange(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.LRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void ltrim(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.LTRIM, key, toByteArray(start), toByteArray(stop));
    }

    void lindex(const(ubyte)[] key, long index) {
        sendCommand(Command.LINDEX, key, toByteArray(index));
    }

    void lset(const(ubyte)[] key, long index, const(ubyte)[] value) {
        sendCommand(Command.LSET, key, toByteArray(index), value);
    }

    void lrem(const(ubyte)[] key, long count, const(ubyte)[] value) {
        sendCommand(Command.LREM, key, toByteArray(count), value);
    }

    void lpop(const(ubyte)[] key) {
        sendCommand(Command.LPOP, key);
    }

    void rpop(const(ubyte)[] key) {
        sendCommand(Command.RPOP, key);
    }

    void rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey) {
        sendCommand(Command.RPOPLPUSH, srckey, dstkey);
    }

    void sadd(const(ubyte)[] key, const(ubyte)[][] members...) {
        sendCommand(Command.SADD, joinParameters(key, members));
    }

    void smembers(const(ubyte)[] key) {
        sendCommand(Command.SMEMBERS, key);
    }

    void srem(const(ubyte)[] key, const(ubyte)[][] members...) {
        sendCommand(Command.SREM, joinParameters(key, members));
    }

    void spop(const(ubyte)[] key) {
        sendCommand(Command.SPOP, key);
    }

    void spop(const(ubyte)[] key, long count) {
        sendCommand(Command.SPOP, key, toByteArray(count));
    }

    void smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member) {
        sendCommand(Command.SMOVE, srckey, dstkey, member);
    }

    void scard(const(ubyte)[] key) {
        sendCommand(Command.SCARD, key);
    }

    void sismember(const(ubyte)[] key, const(ubyte)[] member) {
        sendCommand(Command.SISMEMBER, key, member);
    }

    void sinter(const(ubyte)[][] keys...) {
        sendCommand(Command.SINTER, keys);
    }

    void sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        sendCommand(Command.SINTERSTORE, joinParameters(dstkey, keys));
    }

    void sunion(const(ubyte)[][] keys...) {
        sendCommand(Command.SUNION, keys);
    }

    void sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        sendCommand(Command.SUNIONSTORE, joinParameters(dstkey, keys));
    }

    void sdiff(const(ubyte)[][] keys...) {
        sendCommand(Command.SDIFF, keys);
    }

    void sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        sendCommand(Command.SDIFFSTORE, joinParameters(dstkey, keys));
    }

    void srandmember(const(ubyte)[] key) {
        sendCommand(Command.SRANDMEMBER, key);
    }

    void zadd(const(ubyte)[] key, double score, const(ubyte)[] member) {
        sendCommand(Command.ZADD, key, toByteArray(score), member);
    }

    void zadd(const(ubyte)[] key, double score, const(ubyte)[] member,
            ZAddParams params) {
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(score), member));
    }

    void zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers) {
        ArrayList!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])(scoreMembers.size() * 2 + 1);
        args.add(key);
        args.addAll(convertScoreMembersToByteArrays(scoreMembers));

        const(ubyte)[][] argsArray = args.toArray();

        sendCommand(Command.ZADD, argsArray);
    }

    void zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers, ZAddParams params) {
        ArrayList!(const(ubyte)[]) args = convertScoreMembersToByteArrays(scoreMembers);
        const(ubyte)[][] argsArray = args.toArray();

        sendCommand(Command.ZADD, params.getByteParams(key, argsArray));
    }

    void zrange(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrem(const(ubyte)[] key, const(ubyte)[][] members...) {
        sendCommand(Command.ZREM, joinParameters(key, members));
    }

    void zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member) {
        sendCommand(Command.ZINCRBY, key, toByteArray(increment), member);
    }

    void zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member,
            ZIncrByParams params) {
        // Note that it actually calls ZADD with INCR option, so it requires Redis 3.0.2 or upper.
        sendCommand(Command.ZADD, params.getByteParams(key, toByteArray(increment), member));
    }

    void zrank(const(ubyte)[] key, const(ubyte)[] member) {
        sendCommand(Command.ZRANK, key, member);
    }

    void zrevrank(const(ubyte)[] key, const(ubyte)[] member) {
        sendCommand(Command.ZREVRANK, key, member);
    }

    void zrevrange(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop));
    }

    void zrangeWithScores(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.ZRANGE, key, toByteArray(start), toByteArray(stop), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeWithScores(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.ZREVRANGE, key, toByteArray(start), toByteArray(stop), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zcard(const(ubyte)[] key) {
        sendCommand(Command.ZCARD, key);
    }

    void zscore(const(ubyte)[] key, const(ubyte)[] member) {
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

    void watch(const(ubyte)[][] keys...) {
        sendCommand(Command.WATCH, keys);
        _isInWatch = true;
    }

    void unwatch() {
        sendCommand(Command.UNWATCH);
        _isInWatch = false;
    }

    void sort(const(ubyte)[] key) {
        sendCommand(Command.SORT, key);
    }

    void sort(const(ubyte)[] key, SortingParams sortingParameters) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        sendCommand(Command.SORT, args.toArray());
    }

    void blpop(const(ubyte)[][] args) {
        sendCommand(Command.BLPOP, args);
    }

    void blpop(int timeout, const(ubyte)[][] keys...) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        foreach(const(ubyte)[] arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        blpop(args.toArray());
    }

    void sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.addAll(sortingParameters.getParams());
        args.add(cast(const(ubyte)[])to!string(Keyword.STORE));
        args.add(dstkey);
        sendCommand(Command.SORT, args.toArray());
    }

    void sort(const(ubyte)[] key, const(ubyte)[] dstkey) {
        sendCommand(Command.SORT, key, cast(const(ubyte)[])to!string(Keyword.STORE), dstkey);
    }

    void brpop(const(ubyte)[][] args) {
        sendCommand(Command.BRPOP, args);
    }

    void brpop(int timeout, const(ubyte)[][] keys...) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        foreach(const(ubyte)[] arg ; keys) {
            args.add(arg);
        }
        args.add(Protocol.toByteArray(timeout));
        brpop(args.toArray());
    }

    void auth(string password) {
        import std.range;
        if(password.empty) return;
        setPassword(password);
        sendCommand(Command.AUTH, password);
    }

    void subscribe(const(ubyte)[][] channels...) {
        sendCommand(Command.SUBSCRIBE, channels);
    }

    void publish(const(ubyte)[] channel, const(ubyte)[] message) {
        sendCommand(Command.PUBLISH, channel, message);
    }

    void unsubscribe() {
        sendCommand(Command.UNSUBSCRIBE);
    }

    void unsubscribe(const(ubyte)[][] channels...) {
        sendCommand(Command.UNSUBSCRIBE, channels);
    }

    void psubscribe(const(ubyte)[][] patterns...) {
        sendCommand(Command.PSUBSCRIBE, patterns);
    }

    void punsubscribe() {
        sendCommand(Command.PUNSUBSCRIBE);
    }

    void punsubscribe(const(ubyte)[][] patterns...) {
        sendCommand(Command.PUNSUBSCRIBE, patterns);
    }

    void pubsub(const(ubyte)[][] args...) {
        sendCommand(Command.PUBSUB, args);
    }

    void zcount(const(ubyte)[] key, double min, double max) {
        sendCommand(Command.ZCOUNT, key, toByteArray(min), toByteArray(max));
    }

    void zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZCOUNT, key, min, max);
    }

    void zrangeByScore(const(ubyte)[] key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max);
    }

    void zrevrangeByScore(const(ubyte)[] key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min));
    }

    void zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min);
    }

    void zrangeByScore(const(ubyte)[] key, double min, double max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrevrangeByScore(const(ubyte)[] key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count));
    }

    void zrangeByScoreWithScores(const(ubyte)[] key, double min, double max) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(const(ubyte)[] key, double min, double max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, toByteArray(min), toByteArray(max), cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, toByteArray(max), toByteArray(min), cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
            int offset, int count) {
        sendCommand(Command.ZRANGEBYSCORE, key, min, max, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count),
            cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYSCORE, key, max, min, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset),
            toByteArray(count), cast(const(ubyte)[])to!string(Keyword.WITHSCORES));
    }

    void zremrangeByRank(const(ubyte)[] key, long start, long stop) {
        sendCommand(Command.ZREMRANGEBYRANK, key, toByteArray(start), toByteArray(stop));
    }

    void zremrangeByScore(const(ubyte)[] key, double min, double max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, toByteArray(min), toByteArray(max));
    }

    void zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZREMRANGEBYSCORE, key, min, max);
    }

    void zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        sendCommand(Command.ZUNIONSTORE, joinParameters(dstkey, toByteArray(sets.length), sets));
    }

    void zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(const(ubyte)[] set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZUNIONSTORE, args.toArray());
    }

    void zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        sendCommand(Command.ZINTERSTORE, joinParameters(dstkey, Protocol.toByteArray(sets.length), sets));
    }

    void zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(dstkey);
        args.add(Protocol.toByteArray(sets.length));
        foreach(const(ubyte)[] set ; sets) {
            args.add(set);
        }
        args.addAll(params.getParams());
        sendCommand(Command.ZINTERSTORE, args.toArray());
    }

    void zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZLEXCOUNT, key, min, max);
    }

    void zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max);
    }

    void zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
            int count) {
        sendCommand(Command.ZRANGEBYLEX, key, min, max, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min);
    }

    void zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
            int offset, int count) {
        sendCommand(Command.ZREVRANGEBYLEX, key, max, min, cast(const(ubyte)[])to!string(Keyword.LIMIT), toByteArray(offset), toByteArray(count));
    }

    void zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
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
        sendCommand(Command.SLAVEOF, cast(const(ubyte)[])to!string(Keyword.NO), cast(const(ubyte)[])to!string(Keyword.ONE));
    }

    void configGet(const(ubyte)[] pattern) {
        sendCommand(Command.CONFIG, cast(const(ubyte)[])to!string(Keyword.GET), pattern);
    }

    void configSet(const(ubyte)[] parameter, const(ubyte)[] value) {
        sendCommand(Command.CONFIG, cast(const(ubyte)[])to!string(Keyword.SET), parameter, value);
    }

    void strlen(const(ubyte)[] key) {
        sendCommand(Command.STRLEN, key);
    }

    void sync() {
        sendCommand(Command.SYNC);
    }

    void lpushx(const(ubyte)[] key, const(ubyte)[][] strings...) {
        sendCommand(Command.LPUSHX, joinParameters(key, strings));
    }

    void persist(const(ubyte)[] key) {
        sendCommand(Command.PERSIST, key);
    }

    void rpushx(const(ubyte)[] key, const(ubyte)[][] strings...) {
        sendCommand(Command.RPUSHX, joinParameters(key, strings));
    }

    void echo(const(ubyte)[] strings) {
        sendCommand(Command.ECHO, strings);
    }

    void linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot,
            const(ubyte)[] value) {
        sendCommand(Command.LINSERT, key, cast(const(ubyte)[])to!string(where), pivot, value);
    }

    // void debug(DebugParams params) {
    //   sendCommand(Command.DEBUG, params.getCommand());
    // }

    void brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout) {
        sendCommand(Command.BRPOPLPUSH, source, destination, toByteArray(timeout));
    }

    void configResetStat() {
        sendCommand(Command.CONFIG, cast(const(ubyte)[])to!string(Keyword.RESETSTAT));
    }

    void configRewrite() {
        sendCommand(Command.CONFIG, cast(const(ubyte)[])to!string(Keyword.REWRITE));
    }

    void setbit(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), value);
    }

    void setbit(const(ubyte)[] key, long offset, bool value) {
        sendCommand(Command.SETBIT, key, toByteArray(offset), toByteArray(value));
    }

    void getbit(const(ubyte)[] key, long offset) {
        sendCommand(Command.GETBIT, key, toByteArray(offset));
    }

    void bitpos(const(ubyte)[] key, bool value, BitPosParams params) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.add(toByteArray(value));
        args.addAll(params.getParams());
        sendCommand(Command.BITPOS, args.toArray());
    }

    void setrange(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        sendCommand(Command.SETRANGE, key, toByteArray(offset), value);
    }

    void getrange(const(ubyte)[] key, long startOffset, long endOffset) {
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

    void eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params) {
        sendCommand(Command.EVAL, joinParameters(script, keyCount, params));
    }

    void eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...) {
        sendCommand(Command.EVAL, joinParameters(script, toByteArray(keyCount), params));
    }

    void evalsha(const(ubyte)[] sha1, const(ubyte)[] keyCount, const(ubyte)[][] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, keyCount, params));
    }

    void evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...) {
        sendCommand(Command.EVALSHA, joinParameters(sha1, toByteArray(keyCount), params));
    }

    void scriptFlush() {
        sendCommand(Command.SCRIPT, cast(const(ubyte)[])to!string(Keyword.FLUSH));
    }

    void scriptExists(const(ubyte)[][] sha1...) {
        sendCommand(Command.SCRIPT, joinParameters(cast(const(ubyte)[])to!string(Keyword.EXISTS), sha1));
    }

    void scriptLoad(const(ubyte)[] script) {
        sendCommand(Command.SCRIPT, cast(const(ubyte)[])to!string(Keyword.LOAD), script);
    }

    void scriptKill() {
        sendCommand(Command.SCRIPT, cast(const(ubyte)[])to!string(Keyword.KILL));
    }

    void slowlogGet() {
        sendCommand(Command.SLOWLOG, cast(const(ubyte)[])to!string(Keyword.GET));
    }

    void slowlogGet(long entries) {
        sendCommand(Command.SLOWLOG, cast(const(ubyte)[])to!string(Keyword.GET), toByteArray(entries));
    }

    void slowlogReset() {
        sendCommand(Command.SLOWLOG, cast(const(ubyte)[])to!string(Keyword.RESET));
    }

    void slowlogLen() {
        sendCommand(Command.SLOWLOG, cast(const(ubyte)[])to!string(Keyword.LEN));
    }

    void objectRefcount(const(ubyte)[] key) {
        sendCommand(Command.OBJECT, cast(const(ubyte)[])to!string(Keyword.REFCOUNT), key);
    }

    void objectIdletime(const(ubyte)[] key) {
        sendCommand(Command.OBJECT, cast(const(ubyte)[])to!string(Keyword.IDLETIME), key);
    }

    void objectEncoding(const(ubyte)[] key) {
        sendCommand(Command.OBJECT, cast(const(ubyte)[])to!string(Keyword.ENCODING), key);
    }

    void bitcount(const(ubyte)[] key) {
        sendCommand(Command.BITCOUNT, key);
    }

    void bitcount(const(ubyte)[] key, long start, long end) {
        sendCommand(Command.BITCOUNT, key, toByteArray(start), toByteArray(end));
    }

    void bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...) {
        sendCommand(Command.BITOP, joinParameters(cast(const(ubyte)[])to!string(op), destKey, srcKeys));
    }

    void sentinel(const(ubyte)[][] args...) {
        sendCommand(Command.SENTINEL, args);
    }

    void dump(const(ubyte)[] key) {
        sendCommand(Command.DUMP, key);
    }

    void restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue);
    }

    void restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        sendCommand(Command.RESTORE, key, toByteArray(ttl), serializedValue, cast(const(ubyte)[])to!string(Keyword.REPLACE));
    }

    void pexpire(const(ubyte)[] key, long milliseconds) {
        sendCommand(Command.PEXPIRE, key, toByteArray(milliseconds));
    }

    void pexpireAt(const(ubyte)[] key, long millisecondsTimestamp) {
        sendCommand(Command.PEXPIREAT, key, toByteArray(millisecondsTimestamp));
    }

    void pttl(const(ubyte)[] key) {
        sendCommand(Command.PTTL, key);
    }

    void psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value) {
        sendCommand(Command.PSETEX, key, toByteArray(milliseconds), value);
    }

    void srandmember(const(ubyte)[] key, int count) {
        sendCommand(Command.SRANDMEMBER, key, toByteArray(count));
    }

    void memoryDoctor() {
        sendCommand(Command.MEMORY, cast(const(ubyte)[])to!string(Keyword.DOCTOR));
    }

    void clientKill(const(ubyte)[] ipPort) {
        sendCommand(Command.CLIENT, cast(const(ubyte)[])to!string(Keyword.KILL), ipPort);
    }

    void clientKill(string ip, int port) {
        sendCommand(Command.CLIENT, Keyword.KILL.to!string(), ip ~ ":" ~ port.to!string);
    }

    void clientKill(ClientKillParams params) {
        sendCommand(Command.CLIENT, joinParameters(cast(const(ubyte)[])to!string(Keyword.KILL), params.getByteParams()));
    }

    void clientGetname() {
        sendCommand(Command.CLIENT, cast(const(ubyte)[])to!string(Keyword.GETNAME));
    }

    void clientList() {
        sendCommand(Command.CLIENT, cast(const(ubyte)[])to!string(Keyword.LIST));
    }

    void clientSetname(const(ubyte)[] name) {
        sendCommand(Command.CLIENT, cast(const(ubyte)[])to!string(Keyword.SETNAME), name);
    }

    void clientPause(long timeout) {
        sendCommand(Command.CLIENT, cast(const(ubyte)[])to!string(Keyword.PAUSE), toByteArray(timeout));
    }

    void time() {
        sendCommand(Command.TIME);
    }

    void migrate(string host, int port, const(ubyte)[] key, int destinationDb,
            int timeout) {
        sendCommand(Command.MIGRATE, SafeEncoder.encode(host), toByteArray(port), key,
                toByteArray(destinationDb), toByteArray(timeout));
    }

    void migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, const(ubyte)[][] keys...) {
        const(ubyte)[][] bparams = params.getByteParams();
        int len = cast(int)(5 + bparams.length + 1 + keys.length);
        const(ubyte)[][] args = new const(ubyte)[][len];
        int i = 0;
        args[i++] = SafeEncoder.encode(host);
        args[i++] = toByteArray(port);
        args[i++] = [];
        args[i++] = toByteArray(destinationDB);
        args[i++] = toByteArray(timeout);
        // System.arraycopy(bparams, 0, args, i, bparams.length);
        args[i .. i+bparams.length] = bparams[0 .. $];
        i += bparams.length;
        args[i++] = cast(const(ubyte)[])to!string(Keyword.KEYS);
        // System.arraycopy(keys, 0, args, i, keys.length);
        args[i .. i+keys.length] = keys[0 .. $];
        sendCommand(Command.MIGRATE, args);
    }

    void hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double increment) {
        sendCommand(Command.HINCRBYFLOAT, key, field, toByteArray(increment));
    }

    void scan(const(ubyte)[] cursor, ScanParams params) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SCAN, args.toArray());
    }

    void hscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.HSCAN, args.toArray());
    }

    void sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.SSCAN, args.toArray());
    }

    void zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])();
        args.add(key);
        args.add(cursor);
        args.addAll(params.getParams());
        sendCommand(Command.ZSCAN, args.toArray());
    }

    void waitReplicas(int replicas, long timeout) {
        sendCommand(Command.WAIT, toByteArray(replicas), toByteArray(timeout));
    }

    void cluster(const(ubyte)[][] args...) {
        sendCommand(Command.CLUSTER, args);
    }

    void asking() {
        sendCommand(Command.ASKING);
    }

    void pfadd(const(ubyte)[] key, const(ubyte)[][] elements...) {
        sendCommand(Command.PFADD, joinParameters(key, elements));
    }

    void pfcount(const(ubyte)[] key) {
        sendCommand(Command.PFCOUNT, key);
    }

    void pfcount(const(ubyte)[][] keys...) {
        sendCommand(Command.PFCOUNT, keys);
    }

    void pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...) {
        sendCommand(Command.PFMERGE, joinParameters(destkey, sourcekeys));
    }

    void readonly() {
        sendCommand(Command.READONLY);
    }

    void geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member) {
        sendCommand(Command.GEOADD, key, toByteArray(longitude), toByteArray(latitude), member);
    }

    void geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])(memberCoordinateMap.size() * 3 + 1);
        args.add(key);
        args.addAll(convertGeoCoordinateMapToByteArrays(memberCoordinateMap));

        const(ubyte)[][] argsArray = args.toArray();

        sendCommand(Command.GEOADD, argsArray);
    }

    void geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2) {
        sendCommand(Command.GEODIST, key, member1, member2);
    }

    void geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit) {
        sendCommand(Command.GEODIST, key, member1, member2, cast(const(ubyte)[])(unit.toString()));
    }

    void geohash(const(ubyte)[] key, const(ubyte)[][] members...) {
        sendCommand(Command.GEOHASH, joinParameters(key, members));
    }

    void geopos(const(ubyte)[] key, const(ubyte)[][] members) {
        sendCommand(Command.GEOPOS, joinParameters(key, members));
    }

    void georadius(const(ubyte)[] key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(const(ubyte)[])(unit.toString()));
    }

    void georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUS_RO, key, toByteArray(longitude), toByteArray(latitude), toByteArray(radius),
            cast(const(ubyte)[])(unit.toString()));
    }

    void georadius(const(ubyte)[] key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(const(ubyte)[])(unit.toString())));
    }

    void georadiusReadonly(const(ubyte)[] key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUS_RO, param.getByteParams(key, toByteArray(longitude), toByteArray(latitude),
            toByteArray(radius), cast(const(ubyte)[])(unit.toString())));
    }

    void georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER, key, member, toByteArray(radius), cast(const(ubyte)[])(unit.toString()));
    }

    void georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, key, member, toByteArray(radius), cast(const(ubyte)[])(unit.toString()));
    }

    void georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER, param.getByteParams(key, member, toByteArray(radius), cast(const(ubyte)[])(unit.toString())));
    }

    void georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        sendCommand(Command.GEORADIUSBYMEMBER_RO, param.getByteParams(key, member, toByteArray(radius), cast(const(ubyte)[])(unit.toString())));
    }

    void moduleLoad(const(ubyte)[] path) {
        sendCommand(Command.MODULE, cast(const(ubyte)[])to!string(Keyword.LOAD), path);
    }

    void moduleList() {
        sendCommand(Command.MODULE, cast(const(ubyte)[])to!string(Keyword.LIST));
    }

    void moduleUnload(const(ubyte)[] name) {
        sendCommand(Command.MODULE, cast(const(ubyte)[])to!string(Keyword.UNLOAD), name);
    }

    private ArrayList!(const(ubyte)[]) convertScoreMembersToByteArrays(Map!(const(ubyte)[], double) scoreMembers) {
        ArrayList!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])(scoreMembers.size() * 2);

        foreach(const(ubyte)[] key, double value ; scoreMembers) {
            args.add(toByteArray(value));
            args.add(key);
        }

        return args;
    }

    private List!(const(ubyte)[]) convertGeoCoordinateMapToByteArrays(
            Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
        List!(const(ubyte)[]) args = new ArrayList!(const(ubyte)[])(memberCoordinateMap.size() * 3);

        foreach(const(ubyte)[] key, GeoCoordinate coordinate ; memberCoordinateMap) {
            args.add(toByteArray(coordinate.getLongitude()));
            args.add(toByteArray(coordinate.getLatitude()));
            args.add(key);
        }

        return args;
    }

    void bitfield(const(ubyte)[] key, const(ubyte)[][] value...) {
        sendCommand(Command.BITFIELD, joinParameters(key, value));
    }

    void hstrlen(const(ubyte)[] key, const(ubyte)[] field) {
        sendCommand(Command.HSTRLEN, key, field);
    }
    
    void xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength) {
            int maxLexArgs = 0;
            if(maxLen < long.max) { // optional arguments
                if(approximateLength) {
                    maxLexArgs = 3; // e.g. MAXLEN ~ 1000 
                } else {
                    maxLexArgs = 2; // e.g. MAXLEN 1000
                }
            }
        
        const(ubyte)[][] params = new const(ubyte)[][2 + maxLexArgs + hash.size() * 2];
        int index = 0;
        params[index++] = key;
        if(maxLen < long.max) {
            params[index++] = cast(const(ubyte)[])to!string(Keyword.MAXLEN);
            if(approximateLength) {
                params[index++] = cast(const(ubyte)[])Protocol.BYTES_TILDE;
            }
            params[index++] = toByteArray(maxLen);
        }
        
        params[index++] = id;
        foreach(const(ubyte)[] k, const(ubyte)[] value ; hash) {
            params[index++] = k;
            params[index++] = value;
        }
        sendCommand(Command.XADD, params);
    }
    
    void xlen(const(ubyte)[] key) {
         sendCommand(Command.XLEN, key);
    }
    
    void xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count) { 
         sendCommand(Command.XRANGE, key, start, end, cast(const(ubyte)[])to!string(Keyword.COUNT), toByteArray(count));
    }
    
    void xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count) {
        sendCommand(Command.XREVRANGE, key, end, start, cast(const(ubyte)[])to!string(Keyword.COUNT), toByteArray(count));
    }

    void xread(int count, long block, Map!(const(ubyte)[], const(ubyte)[]) streams) {
        const(ubyte)[][] params = new const(ubyte)[][3 + streams.size() * 2 + (block > 0 ? 2 : 0)];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.COUNT);
        params[streamsIndex++] = toByteArray(count);
        if(block > 0) {
            params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        
        params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.STREAMS);
        int idsIndex = streamsIndex + streams.size();

        foreach(const(ubyte)[] key, const(ubyte)[] value; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREAD, params);
 }
    
    void xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...) {
        const(ubyte)[][] params = new const(ubyte)[][2 + ids.length];
        int index = 0;
        params[index++] = key;
        params[index++] = group;
        foreach(const(ubyte)[] id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XACK, params);
    }
     
    void xgroupCreate(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id, bool makeStream) {
        if(makeStream) {
            sendCommand(Command.XGROUP, cast(const(ubyte)[])to!string(Keyword.CREATE), key, groupname, id, cast(const(ubyte)[])to!string(Keyword.MKSTREAM));  
        } else {
            sendCommand(Command.XGROUP, cast(const(ubyte)[])to!string(Keyword.CREATE), key, groupname, id);  
        }
    }

    void xgroupSetID(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id) {
        sendCommand(Command.XGROUP, cast(const(ubyte)[])to!string(Keyword.SETID), key, groupname, id);    
    }

    void xgroupDestroy(const(ubyte)[] key, const(ubyte)[] groupname) {
        sendCommand(Command.XGROUP, cast(const(ubyte)[])to!string(Keyword.DESTROY), key, groupname);    
    }

    void xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumerName) {
        sendCommand(Command.XGROUP, cast(const(ubyte)[])to!string(Keyword.DELCONSUMER), key, groupname, consumerName);    
    }
     
    void xdel(const(ubyte)[] key, const(ubyte)[][] ids...) {
        const(ubyte)[][] params = new const(ubyte)[][1 + ids.length];
        int index = 0;
        params[index++] = key;
        foreach(const(ubyte)[] id ; ids) {
            params[index++] = id;
        }
        sendCommand(Command.XDEL, params);
    }
    
    void xtrim(const(ubyte)[] key, long maxLen, bool approximateLength) {
        if(approximateLength) {
            sendCommand(Command.XTRIM, key, cast(const(ubyte)[])to!string(Keyword.MAXLEN), Protocol.BYTES_TILDE ,toByteArray(maxLen));
        } else {
            sendCommand(Command.XTRIM, key, cast(const(ubyte)[])to!string(Keyword.MAXLEN), toByteArray(maxLen));
        }
    }
    
    void xreadGroup(const(ubyte)[] groupname, const(ubyte)[] consumer, int count, 
                long block, bool noAck, Map!(const(ubyte)[], const(ubyte)[]) streams) {
        
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
        
        
        const(ubyte)[][] params = new const(ubyte)[][4 + optional + streams.size() * 2];

        int streamsIndex = 0;
        params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.GROUP);
        params[streamsIndex++] = groupname;
        params[streamsIndex++] = consumer;
        if(count>0) {
            params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.COUNT);
            params[streamsIndex++] = toByteArray(count);
        }
        if(block > 0) {
            params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.BLOCK);
            params[streamsIndex++] = toByteArray(block);
        }
        if(noAck) {
            params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.NOACK);
        }
        params[streamsIndex++] = cast(const(ubyte)[])to!string(Keyword.STREAMS);
        
        int idsIndex = streamsIndex + streams.size();
        foreach(const(ubyte)[] key, const(ubyte)[] value ; streams) {
            params[streamsIndex++] = key;
            params[idsIndex++] = value;
        }
        
        sendCommand(Command.XREADGROUP, params);
    }

    
    void xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, 
                                const(ubyte)[] end, int count, const(ubyte)[] consumername) {
        if(consumername is null) {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count));
        } else {
            sendCommand(Command.XPENDING, key, groupname, start, end, toByteArray(count), consumername);
        }
    }

    void xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, long minIdleTime, 
                            long newIdleTime, int retries, bool force, const(ubyte)[][] ids) {
            
            ArrayList!(const(ubyte)[]) arguments = new ArrayList!(const(ubyte)[])(cast(int)(10 + ids.length));

            arguments.add(key);
            arguments.add(groupname);
            arguments.add(consumername);
            arguments.add(toByteArray(minIdleTime));
            
            foreach(const(ubyte)[] id ; ids) {
                arguments.add(id);  
            }
            if(newIdleTime > 0) {
                arguments.add(cast(const(ubyte)[])to!string(Keyword.IDLE));
                arguments.add(toByteArray(newIdleTime));
            }
            if(retries > 0) {
                arguments.add(cast(const(ubyte)[])to!string(Keyword.RETRYCOUNT));
                arguments.add(toByteArray(retries));        
            }
            if(force) {
                arguments.add(cast(const(ubyte)[])to!string(Keyword.FORCE));        
            }
            sendCommand(Command.XCLAIM, arguments.toArray());
    }

}
