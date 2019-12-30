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
 
module hunt.redis.BinaryRedisCluster;

import hunt.redis.RedisSlotBasedConnectionHandler;
import hunt.redis.commands.BinaryRedisClusterCommands;
import hunt.redis.commands.RedisClusterBinaryScriptingCommands;
import hunt.redis.commands.MultiKeyBinaryRedisClusterCommands;
import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisClusterCommand;
import hunt.redis.RedisPool;
import hunt.redis.Protocol;
import hunt.redis.RedisClusterConnectionHandler;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.RedisClusterHashTagUtil;
import hunt.redis.util.KeyMergeUtil;
import hunt.redis.util.SafeEncoder;

import hunt.util.Common;
import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.Long;

private template ClusterBinaryCommandTemplate(string name, R, string[] args) {
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

        return command.runBinary(%4$s);
    }.format(name, R.stringof, args, args[0]);

    // pragma(msg, statementBlock);
    alias ClusterBinaryCommandTemplate = statementBlock;
}


/**
 * 
 */
class BinaryRedisCluster : BinaryRedisClusterCommands, MultiKeyBinaryRedisClusterCommands, 
        RedisClusterBinaryScriptingCommands, Closeable {

    enum int HASHSLOTS = 16384;
    protected enum int DEFAULT_TIMEOUT = 2000;
    protected enum int DEFAULT_MAX_ATTEMPTS = 5;

    protected int maxAttempts;

    protected RedisClusterConnectionHandler connectionHandler;

    this(Set!(HostAndPort) nodes, int timeout) {
        this(nodes, timeout, DEFAULT_MAX_ATTEMPTS, new GenericObjectPoolConfig());
    }

    this(Set!(HostAndPort) nodes) {
        this(nodes, DEFAULT_TIMEOUT);
    }

    this(Set!(HostAndPort) redisClusterNode, int timeout, int maxAttempts,
        GenericObjectPoolConfig poolConfig) {
        this.connectionHandler = new RedisSlotBasedConnectionHandler(redisClusterNode, poolConfig,
            timeout);
        this.maxAttempts = maxAttempts;
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout,
                                int soTimeout, int maxAttempts, GenericObjectPoolConfig poolConfig) {
        this.connectionHandler = new RedisSlotBasedConnectionHandler(redisClusterNode, poolConfig,
            connectionTimeout, soTimeout);
        this.maxAttempts = maxAttempts;
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, 
            string password, GenericObjectPoolConfig poolConfig) {
        this.connectionHandler = new RedisSlotBasedConnectionHandler(redisClusterNode, poolConfig,
                connectionTimeout, soTimeout, password);
        this.maxAttempts = maxAttempts;
    }

    this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, 
            string password, string clientName, GenericObjectPoolConfig poolConfig) {
        this.connectionHandler = new RedisSlotBasedConnectionHandler(redisClusterNode, poolConfig,
                connectionTimeout, soTimeout, password, clientName);
        this.maxAttempts = maxAttempts;
    }

    // this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, 
    //         string password, string clientName, GenericObjectPoolConfig poolConfig, bool ssl) {
    //     this(redisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig, ssl, null, null, null, null);
    // }

    // this(Set!(HostAndPort) redisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, 
    //         string password, string clientName, GenericObjectPoolConfig poolConfig,
    //         bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, 
    //         HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
    //     this.connectionHandler = new RedisSlotBasedConnectionHandler(redisClusterNode, poolConfig,
    //         connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, 
    //         sslParameters, hostnameVerifier, hostAndPortMap);
    //     this.maxAttempts = maxAttempts;
    // }

    override
    void close() {
        if (connectionHandler !is null) {
        connectionHandler.close();
        }
    }

    Map!(string, RedisPool) getClusterNodes() {
        return connectionHandler.getNodes();
    }

    Redis getConnectionFromSlot(int slot) {
        return  this.connectionHandler.getConnectionFromSlot(slot);
    }

    override
    string set(const(ubyte)[] key, const(ubyte)[] value) {
        mixin(ClusterBinaryCommandTemplate!("set", string, [key.stringof, value.stringof]));
    }

    override
    string set(const(ubyte)[] key, const(ubyte)[] value, SetParams params) {
        mixin(ClusterBinaryCommandTemplate!("set", string, [key.stringof, value.stringof, params.stringof]));
    }

    override
    const(ubyte)[] get(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("get", const(ubyte)[], [key.stringof]));
    }

    override
    Long exists(const(ubyte)[][] keys...) {
        mixin(ClusterBinaryCommandTemplate!("exists", Long, [keys.stringof]));
    }

    override
    bool exists(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("exists", bool, [key.stringof]));
    }

    override
    Long persist(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("persist", Long, [key.stringof]));
    }

    override
    string type(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("type", string, [key.stringof]));
    }

    override
    const(ubyte)[] dump(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    }

    // override
    // string restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
    //     // return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     // override
    //     // string execute(Redis connection) {
    //     //     return connection.restore(key, ttl, serializedValue);
    //     // }
    //     // }.runBinary(key);

    //     mixin(ClusterBinaryCommandTemplate!("restore", string, 
    //         [key.stringof, ttl.stringof, serializedValue.stringof]));
    // }

    // override
    // long expire(const(ubyte)[] key, int seconds) {
    //     // return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     // override
    //     // long execute(Redis connection) {
    //     //     return connection.expire(key, seconds);
    //     // }
    //     // }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("expire", Long, [key.stringof]));
    // }

    // override
    // long pexpire(const(ubyte)[] key, long milliseconds) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pexpire(key, milliseconds);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long expireAt(const(ubyte)[] key, long unixTime) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.expireAt(key, unixTime);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long pexpireAt(const(ubyte)[] key, long millisecondsTimestamp) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pexpireAt(key, millisecondsTimestamp);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long ttl(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.ttl(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long pttl(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pttl(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long touch(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.touch(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long touch(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.touch(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [keys.stringof]));
    // }

    // override
    // Boolean setbit(const(ubyte)[] key, long offset, bool value) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //     override
    //     Boolean execute(Redis connection) {
    //         return connection.setbit(key, offset, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Boolean setbit(const(ubyte)[] key, long offset, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //     override
    //     Boolean execute(Redis connection) {
    //         return connection.setbit(key, offset, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Boolean getbit(const(ubyte)[] key, long offset) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //     override
    //     Boolean execute(Redis connection) {
    //         return connection.getbit(key, offset);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long setrange(const(ubyte)[] key, long offset, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.setrange(key, offset, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] getrange(const(ubyte)[] key, long startOffset, long endOffset) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.getrange(key, startOffset, endOffset);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] getSet(const(ubyte)[] key, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.getSet(key, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long setnx(const(ubyte)[] key, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.setnx(key, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // string psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.psetex(key, milliseconds, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // string setex(const(ubyte)[] key, int seconds, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.setex(key, seconds, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long decrBy(const(ubyte)[] key, long decrement) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.decrBy(key, decrement);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long decr(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.decr(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long incrBy(const(ubyte)[] key, long increment) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.incrBy(key, increment);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Double incrByFloat(const(ubyte)[] key, double increment) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.incrByFloat(key, increment);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long incr(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.incr(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long append(const(ubyte)[] key, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.append(key, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] substr(const(ubyte)[] key, int start, int end) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.substr(key, start, end);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hset(key, field, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hset(key, hash);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] hget(const(ubyte)[] key, const(ubyte)[] field) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.hget(key, field);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hsetnx(key, field, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // string hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.hmset(key, hash);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // List!(const(ubyte)[]) hmget(const(ubyte)[] key, const(ubyte)[][] fields...) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.hmget(key, fields);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hincrBy(key, field, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Double hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double value) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.hincrByFloat(key, field, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Boolean hexists(const(ubyte)[] key, const(ubyte)[] field) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //     override
    //     Boolean execute(Redis connection) {
    //         return connection.hexists(key, field);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hdel(const(ubyte)[] key, const(ubyte)[][] field...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hdel(key, field);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long hlen(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hlen(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) hkeys(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.hkeys(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Collection!(const(ubyte)[]) hvals(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(Collection!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Collection!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.hvals(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Map!(const(ubyte)[], const(ubyte)[]) hgetAll(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(Map!(const(ubyte)[], const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Map!(const(ubyte)[], const(ubyte)[]) execute(Redis connection) {
    //         return connection.hgetAll(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long rpush(const(ubyte)[] key, const(ubyte)[][] args...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.rpush(key, args);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long lpush(const(ubyte)[] key, const(ubyte)[][] args...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.lpush(key, args);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long llen(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.llen(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // List!(const(ubyte)[]) lrange(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.lrange(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // string ltrim(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.ltrim(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] lindex(const(ubyte)[] key, long index) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.lindex(key, index);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // string lset(const(ubyte)[] key, long index, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.lset(key, index, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long lrem(const(ubyte)[] key, long count, const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.lrem(key, count, value);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] lpop(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.lpop(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] rpop(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.rpop(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long sadd(const(ubyte)[] key, const(ubyte)[][] member...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sadd(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) smembers(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.smembers(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long srem(const(ubyte)[] key, const(ubyte)[][] member...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.srem(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] spop(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.spop(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) spop(const(ubyte)[] key, long count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.spop(key, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long scard(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.scard(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Boolean sismember(const(ubyte)[] key, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
    //     override
    //     Boolean execute(Redis connection) {
    //         return connection.sismember(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // const(ubyte)[] srandmember(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.srandmember(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long strlen(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.strlen(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zadd(const(ubyte)[] key, double score, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zadd(key, score, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zadd(const(ubyte)[] key, double score, const(ubyte)[] member,
    //     ZAddParams params) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zadd(key, score, member, params);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zadd(key, scoreMembers);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zadd(const(ubyte)[] key, Map!(const(ubyte)[], Double) scoreMembers, ZAddParams params) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zadd(key, scoreMembers, params);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrange(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrange(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zrem(const(ubyte)[] key, const(ubyte)[][] members...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zrem(key, members);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.zincrby(key, increment, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member,
    //     ZIncrByParams params) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.zincrby(key, increment, member, params);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zrank(const(ubyte)[] key, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zrank(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zrevrank(const(ubyte)[] key, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zrevrank(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrevrange(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrange(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrangeWithScores(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrangeWithScores(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrevrangeWithScores(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrevrangeWithScores(key, start, stop);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zcard(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zcard(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Double zscore(const(ubyte)[] key, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.zscore(key, member);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // List!(const(ubyte)[]) sort(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sort(key);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // List!(const(ubyte)[]) sort(const(ubyte)[] key, SortingParams sortingParameters) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sort(key, sortingParameters);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zcount(const(ubyte)[] key, double min, double max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zcount(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // long zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zcount(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByScore(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByScore(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByScore(key, max, min);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByScore(key, min, max, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByScore(key, max, min);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByScore(key, min, max, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByScore(key, max, min, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrangeByScoreWithScores(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrevrangeByScoreWithScores(key, max, min);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrangeByScoreWithScores(key, min, max, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByScore(key, max, min, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrangeByScoreWithScores(key, min, max);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrevrangeByScoreWithScores(key, max, min);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrangeByScoreWithScores(key, min, max, offset, count);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max,
    //     double min, int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max,
    //     const(ubyte)[] min, int offset, int count) {
    //     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(Tuple) execute(Redis connection) {
    //         return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long zremrangeByRank(const(ubyte)[] key, long start, long stop) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zremrangeByRank(key, start, stop);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long zremrangeByScore(const(ubyte)[] key, double min, double max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zremrangeByScore(key, min, max);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zremrangeByScore(key, min, max);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot,
    //     const(ubyte)[] value) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.linsert(key, where, pivot, value);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long lpushx(const(ubyte)[] key, const(ubyte)[][] arg...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.lpushx(key, arg);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long rpushx(const(ubyte)[] key, const(ubyte)[][] arg...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.rpushx(key, arg);
    //     }
    //     }.runBinary(key);
    // }

    override
    Long del(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("del", Long, [key.stringof]));
    }

    override
    Long del(const(ubyte)[][] keys...) {
        mixin(ClusterBinaryCommandTemplate!("del", Long, [keys.stringof]));
        // return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
        // override
        // long execute(Redis connection) {
        //     return connection.del(keys);
        // }
        // }.runBinary(keys.length, keys);
    }

    override
    Long unlink(const(ubyte)[] key) {
        mixin(ClusterBinaryCommandTemplate!("unlink", Long, [key.stringof]));
    }

    override
    Long unlink(const(ubyte)[][] keys...) {
        mixin(ClusterBinaryCommandTemplate!("unlink", Long, [keys.stringof]));
    }

    // override
    // const(ubyte)[] echo(const(ubyte)[] arg) {
    //     // note that it'll be run from arbitary node
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.echo(arg);
    //     }
    //     }.runBinary(arg);
    // }

    // override
    // long bitcount(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.bitcount(key);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long bitcount(const(ubyte)[] key, long start, long end) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.bitcount(key, start, end);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long pfadd(const(ubyte)[] key, const(ubyte)[][] elements...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pfadd(key, elements);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long pfcount(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pfcount(key);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(const(ubyte)[]) srandmember(const(ubyte)[] key, int count) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.srandmember(key, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zlexcount(key, min, max);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByLex(key, min, max);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrangeByLex(key, min, max, offset, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByLex(key, max, min);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
    //     int offset, int count) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.zrevrangeByLex(key, max, min, offset, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zremrangeByLex(key, min, max);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Object eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.eval(script, keyCount, params);
    //     }
    //     }.runBinary(to!int(SafeEncoder.encode(keyCount)), params);
    // }

    // override
    // Object eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.eval(script, keyCount, params);
    //     }
    //     }.runBinary(keyCount, params);
    // }

    // override
    // Object eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.eval(script, keys, args);
    //     }
    //     }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
    // }

    // override
    // Object eval(const(ubyte)[] script, const(ubyte)[] sampleKey) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.eval(script);
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // Object evalsha(const(ubyte)[] sha1, const(ubyte)[] sampleKey) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.evalsha(sha1);
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // Object evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.evalsha(sha1, keys, args);
    //     }
    //     }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
    // }

    // override
    // Object evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection) {
    //         return connection.evalsha(sha1, keyCount, params);
    //     }
    //     }.runBinary(keyCount, params);
    // }

    // override
    // List!(long) scriptExists(const(ubyte)[] sampleKey, const(ubyte)[][] sha1...) {
    //     return new RedisClusterCommand!(List!(long))(connectionHandler, maxAttempts) {
    //     override
    //     List!(long) execute(Redis connection) {
    //         return connection.scriptExists(sha1);
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // const(ubyte)[] scriptLoad(const(ubyte)[] script, const(ubyte)[] sampleKey) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.scriptLoad(script);
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // string scriptFlush(const(ubyte)[] sampleKey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.scriptFlush();
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // string scriptKill(const(ubyte)[] sampleKey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.scriptKill();
    //     }
    //     }.runBinary(sampleKey);
    // }

    // override
    // List!(const(ubyte)[]) blpop(int timeout, const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.blpop(timeout, keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // List!(const(ubyte)[]) brpop(int timeout, const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.brpop(timeout, keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // List!(const(ubyte)[]) mget(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.mget(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // string mset(const(ubyte)[][] keysvalues...) {
    //     const(ubyte)[][] keys = new byte[keysvalues.length / 2][];

    //     for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
    //     keys[keyIdx] = keysvalues[keyIdx * 2];
    //     }

    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.mset(keysvalues);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long msetnx(const(ubyte)[][] keysvalues...) {
    //     const(ubyte)[][] keys = new byte[keysvalues.length / 2][];

    //     for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
    //     keys[keyIdx] = keysvalues[keyIdx * 2];
    //     }

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.msetnx(keysvalues);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // string rename(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.rename(oldkey, newkey);
    //     }
    //     }.runBinary(2, oldkey, newkey);
    // }

    // override
    // long renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.renamenx(oldkey, newkey);
    //     }
    //     }.runBinary(2, oldkey, newkey);
    // }

    // override
    // const(ubyte)[] rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.rpoplpush(srckey, dstkey);
    //     }
    //     }.runBinary(2, srckey, dstkey);
    // }

    // override
    // Set!(const(ubyte)[]) sdiff(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sdiff(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sdiffstore(dstkey, keys);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // Set!(const(ubyte)[]) sinter(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sinter(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sinterstore(dstkey, keys);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.smove(srckey, dstkey, member);
    //     }
    //     }.runBinary(2, srckey, dstkey);
    // }

    // override
    // long sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sort(key, sortingParameters, dstkey);
    //     }
    //     }.runBinary(2, key, dstkey);
    // }

    // override
    // long sort(const(ubyte)[] key, const(ubyte)[] dstkey) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sort(key, dstkey);
    //     }
    //     }.runBinary(2, key, dstkey);
    // }

    // override
    // Set!(const(ubyte)[]) sunion(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sunion(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.sunionstore(dstkey, keys);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zinterstore(dstkey, sets);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zinterstore(dstkey, params, sets);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zunionstore(dstkey, sets);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.zunionstore(dstkey, params, sets);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // const(ubyte)[] brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout) {
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.brpoplpush(source, destination, timeout);
    //     }
    //     }.runBinary(2, source, destination);
    // }

    // override
    // long publish(const(ubyte)[] channel, const(ubyte)[] message) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.publish(channel, message);
    //     }
    //     }.runWithAnyNode();
    // }

    // override
    // void subscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] channels...) {
    //     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
    //     override
    //     Integer execute(Redis connection) {
    //         connection.subscribe(jedisPubSub, channels);
    //         return 0;
    //     }
    //     }.runWithAnyNode();
    // }

    // override
    // void psubscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] patterns...) {
    //     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
    //     override
    //     Integer execute(Redis connection) {
    //         connection.psubscribe(jedisPubSub, patterns);
    //         return 0;
    //     }
    //     }.runWithAnyNode();
    // }

    // override
    // long bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(destKey, srcKeys);

    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.bitop(op, destKey, srcKeys);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // string pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...) {
    //     const(ubyte)[][] wholeKeys = KeyMergeUtil.merge(destkey, sourcekeys);

    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.pfmerge(destkey, sourcekeys);
    //     }
    //     }.runBinary(wholeKeys.length, wholeKeys);
    // }

    // override
    // long pfcount(const(ubyte)[][] keys...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.pfcount(keys);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long geoadd(const(ubyte)[] key, double longitude, double latitude,
    //     const(ubyte)[] member) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.geoadd(key, longitude, latitude, member);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.geoadd(key, memberCoordinateMap);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.geodist(key, member1, member2);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2,
    //     GeoUnit unit) {
    //     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
    //     override
    //     Double execute(Redis connection) {
    //         return connection.geodist(key, member1, member2, unit);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(const(ubyte)[]) geohash(const(ubyte)[] key, const(ubyte)[][] members...) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.geohash(key, members);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoCoordinate) geopos(const(ubyte)[] key, const(ubyte)[][] members...) {
    //     return new RedisClusterCommand!(List!(GeoCoordinate))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoCoordinate) execute(Redis connection) {
    //         return connection.geopos(key, members);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude,
    //     double latitude, double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadius(key, longitude, latitude, radius, unit);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude,
    //     double latitude, double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusReadonly(key, longitude, latitude, radius, unit);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude,
    //     double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadius(key, longitude, latitude, radius, unit, param);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude,
    //     double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusReadonly(key, longitude, latitude, radius, unit, param);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member,
    //     double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusByMember(key, member, radius, unit);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member,
    //     double radius, GeoUnit unit) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusByMemberReadonly(key, member, radius, unit);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member,
    //     double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusByMember(key, member, radius, unit, param);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member,
    //     double radius, GeoUnit unit, GeoRadiusParam param) {
    //     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
    //     override
    //     List!(GeoRadiusResponse) execute(Redis connection) {
    //         return connection.georadiusByMemberReadonly(key, member, radius, unit, param);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // Set!(const(ubyte)[]) keys(const(ubyte)[] pattern) {
    //     if (pattern is null || pattern.length == 0) {
    //     throw new IllegalArgumentException(this.getClass().getSimpleName()
    //         ~ " only supports KEYS commands with non-empty patterns");
    //     }
    //     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(pattern)) {
    //     throw new IllegalArgumentException(this.getClass().getSimpleName()
    //         ~ " only supports KEYS commands with patterns containing hash-tags ( curly-brackets enclosed strings )");
    //     }
    //     return new RedisClusterCommand!(Set!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     Set!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.keys(pattern);
    //     }
    //     }.runBinary(pattern);
    // }

    // override
    // ScanResult!(const(ubyte)[]) scan(const(ubyte)[] cursor, ScanParams params) {

    //     const(ubyte)[] matchPattern = null;

    //     if (params is null || (matchPattern = params.binaryMatch()) is null || matchPattern.length == 0) {
    //     throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
    //         ~ " only supports SCAN commands with non-empty MATCH patterns");
    //     }

    //     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(matchPattern)) {
    //     throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
    //         ~ " only supports SCAN commands with MATCH patterns containing hash-tags ( curly-brackets enclosed strings )");
    //     }

    //     return new RedisClusterCommand!( ScanResult!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     ScanResult!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.scan(cursor, params);
    //     }
    //     }.runBinary(matchPattern);
    // }
    
    // override
    // ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor) {
    //     return new RedisClusterCommand!(ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])))(connectionHandler,
    //                                                                         maxAttempts) {
    //     override
    //     ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) execute(Redis connection) {
    //         return connection.hscan(key, cursor);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor,
    //     ScanParams params) {
    //     return new RedisClusterCommand!(ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])))(connectionHandler,
    //                                                                         maxAttempts) {
    //     override
    //     ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) execute(Redis connection) {
    //         return connection.hscan(key, cursor, params);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor) {
    //     return new RedisClusterCommand!(ScanResult!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     ScanResult!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sscan(key, cursor);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
    //     return new RedisClusterCommand!(ScanResult!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     ScanResult!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.sscan(key, cursor, params);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor) {
    //     return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     ScanResult!(Tuple) execute(Redis connection) {
    //         return connection.zscan(key, cursor);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
    //     return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
    //     override
    //     ScanResult!(Tuple) execute(Redis connection) {
    //         return connection.zscan(key, cursor, params);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(long) bitfield(const(ubyte)[] key, const(ubyte)[][] arguments...) {
    //     return new RedisClusterCommand!(List!(long))(connectionHandler, maxAttempts) {
    //     override
    //     List!(long) execute(Redis connection) {
    //         return connection.bitfield(key, arguments);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long hstrlen(const(ubyte)[] key, const(ubyte)[] field) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.hstrlen(key, field);
    //     }
    //     }.runBinary(key);
    // }
    
    // override
    // const(ubyte)[] xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength){
    //     return new RedisClusterCommand!(const(ubyte)[])(connectionHandler, maxAttempts) {
    //     override
    //     const(ubyte)[] execute(Redis connection) {
    //         return connection.xadd(key, id, hash, maxLen, approximateLength);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long xlen(const(ubyte)[] key) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.xlen(key);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(const(ubyte)[]) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xrange(key, start, end, count);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(const(ubyte)[]) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xrevrange(key, end, start, count);
    //     }
    //     }.runBinary(key);  
    // }

    // override
    // List!(const(ubyte)[]) xread(int count, long block, Map!(const(ubyte)[], const(ubyte)[]) streams) {
    //     const(ubyte)[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
        
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xread(count, block, streams);
    //     }
    //     }.runBinary(keys.length, keys);  
    // }

    // override
    // long xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.xack(key, group, ids);
    //     }
    //     }.runBinary(key);   
    // }

    // override
    // string xgroupCreate(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id, bool makeStream) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.xgroupCreate(key, consumer, id, makeStream);
    //     }
    //     }.runBinary(key);  
    // }

    // override
    // string xgroupSetID(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.xgroupSetID(key, consumer, id);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long xgroupDestroy(const(ubyte)[] key, const(ubyte)[] consumer) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.xgroupDestroy(key, consumer);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // string xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] consumerName) {
    //     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
    //     override
    //     string execute(Redis connection) {
    //         return connection.xgroupDelConsumer(key, consumer, consumerName);
    //     }
    //     }.runBinary(key);
    // }

    // override
    //     List!(const(ubyte)[]) xreadGroup(const(ubyte)[] groupname, const(ubyte)[] consumer, int count, long block, 
    //     bool noAck, Map!(const(ubyte)[], const(ubyte)[]) streams){
        
    //     const(ubyte)[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
        
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xreadGroup(groupname, consumer, count, block, noAck, streams);
    //     }
    //     }.runBinary(keys.length, keys);
    // }

    // override
    // long xdel(const(ubyte)[] key, const(ubyte)[][] ids...) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.xdel(key, ids);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long xtrim(const(ubyte)[] key, long maxLen, bool approximateLength) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.xtrim(key, maxLen, approximateLength);
    //     }
    //     }.runBinary(key);
    // }
    
    // override
    // List!(const(ubyte)[]) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, 
    //     int count, const(ubyte)[] consumername) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xpending(key, groupname, start, end, count, consumername);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // List!(const(ubyte)[]) xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, 
    //     Long minIdleTime, long newIdleTime, int retries, bool force, const(ubyte)[][] ids) {
    //     return new RedisClusterCommand!(List!(const(ubyte)[]))(connectionHandler, maxAttempts) {
    //     override
    //     List!(const(ubyte)[]) execute(Redis connection) {
    //         return connection.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
    //     }
    //     }.runBinary(key);
    // }

    // override
    // long waitReplicas(const(ubyte)[] key, int replicas, long timeout) {
    //     return new RedisClusterCommand!(long)(connectionHandler, maxAttempts) {
    //     override
    //     Long execute(Redis connection) {
    //         return connection.waitReplicas(replicas, timeout);
    //     }
    //     }.runBinary(key);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }

    // override
    // Object sendCommand(const(ubyte)[] sampleKey, ProtocolCommand cmd, const(ubyte)[][] args...) {
    //     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
    //     override
    //     Object execute(Redis connection){
    //         return connection.sendCommand(cmd, args);
    //     }
    //     }.runBinary(sampleKey);
    //     mixin(ClusterBinaryCommandTemplate!("dump", const(ubyte)[], [key.stringof]));
    // }
}
