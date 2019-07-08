module hunt.redis.RedisFactory;
import java.util.concurrent.atomic.AtomicReference;

import hunt.pool.PooledObject;
import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.DefaultPooledObject;

import hunt.redis.exceptions.InvalidURIException;
import hunt.redis.exceptions.RedisException;
import hunt.redis.util.RedisURIHelper;

/**
 * PoolableObjectFactory custom impl.
 */
class RedisFactory : PooledObjectFactory!(Redis) {
  private AtomicReference!(HostAndPort) hostAndPort = new AtomicReference!(HostAndPort)();
  private int connectionTimeout;
  private int soTimeout;
  private string password;
  private int database;
  private string clientName;
  private bool ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;

  this(string host, int port, int connectionTimeout,
      int soTimeout, string password, int database, string clientName) {
    this(host, port, connectionTimeout, soTimeout, password, database, clientName,
        false, null, null, null);
  }

  this(string host, int port, int connectionTimeout,
      int soTimeout, string password, int database, string clientName,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this.hostAndPort.set(new HostAndPort(host, port));
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.password = password;
    this.database = database;
    this.clientName = clientName;
    this.ssl = ssl;
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  this(URI uri, int connectionTimeout, int soTimeout,
      string clientName) {
    this(uri, connectionTimeout, soTimeout, clientName, null, null, null);
  }

  this(URI uri, int connectionTimeout, int soTimeout,
      string clientName, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    if (!RedisURIHelper.isValid(uri)) {
      throw new InvalidURIException(string.format(
        "Cannot open Redis connection due invalid URI. %s", uri.toString()));
    }

    this.hostAndPort.set(new HostAndPort(uri.getHost(), uri.getPort()));
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.password = RedisURIHelper.getPassword(uri);
    this.database = RedisURIHelper.getDBIndex(uri);
    this.clientName = clientName;
    this.ssl = RedisURIHelper.isRedisSSLScheme(uri);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  void setHostAndPort(HostAndPort hostAndPort) {
    this.hostAndPort.set(hostAndPort);
  }

  override
  void activateObject(PooledObject!(Redis) pooledRedis) {
    BinaryRedis jedis = pooledRedis.getObject();
    if (jedis.getDB() != database) {
      jedis.select(database);
    }

  }

  override
  void destroyObject(PooledObject!(Redis) pooledRedis) {
    BinaryRedis jedis = pooledRedis.getObject();
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

  override
  PooledObject!(Redis) makeObject() {
    HostAndPort hostAndPort = this.hostAndPort.get();
    Redis jedis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(), connectionTimeout,
        soTimeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);

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

  override
  void passivateObject(PooledObject!(Redis) pooledRedis) {
    // TODO maybe should select db 0? Not sure right now.
  }

  override
  bool validateObject(PooledObject!(Redis) pooledRedis) {
    BinaryRedis jedis = pooledRedis.getObject();
    try {
      HostAndPort hostAndPort = this.hostAndPort.get();

      string connectionHost = jedis.getClient().getHost();
      int connectionPort = jedis.getClient().getPort();

      return hostAndPort.getHost() == connectionHost
          && hostAndPort.getPort() == connectionPort && jedis.isConnected()
          && jedis.ping().equals("PONG");
    } catch (Exception e) {
      return false;
    }
  }
}