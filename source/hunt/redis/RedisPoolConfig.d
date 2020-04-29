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
 
module hunt.redis.RedisPoolConfig;

import hunt.redis.Protocol;
import hunt.pool.impl.GenericObjectPoolConfig;

struct RedisClusterConfig {
    string[] nodes;
}


/**
 * 
 */
class RedisPoolConfig : GenericObjectPoolConfig {

    string host = Protocol.DEFAULT_HOST;
    int port = Protocol.DEFAULT_PORT;
    int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
    int soTimeout = Protocol.DEFAULT_TIMEOUT;
    string password;
    int database = Protocol.DEFAULT_DATABASE;
    string clientName;
    bool ssl = false;
    
    this() {
        // defaults to make your life with connection pool easier :)
        setTestWhileIdle(true);
        setMinEvictableIdleTimeMillis(60000);
        setTimeBetweenEvictionRunsMillis(30000);
        setNumTestsPerEvictionRun(-1);
    }
}
