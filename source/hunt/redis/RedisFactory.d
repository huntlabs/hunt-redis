module hunt.redis.RedisFactory;

import hunt.pool.PooledObject;
import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.DefaultPooledObject;

import hunt.redis.Redis;
import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.util.RedisURIHelper;

import hunt.net.util.HttpURI;

import std.format;

/**
 * PoolableObjectFactory custom impl.
 */
class RedisFactory : PooledObjectFactory!(Redis) {
    private HostAndPort hostAndPort; 
    private int connectionTimeout;
    private int soTimeout;
    private string password;
    private int database;
    private string clientName;
    private bool ssl;
    // private SSLSocketFactory sslSocketFactory;
    // private SSLParameters sslParameters;
    // private HostnameVerifier hostnameVerifier;

    this(string host, int port, int connectionTimeout, int soTimeout,
            string password, int database, string clientName) {
        // this(host, port, connectionTimeout, soTimeout, password, database, clientName,
        //     false, null, null, null);
        this.hostAndPort = new HostAndPort(host, port);
        this.connectionTimeout = connectionTimeout;
        this.soTimeout = soTimeout;
        this.password = password;
        this.database = database;
        this.clientName = clientName;
        this.ssl = false;
    }

    // this(string host, int port, int connectionTimeout,
    //     int soTimeout, string password, int database, string clientName,
    //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this.hostAndPort.set(new HostAndPort(host, port));
    //   this.connectionTimeout = connectionTimeout;
    //   this.soTimeout = soTimeout;
    //   this.password = password;
    //   this.database = database;
    //   this.clientName = clientName;
    //   this.ssl = ssl;
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

    this(HttpURI uri, int connectionTimeout, int soTimeout, string clientName) {
        // this(uri, connectionTimeout, soTimeout, clientName, null, null, null);
        if (!RedisURIHelper.isValid(uri)) {
            throw new InvalidURIException(format(
                    "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
        }

        this.hostAndPort = new HostAndPort(uri.getHost(), uri.getPort());
        this.connectionTimeout = connectionTimeout;
        this.soTimeout = soTimeout;
        this.password = RedisURIHelper.getPassword(uri);
        this.database = RedisURIHelper.getDBIndex(uri);
        this.clientName = clientName;
        this.ssl = false; //RedisURIHelper.isRedisSSLScheme(uri);
    }

    // this(HttpURI uri, int connectionTimeout, int soTimeout,
    //     string clientName, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   if (!RedisURIHelper.isValid(uri)) {
    //     throw new InvalidURIException(format(
    //       "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
    //   }

    //   this.hostAndPort.set(new HostAndPort(uri.getHost(), uri.getPort()));
    //   this.connectionTimeout = connectionTimeout;
    //   this.soTimeout = soTimeout;
    //   this.password = RedisURIHelper.getPassword(uri);
    //   this.database = RedisURIHelper.getDBIndex(uri);
    //   this.clientName = clientName;
    //   this.ssl = RedisURIHelper.isRedisSSLScheme(uri);
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

    void setHostAndPort(HostAndPort hostAndPort) {
        this.hostAndPort = hostAndPort;
    }

    void activateObject(IPooledObject pooledRedis) {
        BinaryRedis jedis = cast(BinaryRedis)pooledRedis.getObject();
        if (jedis.getDB() != database) {
            jedis.select(database);
        }

    }

    void destroyObject(IPooledObject pooledRedis) {
        BinaryRedis jedis = cast(BinaryRedis)pooledRedis.getObject();
        if (jedis.isConnected()) {
            try {
                try {
                    jedis.quit();
                } catch (Exception e) {
                }
                jedis.disconnect();
            } catch (Exception e) {

            }
        }

    }

    IPooledObject makeObject() {
        HostAndPort hostAndPort = this.hostAndPort;
        // Redis jedis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(),
        //         connectionTimeout, soTimeout, ssl, sslSocketFactory,
        //         sslParameters, hostnameVerifier);
        Redis jedis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(),
                connectionTimeout, soTimeout, ssl);

        try {
            jedis.connect();
            if (password !is null) {
                jedis.auth(password);
            }
            if (database != 0) {
                jedis.select(database);
            }
            if (clientName !is null) {
                jedis.clientSetname(clientName);
            }
        } catch (RedisException je) {
            jedis.close();
            throw je;
        }

        return new DefaultPooledObject!(Redis)(jedis);

    }

    void passivateObject(IPooledObject pooledRedis) {
        // TODO maybe should select db 0? Not sure right now.
    }

    bool validateObject(IPooledObject pooledRedis) {
        BinaryRedis jedis = cast(BinaryRedis)pooledRedis.getObject();
        try {
            HostAndPort hostAndPort = this.hostAndPort;

            string connectionHost = jedis.getClient().getHost();
            int connectionPort = jedis.getClient().getPort();

            return hostAndPort.getHost() == connectionHost && hostAndPort.getPort() == connectionPort
                && jedis.isConnected() && jedis.ping() == "PONG";
        } catch (Exception e) {
            return false;
        }
    }
}
