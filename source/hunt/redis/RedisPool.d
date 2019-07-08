module hunt.redis.RedisPool;

import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisException;
import hunt.redis.util.RedisURIHelper;

public class RedisPool extends RedisPoolAbstract {

  public RedisPool() {
    this(Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host) {
    this(poolConfig, host, Protocol.DEFAULT_PORT);
  }

  public RedisPool(String host, int port) {
    this(new GenericObjectPoolConfig(), host, port);
  }

  public RedisPool(final String host) {
    URI uri = URI.create(host);
    if (RedisURIHelper.isValid(uri)) {
      this.internalPool = new GenericObjectPool<Redis>(new RedisFactory(uri,
          Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null), new GenericObjectPoolConfig());
    } else {
      this.internalPool = new GenericObjectPool<Redis>(new RedisFactory(host,
          Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
          Protocol.DEFAULT_DATABASE, null), new GenericObjectPoolConfig());
    }
  }

  public RedisPool(final String host, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    URI uri = URI.create(host);
    if (RedisURIHelper.isValid(uri)) {
      this.internalPool = new GenericObjectPool<Redis>(new RedisFactory(uri,
          Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null, sslSocketFactory, sslParameters,
          hostnameVerifier), new GenericObjectPoolConfig());
    } else {
      this.internalPool = new GenericObjectPool<Redis>(new RedisFactory(host,
          Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
          Protocol.DEFAULT_DATABASE, null, false, null, null, null), new GenericObjectPoolConfig());
    }
  }

  public RedisPool(final URI uri) {
    this(new GenericObjectPoolConfig(), uri);
  }

  public RedisPool(final URI uri, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  public RedisPool(final URI uri, final int timeout) {
    this(new GenericObjectPoolConfig(), uri, timeout);
  }

  public RedisPool(final URI uri, final int timeout, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, timeout, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final boolean ssl) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final boolean ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final boolean ssl) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final boolean ssl, final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout) {
    this(poolConfig, host, port, timeout, null);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout, final boolean ssl) {
    this(poolConfig, host, port, timeout, null, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout, final boolean ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, null, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database) {
    this(poolConfig, host, port, timeout, password, database, null);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final boolean ssl) {
    this(poolConfig, host, port, timeout, password, database, null, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final boolean ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, database, null, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName,
      final boolean ssl) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName,
      final boolean ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName, final boolean ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier));
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig) {
    this(poolConfig, Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  public RedisPool(final String host, final int port, final boolean ssl) {
    this(new GenericObjectPoolConfig(), host, port, ssl);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName));
  }

  public RedisPool(final String host, final int port, final boolean ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), host, port, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName, final boolean ssl) {
    this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName, ssl,
        null, null, null);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri, final int timeout) {
    this(poolConfig, uri, timeout, timeout);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri, final int timeout,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final int connectionTimeout, final int soTimeout) {
    super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null));
  }

  public RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final int connectionTimeout, final int soTimeout, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null, sslSocketFactory,
        sslParameters, hostnameVerifier));
  }

  @Override
  public Redis getResource() {
    Redis jedis = super.getResource();
    jedis.setDataSource(this);
    return jedis;
  }

  @Override
  protected void returnBrokenResource(final Redis resource) {
    if (resource != null) {
      returnBrokenResourceObject(resource);
    }
  }

  @Override
  protected void returnResource(final Redis resource) {
    if (resource != null) {
      try {
        resource.resetState();
        returnResourceObject(resource);
      } catch (Exception e) {
        returnBrokenResource(resource);
        throw new RedisException("Resource is returned to the pool as broken", e);
      }
    }
  }
}
