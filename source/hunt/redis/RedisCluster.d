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
 
module hunt.redis.RedisCluster;


import hunt.redis.BinaryRedisCluster;
import hunt.redis.Redis;
import hunt.redis.RedisClusterCommand;
import hunt.redis.HostAndPort;
import hunt.redis.Protocol;
import hunt.redis.RedisClusterConnectionHandler;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.commands.RedisClusterCommands;
import hunt.redis.commands.RedisClusterScriptingCommands;
import hunt.redis.commands.MultiKeyRedisClusterCommands;
import hunt.redis.util.RedisClusterHashTagUtil;
import hunt.redis.util.KeyMergeUtil;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.pool.impl.GenericObjectPoolConfig;


private template ClusterStringCommandTemplate(string name, R, string[] args) {
    import std.format;

    enum string statementBlock = q{
        scope RedisClusterCommand!(%2$s) command = 
                new class(connectionHandler, maxAttempts) RedisClusterCommand!(%2$s) {

            this(RedisClusterConnectionHandler connectionHandler, int maxAttempts) {
                super(connectionHandler, maxAttempts);
            }

            override %2$s execute(Redis connection) {
                return connection.%1$s(%3$-(%s, %));
            }
        };

        return command.run(%4$s);
    }.format(name, R.stringof, args, args[0]);

    // pragma(msg, statementBlock);
    alias ClusterStringCommandTemplate = statementBlock;
}

/**
 * 
 */
