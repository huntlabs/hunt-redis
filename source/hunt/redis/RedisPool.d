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
import hunt.redis.RedisPoolAbstract;
import hunt.redis.RedisPoolOptions;
import hunt.redis.RedisFactory;
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

        // PoolOptions poolOptions = new PoolOptions();
        // poolOptions.size = options.maxSize;
        // poolOptions.name = "RedisPool";
        // poolOptions.maxWaitQueueSize = options.maxWaitQueueSize;

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

        // Redis redis = new Redis(_options.host, _options.port,
        //         _options.connectionTimeout, _options.soTimeout, _options.ssl);

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


// /**
//  * 
//  */
// class RedisPool : RedisPoolAbstract {

//     this() {
//         this(Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
//     }

//     this(RedisPoolOptions config) {
//         this(config, config.host, config.port, config.connectionTimeout,
//             config.soTimeout, config.password, config.database, config.clientName);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host) {
//     //     this(poolConfig, host, Protocol.DEFAULT_PORT);
//     // }

//     this(string host, int port) {
//         this(new GenericObjectPoolConfig(), host, port);
//     }

//     this(string host) {
//         HttpURI uri = new HttpURI(host);
//         if (RedisURIHelper.isValid(uri)) {
//             this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
//                     Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null), new GenericObjectPoolConfig());
//         } else {
//             this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
//                     Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
//                     Protocol.DEFAULT_DATABASE, null), new GenericObjectPoolConfig());
//         }
//     }

//     // this(string host, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   HttpURI uri = HttpURI.create(host);
//     //   if (RedisURIHelper.isValid(uri)) {
//     //     this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
//     //         Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null, sslSocketFactory, sslParameters,
//     //         hostnameVerifier), new GenericObjectPoolConfig());
//     //   } else {
//     //     this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
//     //         Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
//     //         Protocol.DEFAULT_DATABASE, null, false, null, null, null), new GenericObjectPoolConfig());
//     //   }
//     // }

//     this(HttpURI uri) {
//         this(new GenericObjectPoolConfig(), uri);
//     }

//     // this(HttpURI uri, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   this(new GenericObjectPoolConfig(), uri, sslSocketFactory, sslParameters, hostnameVerifier);
//     // }

//     this(HttpURI uri, int timeout) {
//         this(new GenericObjectPoolConfig(), uri, timeout);
//     }

//     // this(HttpURI uri, int timeout, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   this(new GenericObjectPoolConfig(), uri, timeout, sslSocketFactory, sslParameters,
//     //       hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password) {
//         this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password, bool ssl) {
//         this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     int timeout, string password, bool ssl,
//     //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl,
//     //       sslSocketFactory, sslParameters, hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port) {
//         this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             bool ssl) {
//         this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
//     //       hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout) {
//         this(poolConfig, host, port, timeout, null);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, bool ssl) {
//         this(poolConfig, host, port, timeout, null, ssl);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     int timeout, bool ssl, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, host, port, timeout, null, ssl, sslSocketFactory, sslParameters,
//     //       hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password, int database) {
//         this(poolConfig, host, port, timeout, password, database, null);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password, int database, bool ssl) {
//         this(poolConfig, host, port, timeout, password, database, null, ssl);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     int timeout, string password, int database, bool ssl,
//     //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, host, port, timeout, password, database, null, ssl, sslSocketFactory,
//     //       sslParameters, hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password, int database, string clientName) {
//         this(poolConfig, host, port, timeout, timeout, password, database, clientName);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int timeout, string password, int database, string clientName,
//             bool ssl) {
//         this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl);
//     }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     int timeout, string password, int database, string clientName,
//     //     bool ssl, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl,
//     //       sslSocketFactory, sslParameters, hostnameVerifier);
//     // }

//     // this(GenericObjectPoolConfig poolConfig, string host, int port,
//     //     int connectionTimeout, int soTimeout, string password, int database,
//     //     string clientName, bool ssl, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
//     //       database, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier));
//     // }

//     this(GenericObjectPoolConfig poolConfig) {
//         this(poolConfig, Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
//     }

//     this(string host, int port, bool ssl) {
//         this(new GenericObjectPoolConfig(), host, port, ssl);
//     }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int connectionTimeout, int soTimeout, string password, int database,
//             string clientName) {
//         super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
//                 database, clientName));
//     }

//     // this(string host, int port, bool ssl,
//     //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(new GenericObjectPoolConfig(), host, port, ssl, sslSocketFactory, sslParameters,
//     //       hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, string host, int port,
//             int connectionTimeout, int soTimeout, string password, int database,
//             string clientName, bool ssl) {
//         // this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName, ssl,
//         //     null, null, null);
//         this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName);    
//     }

//     this(GenericObjectPoolConfig poolConfig, HttpURI uri) {
//         this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT);
//     }

//     // this(GenericObjectPoolConfig poolConfig, HttpURI uri,
//     //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT, sslSocketFactory, sslParameters,
//     //       hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, HttpURI uri, int timeout) {
//         this(poolConfig, uri, timeout, timeout);
//     }

//     // this(GenericObjectPoolConfig poolConfig, HttpURI uri, int timeout,
//     //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
//     //     HostnameVerifier hostnameVerifier) {
//     //   this(poolConfig, uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
//     // }

//     this(GenericObjectPoolConfig poolConfig, HttpURI uri,
//             int connectionTimeout, int soTimeout) {
//         super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null));
//     }

//     // this(GenericObjectPoolConfig poolConfig, HttpURI uri,
//     //     int connectionTimeout, int soTimeout, SSLSocketFactory sslSocketFactory,
//     //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
//     //   super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null, sslSocketFactory,
//     //       sslParameters, hostnameVerifier));
//     // }

//     void initPool(RedisPoolOptions config) {
//         RedisFactory redisFactory = new RedisFactory(config.host, config.port, config.connectionTimeout,
//             config.soTimeout, config.password, config.database, config.clientName);
//         initPool(config, redisFactory);
//     }

//     alias initPool = RedisPoolAbstract.initPool;

//     override
//     Redis getResource() {
//         Redis redis = super.getResource();
//         redis.setDataSource(this);
//         return redis;
//     }

//     override
//     protected void returnBrokenResource(Redis resource) {
//         if (resource !is null) {
//             returnBrokenResourceObject(resource);
//         }
//     }

//     override
//     protected void returnResource(Redis resource) {
//         if (resource !is null) {
//             try {
//                 resource.resetState();
//                 returnResourceObject(resource);
//             } catch (Exception e) {
//                 returnBrokenResource(resource);
//                 throw new RedisException("Resource is returned to the pool as broken", e);
//             }
//         }
//     }
// }



@property RedisPool defaultRedisPool() @trusted {
    import std.concurrency : initOnce;

    __gshared RedisPool pool;
    return initOnce!pool({
        RedisPoolOptions config = defalutPoolConfig();

        // PoolOptions options = new PoolOptions();
        // options.size = config.maxSize;
        // options.name = "RedisPool";
        // options.maxWaitQueueSize = config.maxWaitQueueSize;

        RedisFactory factory = new RedisFactory(config);

        // auto p = new RedisPool(factory, options);
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