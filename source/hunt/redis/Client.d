module hunt.redis.Client;

import hunt.redis.BinaryClient;
import hunt.redis.BitOP;
import hunt.redis.BitPosParams;
import hunt.redis.ClusterReset;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Protocol;
import hunt.redis.ScanParams;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntryID;
import hunt.redis.ZParams;

import hunt.redis.commands.Commands;
import hunt.redis.params.ClientKillParams;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;


// import hunt.Double;
import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;

import std.conv;

class Client : BinaryClient, Commands {

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

    override
    void ping(string message) {
        ping(SafeEncoder.encode(message));
    }
    alias ping = BinaryClient.ping;
    
    override
    void set(string key, string value) {
        set(SafeEncoder.encode(key), SafeEncoder.encode(value));
    }
    alias set = BinaryClient.set;

    override
    void set(string key, string value, SetParams params) {
        set(SafeEncoder.encode(key), SafeEncoder.encode(value), params);
    }

    override
    void get(string key) {
        get(SafeEncoder.encode(key));
    }
    alias get = BinaryClient.get;

    override
    void exists(string[] keys...) {
        exists(SafeEncoder.encodeMany(keys));
    }
    alias exists = BinaryClient.exists;

    override
    void del(string[] keys...) {
        del(SafeEncoder.encodeMany(keys));
    }
    alias del = BinaryClient.del;

    override
    void unlink(string[] keys...) {
        unlink(SafeEncoder.encodeMany(keys));
    }
    alias unlink = BinaryClient.unlink;

    override
    void type(string key) {
        type(SafeEncoder.encode(key));
    }
    alias type = BinaryClient.type;

    override
    void keys(string pattern) {
        keys(SafeEncoder.encode(pattern));
    }
    alias keys = BinaryClient.keys;

    override
    void rename(string oldkey, string newkey) {
        rename(SafeEncoder.encode(oldkey), SafeEncoder.encode(newkey));
    }
    alias rename = BinaryClient.rename;

    void renamenx(string oldkey, string newkey) {
        renamenx(SafeEncoder.encode(oldkey), SafeEncoder.encode(newkey));
    }
    alias renamenx = BinaryClient.renamenx;

    void expire(string key, int seconds) {
        expire(SafeEncoder.encode(key), seconds);
    }
    alias expire = BinaryClient.expire;

    // override
    void expireAt(string key, long unixTime) {
        expireAt(SafeEncoder.encode(key), unixTime);
    }
    alias expireAt = BinaryClient.expireAt;


    void ttl(string key) {
        ttl(SafeEncoder.encode(key));
    }
    alias ttl = BinaryClient.ttl;

    override
    void touch(string[] keys...) {
        touch(SafeEncoder.encodeMany(keys));
    }
    alias touch = BinaryClient.touch;

    override
    void move(string key, int dbIndex) {
        move(SafeEncoder.encode(key), dbIndex);
    }
    alias move = BinaryClient.move;

    override
    void getSet(string key, string value) {
        getSet(SafeEncoder.encode(key), SafeEncoder.encode(value));
    }
    alias getSet = BinaryClient.getSet;

    override
    void mget(string[] keys...) {
        mget(SafeEncoder.encodeMany(keys));
    }
    alias mget = BinaryClient.mget;

    override
    void setnx(string key, string value) {
        setnx(SafeEncoder.encode(key), SafeEncoder.encode(value));
    }
    alias setnx = BinaryClient.setnx;

    override
    void setex(string key, int seconds, string value) {
        setex(SafeEncoder.encode(key), seconds, SafeEncoder.encode(value));
    }
    alias setex = BinaryClient.setex;

    override
    void mset(string[] keysvalues...) {
        mset(SafeEncoder.encodeMany(keysvalues));
    }
    alias mset = BinaryClient.mset;

    override
    void msetnx(string[] keysvalues...) {
        msetnx(SafeEncoder.encodeMany(keysvalues));
    }
    alias msetnx = BinaryClient.msetnx;

    override
    void decrBy(string key, long decrement) {
        decrBy(SafeEncoder.encode(key), decrement);
    }
    alias decrBy = BinaryClient.decrBy;

    override
    void decr(string key) {
        decr(SafeEncoder.encode(key));
    }
    alias decr = BinaryClient.decr;

    override
    void incrBy(string key, long increment) {
        incrBy(SafeEncoder.encode(key), increment);
    }
    alias incrBy = BinaryClient.incrBy;

    override
    void incr(string key) {
        incr(SafeEncoder.encode(key));
    }
    alias incr = BinaryClient.incr;

    override
    void append(string key, string value) {
        append(SafeEncoder.encode(key), SafeEncoder.encode(value));
    }
    alias append = BinaryClient.append;

    override
    void substr(string key, int start, int end) {
        substr(SafeEncoder.encode(key), start, end);
    }
    alias substr = BinaryClient.substr;

    override
    void hset(string key, string field, string value) {
        hset(SafeEncoder.encode(key), SafeEncoder.encode(field), SafeEncoder.encode(value));
    }
    alias hset = BinaryClient.hset;

    override
    void hset(string key, Map!(string, string) hash) {
        Map!(const(ubyte)[], const(ubyte)[]) bhash = new HashMap!(const(ubyte)[], const(ubyte)[])(hash.size());
        foreach(string k, string v; hash) {
            bhash.put(SafeEncoder.encode(k), SafeEncoder.encode(v));
        }
        hset(SafeEncoder.encode(key), bhash);
    }

    override
    void hget(string key, string field) {
        hget(SafeEncoder.encode(key), SafeEncoder.encode(field));
    }
    alias hget = BinaryClient.hget;

    override
    void hsetnx(string key, string field, string value) {
        hsetnx(SafeEncoder.encode(key), SafeEncoder.encode(field), SafeEncoder.encode(value));
    }
    alias hsetnx = BinaryClient.hsetnx;

