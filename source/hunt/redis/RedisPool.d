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
 
module hunt.redis.RedisPool;

import hunt.redis.Exceptions;
import hunt.redis.Redis;
import hunt.redis.RedisPoolOptions;
import hunt.redis.Protocol;

// import hunt.pool.impl.GenericObjectPool;
// import hunt.util.pool;

// import hunt.redis.util.RedisURIHelper;
// import hunt.net.util.HttpURI;

import hunt.logging.ConsoleLogger;
import hunt.util.pool;

import core.atomic;

import std.conv;
import std.range;

alias RedisPool = ObjectPool!Redis;

/** 
 * 
 */
class RedisFactory : ObjectFactory!(Redis) {
    private RedisPool _pool;
    private shared int counter = 0;
    private RedisPoolOptions _options;

    this(RedisPoolOptions options) {
        _options = options;
        _pool = new RedisPool(this, options);
    }

    RedisPool pool() {
        return _pool;
    }

    override Redis makeObject() {
        int c = atomicOp!("+=")(counter, 1);
        string name = "RedisObject-" ~ c.to!string();
        version(HUNT_DEBUG) {
            tracef("Making a Redis: %s", name);
        }

        Redis redis = new PooledRedis(_options);
            
        version(HUNT_DEBUG) {
            infof("Redis making finished: %s", name);
        }

        try {
            redis.connect();

            if (!_options.password.empty) {
                redis.auth(_options.password);
            }

            if (_options.database != 0) {
                redis.select(_options.database);
            }
            if (_options.clientName !is null) {
                redis.clientSetname(_options.clientName);
            }
        } catch (RedisException je) {
            debug warning(je.msg);
            version(HUNT_DEBUG) warning(je);
            redis.close();
            throw je;
        }

        return redis;
    }

    override void destroyObject(Redis redis) {
        if(redis is null) {
            warning("The Redis is null");
            return;
        }
        version(HUNT_DEBUG) {
            tracef("Redis [%s] destroying.", redis.toString());
        }

        if (!redis.isConnected()) return;

        try {
            try {
                redis.quit();
            } catch (Exception e) {
                warning(e);
            }
            // redis.disconnect();
            // redis.close();
        } catch (Exception e) {
            warning(e);
        }
    }

    override bool isValid(Redis p) {
        if(p is null) {
            return false;
        } else {
            return p.isConnected();
        }
    }

    /** 
     * 
     */
    class PooledRedis : Redis {

        this(RedisPoolOptions options) {
            super(options.host, options.port,
                options.connectionTimeout, options.soTimeout, options.ssl);
        }

        override string quit() {
            ObjectPoolState state = _pool.state();
            version(HUNT_DEBUG) {
                tracef("Quiting Redis, Pool state: %s", state);
            }

            if(state == ObjectPoolState.Open) {
                _pool.returnObject(this);
                return "Rejected by Pool";
            } else {
                return super.quit();
            }
        }

        override void close() {
            ObjectPoolState state = _pool.state();
            version(HUNT_DEBUG) {
                tracef("Closing Redis, Pool state: %s", state);
            }

            if(state == ObjectPoolState.Open) {
                _pool.returnObject(this);
            } else {
                super.close();
            }
        }
    }
}


@property RedisPool defaultRedisPool() @trusted {
    import std.concurrency : initOnce;

    __gshared RedisPool pool;
    return initOnce!pool({
        RedisPoolOptions config = defalutPoolConfig();
        RedisFactory factory = new RedisFactory(config);
        return factory.pool();
    }());
}

private __gshared RedisPoolOptions _defalutPoolConfig;

RedisPoolOptions defalutPoolConfig() {
    if(_defalutPoolConfig is null) {
        _defalutPoolConfig = new RedisPoolOptions();
    }
    return _defalutPoolConfig;
}


void defalutPoolConfig(RedisPoolOptions config) {
    _defalutPoolConfig = config;
}