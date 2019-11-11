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
 
module hunt.redis.BinaryShardedRedis;

import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Redis;
import hunt.redis.RedisShardInfo;
import hunt.redis.ShardedRedisPipeline;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.Tuple;


import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.commands.BinaryRedisCommands;
import hunt.redis.Protocol;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.Hashing;
import hunt.redis.util.Sharded;

import hunt.Double;
// import hunt.long;

import std.conv;
import std.regex;
alias Pattern = Regex!char;

/**
 * 
 */
class BinaryShardedRedis : Sharded!(Redis, RedisShardInfo), BinaryRedisCommands {
    this(List!(RedisShardInfo) shards) {
        super(shards);
    }

    this(List!(RedisShardInfo) shards, Hashing algo) {
        super(shards, algo);
    }

    this(List!(RedisShardInfo) shards, Pattern keyTagPattern) {
        super(shards, keyTagPattern);
    }

    this(List!(RedisShardInfo) shards, Hashing algo, Pattern keyTagPattern) {
        super(shards, algo, keyTagPattern);
    }

    void disconnect() {
        foreach(Redis jedis ; getAllShards()) {
            if (jedis.isConnected()) {
                try {
                    jedis.quit();
                } catch (RedisConnectionException e) {
                    // ignore the exception node, so that all other normal nodes can release all connections.
                }
                try {
                    jedis.disconnect();
                } catch (RedisConnectionException e) {
                    // ignore the exception node, so that all other normal nodes can release all connections.
                }
            }
        }
    }

    protected Redis create(RedisShardInfo shard) {
        return new Redis(shard);
    }

    override
    string set(const(ubyte)[] key, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.set(key, value);
    }

    override
    string set(const(ubyte)[] key, const(ubyte)[] value, SetParams params) {
        Redis j = getShard(key);
        return j.set(key, value, params);
    }

    override
    const(ubyte)[] get(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.get(key);
    }

    override
    bool exists(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.exists(key);
    }

    override
    string type(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.type(key);
    }

    override
    const(ubyte)[] dump(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.dump(key);
    }

    override
    string restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        Redis j = getShard(key);
        return j.restore(key, ttl, serializedValue);
    }

    override
    string restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        Redis j = getShard(key);
        return j.restoreReplace(key, ttl, serializedValue);
    }

    override
    long expire(const(ubyte)[] key, int seconds) {
        Redis j = getShard(key);
        return j.expire(key, seconds);
    }

    override
    long pexpire(const(ubyte)[] key, long milliseconds) {
        Redis j = getShard(key);
        return j.pexpire(key, milliseconds);
    }

    override
    long expireAt(const(ubyte)[] key, long unixTime) {
        Redis j = getShard(key);
        return j.expireAt(key, unixTime);
    }

    override
    long pexpireAt(const(ubyte)[] key, long millisecondsTimestamp) {
        Redis j = getShard(key);
        return j.pexpireAt(key, millisecondsTimestamp);
    }

    override
    long ttl(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.ttl(key);
    }

    override
    long pttl(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.pttl(key);
    }

    override
    long touch(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.touch(key);
    }

    override
    const(ubyte)[] getSet(const(ubyte)[] key, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.getSet(key, value);
    }

    override
    long setnx(const(ubyte)[] key, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.setnx(key, value);
    }

    override
    string setex(const(ubyte)[] key, int seconds, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.setex(key, seconds, value);
    }

    override
    string psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.psetex(key, milliseconds, value);
    }

    override
    long decrBy(const(ubyte)[] key, long decrement) {
        Redis j = getShard(key);
        return j.decrBy(key, decrement);
    }

    override
    long decr(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.decr(key);
    }

    override
    long del(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.del(key);
    }

    override
    long unlink(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.unlink(key);
    }

    override
    long incrBy(const(ubyte)[] key, long increment) {
        Redis j = getShard(key);
        return j.incrBy(key, increment);
    }

    override
    Double incrByFloat(const(ubyte)[] key, double increment) {
        Redis j = getShard(key);
        return j.incrByFloat(key, increment);
    }

//     override
//     long incr(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.incr(key);
//     }

//     override
//     long append(const(ubyte)[] key, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.append(key, value);
//     }