    override
    void hmset(string key, Map!(string, string) hash) {
        Map!(const(ubyte)[], const(ubyte)[]) bhash = new HashMap!(const(ubyte)[], const(ubyte)[])(hash.size());
        foreach(string k, string v; hash) {
            bhash.put(SafeEncoder.encode(k), SafeEncoder.encode(v));
        }
        hmset(SafeEncoder.encode(key), bhash);
    }
    alias hmset = BinaryClient.hmset;

    override
    void hmget(string key, string[] fields...) {
        hmget(SafeEncoder.encode(key), SafeEncoder.encodeMany(fields));
    }
    alias hmget = BinaryClient.hmget;

    override
    void hincrBy(string key, string field, long value) {
        hincrBy(SafeEncoder.encode(key), SafeEncoder.encode(field), value);
    }
    alias hincrBy = BinaryClient.hincrBy;

    override
    void hexists(string key, string field) {
        hexists(SafeEncoder.encode(key), SafeEncoder.encode(field));
    }
    alias hexists = BinaryClient.hexists;

    override
    void hdel(string key, string[] fields...) {
        hdel(SafeEncoder.encode(key), SafeEncoder.encodeMany(fields));
    }
    alias hdel = BinaryClient.hdel;

    override
    void hlen(string key) {
        hlen(SafeEncoder.encode(key));
    }
    alias hlen = BinaryClient.hlen;

    override
    void hkeys(string key) {
        hkeys(SafeEncoder.encode(key));
    }
    alias hkeys = BinaryClient.hkeys;

    override
    void hvals(string key) {
        hvals(SafeEncoder.encode(key));
    }
    alias hvals = BinaryClient.hvals;

    override
    void hgetAll(string key) {
        hgetAll(SafeEncoder.encode(key));
    }
    alias hgetAll = BinaryClient.hgetAll;