class RedisCluster : BinaryRedisCluster, RedisClusterCommands,
         MultiKeyRedisClusterCommands, RedisClusterScriptingCommands {

    this(HostAndPort node) {
        this(Collections.singleton(node));
    }

    this(HostAndPort node, int timeout) {
        this(Collections.singleton(node), timeout);
    }

    this(HostAndPort node, int timeout, int maxAttempts) {
        this(Collections.singleton(node), timeout, maxAttempts);
    }

    this(HostAndPort node, GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), poolConfig);
    }

    this(HostAndPort node, int timeout, GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), timeout, poolConfig);
    }

    this(HostAndPort node, int timeout, int maxAttempts,
            GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), timeout, maxAttempts, poolConfig);
    }

    this(HostAndPort node, int connectionTimeout, int soTimeout,
            int maxAttempts, GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), connectionTimeout, soTimeout, maxAttempts, poolConfig);
    }

    this(HostAndPort node, int connectionTimeout, int soTimeout,
            int maxAttempts, string password, GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), connectionTimeout, soTimeout, maxAttempts, password, poolConfig);
    }

    this(HostAndPort node, int connectionTimeout, int soTimeout,
            int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig) {
        this(Collections.singleton(node), connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig);
    }

    // this(HostAndPort node, int connectionTimeout, int soTimeout,
    //         int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
    //         bool ssl) {
    //     this(Collections.singleton(node), connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig, ssl);
    // }

    // this(HostAndPort node, int connectionTimeout, int soTimeout,
    //         int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
    //         bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //         HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
    //     this(Collections.singleton(node), connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig,
    //             ssl, sslSocketFactory, sslParameters, hostnameVerifier, hostAndPortMap);
    // }

    this(Set!(HostAndPort) nodes) {
        this(nodes, DEFAULT_TIMEOUT);
    }

    this(Set!(HostAndPort) nodes, int timeout) {
        this(nodes, timeout, DEFAULT_MAX_ATTEMPTS);
    }

    this(Set!(HostAndPort) nodes, int timeout, int maxAttempts) {
        this(nodes, timeout, maxAttempts, new GenericObjectPoolConfig());
    }

    this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig) {
        this(nodes, DEFAULT_TIMEOUT, DEFAULT_MAX_ATTEMPTS, poolConfig);
    }

    this(Set!(HostAndPort) nodes, int timeout, GenericObjectPoolConfig poolConfig) {
        this(nodes, timeout, DEFAULT_MAX_ATTEMPTS, poolConfig);
    }

    this(Set!(HostAndPort) redisClusterNode, int timeout, int maxAttempts,
            GenericObjectPoolConfig poolConfig) {
        super(redisClusterNode, timeout, maxAttempts, poolConfig);
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout,
            int maxAttempts, GenericObjectPoolConfig poolConfig) {
        super(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, poolConfig);
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout,
                                            int maxAttempts, string password, GenericObjectPoolConfig poolConfig) {
        super(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, poolConfig);
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout,
                    int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig) {
        super(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig);
    }

    // this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout,
    //         int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
    //         bool ssl) {
    //     super(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig, ssl);
    // }

    // this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout,
    //         int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
    //         bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //         HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
    //     super(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig,
    //             ssl, sslSocketFactory, sslParameters, hostnameVerifier, hostAndPortMap);
    // }

    override
    string set(string key, string value) {
        mixin(ClusterStringCommandTemplate!("set", string, [key.stringof, value.stringof]));
    }

    override
    string set(string key, string value, SetParams params) {
        mixin(ClusterStringCommandTemplate!("set", string, [key.stringof, value.stringof, params.stringof]));
    }

    override
    string get(string key) {
        mixin(ClusterStringCommandTemplate!("get", string, [key.stringof]));
    }

    override
    bool exists(string key) {
        mixin(ClusterStringCommandTemplate!("exists", bool, [key.stringof]));
    }

    override
    long exists(string[] keys...) {
        mixin(ClusterStringCommandTemplate!("exists", long, [keys.stringof]));
    }
    alias exists = BinaryRedisCluster.exists;

    override
    long persist(string key) {
        mixin(ClusterStringCommandTemplate!("persist", long, [key.stringof]));
    }

    override
    string type(string key) {
        mixin(ClusterStringCommandTemplate!("type", string, [key.stringof]));
    }

    // override
    // byte[] dump(string key) {
    //     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
    //         override
    //         byte[] execute(Redis connection) {
    //             return connection.dump(key);
    //         }
    //     }.run(key);
    // }

    // override
    // string restore(string key, int ttl, byte[] serializedValue) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.restore(key, ttl, serializedValue);
    //         }
    //     }.run(key);
    // }

    // override
    // Long expire(string key, int seconds) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.expire(key, seconds);
    //         }
    //     }.run(key);
    // }

    // override
    // Long pexpire(string key, long milliseconds) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pexpire(key, milliseconds);
    //         }
    //     }.run(key);
    // }

    // override
    // Long expireAt(string key, long unixTime) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.expireAt(key, unixTime);
    //         }
    //     }.run(key);
    // }

    // override
    // Long pexpireAt(string key, long millisecondsTimestamp) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pexpireAt(key, millisecondsTimestamp);
    //         }
    //     }.run(key);
    // }

    // override
    // Long ttl(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.ttl(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long pttl(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pttl(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long touch(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.touch(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long touch(string[] keys...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.touch(keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // Boolean setbit(string key, long offset, bool value) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.setbit(key, offset, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Boolean setbit(string key, long offset, string value) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.setbit(key, offset, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Boolean getbit(string key, long offset) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.getbit(key, offset);
    //         }
    //     }.run(key);
    // }

    // override
    // Long setrange(string key, long offset, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.setrange(key, offset, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string getrange(string key, long startOffset, long endOffset) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.getrange(key, startOffset, endOffset);
    //         }
    //     }.run(key);
    // }

    // override
    // string getSet(string key, string value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.getSet(key, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Long setnx(string key, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.setnx(key, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string setex(string key, int seconds, string value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.setex(key, seconds, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string psetex(string key, long milliseconds, string value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.psetex(key, milliseconds, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Long decrBy(string key, long decrement) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.decrBy(key, decrement);
    //         }
    //     }.run(key);
    // }

    // override
    // Long decr(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.decr(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long incrBy(string key, long increment) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.incrBy(key, increment);
    //         }
    //     }.run(key);
    // }

    // override
    // Double incrByFloat(string key, double increment) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.incrByFloat(key, increment);
    //         }
    //     }.run(key);
    // }

    // override
    // Long incr(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.incr(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long append(string key, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.append(key, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string substr(string key, int start, int end) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.substr(key, start, end);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hset(string key, string field, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hset(key, field, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hset(string key, Map!(string, string) hash) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hset(key, hash);
    //         }
    //     }.run(key);
    // }

    // override
    // string hget(string key, string field) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.hget(key, field);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hsetnx(string key, string field, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hsetnx(key, field, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string hmset(string key, Map!(string, string) hash) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.hmset(key, hash);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) hmget(string key, string[] fields...) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.hmget(key, fields);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hincrBy(string key, string field, long value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hincrBy(key, field, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Boolean hexists(string key, string field) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.hexists(key, field);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hdel(string key, string[] field...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hdel(key, field);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hlen(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hlen(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) hkeys(string key) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.hkeys(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) hvals(string key) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.hvals(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Map!(string, string) hgetAll(string key) {
    //     return new RedisClusterCommand!(Map!(string, string))(connectionHandler, maxAttempts) {
    //         override
    //         Map!(string, string) execute(Redis connection) {
    //             return connection.hgetAll(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long rpush(string key, string[] string...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.rpush(key, string);
    //         }
    //     }.run(key);
    // }

    // override
    // Long lpush(string key, string[] string...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.lpush(key, string);
    //         }
    //     }.run(key);
    // }

    // override
    // Long llen(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.llen(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) lrange(string key, long start, long stop) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.lrange(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // string ltrim(string key, long start, long stop) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.ltrim(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // string lindex(string key, long index) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.lindex(key, index);
    //         }
    //     }.run(key);
    // }

    // override
    // string lset(string key, long index, string value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.lset(key, index, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Long lrem(string key, long count, string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.lrem(key, count, value);
    //         }
    //     }.run(key);
    // }

    // override
    // string lpop(string key) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.lpop(key);
    //         }
    //     }.run(key);
    // }

    // override
    // string rpop(string key) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.rpop(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long sadd(string key, string[] member...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sadd(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) smembers(string key) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.smembers(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long srem(string key, string[] member...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.srem(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // string spop(string key) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.spop(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) spop(string key, long count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.spop(key, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Long scard(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.scard(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Boolean sismember(string key, string member) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.sismember(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // string srandmember(string key) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.srandmember(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) srandmember(string key, int count) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.srandmember(key, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Long strlen(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.strlen(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zadd(string key, double score, string member) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zadd(key, score, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zadd(string key, double score, string member,
    //         ZAddParams params) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zadd(key, score, member, params);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zadd(string key, Map!(string, double) scoreMembers) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zadd(key, scoreMembers);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zadd(string key, Map!(string, double) scoreMembers, ZAddParams params) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zadd(key, scoreMembers, params);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrange(string key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrange(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zrem(string key, string[] members...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zrem(key, members);
    //         }
    //     }.run(key);
    // }

    // override
    // Double zincrby(string key, double increment, string member) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.zincrby(key, increment, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Double zincrby(string key, double increment, string member,
    //         ZIncrByParams params) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.zincrby(key, increment, member, params);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zrank(string key, string member) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zrank(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zrevrank(string key, string member) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zrevrank(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrange(string key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrange(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrangeWithScores(string key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrangeWithScores(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrevrangeWithScores(string key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrevrangeWithScores(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zcard(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zcard(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Double zscore(string key, string member) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.zscore(key, member);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) sort(string key) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.sort(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) sort(string key, SortingParams sortingParameters) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.sort(key, sortingParameters);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zcount(string key, double min, double max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zcount(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zcount(string key, string min, string max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zcount(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByScore(string key, double min, double max) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByScore(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByScore(string key, string min, string max) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByScore(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByScore(string key, double max, double min) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByScore(key, max, min);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByScore(string key, double min, double max,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByScore(key, min, max, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByScore(string key, string max, string min) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByScore(key, max, min);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByScore(string key, string min, string max,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByScore(key, min, max, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByScore(string key, double max, double min,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByScore(key, max, min, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrangeByScoreWithScores(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrevrangeByScoreWithScores(key, max, min);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrangeByScoreWithScores(key, min, max, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByScore(string key, string max, string min,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByScore(key, max, min, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrangeByScoreWithScores(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrevrangeByScoreWithScores(key, max, min);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrangeByScoreWithScores(key, min, max, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(string key, double max,
    //         double min, int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(string key, string max,
    //         string min, int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(Tuple) execute(Redis connection) {
    //             return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zremrangeByRank(string key, long start, long stop) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zremrangeByRank(key, start, stop);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zremrangeByScore(string key, double min, double max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zremrangeByScore(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zremrangeByScore(string key, string min, string max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zremrangeByScore(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zlexcount(string key, string min, string max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zlexcount(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByLex(string key, string min, string max) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByLex(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrangeByLex(string key, string min, string max,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrangeByLex(key, min, max, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByLex(string key, string max, string min) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByLex(key, max, min);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) zrevrangeByLex(string key, string max, string min,
    //         int offset, int count) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.zrevrangeByLex(key, max, min, offset, count);
    //         }
    //     }.run(key);
    // }

    // override
    // Long zremrangeByLex(string key, string min, string max) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zremrangeByLex(key, min, max);
    //         }
    //     }.run(key);
    // }

    // override
    // Long linsert(string key, ListPosition where, string pivot,
    //         string value) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.linsert(key, where, pivot, value);
    //         }
    //     }.run(key);
    // }

    // override
    // Long lpushx(string key, string[] string...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.lpushx(key, string);
    //         }
    //     }.run(key);
    // }

    // override
    // Long rpushx(string key, string[] string...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.rpushx(key, string);
    //         }
    //     }.run(key);
    // }

    override
    long del(string key) {
        mixin(ClusterStringCommandTemplate!("del", long, [key.stringof]));
    }

    override
    long del(string[] keys...) {
        mixin(ClusterStringCommandTemplate!("del", long, [keys.stringof]));
    }
    alias del = BinaryRedisCluster.del;

    override
    long unlink(string key) {
        mixin(ClusterStringCommandTemplate!("unlink", long, [key.stringof]));
    }

    override
    long unlink(string[] keys...) {
        mixin(ClusterStringCommandTemplate!("unlink", long, [keys.stringof]));
    }
    alias unlink = BinaryRedisCluster.unlink;

    // override
    // string echo(string string) {
    //     // note that it'll be run from arbitrary node
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.echo(string);
    //         }
    //     }.run(string);
    // }

    // override
    // Long bitcount(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.bitcount(key);
    //         }
    //     }.run(key);
    // }

    // override
    // Long bitcount(string key, long start, long end) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.bitcount(key, start, end);
    //         }
    //     }.run(key);
    // }

    // override
    // Set!(string) keys(string pattern) {
    //     if (pattern is null || pattern.isEmpty()) {
    //         throw new IllegalArgumentException(this.getClass().getSimpleName()
    //                 ~ " only supports KEYS commands with non-empty patterns");
    //     }
    //     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(pattern)) {
    //         throw new IllegalArgumentException(this.getClass().getSimpleName()
    //                 ~ " only supports KEYS commands with patterns containing hash-tags ( curly-brackets enclosed strings )");
    //     }
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.keys(pattern);
    //         }
    //     }.run(pattern);
    // }

    // override
    // ScanResult!(string) scan(string cursor, ScanParams params) {

    //     string matchPattern = null;

    //     if (params is null || (matchPattern = params.match()) is null || matchPattern.isEmpty()) {
    //         throw new IllegalArgumentException(RedisCluster.class.getSimpleName()
    //                 ~ " only supports SCAN commands with non-empty MATCH patterns");
    //     }

    //     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(matchPattern)) {
    //         throw new IllegalArgumentException(RedisCluster.class.getSimpleName()
    //                 ~ " only supports SCAN commands with MATCH patterns containing hash-tags ( curly-brackets enclosed strings )");
    //     }

    //     return new RedisClusterCommand!( ScanResult!(string))(connectionHandler, maxAttempts) {
    //         override
    //         ScanResult!(string) execute(Redis connection) {
    //             return connection.scan(cursor, params);
    //         }
    //     }.run(matchPattern);
    // }

    // override
    // ScanResult!(Entry!(string, string)) hscan(string key, string cursor) {
    //     return new RedisClusterCommand!(ScanResult!(Entry!(string, string)))(connectionHandler,
    //                                                                                                                                         maxAttempts) {
    //         override
    //         ScanResult!(Entry!(string, string)) execute(Redis connection) {
    //             return connection.hscan(key, cursor);
    //         }
    //     }.run(key);
    // }

    // override
    // ScanResult!(string) sscan(string key, string cursor) {
    //     return new RedisClusterCommand!(ScanResult!(string))(connectionHandler, maxAttempts) {
    //         override
    //         ScanResult!(string) execute(Redis connection) {
    //             return connection.sscan(key, cursor);
    //         }
    //     }.run(key);
    // }

    // override
    // ScanResult!(Tuple) zscan(string key, string cursor) {
    //     return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
    //         override
    //         ScanResult!(Tuple) execute(Redis connection) {
    //             return connection.zscan(key, cursor);
    //         }
    //     }.run(key);
    // }

    // override
    // Long pfadd(string key, string[] elements...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pfadd(key, elements);
    //         }
    //     }.run(key);
    // }

    // override
    // long pfcount(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pfcount(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) blpop(int timeout, string key) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.blpop(timeout, key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) brpop(int timeout, string key) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.brpop(timeout, key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) blpop(int timeout, string[] keys...) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.blpop(timeout, keys);
    //         }
    //     }.run(keys.length, keys);

    // }

    // override
    // List!(string) brpop(int timeout, string[] keys...) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.brpop(timeout, keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    override
    List!(string) mget(string[] keys...) {
        mixin(ClusterStringCommandTemplate!("mget", List!(string), [keys.stringof]));
        // return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
        //     override
        //     List!(string) execute(Redis connection) {
        //         return connection.mget(keys);
        //     }
        // }.run(keys.length, keys);
    }

    override
    string mset(string[] keysvalues...) {
        string[] keys = new string[keysvalues.length / 2];

        for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
            
            keys[keyIdx] = keysvalues[keyIdx * 2];
        }
        
        mixin(ClusterStringCommandTemplate!("mset", string, [keys.stringof]));

        // return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
        //     override
        //     string execute(Redis connection) {
        //         return connection.mset(keysvalues);
        //     }
        // }.run(keys.length, keys);
    }

    // override
    // Long msetnx(string[] keysvalues...) {
    //     string[] keys = new string[keysvalues.length / 2];

    //     for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
    //         keys[keyIdx] = keysvalues[keyIdx * 2];
    //     }

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.msetnx(keysvalues);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // string rename(string oldkey, string newkey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.rename(oldkey, newkey);
    //         }
    //     }.run(2, oldkey, newkey);
    // }

    // override
    // Long renamenx(string oldkey, string newkey) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.renamenx(oldkey, newkey);
    //         }
    //     }.run(2, oldkey, newkey);
    // }

    // override
    // string rpoplpush(string srckey, string dstkey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.rpoplpush(srckey, dstkey);
    //         }
    //     }.run(2, srckey, dstkey);
    // }

    // override
    // Set!(string) sdiff(string[] keys...) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.sdiff(keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // Long sdiffstore(string dstkey, string[] keys...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sdiffstore(dstkey, keys);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // Set!(string) sinter(string[] keys...) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.sinter(keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // Long sinterstore(string dstkey, string[] keys...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sinterstore(dstkey, keys);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // Long smove(string srckey, string dstkey, string member) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.smove(srckey, dstkey, member);
    //         }
    //     }.run(2, srckey, dstkey);
    // }

    // override
    // Long sort(string key, SortingParams sortingParameters, string dstkey) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sort(key, sortingParameters, dstkey);
    //         }
    //     }.run(2, key, dstkey);
    // }

    // override
    // Long sort(string key, string dstkey) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sort(key, dstkey);
    //         }
    //     }.run(2, key, dstkey);
    // }

    // override
    // Set!(string) sunion(string[] keys...) {
    //     return new RedisClusterCommand!(Set!(string))(connectionHandler, maxAttempts) {
    //         override
    //         Set!(string) execute(Redis connection) {
    //             return connection.sunion(keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // Long sunionstore(string dstkey, string[] keys...) {
    //     string[] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.sunionstore(dstkey, keys);
    //         }
    //     }.run(wholeKeys.length, wholeKeys);
    // }

    // override
    // Long zinterstore(string dstkey, string[] sets...) {
    //     string[] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zinterstore(dstkey, sets);
    //         }
    //     }.run(wholeKeys.length, wholeKeys);
    // }

    // override
    // Long zinterstore(string dstkey, ZParams params, string[] sets...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zinterstore(dstkey, params, sets);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // Long zunionstore(string dstkey, string[] sets...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zunionstore(dstkey, sets);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // Long zunionstore(string dstkey, ZParams params, string[] sets...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.zunionstore(dstkey, params, sets);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // string brpoplpush(string source, string destination, int timeout) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.brpoplpush(source, destination, timeout);
    //         }
    //     }.run(2, source, destination);
    // }

    // override
    // Long publish(string channel, string message) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.publish(channel, message);
    //         }
    //     }.runWithAnyNode();
    // }

    // override
    // void subscribe(RedisPubSub redisPubSub, string[] channels...) {
    //     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
    //         override
    //         Integer execute(Redis connection) {
    //             connection.subscribe(redisPubSub, channels);
    //             return 0;
    //         }
    //     }.runWithAnyNode();
    // }

    // override
    // void psubscribe(RedisPubSub redisPubSub, string[] patterns...) {
    //     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
    //         override
    //         Integer execute(Redis connection) {
    //             connection.psubscribe(redisPubSub, patterns);
    //             return 0;
    //         }
    //     }.runWithAnyNode();
    // }

    // override
    // Long bitop(BitOP op, string destKey, string[] srcKeys...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(destKey, srcKeys);

    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.bitop(op, destKey, srcKeys);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // string pfmerge(string destkey, string[] sourcekeys...) {
    //     string[] mergedKeys = KeyMergeUtil.merge(destkey, sourcekeys);

    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.pfmerge(destkey, sourcekeys);
    //         }
    //     }.run(mergedKeys.length, mergedKeys);
    // }

    // override
    // long pfcount(string[] keys...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.pfcount(keys);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // Object eval(string script, int keyCount, string[] params...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.eval(script, keyCount, params);
    //         }
    //     }.run(keyCount, params);
    // }

    // override
    // Object eval(string script, string sampleKey) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.eval(script);
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // Object eval(string script, List!(string) keys, List!(string) args) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.eval(script, keys, args);
    //         }
    //     }.run(keys.size(), keys.toArray(new string[keys.size()]));
    // }

    // override
    // Object evalsha(string sha1, int keyCount, string[] params...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.evalsha(sha1, keyCount, params);
    //         }
    //     }.run(keyCount, params);
    // }

    // override
    // Object evalsha(string sha1, List!(string) keys, List!(string) args) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.evalsha(sha1, keys, args);
    //         }
    //     }.run(keys.size(), keys.toArray(new string[keys.size()]));
    // }

    // override
    // Object evalsha(string sha1, string sampleKey) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection) {
    //             return connection.evalsha(sha1);
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // Boolean scriptExists(string sha1, string sampleKey) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //         override
    //         Boolean execute(Redis connection) {
    //             return connection.scriptExists(sha1);
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // List!(Boolean) scriptExists(string sampleKey, string[] sha1...) {
    //     return new RedisClusterCommand!(List!(Boolean))(connectionHandler, maxAttempts) {
    //         override
    //         List!(Boolean) execute(Redis connection) {
    //             return connection.scriptExists(sha1);
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // string scriptLoad(string script, string sampleKey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.scriptLoad(script);
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // string scriptFlush(string sampleKey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.scriptFlush();
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // string scriptKill(string sampleKey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.scriptKill();
    //         }
    //     }.run(sampleKey);
    // }

    // override
    // Long geoadd(string key, double longitude, double latitude,
    //         string member) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.geoadd(key, longitude, latitude, member);
    //         }
    //     }.run(key);
    // }

    // override
    // Long geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.geoadd(key, memberCoordinateMap);
    //         }
    //     }.run(key);
    // }

    // override
    // Double geodist(string key, string member1, string member2) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.geodist(key, member1, member2);
    //         }
    //     }.run(key);
    // }

    // override
    // Double geodist(string key, string member1, string member2,
    //         GeoUnit unit) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //         override
    //         Double execute(Redis connection) {
    //             return connection.geodist(key, member1, member2, unit);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(string) geohash(string key, string[] members...) {
    //     return new RedisClusterCommand!(List!(string))(connectionHandler, maxAttempts) {
    //         override
    //         List!(string) execute(Redis connection) {
    //             return connection.geohash(key, members);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoCoordinate) geopos(string key, string[] members...) {
    //     return new RedisClusterCommand!(List!(GeoCoordinate))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoCoordinate) execute(Redis connection) {
    //             return connection.geopos(key, members);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadius(string key, double longitude,
    //         double latitude, double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadius(key, longitude, latitude, radius, unit);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude,
    //         double latitude, double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusReadonly(key, longitude, latitude, radius, unit);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadius(string key, double longitude,
    //         double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadius(key, longitude, latitude, radius, unit, param);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude,
    //         double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusReadonly(key, longitude, latitude, radius, unit, param);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMember(string key, string member,
    //         double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusByMember(key, member, radius, unit);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member,
    //         double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusByMemberReadonly(key, member, radius, unit);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMember(string key, string member,
    //         double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusByMember(key, member, radius, unit, param);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member,
    //         double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //         override
    //         List!(GeoRadiusResponse) execute(Redis connection) {
    //             return connection.georadiusByMemberReadonly(key, member, radius, unit, param);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(Long) bitfield(string key, string[] arguments...) {
    //     return new RedisClusterCommand!(List!(Long))(connectionHandler, maxAttempts) {
    //         override
    //         List!(Long) execute(Redis connection) {
    //             return connection.bitfield(key, arguments);
    //         }
    //     }.run(key);
    // }

    // override
    // Long hstrlen(string key, string field) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.hstrlen(key, field);
    //         }
    //     }.run(key);
    // }

    // override
    // StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash) {
    //     return new RedisClusterCommand!(StreamEntryID)(connectionHandler, maxAttempts) {
    //         override
    //         StreamEntryID execute(Redis connection) {
    //             return connection.xadd(key, id, hash);
    //         }
    //     }.run(key);
    // }

    // override
    // StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength) {
    //     return new RedisClusterCommand!(StreamEntryID)(connectionHandler, maxAttempts) {
    //         override
    //         StreamEntryID execute(Redis connection) {
    //             return connection.xadd(key, id, hash, maxLen, approximateLength);
    //         }
    //     }.run(key);
    // }

    // override
    // Long xlen(string key) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.xlen(key);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(StreamEntry) xrange(string key, StreamEntryID start, StreamEntryID end, int count) {
    //     return new RedisClusterCommand!(List!(StreamEntry))(connectionHandler, maxAttempts) {
    //         override
    //         List!(StreamEntry) execute(Redis connection) {
    //             return connection.xrange(key, start, end, count);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(StreamEntry) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count) {
    //     return new RedisClusterCommand!(List!(StreamEntry))(connectionHandler, maxAttempts) {
    //         override
    //         List!(StreamEntry) execute(Redis connection) {
    //             return connection.xrevrange(key, end, start, count);
    //         }
    //     }.run(key);  
    // }

    // override
    // List!(Entry!(string, List!(StreamEntry))) xread(int count, long block, Entry!(string, StreamEntryID) streams...) {
    //     string[] keys = new string[streams.length];
    //     for(int i=0; i<streams.length; ++i) {
    //         keys[i] = streams[i].getKey();
    //     }
        
    //     return new RedisClusterCommand!(List!(Entry!(string, List!(StreamEntry))))(connectionHandler, maxAttempts) {
    //         override
    //         List!(Entry!(string, List!(StreamEntry))) execute(Redis connection) {
    //             return connection.xread(count, block, streams);
    //         }
    //     }.run(keys.length, keys);  
    // }

    // override
    // Long xack(string key, string group, StreamEntryID[] ids...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.xack(key, group, ids);
    //         }
    //     }.run(key);   
    // }

    // override
    // string xgroupCreate(string key, string groupname, StreamEntryID id, bool makeStream) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.xgroupCreate(key, groupname, id, makeStream);
    //         }
    //     }.run(key);  
    // }

    // override
    // string xgroupSetID(string key, string groupname, StreamEntryID id) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.xgroupSetID(key, groupname, id);
    //         }
    //     }.run(key);
    // }

    // override
    // Long xgroupDestroy(string key, string groupname) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.xgroupDestroy(key, groupname);
    //         }
    //     }.run(key);
    // }

    // override
    // string xgroupDelConsumer(string key, string groupname, string consumername) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //         override
    //         string execute(Redis connection) {
    //             return connection.xgroupDelConsumer(key, groupname, consumername);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(Entry!(string, List!(StreamEntry))) xreadGroup(string groupname, string consumer, int count, long block,
    //         bool noAck, Entry!(string, StreamEntryID) streams...) {
        
    //     string[] keys = new string[streams.length];
    //     for(int i=0; i<streams.length; ++i) {
    //         keys[i] = streams[i].getKey();
    //     }
        
    //     return new RedisClusterCommand!(List!(Entry!(string, List!(StreamEntry))))(connectionHandler, maxAttempts) {
    //         override
    //         List!(Entry!(string, List!(StreamEntry))) execute(Redis connection) {
    //             return connection.xreadGroup(groupname, consumer, count, block, noAck, streams);
    //         }
    //     }.run(keys.length, keys);
    // }

    // override
    // List!(StreamPendingEntry) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count,
    //         string consumername) {
    //     return new RedisClusterCommand!(List!(StreamPendingEntry))(connectionHandler, maxAttempts) {
    //         override
    //         List!(StreamPendingEntry) execute(Redis connection) {
    //             return connection.xpending(key, groupname, start, end, count, consumername);
    //         }
    //     }.run(key);
    // }

    // override
    // Long xdel(string key, StreamEntryID[] ids...) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.xdel(key, ids);
    //         }
    //     }.run(key);
    // }

    // override
    // Long xtrim( string key, long maxLen, bool approximateLength) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.xtrim(key, maxLen, approximateLength);
    //         }
    //     }.run(key);
    // }

    // override
    // List!(StreamEntry) xclaim(string key, string group, string consumername, long minIdleTime, long newIdleTime,
    //         int retries, bool force, StreamEntryID[] ids...) {
    //     return new RedisClusterCommand!(List!(StreamEntry))(connectionHandler, maxAttempts) {
    //         override
    //         List!(StreamEntry) execute(Redis connection) {
    //             return connection.xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
    //         }
    //     }.run(key);
    // }

    // Long waitReplicas(string key, int replicas, long timeout) {
    //     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
    //         override
    //         Long execute(Redis connection) {
    //             return connection.waitReplicas(replicas, timeout);
    //         }
    //     }.run(key);
    // }

    // override
    // Object sendCommand(string sampleKey, ProtocolCommand cmd, string[] args...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //         override
    //         Object execute(Redis connection){
    //             return connection.sendCommand(cmd, args);
    //         }
    //     }.run(sampleKey);
    // }


}
