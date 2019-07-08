module hunt.redis.RedisFactory;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.DefaultPooledObject;

import hunt.redis.exceptions.InvalidURIException;
import hunt.redis.exceptions.RedisException;
import hunt.redis.util.RedisURIHelper;

/**
 * PoolableObjectFactory custom impl.
 */
class RedisFactory : PooledObjectFactory!(Redis) {
  private final AtomicReference!(HostAndPort) hostAndPort = new AtomicReference!(HostAndPort)();
  private final int connectionTimeout;
  private final int soTimeout;
  private final String password;
  private final int database;
  private final String clientName;
  private final boolean ssl;
  private final SSLSocketFactory sslSocketFactory;
  private final SSLParameters sslParameters;
  private final HostnameVerifier hostnameVerifier;

  RedisFactory(final String host, final int port, final int connectionTimeout,
      final int soTimeout, final String password, final int database, final String clientName) {
    this(host, port, connectionTimeout, soTimeout, password, database, clientName,
        false, null, null, null);
  }

  RedisFactory(final String host, final int port, final int connectionTimeout,
      final int soTimeout, final String password, final int database, final String clientName,
      final boolean ssl, final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
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

  RedisFactory(final URI uri, final int connectionTimeout, final int soTimeout,
      final String clientName) {
    this(uri, connectionTimeout, soTimeout, clientName, null, null, null);
  }

  RedisFactory(final URI uri, final int connectionTimeout, final int soTimeout,
      final String clientName, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    if (!RedisURIHelper.isValid(uri)) {
      throw new InvalidURIException(String.format(
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

  public void setHostAndPort(final HostAndPort hostAndPort) {
    this.hostAndPort.set(hostAndPort);
  }

  override
  public void activateObject(PooledObject!(Redis) pooledRedis) throws Exception {
    final BinaryRedis jedis = pooledRedis.getObject();
    if (jedis.getDB() != database) {
      jedis.select(database);
    }

  }

  override
  public void destroyObject(PooledObject!(Redis) pooledRedis) throws Exception {
    final BinaryRedis jedis = pooledRedis.getObject();
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
  public PooledObject!(Redis) makeObject() throws Exception {
    final HostAndPort hostAndPort = this.hostAndPort.get();
    final Redis jedis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(), connectionTimeout,
        soTimeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);

    try {
      jedis.connect();
      if (password != null) {
        jedis.auth(password);
      }
      if (database != 0) {
        jedis.select(database);
      }
      if (clientName != null) {
        jedis.clientSetname(clientName);
      }
    } catch (RedisException je) {
      jedis.close();
      throw je;
    }

    return new DefaultPooledObject!(Redis)(jedis);

  }

  override
  public void passivateObject(PooledObject!(Redis) pooledRedis) throws Exception {
    // TODO maybe should select db 0? Not sure right now.
  }

  override
  public boolean validateObject(PooledObject!(Redis) pooledRedis) {
    final BinaryRedis jedis = pooledRedis.getObject();
    try {
      HostAndPort hostAndPort = this.hostAndPort.get();

      String connectionHost = jedis.getClient().getHost();
      int connectionPort = jedis.getClient().getPort();

      return hostAndPort.getHost() == connectionHost
          && hostAndPort.getPort() == connectionPort && jedis.isConnected()
          && jedis.ping().equals("PONG");
    } catch (final Exception e) {
      return false;
    }
  }
}