    override
    void rpush(string key, string[] string...) {
        rpush(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
    }
    alias rpush = BinaryClient.rpush;

    override
    void lpush(string key, string[] string...) {
        lpush(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
    }
    alias lpush = BinaryClient.lpush;

    override
    void llen(string key) {
        llen(SafeEncoder.encode(key));
    }
    alias llen = BinaryClient.llen;

    override
    void lrange(string key, long start, long stop) {
        lrange(SafeEncoder.encode(key), start, stop);
    }
    alias lrange = BinaryClient.lrange;

    override
    void ltrim(string key, long start, long stop) {
        ltrim(SafeEncoder.encode(key), start, stop);
    }
    alias ltrim = BinaryClient.ltrim;

    override
    void lindex(string key, long index) {
        lindex(SafeEncoder.encode(key), index);
    }
    alias lindex = BinaryClient.lindex;

    override
    void lset(string key, long index, string value) {
        lset(SafeEncoder.encode(key), index, SafeEncoder.encode(value));
    }
    alias lset = BinaryClient.lset;

    override
    void lrem(string key, long count, string value) {
        lrem(SafeEncoder.encode(key), count, SafeEncoder.encode(value));
    }
    alias lrem = BinaryClient.lrem;

    override
    void lpop(string key) {
        lpop(SafeEncoder.encode(key));
    }
    alias lpop = BinaryClient.lpop;

    override
    void rpop(string key) {
        rpop(SafeEncoder.encode(key));
    }
    alias rpop = BinaryClient.rpop;

    override
    void rpoplpush(string srckey, string dstkey) {
        rpoplpush(SafeEncoder.encode(srckey), SafeEncoder.encode(dstkey));
    }
    alias rpoplpush = BinaryClient.rpoplpush;

    override
    void sadd(string key, string[] members...) {
        sadd(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
    }
    alias sadd = BinaryClient.sadd;

    override
    void smembers(string key) {
        smembers(SafeEncoder.encode(key));
    }
    alias smembers = BinaryClient.smembers;

    override
    void srem(string key, string[] members...) {
        srem(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
    }
    alias srem = BinaryClient.srem;

    override
    void spop(string key) {
        spop(SafeEncoder.encode(key));
    }
    alias spop = BinaryClient.spop;

    override
    void spop(string key, long count) {
        spop(SafeEncoder.encode(key), count);
    }
    alias spop = BinaryClient.spop;

    override
    void smove(string srckey, string dstkey, string member) {
        smove(SafeEncoder.encode(srckey), SafeEncoder.encode(dstkey), SafeEncoder.encode(member));
    }
    alias smove = BinaryClient.smove;

    override
    void scard(string key) {
        scard(SafeEncoder.encode(key));
    }
    alias scard = BinaryClient.scard;

    override
    void sismember(string key, string member) {
        sismember(SafeEncoder.encode(key), SafeEncoder.encode(member));
    }
    alias sismember = BinaryClient.sismember;

    override
    void sinter(string[] keys...) {
        sinter(SafeEncoder.encodeMany(keys));
    }
    alias sinter = BinaryClient.sinter;

    override
    void sinterstore(string dstkey, string[] keys...) {
        sinterstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
    }
    alias sinterstore = BinaryClient.sinterstore;

    override
    void sunion(string[] keys...) {
        sunion(SafeEncoder.encodeMany(keys));
    }
    alias sunion = BinaryClient.sunion;

    override
    void sunionstore(string dstkey, string[] keys...) {
        sunionstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
    }
    alias sunionstore = BinaryClient.sunionstore;

    override
    void sdiff(string[] keys...) {
        sdiff(SafeEncoder.encodeMany(keys));
    }
    alias sdiff = BinaryClient.sdiff;

    override
    void sdiffstore(string dstkey, string[] keys...) {
        sdiffstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(keys));
    }
    alias sdiffstore = BinaryClient.sdiffstore;

    override
    void srandmember(string key) {
        srandmember(SafeEncoder.encode(key));
    }
    alias srandmember = BinaryClient.srandmember;

    override
    void zadd(string key, double score, string member) {
        zadd(SafeEncoder.encode(key), score, SafeEncoder.encode(member));
    }
    alias zadd = BinaryClient.zadd;

    override
    void zadd(string key, double score, string member,
            ZAddParams params) {
        zadd(SafeEncoder.encode(key), score, SafeEncoder.encode(member), params);
    }
    alias zadd = BinaryClient.zadd;

    override
    void zadd(string key, Map!(string, double) scoreMembers) {
        HashMap!(const(ubyte)[], double) binaryScoreMembers = convertScoreMembersToBinary(scoreMembers);
        zadd(SafeEncoder.encode(key), binaryScoreMembers);
    }
    alias zadd = BinaryClient.zadd;

    override
    void zadd(string key, Map!(string, double) scoreMembers, ZAddParams params) {
        HashMap!(const(ubyte)[], double) binaryScoreMembers = convertScoreMembersToBinary(scoreMembers);
        zadd(SafeEncoder.encode(key), binaryScoreMembers, params);
    }
    alias zadd = BinaryClient.zadd;

    override
    void zrange(string key, long start, long stop) {
        zrange(SafeEncoder.encode(key), start, stop);
    }
    alias zrange = BinaryClient.zrange;

    override
    void zrem(string key, string[] members...) {
        zrem(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
    }
    alias zrem = BinaryClient.zrem;

    override
    void zincrby(string key, double increment, string member) {
        zincrby(SafeEncoder.encode(key), increment, SafeEncoder.encode(member));
    }
    alias zincrby = BinaryClient.zincrby;

    override
    void zincrby(string key, double increment, string member, ZIncrByParams params) {
        zincrby(SafeEncoder.encode(key), increment, SafeEncoder.encode(member), params);
    }

    override
    void zrank(string key, string member) {
        zrank(SafeEncoder.encode(key), SafeEncoder.encode(member));
    }
    alias zrank = BinaryClient.zrank;

    override
    void zrevrank(string key, string member) {
        zrevrank(SafeEncoder.encode(key), SafeEncoder.encode(member));
    }
    alias zrevrank = BinaryClient.zrevrank;

    override
    void zrevrange(string key, long start, long stop) {
        zrevrange(SafeEncoder.encode(key), start, stop);
    }
    alias zrevrange = BinaryClient.zrevrange;

    override
    void zrangeWithScores(string key, long start, long stop) {
        zrangeWithScores(SafeEncoder.encode(key), start, stop);
    }
    alias zrangeWithScores = BinaryClient.zrangeWithScores;

    override
    void zrevrangeWithScores(string key, long start, long stop) {
        zrevrangeWithScores(SafeEncoder.encode(key), start, stop);
    }
    alias zrevrangeWithScores = BinaryClient.zrevrangeWithScores;

    override
    void zcard(string key) {
        zcard(SafeEncoder.encode(key));
    }
    alias zcard = BinaryClient.zcard;

    override
    void zscore(string key, string member) {
        zscore(SafeEncoder.encode(key), SafeEncoder.encode(member));
    }
    alias zscore = BinaryClient.zscore;

    override
    void watch(string[] keys...) {
        watch(SafeEncoder.encodeMany(keys));
    }
    alias watch = BinaryClient.watch;

    override
    void sort(string key) {
        sort(SafeEncoder.encode(key));
    }
    alias sort = BinaryClient.sort;

    override
    void sort(string key, SortingParams sortingParameters) {
        sort(SafeEncoder.encode(key), sortingParameters);
    }

    override
    void blpop(string[] args) {
        blpop(SafeEncoder.encodeMany(args));
    }
    alias blpop = BinaryClient.blpop;

    void blpop(int timeout, string[] keys...) {
        size_t size = keys.length + 1;
        List!(string) args = new ArrayList!(string)(cast(int)size);
        foreach(string arg ; keys) {
            args.add(arg);
        }
        args.add(to!string(timeout));
        blpop(args.toArray());
    }

    override
    void sort(string key, SortingParams sortingParameters, string dstkey) {
        sort(SafeEncoder.encode(key), sortingParameters, SafeEncoder.encode(dstkey));
    }
    alias sort = BinaryClient.sort;

    override
    void sort(string key, string dstkey) {
        sort(SafeEncoder.encode(key), SafeEncoder.encode(dstkey));
    }

    override
    void brpop(string[] args) {
        brpop(SafeEncoder.encodeMany(args));
    }
    alias brpop = BinaryClient.brpop;

    void brpop(int timeout, string[] keys...) {
        size_t size = keys.length + 1;
        List!(string) args = new ArrayList!(string)(cast(int)size);
        foreach(string arg ; keys) {
            args.add(arg);
        }
        args.add(to!string(timeout));
        brpop(args.toArray());
    }

    override
    void zcount(string key, double min, double max) {
        zcount(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
    }
    alias zcount = BinaryClient.zcount;

    override
    void zcount(string key, string min, string max) {
        zcount(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }

    override
    void zrangeByScore(string key, double min, double max) {
        zrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
    }
    alias zrangeByScore = BinaryClient.zrangeByScore;

    override
    void zrangeByScore(string key, string min, string max) {
        zrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }

    override
    void zrangeByScore(string key, double min, double max, int offset,
            int count) {
        zrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max), offset, count);
    }

    override
    void zrangeByScoreWithScores(string key, double min, double max) {
        zrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
    }
    alias zrangeByScoreWithScores = BinaryClient.zrangeByScoreWithScores;

    override
    void zrangeByScoreWithScores(string key, double min, double max,
            int offset, int count) {
        zrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(min), toByteArray(max), offset,
            count);
    }

    override
    void zrevrangeByScore(string key, double max, double min) {
        zrevrangeByScore(SafeEncoder.encode(key), toByteArray(max), toByteArray(min));
    }
    alias zrevrangeByScore = BinaryClient.zrevrangeByScore;

    override
    void zrangeByScore(string key, string min, string max, int offset,
            int count) {
        zrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max),
            offset, count);
    }

    override
    void zrangeByScoreWithScores(string key, string min, string max) {
        zrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(min),
            SafeEncoder.encode(max));
    }
    alias zrangeByScoreWithScores = BinaryClient.zrangeByScoreWithScores;