//     override
//     const(ubyte)[] substr(const(ubyte)[] key, int start, int end) {
//         Redis j = getShard(key);
//         return j.substr(key, start, end);
//     }

//     override
//     long hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.hset(key, field, value);
//     }

//     override
//     long hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
//         Redis j = getShard(key);
//         return j.hset(key, hash);
//     }

//     override
//     const(ubyte)[] hget(const(ubyte)[] key, const(ubyte)[] field) {
//         Redis j = getShard(key);
//         return j.hget(key, field);
//     }

//     override
//     long hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.hsetnx(key, field, value);
//     }

//     override
//     string hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
//         Redis j = getShard(key);
//         return j.hmset(key, hash);
//     }

//     override
//     List!(const(ubyte)[]) hmget(const(ubyte)[] key, const(ubyte)[][] fields...) {
//         Redis j = getShard(key);
//         return j.hmget(key, fields);
//     }

//     override
//     long hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value) {
//         Redis j = getShard(key);
//         return j.hincrBy(key, field, value);
//     }

//     override
//     Double hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double value) {
//         Redis j = getShard(key);
//         return j.hincrByFloat(key, field, value);
//     }

//     override
//     bool hexists(const(ubyte)[] key, const(ubyte)[] field) {
//         Redis j = getShard(key);
//         return j.hexists(key, field);
//     }

//     override
//     long hdel(const(ubyte)[] key, const(ubyte)[][] fields...) {
//         Redis j = getShard(key);
//         return j.hdel(key, fields);
//     }

//     override
//     long hlen(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.hlen(key);
//     }

//     override
//     Set!(const(ubyte)[]) hkeys(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.hkeys(key);
//     }

//     override
//     Collection!(const(ubyte)[]) hvals(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.hvals(key);
//     }

//     override
//     Map!(const(ubyte)[], const(ubyte)[]) hgetAll(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.hgetAll(key);
//     }

//     override
//     long rpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
//         Redis j = getShard(key);
//         return j.rpush(key, strings);
//     }

//     override
//     long lpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
//         Redis j = getShard(key);
//         return j.lpush(key, strings);
//     }

    override
    long strlen(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.strlen(key);
    }

//     override
//     long lpushx(const(ubyte)[] key, const(ubyte)[][] string...) {
//         Redis j = getShard(key);
//         return j.lpushx(key, string);
//     }

    override
    long persist(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.persist(key);
    }

//     override
//     long rpushx(const(ubyte)[] key, const(ubyte)[][] string...) {
//         Redis j = getShard(key);
//         return j.rpushx(key, string);
//     }

//     override
//     long llen(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.llen(key);
//     }

//     override
//     List!(const(ubyte)[]) lrange(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.lrange(key, start, stop);
//     }

//     override
//     string ltrim(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.ltrim(key, start, stop);
//     }

//     override
//     const(ubyte)[] lindex(const(ubyte)[] key, long index) {
//         Redis j = getShard(key);
//         return j.lindex(key, index);
//     }

//     override
//     string lset(const(ubyte)[] key, long index, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.lset(key, index, value);
//     }

//     override
//     long lrem(const(ubyte)[] key, long count, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.lrem(key, count, value);
//     }

//     override
//     const(ubyte)[] lpop(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.lpop(key);
//     }

//     override
//     const(ubyte)[] rpop(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.rpop(key);
//     }

//     override
//     long sadd(const(ubyte)[] key, const(ubyte)[][] members...) {
//         Redis j = getShard(key);
//         return j.sadd(key, members);
//     }

//     override
//     Set!(const(ubyte)[]) smembers(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.smembers(key);
//     }

//     override
//     long srem(const(ubyte)[] key, const(ubyte)[][] members...) {
//         Redis j = getShard(key);
//         return j.srem(key, members);
//     }

//     override
//     const(ubyte)[] spop(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.spop(key);
//     }

//     override
//     Set!(const(ubyte)[]) spop(const(ubyte)[] key, long count) {
//         Redis j = getShard(key);
//         return j.spop(key, count);
//     }

//     override
//     long scard(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.scard(key);
//     }

//     override
//     bool sismember(const(ubyte)[] key, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.sismember(key, member);
//     }

//     override
//     const(ubyte)[] srandmember(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.srandmember(key);
//     }

//     override
//     List!(const(ubyte)[]) srandmember(const(ubyte)[] key, int count) {
//         Redis j = getShard(key);
//         return j.srandmember(key, count);
//     }

