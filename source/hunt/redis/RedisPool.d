module hunt.redis.RedisPool;

import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisException;
import hunt.redis.util.RedisURIHelper;

class RedisPool : RedisPoolAbstract {

  RedisPool() {
    this(Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host) {
    this(poolConfig, host, Protocol.DEFAULT_PORT);
  }

  RedisPool(String host, int port) {
    this(new GenericObjectPoolConfig(), host, port);
  }

  RedisPool(final String host) {
    URI uri = URI.create(host);
    if (RedisURIHelper.isValid(uri)) {
      this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
          Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null), new GenericObjectPoolConfig());
    } else {
      this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
          Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
          Protocol.DEFAULT_DATABASE, null), new GenericObjectPoolConfig());
    }
  }

  RedisPool(final String host, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    URI uri = URI.create(host);
    if (RedisURIHelper.isValid(uri)) {
      this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
          Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null, sslSocketFactory, sslParameters,
          hostnameVerifier), new GenericObjectPoolConfig());
    } else {
      this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
          Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
          Protocol.DEFAULT_DATABASE, null, false, null, null, null), new GenericObjectPoolConfig());
    }
  }

  RedisPool(final URI uri) {
    this(new GenericObjectPoolConfig(), uri);
  }

  RedisPool(final URI uri, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(final URI uri, final int timeout) {
    this(new GenericObjectPoolConfig(), uri, timeout);
  }

  RedisPool(final URI uri, final int timeout, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, timeout, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final bool ssl) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final bool ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final bool ssl) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final bool ssl, final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout) {
    this(poolConfig, host, port, timeout, null);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout, final bool ssl) {
    this(poolConfig, host, port, timeout, null, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int timeout, final bool ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, null, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database) {
    this(poolConfig, host, port, timeout, password, database, null);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final bool ssl) {
    this(poolConfig, host, port, timeout, password, database, null, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final bool ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, database, null, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName,
      final bool ssl) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      int timeout, final String password, final int database, final String clientName,
      final bool ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName, final bool ssl, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier));
  }

  RedisPool(final GenericObjectPoolConfig poolConfig) {
    this(poolConfig, Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  RedisPool(final String host, final int port, final bool ssl) {
    this(new GenericObjectPoolConfig(), host, port, ssl);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName));
  }

  RedisPool(final String host, final int port, final bool ssl,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), host, port, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final String host, final int port,
      final int connectionTimeout, final int soTimeout, final String password, final int database,
      final String clientName, final bool ssl) {
    this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName, ssl,
        null, null, null);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri, final int timeout) {
    this(poolConfig, uri, timeout, timeout);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri, final int timeout,
      final SSLSocketFactory sslSocketFactory, final SSLParameters sslParameters,
      final HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final int connectionTimeout, final int soTimeout) {
    super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null));
  }

  RedisPool(final GenericObjectPoolConfig poolConfig, final URI uri,
      final int connectionTimeout, final int soTimeout, final SSLSocketFactory sslSocketFactory,
      final SSLParameters sslParameters, final HostnameVerifier hostnameVerifier) {
    super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null, sslSocketFactory,
        sslParameters, hostnameVerifier));
  }

  override
  Redis getResource() {
    Redis jedis = super.getResource();
    jedis.setDataSource(this);
    return jedis;
  }

  override
  protected void returnBrokenResource(final Redis resource) {
    if (resource != null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
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