    override
    void zrangeByScoreWithScores(string key, string min, string max,
            int offset, int count) {
        zrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(min),
            SafeEncoder.encode(max), offset, count);
    }

    override
    void zrevrangeByScore(string key, string max, string min) {
        zrevrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min));
    }
    alias zrevrangeByScore = BinaryClient.zrevrangeByScore;

    override
    void zrevrangeByScore(string key, double max, double min,
            int offset, int count) {
        zrevrangeByScore(SafeEncoder.encode(key), toByteArray(max), toByteArray(min), offset, count);
    }

    override
    void zrevrangeByScore(string key, string max, string min,
            int offset, int count) {
        zrevrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min),
            offset, count);
    }


    override
    void zrevrangeByScoreWithScores(string key, double max, double min) {
        zrevrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(max), toByteArray(min));
    }
    alias zrevrangeByScoreWithScores = BinaryClient.zrevrangeByScoreWithScores;

    override
    void zrevrangeByScoreWithScores(string key, string max, string min) {
        zrevrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(max),
            SafeEncoder.encode(min));
    }

    override
    void zrevrangeByScoreWithScores(string key, double max, double min,
            int offset, int count) {
        zrevrangeByScoreWithScores(SafeEncoder.encode(key), toByteArray(max), toByteArray(min), offset,
            count);
    }

    override
    void zrevrangeByScoreWithScores(string key, string max, string min,
            int offset, int count) {
        zrevrangeByScoreWithScores(SafeEncoder.encode(key), SafeEncoder.encode(max),
            SafeEncoder.encode(min), offset, count);
    }

    override
    void zremrangeByRank(string key, long start, long stop) {
        zremrangeByRank(SafeEncoder.encode(key), start, stop);
    }
    alias zremrangeByRank = BinaryClient.zremrangeByRank;

    override
    void zremrangeByScore(string key, double min, double max) {
        zremrangeByScore(SafeEncoder.encode(key), toByteArray(min), toByteArray(max));
    }
    alias zremrangeByScore = BinaryClient.zremrangeByScore;

    override
    void zremrangeByScore(string key, string min, string max) {
        zremrangeByScore(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }

    override
    void zunionstore(string dstkey, string[] sets...) {
        zunionstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(sets));
    }
    alias zunionstore = BinaryClient.zunionstore;

    override
    void zunionstore(string dstkey, ZParams params, string[] sets...) {
        zunionstore(SafeEncoder.encode(dstkey), params, SafeEncoder.encodeMany(sets));
    }

    override
    void zinterstore(string dstkey, string[] sets...) {
        zinterstore(SafeEncoder.encode(dstkey), SafeEncoder.encodeMany(sets));
    }
    alias zinterstore = BinaryClient.zinterstore;

    override
    void zinterstore(string dstkey, ZParams params, string[] sets...) {
        zinterstore(SafeEncoder.encode(dstkey), params, SafeEncoder.encodeMany(sets));
    }

    void zlexcount(string key, string min, string max) {
        zlexcount(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }
    alias zlexcount = BinaryClient.zlexcount;

    void zrangeByLex(string key, string min, string max) {
        zrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }
    alias zrangeByLex = BinaryClient.zrangeByLex;

    void zrangeByLex(string key, string min, string max, int offset,
            int count) {
        zrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max), offset,
            count);
    }

    void zrevrangeByLex(string key, string max, string min) {
        zrevrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min));
    }
    alias zrevrangeByLex = BinaryClient.zrevrangeByLex;

    void zrevrangeByLex(string key, string max, string min, int offset, int count) {
        zrevrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(max), SafeEncoder.encode(min),
            offset, count);
    }

    void zremrangeByLex(string key, string min, string max) {
        zremrangeByLex(SafeEncoder.encode(key), SafeEncoder.encode(min), SafeEncoder.encode(max));
    }
    alias zremrangeByLex = BinaryClient.zremrangeByLex;

    override
    void strlen(string key) {
        strlen(SafeEncoder.encode(key));
    }
    alias strlen = BinaryClient.strlen;

    override
    void lpushx(string key, string[] string...) {
        lpushx(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
    }
    alias lpushx = BinaryClient.lpushx;

    override
    void persist(string key) {
        persist(SafeEncoder.encode(key));
    }
    alias persist = BinaryClient.persist;

    override
    void rpushx(string key, string[] string...) {
        rpushx(SafeEncoder.encode(key), SafeEncoder.encodeMany(string));
    }
    alias rpushx = BinaryClient.rpushx;

    override
    void echo(string string) {
        echo(SafeEncoder.encode(string));
    }
    alias echo = BinaryClient.echo;

    override
    void linsert(string key, ListPosition where, string pivot,
            string value) {
        linsert(SafeEncoder.encode(key), where, SafeEncoder.encode(pivot), SafeEncoder.encode(value));
    }
    alias linsert = BinaryClient.linsert;

    override
    void brpoplpush(string source, string destination, int timeout) {
        brpoplpush(SafeEncoder.encode(source), SafeEncoder.encode(destination), timeout);
    }
    alias brpoplpush = BinaryClient.brpoplpush;

    override
    void setbit(string key, long offset, bool value) {
        setbit(SafeEncoder.encode(key), offset, value);
    }
    alias setbit = BinaryClient.setbit;

    override
    void setbit(string key, long offset, string value) {
        setbit(SafeEncoder.encode(key), offset, SafeEncoder.encode(value));
    }
    alias setbit = BinaryClient.setbit;

    override
    void getbit(string key, long offset) {
        getbit(SafeEncoder.encode(key), offset);
    }
    alias getbit = BinaryClient.getbit;

    void bitpos(string key, bool value, BitPosParams params) {
        bitpos(SafeEncoder.encode(key), value, params);
    }
    alias bitpos = BinaryClient.bitpos;

    override
    void setrange(string key, long offset, string value) {
        setrange(SafeEncoder.encode(key), offset, SafeEncoder.encode(value));
    }
    alias setrange = BinaryClient.setrange;

    override
    void getrange(string key, long startOffset, long endOffset) {
        getrange(SafeEncoder.encode(key), startOffset, endOffset);
    }
    alias getrange = BinaryClient.getrange;

    void publish(string channel, string message) {
        publish(SafeEncoder.encode(channel), SafeEncoder.encode(message));
    }
    alias publish = BinaryClient.publish;

    void unsubscribe(string[] channels...) {
        unsubscribe(SafeEncoder.encodeMany(channels));
    }
    alias unsubscribe = BinaryClient.unsubscribe;

    void psubscribe(string[] patterns...) {
        psubscribe(SafeEncoder.encodeMany(patterns));
    }
    alias psubscribe = BinaryClient.psubscribe;

    void punsubscribe(string[] patterns...) {
        punsubscribe(SafeEncoder.encodeMany(patterns));
    }
    alias punsubscribe = BinaryClient.punsubscribe;

    void subscribe(string[] channels...) {
        subscribe(SafeEncoder.encodeMany(channels));
    }
    alias subscribe = BinaryClient.subscribe;

    void pubsubChannels(string pattern) {
        pubsub(Protocol.PUBSUB_CHANNELS, pattern);
    }

    void pubsubNumPat() {
        pubsub(Protocol.PUBSUB_NUM_PAT);
    }

    void pubsubNumSub(string[] channels...) {
        pubsub(Protocol.PUBSUB_NUMSUB, channels);
    }

    // override
    void configSet(string parameter, string value) {
        configSet(SafeEncoder.encode(parameter), SafeEncoder.encode(value));
    }
    alias configSet = BinaryClient.configSet;

    // override
    void configGet(string pattern) {
        configGet(SafeEncoder.encode(pattern));
    }
    alias configGet = BinaryClient.configGet;

    void eval(string script, int keyCount, string[] params...) {
        eval(SafeEncoder.encode(script), toByteArray(keyCount), SafeEncoder.encodeMany(params));
    }
    alias eval = BinaryClient.eval;

    void evalsha(string sha1, int keyCount, string[] params...) {
        evalsha(SafeEncoder.encode(sha1), toByteArray(keyCount), SafeEncoder.encodeMany(params));
    }
    alias evalsha = BinaryClient.evalsha;

    void scriptExists(string[] sha1...) {
        scriptExists(SafeEncoder.encodeMany(sha1));
    }
    alias scriptExists = BinaryClient.scriptExists;

    void scriptLoad(string script) {
        scriptLoad(SafeEncoder.encode(script));
    }
    alias scriptLoad = BinaryClient.scriptLoad;

    override
    void objectRefcount(string key) {
        objectRefcount(SafeEncoder.encode(key));
    }
    alias objectRefcount = BinaryClient.objectRefcount;

    override
    void objectIdletime(string key) {
        objectIdletime(SafeEncoder.encode(key));
    }
    alias objectIdletime = BinaryClient.objectIdletime;

    override
    void objectEncoding(string key) {
        objectEncoding(SafeEncoder.encode(key));
    }
    alias objectEncoding = BinaryClient.objectEncoding;

    override
    void bitcount(string key) {
        bitcount(SafeEncoder.encode(key));
    }
    alias bitcount = BinaryClient.bitcount;

    override
    void bitcount(string key, long start, long end) {
        bitcount(SafeEncoder.encode(key), start, end);
    }
    alias bitcount = BinaryClient.bitcount;

    override
    void bitop(BitOP op, string destKey, string[] srcKeys...) {
        bitop(op, SafeEncoder.encode(destKey), SafeEncoder.encodeMany(srcKeys));
    }
    alias bitop = BinaryClient.bitop;

    void sentinel(string[] args...) {
        sentinel(SafeEncoder.encodeMany(args));
    }
    alias sentinel = BinaryClient.sentinel;

    override
    void dump(string key) {
        dump(SafeEncoder.encode(key));
    }
    alias dump = BinaryClient.dump;

    // override
    void restore(string key, int ttl, const(ubyte)[] serializedValue) {
        restore(SafeEncoder.encode(key), ttl, serializedValue);
    }
    alias restore = BinaryClient.restore;

    // override
    void restoreReplace(string key, int ttl, const(ubyte)[] serializedValue) {
        restoreReplace(SafeEncoder.encode(key), ttl, serializedValue);
    }
    alias restoreReplace = BinaryClient.restoreReplace;

    void pexpire(string key, long milliseconds) {
        pexpire(SafeEncoder.encode(key), milliseconds);
    }
    alias pexpire = BinaryClient.pexpire;

    void pexpireAt(string key, long millisecondsTimestamp) {
        pexpireAt(SafeEncoder.encode(key), millisecondsTimestamp);
    }
    alias pexpireAt = BinaryClient.pexpireAt;

    override
    void pttl(string key) {
        pttl(SafeEncoder.encode(key));
    }
    alias pttl = BinaryClient.pttl;

    override
    void incrByFloat(string key, double increment) {
        incrByFloat(SafeEncoder.encode(key), increment);
    }
    alias incrByFloat = BinaryClient.incrByFloat;

    void psetex(string key, long milliseconds, string value) {
        psetex(SafeEncoder.encode(key), milliseconds, SafeEncoder.encode(value));
    }
    alias psetex = BinaryClient.psetex;

    void srandmember(string key, int count) {
        srandmember(SafeEncoder.encode(key), count);
    }
    alias srandmember = BinaryClient.srandmember;

    void clientKill(string ipPort) {
        clientKill(SafeEncoder.encode(ipPort));
    }
    alias clientKill = BinaryClient.clientKill;

    void clientSetname(string name) {
        clientSetname(SafeEncoder.encode(name));
    }
    alias clientSetname = BinaryClient.clientSetname;

    override
    void migrate(string host, int port, string key,
            int destinationDb, int timeout) {
        migrate(host, port, SafeEncoder.encode(key), destinationDb, timeout);
    }
    alias migrate = BinaryClient.migrate;

    override
    void migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, string[] keys...) {
        migrate(host, port, destinationDB, timeout, params, SafeEncoder.encodeMany(keys));
    }

    override
    void hincrByFloat(string key, string field, double increment) {
        hincrByFloat(SafeEncoder.encode(key), SafeEncoder.encode(field), increment);
    }
    alias hincrByFloat = BinaryClient.hincrByFloat;

    override
    void scan(string cursor, ScanParams params) {
        scan(SafeEncoder.encode(cursor), params);
    }
    alias scan = BinaryClient.scan;

    override
    void hscan(string key, string cursor, ScanParams params) {
        hscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
    }
    alias hscan = BinaryClient.hscan;

    override
    void sscan(string key, string cursor, ScanParams params) {
        sscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
    }
    alias sscan = BinaryClient.sscan;

    override
    void zscan(string key, string cursor, ScanParams params) {
        zscan(SafeEncoder.encode(key), SafeEncoder.encode(cursor), params);
    }
    alias zscan = BinaryClient.zscan;

    void cluster(string subcommand, int[] args...) {
        const(ubyte)[][] arg = new const(ubyte)[][args.length + 1];
        for (int i = 1; i < arg.length; i++) {
            arg[i] = toByteArray(args[i - 1]);
        }
        arg[0] = SafeEncoder.encode(subcommand);
        cluster(arg);
    }

    void pubsub(string subcommand, string[] args...) {
        const(ubyte)[][] arg = new const(ubyte)[][args.length + 1];
        for (int i = 1; i < arg.length; i++) {
            arg[i] = SafeEncoder.encode(args[i - 1]);
        }
        arg[0] = SafeEncoder.encode(subcommand);
        pubsub(arg);
    }
        alias pubsub = BinaryClient.pubsub;

    void cluster(string subcommand, string[] args...) {
        const(ubyte)[][] arg = new const(ubyte)[][args.length + 1];
        for (size_t i = 1; i < arg.length; i++) {
            arg[i] = SafeEncoder.encode(args[i - 1]);
        }
        arg[0] = SafeEncoder.encode(subcommand);
        cluster(arg);
    }
        alias cluster = BinaryClient.cluster;

    void cluster(string subcommand) {
        const(ubyte)[][] arg = new const(ubyte)[][1];
        arg[0] = SafeEncoder.encode(subcommand);
        cluster(arg);
    }

    void clusterNodes() {
        cluster(Protocol.CLUSTER_NODES);
    }

    void clusterMeet(string ip, int port) {
        cluster(Protocol.CLUSTER_MEET, ip, to!string(port));
    }

    void clusterReset(ClusterReset resetType) {
        cluster(Protocol.CLUSTER_RESET, resetType.to!string());
    }

    void clusterAddSlots(int[] slots...) {
        cluster(Protocol.CLUSTER_ADDSLOTS, slots);
    }

    void clusterDelSlots(int[] slots...) {
        cluster(Protocol.CLUSTER_DELSLOTS, slots);
    }

    void clusterInfo() {
        cluster(Protocol.CLUSTER_INFO);
    }

    void clusterGetKeysInSlot(int slot, int count) {
        int[] args = [slot, count];
        cluster(Protocol.CLUSTER_GETKEYSINSLOT, args);
    }

    void clusterSetSlotNode(int slot, string nodeId) {
        cluster(Protocol.CLUSTER_SETSLOT, to!string(slot), Protocol.CLUSTER_SETSLOT_NODE, nodeId);
    }

    void clusterSetSlotMigrating(int slot, string nodeId) {
        cluster(Protocol.CLUSTER_SETSLOT, to!string(slot), Protocol.CLUSTER_SETSLOT_MIGRATING,
            nodeId);
    }

    void clusterSetSlotImporting(int slot, string nodeId) {
        cluster(Protocol.CLUSTER_SETSLOT, to!string(slot), Protocol.CLUSTER_SETSLOT_IMPORTING,
            nodeId);
    }

    void pfadd(string key, string[] elements...) {
        pfadd(SafeEncoder.encode(key), SafeEncoder.encodeMany(elements));
    }
    alias pfadd = BinaryClient.pfadd;

    void pfcount(string key) {
        pfcount(SafeEncoder.encode(key));
    }
    alias pfcount = BinaryClient.pfcount;

    void pfcount(string[] keys...) {
        pfcount(SafeEncoder.encodeMany(keys));
    }

    void pfmerge(string[] keys...) {
        pfcount(SafeEncoder.encodeMany(keys));
    }
    alias pfmerge = BinaryClient.pfmerge;

    void pfmerge(string destkey, string[] sourcekeys...) {
        pfmerge(SafeEncoder.encode(destkey), SafeEncoder.encodeMany(sourcekeys));
    }

    void clusterSetSlotStable(int slot) {
        cluster(Protocol.CLUSTER_SETSLOT, to!string(slot), Protocol.CLUSTER_SETSLOT_STABLE);
    }

    void clusterForget(string nodeId) {
        cluster(Protocol.CLUSTER_FORGET, nodeId);
    }

    void clusterFlushSlots() {
        cluster(Protocol.CLUSTER_FLUSHSLOT);
    }

    void clusterKeySlot(string key) {
        cluster(Protocol.CLUSTER_KEYSLOT, key);
    }

    void clusterCountKeysInSlot(int slot) {
        cluster(Protocol.CLUSTER_COUNTKEYINSLOT, to!string(slot));
    }

    void clusterSaveConfig() {
        cluster(Protocol.CLUSTER_SAVECONFIG);
    }

    void clusterReplicate(string nodeId) {
        cluster(Protocol.CLUSTER_REPLICATE, nodeId);
    }

    void clusterSlaves(string nodeId) {
        cluster(Protocol.CLUSTER_SLAVES, nodeId);
    }

    void clusterFailover() {
        cluster(Protocol.CLUSTER_FAILOVER);
    }

    void clusterSlots() {
        cluster(Protocol.CLUSTER_SLOTS);
    }

    void geoadd(string key, double longitude, double latitude, string member) {
        geoadd(SafeEncoder.encode(key), longitude, latitude, SafeEncoder.encode(member));
    }
    alias geoadd = BinaryClient.geoadd;

    void geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
        geoadd(SafeEncoder.encode(key), convertMemberCoordinateMapToBinary(memberCoordinateMap));
    }

    void geodist(string key, string member1, string member2) {
        geodist(SafeEncoder.encode(key), SafeEncoder.encode(member1), SafeEncoder.encode(member2));
    }
    alias geodist = BinaryClient.geodist;

    void geodist(string key, string member1, string member2, GeoUnit unit) {
        geodist(SafeEncoder.encode(key), SafeEncoder.encode(member1), SafeEncoder.encode(member2), unit);
    }

    void geohash(string key, string[] members...) {
        geohash(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
    }
    alias geohash = BinaryClient.geohash;

    void geopos(string key, string[] members) {
        geopos(SafeEncoder.encode(key), SafeEncoder.encodeMany(members));
    }
    alias geopos = BinaryClient.geopos;

    void georadius(string key, double longitude, double latitude, double radius, GeoUnit unit) {
        georadius(SafeEncoder.encode(key), longitude, latitude, radius, unit);
    }
    alias georadius = BinaryClient.georadius;

    void georadiusReadonly(string key, double longitude, double latitude, double radius, GeoUnit unit) {
        georadiusReadonly(SafeEncoder.encode(key), longitude, latitude, radius, unit);
    }
    alias georadiusReadonly = BinaryClient.georadiusReadonly;

    void georadius(string key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        georadius(SafeEncoder.encode(key), longitude, latitude, radius, unit, param);
    }

    void georadiusReadonly(string key, double longitude, double latitude, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        georadiusReadonly(SafeEncoder.encode(key), longitude, latitude, radius, unit, param);
    }

    void georadiusByMember(string key, string member, double radius, GeoUnit unit) {
        georadiusByMember(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit);
    }
    alias georadiusByMember = BinaryClient.georadiusByMember;

    void georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit) {
        georadiusByMemberReadonly(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit);
    }
    alias georadiusByMemberReadonly = BinaryClient.georadiusByMemberReadonly;

    void georadiusByMember(string key, string member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        georadiusByMember(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit, param);
    }
    alias georadiusByMember = BinaryClient.georadiusByMember;

    void georadiusByMemberReadonly(string key, string member, double radius, GeoUnit unit,
            GeoRadiusParam param) {
        georadiusByMemberReadonly(SafeEncoder.encode(key), SafeEncoder.encode(member), radius, unit, param);
    }
    alias georadiusByMemberReadonly = BinaryClient.georadiusByMemberReadonly;

    void moduleLoad(string path) {
        moduleLoad(SafeEncoder.encode(path));
    }
    alias moduleLoad = BinaryClient.moduleLoad;

    void moduleUnload(string name) {
        moduleUnload(SafeEncoder.encode(name));
    }
    alias moduleUnload = BinaryClient.moduleUnload;

    private HashMap!(const(ubyte)[], double) convertScoreMembersToBinary(Map!(string, double) scoreMembers) {
        HashMap!(const(ubyte)[], double) binaryScoreMembers = new HashMap!(const(ubyte)[], double)();
        foreach(string key, double value; scoreMembers) {
            binaryScoreMembers.put(SafeEncoder.encode(key), value);
        }
        return binaryScoreMembers;
    }

    private HashMap!(const(ubyte)[], GeoCoordinate) convertMemberCoordinateMapToBinary(
            Map!(string, GeoCoordinate) memberCoordinateMap) {
        HashMap!(const(ubyte)[], GeoCoordinate) binaryMemberCoordinateMap = new HashMap!(const(ubyte)[], GeoCoordinate)();
        foreach(string key, GeoCoordinate value; memberCoordinateMap) {
            binaryMemberCoordinateMap.put(SafeEncoder.encode(key), value);
        }
        return binaryMemberCoordinateMap;
    }

    override
    void bitfield(string key, string[] arguments...) {
        bitfield(SafeEncoder.encode(key), SafeEncoder.encodeMany(arguments));
    }
    alias bitfield = BinaryClient.bitfield;

    override
    void hstrlen(string key, string field) {
        hstrlen(SafeEncoder.encode(key), SafeEncoder.encode(field));
    }
    alias hstrlen = BinaryClient.hstrlen;

    override
    void xadd(string key,  StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength) {
        Map!(const(ubyte)[], const(ubyte)[]) bhash = new HashMap!(const(ubyte)[], const(ubyte)[])(hash.size());
        foreach(string k, string v; hash) {
            bhash.put(SafeEncoder.encode(k), SafeEncoder.encode(v));
        }
        xadd(SafeEncoder.encode(key), SafeEncoder.encode(id is null ? "*" : id.toString()), bhash, maxLen, approximateLength);
    }
    alias xadd = BinaryClient.xadd;
    
    override
    void xlen(string key) {
            xlen(SafeEncoder.encode(key));
    }
    alias xlen = BinaryClient.xlen;
    
    override
    void xrange(string key, StreamEntryID start,  StreamEntryID end, long count) {
            xrange(SafeEncoder.encode(key), SafeEncoder.encode(start is null ? "-" : start.toString()), 
            SafeEncoder.encode(end is null ? "+" : end.toString()), count);
    }
    alias xrange = BinaryClient.xrange;
    
    override
    void xrevrange(string key, StreamEntryID end, StreamEntryID start, int count) {
        xrevrange(SafeEncoder.encode(key), SafeEncoder.encode(end is null ? "+" : end.toString()), 
            SafeEncoder.encode(start is null ? "-" : start.toString()), count);
    }
    alias xrevrange = BinaryClient.xrevrange;
    
    override
    void xread(int count, long block, MapEntry!(string, StreamEntryID)[] streams...) {
        Map!(const(ubyte)[], const(ubyte)[]) bhash = new HashMap!(const(ubyte)[], const(ubyte)[])(cast(int)streams.length);
        foreach(MapEntry!(string, StreamEntryID) entry ; streams) {
            bhash.put(SafeEncoder.encode(entry.getKey()), 
            SafeEncoder.encode(entry.getValue() is null ? "0-0" : entry.getValue().toString()));
        }
        xread(count, block, bhash);
    }
    alias xread = BinaryClient.xread;
    
    override
    void xack(string key, string group, StreamEntryID[] ids...) {
        const(ubyte)[][] bids = new const(ubyte)[][ids.length];
        for (int i=0 ; i< ids.length; ++i ) {
            StreamEntryID id = ids[i];
            bids[i] = SafeEncoder.encode(id is null ? "0-0" : id.toString()); 
        }
        xack(SafeEncoder.encode(key), SafeEncoder.encode(group), bids);
    }
    alias xack = BinaryClient.xack;
    
    override
    void xgroupCreate(string key, string groupname, StreamEntryID id, bool makeStream) {
        xgroupCreate(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(id is null ? "0-0" : id.toString()), makeStream);
    }
    alias xgroupCreate = BinaryClient.xgroupCreate;

    override
    void xgroupSetID(string key, string groupname, StreamEntryID id) {
        xgroupSetID(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(id is null ? "0-0" : id.toString()));    
    }
    alias xgroupSetID = BinaryClient.xgroupSetID;

    override
    void xgroupDestroy(string key, string groupname) {
        xgroupDestroy(SafeEncoder.encode(key), SafeEncoder.encode(groupname));    
    }
    alias xgroupDestroy = BinaryClient.xgroupDestroy;

    override
    void xgroupDelConsumer(string key, string groupname, string consumerName) {
        xgroupDelConsumer(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(consumerName));    
    }
    alias xgroupDelConsumer = BinaryClient.xgroupDelConsumer;

    override
    void xdel(string key, StreamEntryID[] ids...) {
        const(ubyte)[][] bids = new const(ubyte)[][ids.length];
        for (int i=0 ; i< ids.length; ++i ) {
            StreamEntryID id = ids[i];
            bids[i] = SafeEncoder.encode(id is null ? "0-0" : id.toString()); 
        }
        xdel(SafeEncoder.encode(key), bids);    
    }
    alias xdel = BinaryClient.xdel;

    override
    void xtrim(string key, long maxLen, bool approximateLength) {
        xtrim(SafeEncoder.encode(key), maxLen, approximateLength);    
    }
    alias xtrim = BinaryClient.xtrim;

    override
    void xreadGroup(string groupname, string consumer, int count, long block, 
                                    bool noAck, MapEntry!(string, StreamEntryID)[] streams...) {
        Map!(const(ubyte)[], const(ubyte)[]) bhash = new HashMap!(const(ubyte)[], const(ubyte)[])(cast(int)streams.length);
        foreach(MapEntry!(string, StreamEntryID) entry ; streams) {
            bhash.put(SafeEncoder.encode(entry.getKey()), SafeEncoder.encode(entry.getValue() is null ? ">" : entry.getValue().toString()));
        }
        xreadGroup(SafeEncoder.encode(groupname), SafeEncoder.encode(consumer), count, block, noAck, bhash);    
    }
    alias xreadGroup = BinaryClient.xreadGroup;

    override
    void xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername) {
        xpending(SafeEncoder.encode(key), SafeEncoder.encode(groupname), SafeEncoder.encode(start is null ? "-" : start.toString()),
                SafeEncoder.encode(end is null ? "+" : end.toString()), count, consumername is null? null : SafeEncoder.encode(consumername));    
    }
    alias xpending = BinaryClient.xpending;

    override
    void xclaim(string key, string group, string consumername, long minIdleTime, long newIdleTime, int retries,
            bool force, StreamEntryID[] ids...) {
        
        const(ubyte)[][] bids = new const(ubyte)[][ids.length];
        for (int i = 0; i < ids.length; i++) {
            bids[i] = SafeEncoder.encode(ids[i].toString());
        }
        xclaim(SafeEncoder.encode(key), SafeEncoder.encode(group), SafeEncoder.encode(consumername), 
            minIdleTime, newIdleTime, retries, force, bids);    
    }
    alias xclaim = BinaryClient.xclaim;

    override void bgrewriteaof() { super.bgrewriteaof(); }

    override void bgsave() { super.bgsave(); }

    override void lastsave() { super.lastsave(); }

    override void save() { super.save(); }

    override void configResetStat() { super.configResetStat(); }

    override void multi() { super.multi(); }

    override void exec() { super.exec(); }

    override void discard() { super.discard(); }


    override void waitReplicas(int replicas, long timeout) { super.waitReplicas(replicas, timeout); }

    override void clientKill(string ip, int port) { super.clientKill(ip, port); }

    override void clientKill(ClientKillParams params) { super.clientKill(params); }

    override void clientGetname() { super.clientGetname(); }
    
    override void clientList() { super.discard(); }

    override void memoryDoctor() { super.discard(); }

}