//     override
//     long zadd(const(ubyte)[] key, double score, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.zadd(key, score, member);
//     }

//     override
//     long zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params) {
//         Redis j = getShard(key);
//         return j.zadd(key, score, member, params);
//     }

//     override
//     long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers) {
//         Redis j = getShard(key);
//         return j.zadd(key, scoreMembers);
//     }

//     override
//     long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers, ZAddParams params) {
//         Redis j = getShard(key);
//         return j.zadd(key, scoreMembers, params);
//     }

//     override
//     Set!(const(ubyte)[]) zrange(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.zrange(key, start, stop);
//     }

//     override
//     long zrem(const(ubyte)[] key, const(ubyte)[][] members...) {
//         Redis j = getShard(key);
//         return j.zrem(key, members);
//     }

//     override
//     Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.zincrby(key, increment, member);
//     }

//     override
//     Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params) {
//         Redis j = getShard(key);
//         return j.zincrby(key, increment, member, params);
//     }

//     override
//     long zrank(const(ubyte)[] key, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.zrank(key, member);
//     }

//     override
//     long zrevrank(const(ubyte)[] key, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.zrevrank(key, member);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrange(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.zrevrange(key, start, stop);
//     }

//     override
//     Set!(Tuple) zrangeWithScores(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.zrangeWithScores(key, start, stop);
//     }

//     override
//     Set!(Tuple) zrevrangeWithScores(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.zrevrangeWithScores(key, start, stop);
//     }

//     override
//     long zcard(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.zcard(key);
//     }

//     override
//     Double zscore(const(ubyte)[] key, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.zscore(key, member);
//     }

//     override
//     List!(const(ubyte)[]) sort(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.sort(key);
//     }

//     override
//     List!(const(ubyte)[]) sort(const(ubyte)[] key, SortingParams sortingParameters) {
//         Redis j = getShard(key);
//         return j.sort(key, sortingParameters);
//     }

//     override
//     long zcount(const(ubyte)[] key, double min, double max) {
//         Redis j = getShard(key);
//         return j.zcount(key, min, max);
//     }

//     override
//     long zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zcount(key, min, max);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max) {
//         Redis j = getShard(key);
//         return j.zrangeByScore(key, min, max);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max, int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrangeByScore(key, min, max, offset, count);
//     }

//     override
//     Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max) {
//         Redis j = getShard(key);
//         return j.zrangeByScoreWithScores(key, min, max);
//     }

//     override
//     Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max, int offset,
//             int count) {
//         Redis j = getShard(key);
//         return j.zrangeByScoreWithScores(key, min, max, offset, count);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zrangeByScore(key, min, max);
//     }

//     override
//     Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zrangeByScoreWithScores(key, min, max);
//     }

//     override
//     Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
//             int count) {
//         Redis j = getShard(key);
//         return j.zrangeByScoreWithScores(key, min, max, offset, count);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrangeByScore(key, min, max, offset, count);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScore(key, max, min);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min, int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScore(key, max, min, offset, count);
//     }

//     override
//     Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScoreWithScores(key, max, min);
//     }

//     override
//     Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min, int offset,
//             int count) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScore(key, max, min);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScore(key, max, min, offset, count);
//     }

//     override
//     Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScoreWithScores(key, max, min);
//     }

//     override
//     Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset,
//             int count) {
//         Redis j = getShard(key);
//         return j.zrevrangeByScoreWithScores(key, max, min, offset, count);
//     }

//     override
//     long zremrangeByRank(const(ubyte)[] key, long start, long stop) {
//         Redis j = getShard(key);
//         return j.zremrangeByRank(key, start, stop);
//     }

//     override
//     long zremrangeByScore(const(ubyte)[] key, double min, double max) {
//         Redis j = getShard(key);
//         return j.zremrangeByScore(key, min, max);
//     }

//     override
//     long zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zremrangeByScore(key, min, max);
//     }

//     override
//     long zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zlexcount(key, min, max);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zrangeByLex(key, min, max);
//     }

//     override
//     Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
//             int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrangeByLex(key, min, max, offset, count);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
//         Redis j = getShard(key);
//         return j.zrevrangeByLex(key, max, min);
//     }

