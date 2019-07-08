module hunt.redis.RedisPool;

import hunt.pool.impl.GenericObjectPool;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisException;
import hunt.redis.util.RedisURIHelper;

class RedisPool : RedisPoolAbstract {

  RedisPool() {
    this(Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host) {
    this(poolConfig, host, Protocol.DEFAULT_PORT);
  }

  RedisPool(string host, int port) {
    this(new GenericObjectPoolConfig(), host, port);
  }

  RedisPool(string host) {
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

  RedisPool(string host, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
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

  RedisPool(URI uri) {
    this(new GenericObjectPoolConfig(), uri);
  }

  RedisPool(URI uri, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(URI uri, int timeout) {
    this(new GenericObjectPoolConfig(), uri, timeout);
  }

  RedisPool(URI uri, int timeout, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), uri, timeout, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, bool ssl) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      bool ssl) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout) {
    this(poolConfig, host, port, timeout, null);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, bool ssl) {
    this(poolConfig, host, port, timeout, null, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, null, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database) {
    this(poolConfig, host, port, timeout, password, database, null);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database, bool ssl) {
    this(poolConfig, host, port, timeout, password, database, null, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, password, database, null, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database, string clientName) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database, string clientName,
      bool ssl) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int timeout, string password, int database, string clientName,
      bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl,
        sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int connectionTimeout, int soTimeout, string password, int database,
      string clientName, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier));
  }

  RedisPool(GenericObjectPoolConfig poolConfig) {
    this(poolConfig, Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
  }

  RedisPool(string host, int port, bool ssl) {
    this(new GenericObjectPoolConfig(), host, port, ssl);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int connectionTimeout, int soTimeout, string password, int database,
      string clientName) {
    super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
        database, clientName));
  }

  RedisPool(string host, int port, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(new GenericObjectPoolConfig(), host, port, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, string host, int port,
      int connectionTimeout, int soTimeout, string password, int database,
      string clientName, bool ssl) {
    this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName, ssl,
        null, null, null);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri, int timeout) {
    this(poolConfig, uri, timeout, timeout);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri, int timeout,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(poolConfig, uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri,
      int connectionTimeout, int soTimeout) {
    super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null));
  }

  RedisPool(GenericObjectPoolConfig poolConfig, URI uri,
      int connectionTimeout, int soTimeout, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
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
  protected void returnBrokenResource(Redis resource) {
    if (resource !is null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
  protected void returnResource(Redis resource) {
    if (resource !is null) {
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
