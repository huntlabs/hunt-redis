module hunt.redis.RedisShardInfo;

import hunt.redis.exceptions.InvalidURIException;
import hunt.redis.util.RedisURIHelper;
import hunt.redis.util.ShardInfo;
import hunt.redis.util.Sharded;

class RedisShardInfo : ShardInfo!(Redis) {

  private int connectionTimeout;
  private int soTimeout;
  private String host;
  private int port;
  private String password = null;
  private String name = null;
  // Default Redis DB
  private int db = 0;
  private bool ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;
  
  RedisShardInfo(String host) {
    super(Sharded.DEFAULT_WEIGHT);
    URI uri = URI.create(host);
    if (RedisURIHelper.isValid(uri)) {
      this.host = uri.getHost();
      this.port = uri.getPort();
      this.password = RedisURIHelper.getPassword(uri);
      this.db = RedisURIHelper.getDBIndex(uri);
      this.ssl = RedisURIHelper.isRedisSSLScheme(uri);
    } else {
      this.host = host;
      this.port = Protocol.DEFAULT_PORT;
    }
  }

  RedisShardInfo(String host, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  RedisShardInfo(String host, String name) {
    this(host, Protocol.DEFAULT_PORT, name);
  }

  RedisShardInfo(HostAndPort hp) {
    this(hp.getHost(), hp.getPort());
  }

  RedisShardInfo(String host, int port) {
    this(host, port, Protocol.DEFAULT_TIMEOUT);
  }

  RedisShardInfo(String host, int port, bool ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  RedisShardInfo(String host, int port, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisShardInfo(String host, int port, String name) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name);
  }

  RedisShardInfo(String host, int port, String name, bool ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl);
  }

  RedisShardInfo(String host, int port, String name, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisShardInfo(String host, int port, int timeout) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
  }

  RedisShardInfo(String host, int port, int timeout, bool ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
  }

  RedisShardInfo(String host, int port, int timeout, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  RedisShardInfo(String host, int port, int timeout, String name) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
    this.name = name;
  }

  RedisShardInfo(String host, int port, int timeout, String name, bool ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
    this.name = name;
  }

  RedisShardInfo(String host, int port, int timeout, String name, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
  }

  RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight,
      bool ssl) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.ssl = ssl;
  }

  RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, connectionTimeout, soTimeout, weight, ssl);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  RedisShardInfo(String host, String name, int port, int timeout, int weight) {
    this(host, port, timeout, timeout, weight);
    this.name = name;
  }

  RedisShardInfo(String host, String name, int port, int timeout, int weight, bool ssl) {
    this(host, port, timeout, timeout, weight, ssl);
    this.name = name;
  }

  RedisShardInfo(String host, String name, int port, int timeout, int weight,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, weight, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  RedisShardInfo(URI uri) {
    super(Sharded.DEFAULT_WEIGHT);
    if (!RedisURIHelper.isValid(uri)) {
      throw new InvalidURIException(String.format(
        "Cannot open Redis connection due invalid URI. %s", uri.toString()));
    }

    this.host = uri.getHost();
    this.port = uri.getPort();
    this.password = RedisURIHelper.getPassword(uri);
    this.db = RedisURIHelper.getDBIndex(uri);
    this.ssl = RedisURIHelper.isRedisSSLScheme(uri);
  }

  RedisShardInfo(URI uri, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(uri);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  override
  String toString() {
    return host + ":" + port + "*" + getWeight();
  }

  String getHost() {
    return host;
  }

  int getPort() {
    return port;
  }

  String getPassword() {
    return password;
  }

  void setPassword(String auth) {
    this.password = auth;
  }

  int getConnectionTimeout() {
    return connectionTimeout;
  }

  void setConnectionTimeout(int connectionTimeout) {
    this.connectionTimeout = connectionTimeout;
  }

  int getSoTimeout() {
    return soTimeout;
  }

  void setSoTimeout(int soTimeout) {
    this.soTimeout = soTimeout;
  }

  override
  String getName() {
    return name;
  }

  int getDb() {
    return db;
  }

  bool getSsl() {
      return ssl;
  }

  SSLSocketFactory getSslSocketFactory() {
    return sslSocketFactory;
  }

  SSLParameters getSslParameters() {
    return sslParameters;
  }

  HostnameVerifier getHostnameVerifier() {
    return hostnameVerifier;
  }

  override
  Redis createResource() {
    return new Redis(this);
  }
  
}