//     override
//     Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count) {
//         Redis j = getShard(key);
//         return j.zrevrangeByLex(key, max, min, offset, count);
//     }

//     override
//     long zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
//         Redis j = getShard(key);
//         return j.zremrangeByLex(key, min, max);
//     }

//     override
//     long linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot, const(ubyte)[] value) {
//         Redis j = getShard(key);
//         return j.linsert(key, where, pivot, value);
//     }

//     ShardedRedisPipeline pipelined() {
//         ShardedRedisPipeline pipeline = new ShardedRedisPipeline();
//         pipeline.setShardedRedis(this);
//         return pipeline;
//     }

//     long objectRefcount(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.objectRefcount(key);
//     }

//     const(ubyte)[] objectEncoding(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.objectEncoding(key);
//     }

//     long objectIdletime(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.objectIdletime(key);
//     }

    override
    bool setbit(const(ubyte)[] key, long offset, bool value) {
        Redis j = getShard(key);
        return j.setbit(key, offset, value);
    }

    override
    bool setbit(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.setbit(key, offset, value);
    }

    override
    bool getbit(const(ubyte)[] key, long offset) {
        Redis j = getShard(key);
        return j.getbit(key, offset);
    }

    override
    long setrange(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        Redis j = getShard(key);
        return j.setrange(key, offset, value);
    }

    override
    const(ubyte)[] getrange(const(ubyte)[] key, long startOffset, long endOffset) {
        Redis j = getShard(key);
        return j.getrange(key, startOffset, endOffset);
    }

    override
    long move(const(ubyte)[] key, int dbIndex) {
        Redis j = getShard(key);
        return j.move(key, dbIndex);
    }

    override
    const(ubyte)[] echo(const(ubyte)[] arg) {
        Redis j = getShard(arg);
        return j.echo(arg);
    }

//     List!(const(ubyte)[]) brpop(const(ubyte)[] arg) {
//         Redis j = getShard(arg);
//         return j.brpop(arg);
//     }

//     List!(const(ubyte)[]) blpop(const(ubyte)[] arg) {
//         Redis j = getShard(arg);
//         return j.blpop(arg);
//     }

    override
    long bitcount(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.bitcount(key);
    }

    override
    long bitcount(const(ubyte)[] key, long start, long end) {
        Redis j = getShard(key);
        return j.bitcount(key, start, end);
    }

    override
    long pfadd(const(ubyte)[] key, const(ubyte)[][] elements...) {
        Redis j = getShard(key);
        return j.pfadd(key, elements);
    }

    override
    long pfcount(const(ubyte)[] key) {
        Redis j = getShard(key);
        return j.pfcount(key);
    }

//     override
//     long geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member) {
//         Redis j = getShard(key);
//         return j.geoadd(key, longitude, latitude, member);
//     }

//     override
//     long geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
//         Redis j = getShard(key);
//         return j.geoadd(key, memberCoordinateMap);
//     }

//     override
//     Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2) {
//         Redis j = getShard(key);
//         return j.geodist(key, member1, member2);
//     }

//     override
//     Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit) {
//         Redis j = getShard(key);
//         return j.geodist(key, member1, member2, unit);
//     }

//     override
//     List!(const(ubyte)[]) geohash(const(ubyte)[] key, const(ubyte)[][] members...) {
//         Redis j = getShard(key);
//         return j.geohash(key, members);
//     }

//     override
//     List!(GeoCoordinate) geopos(const(ubyte)[] key, const(ubyte)[][] members...) {
//         Redis j = getShard(key);
//         return j.geopos(key, members);
//     }

//     override
//     List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude,
//             double radius, GeoUnit unit) {
//         Redis j = getShard(key);
//         return j.georadius(key, longitude, latitude, radius, unit);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
//             double radius, GeoUnit unit) {
//         Redis j = getShard(key);
//         return j.georadiusReadonly(key, longitude, latitude, radius, unit);
//     }

