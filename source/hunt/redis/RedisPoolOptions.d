module hunt.redis.RedisPoolOptions;

import hunt.redis.Protocol;
import hunt.util.pool.ObjectPool;

import std.format;

/** 
 * 
 */
struct RedisClusterConfig {
    string[] nodes;
    uint redirections = 5;
}

/**
 * 
 */
class RedisPoolOptions : PoolOptions  {

    string host = Protocol.DEFAULT_HOST;

    int port = Protocol.DEFAULT_PORT;

    int connectionTimeout = Protocol.DEFAULT_TIMEOUT;

    int soTimeout = Protocol.DEFAULT_TIMEOUT;

    string password;

    int database = Protocol.DEFAULT_DATABASE;

    string clientName = "";

    int maxAttempts = Protocol.DEFAULT_MAX_ATTEMPTS;

    bool ssl = false;

    this() {
        name = "RedisPool";
        clientName = "default-client";
    }

    this(RedisPoolOptions other) {
        host = other.host;
        port = other.port;
        connectionTimeout = other.connectionTimeout;
        soTimeout = other.soTimeout;
        password = other.password;
        database = other.database;
        clientName = other.clientName;
        maxAttempts = other.maxAttempts;
        ssl = other.ssl;
    }

    override string toString() {
        return format("Host: %s:%d Timeout: %s", host, port, connectionTimeout);
    }
}