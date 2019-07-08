module hunt.redis.RedisShardInfo;

import hunt.redis.exceptions.InvalidURIException;
import hunt.redis.util.RedisURIHelper;
import hunt.redis.util.ShardInfo;
import hunt.redis.util.Sharded;

class RedisShardInfo : ShardInfo!(Redis) {

  private int connectionTimeout;
  private int soTimeout;
  private string host;
  private int port;
  private string password = null;
  private string name = null;
  // Default Redis DB
  private int db = 0;
  private bool ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;
  
  RedisShardInfo(string host) {
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

  RedisShardInfo(string host, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  RedisShardInfo(string host, string name) {
    this(host, Protocol.DEFAULT_PORT, name);
  }

  RedisShardInfo(HostAndPort hp) {
    this(hp.getHost(), hp.getPort());
  }

  RedisShardInfo(string host, int port) {
    this(host, port, Protocol.DEFAULT_TIMEOUT);
  }

  RedisShardInfo(string host, int port, bool ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  RedisShardInfo(string host, int port, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  RedisShardInfo(string host, int port, string name) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name);
  }

  RedisShardInfo(string host, int port, string name, bool ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl);
  }

  RedisShardInfo(string host, int port, string name, bool ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  RedisShardInfo(string host, int port, int timeout) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
  }

  RedisShardInfo(string host, int port, int timeout, bool ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
  }

  RedisShardInfo(string host, int port, int timeout, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  RedisShardInfo(string host, int port, int timeout, string name) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
    this.name = name;
  }

  RedisShardInfo(string host, int port, int timeout, string name, bool ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
    this.name = name;
  }

  RedisShardInfo(string host, int port, int timeout, string name, bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  RedisShardInfo(string host, int port, int connectionTimeout, int soTimeout, int weight) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
  }

  RedisShardInfo(string host, int port, int connectionTimeout, int soTimeout, int weight,
      bool ssl) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.ssl = ssl;
  }

  RedisShardInfo(string host, int port, int connectionTimeout, int soTimeout, int weight,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, connectionTimeout, soTimeout, weight, ssl);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  RedisShardInfo(string host, string name, int port, int timeout, int weight) {
    this(host, port, timeout, timeout, weight);
    this.name = name;
  }

  RedisShardInfo(string host, string name, int port, int timeout, int weight, bool ssl) {
    this(host, port, timeout, timeout, weight, ssl);
    this.name = name;
  }

  RedisShardInfo(string host, string name, int port, int timeout, int weight,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, weight, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  RedisShardInfo(URI uri) {
    super(Sharded.DEFAULT_WEIGHT);
    if (!RedisURIHelper.isValid(uri)) {
      throw new InvalidURIException(string.format(
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
  string toString() {
    return host ~ ":" ~ port ~ "*" ~ getWeight();
  }

  string getHost() {
    return host;
  }

  int getPort() {
    return port;
  }

  string getPassword() {
    return password;
  }

  void setPassword(string auth) {
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
  string getName() {
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