//     override
//     List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude,
//             double radius, GeoUnit unit, GeoRadiusParam param) {
//         Redis j = getShard(key);
//         return j.georadius(key, longitude, latitude, radius, unit, param);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
//             double radius, GeoUnit unit, GeoRadiusParam param) {
//         Redis j = getShard(key);
//         return j.georadiusReadonly(key, longitude, latitude, radius, unit, param);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
//             GeoUnit unit) {
//         Redis j = getShard(key);
//         return j.georadiusByMember(key, member, radius, unit);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
//             GeoUnit unit) {
//         Redis j = getShard(key);
//         return j.georadiusByMemberReadonly(key, member, radius, unit);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
//             GeoUnit unit, GeoRadiusParam param) {
//         Redis j = getShard(key);
//         return j.georadiusByMember(key, member, radius, unit, param);
//     }

//     override
//     List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
//             GeoUnit unit, GeoRadiusParam param) {
//         Redis j = getShard(key);
//         return j.georadiusByMemberReadonly(key, member, radius, unit, param);
//     }

//     override
//     ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor) {
//         Redis j = getShard(key);
//         return j.hscan(key, cursor);
//     }

//     override
//     ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
//         Redis j = getShard(key);
//         return j.hscan(key, cursor, params);
//     }

//     override
//     ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor) {
//         Redis j = getShard(key);
//         return j.sscan(key, cursor);
//     }

//     override
//     ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
//         Redis j = getShard(key);
//         return j.sscan(key, cursor, params);
//     }

//     override
//     ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor) {
//         Redis j = getShard(key);
//         return j.zscan(key, cursor);
//     }

//     override
//     ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
//         Redis j = getShard(key);
//         return j.zscan(key, cursor, params);
//     }

//     override
//     List!(long) bitfield(const(ubyte)[] key, const(ubyte)[][] arguments...) {
//         Redis j = getShard(key);
//         return j.bitfield(key, arguments);
//  }

//     override
//     long hstrlen(const(ubyte)[] key, const(ubyte)[] field) {
//         Redis j = getShard(key);
//         return j.hstrlen(key, field);
//     }

//     override
//     const(ubyte)[] xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength) {
//         Redis j = getShard(key);
//         return j.xadd(key, id, hash, maxLen, approximateLength);
//     }

//     override
//     long xlen(const(ubyte)[] key) {
//         Redis j = getShard(key);
//         return j.xlen(key);
//     }

//     override
//     List!(const(ubyte)[]) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count) {
//         Redis j = getShard(key);
//         return j.xrange(key, start, end, count);
//     }

//     override
//     List!(const(ubyte)[]) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count) {
//         Redis j = getShard(key);
//         return j.xrevrange(key, end, start, count);
//     }

//     override
//     long xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...) {
//         Redis j = getShard(key);
//         return j.xack(key, group, ids);
//     }

//     override
//     string xgroupCreate(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id, bool makeStream) {
//         Redis j = getShard(key);
//         return j.xgroupCreate(key, consumer, id, makeStream);
//     }

//     override
//     string xgroupSetID(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id) {
//         Redis j = getShard(key);
//         return j.xgroupSetID(key, consumer, id);
//     }

//     override
//     long xgroupDestroy(const(ubyte)[] key, const(ubyte)[] consumer) {
//         Redis j = getShard(key);
//         return j.xgroupDestroy(key, consumer);
//     }

//     override
//     string xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] consumerName) {
//         Redis j = getShard(key);
//         return j.xgroupDelConsumer(key, consumer, consumerName);
//     }

//     override
//     long xdel(const(ubyte)[] key, const(ubyte)[][] ids...) {
//         Redis j = getShard(key);
//         return j.xdel(key, ids);
//     }

//     override
//     long xtrim(const(ubyte)[] key, long maxLen, bool approximateLength) {
//         Redis j = getShard(key);
//         return j.xtrim(key, maxLen, approximateLength);
//     }

//     override
//     List!(const(ubyte)[]) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername) {
//         Redis j = getShard(key);
//         return j.xpending(key, groupname, start, end, count, consumername);
//     }

//     override
//     List!(const(ubyte)[]) xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, long minIdleTime, long newIdleTime,
//             int retries, bool force, const(ubyte)[][] ids) {
//         Redis j = getShard(key);
//         return j.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
//     }

//     override
//     Object sendCommand(ProtocolCommand cmd, const(ubyte)[][] args...) {
//         // default since no sample key provided in RedisCommands interface
//         const(ubyte)[] sampleKey = args.length > 0 ? args[0] : cast(const(ubyte)[])(cmd.to!string());
//         Redis j = getShard(args[0]);
//         return j.sendCommand(cmd, args);
//     }

}
