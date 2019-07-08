module hunt.redis.RedisShardInfo;

import hunt.redis.exceptions.InvalidURIException;
import hunt.redis.util.RedisURIHelper;
import hunt.redis.util.ShardInfo;
import hunt.redis.util.Sharded;

public class RedisShardInfo extends ShardInfo<Redis> {

  private int connectionTimeout;
  private int soTimeout;
  private String host;
  private int port;
  private String password = null;
  private String name = null;
  // Default Redis DB
  private int db = 0;
  private boolean ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;
  
  public RedisShardInfo(String host) {
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

  public RedisShardInfo(String host, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  public RedisShardInfo(String host, String name) {
    this(host, Protocol.DEFAULT_PORT, name);
  }

  public RedisShardInfo(HostAndPort hp) {
    this(hp.getHost(), hp.getPort());
  }

  public RedisShardInfo(String host, int port) {
    this(host, port, Protocol.DEFAULT_TIMEOUT);
  }

  public RedisShardInfo(String host, int port, boolean ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl);
  }

  public RedisShardInfo(String host, int port, boolean ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
        hostnameVerifier);
  }

  public RedisShardInfo(String host, int port, String name) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name);
  }

  public RedisShardInfo(String host, int port, String name, boolean ssl) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl);
  }

  public RedisShardInfo(String host, int port, String name, boolean ssl, SSLSocketFactory sslSocketFactory,
      SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  public RedisShardInfo(String host, int port, int timeout) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
  }

  public RedisShardInfo(String host, int port, int timeout, boolean ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
  }

  public RedisShardInfo(String host, int port, int timeout, boolean ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl, sslSocketFactory,
        sslParameters, hostnameVerifier);
  }

  public RedisShardInfo(String host, int port, int timeout, String name) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
    this.name = name;
  }

  public RedisShardInfo(String host, int port, int timeout, String name, boolean ssl) {
    this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
    this.name = name;
  }

  public RedisShardInfo(String host, int port, int timeout, String name, boolean ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  public RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
  }

  public RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight,
      boolean ssl) {
    super(weight);
    this.host = host;
    this.port = port;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.ssl = ssl;
  }

  public RedisShardInfo(String host, int port, int connectionTimeout, int soTimeout, int weight,
      boolean ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, connectionTimeout, soTimeout, weight, ssl);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  public RedisShardInfo(String host, String name, int port, int timeout, int weight) {
    this(host, port, timeout, timeout, weight);
    this.name = name;
  }

  public RedisShardInfo(String host, String name, int port, int timeout, int weight, boolean ssl) {
    this(host, port, timeout, timeout, weight, ssl);
    this.name = name;
  }

  public RedisShardInfo(String host, String name, int port, int timeout, int weight,
      boolean ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(host, port, timeout, timeout, weight, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    this.name = name;
  }

  public RedisShardInfo(URI uri) {
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

  public RedisShardInfo(URI uri, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this(uri);
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

  @Override
  public String toString() {
    return host + ":" + port + "*" + getWeight();
  }

  public String getHost() {
    return host;
  }

  public int getPort() {
    return port;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String auth) {
    this.password = auth;
  }

  public int getConnectionTimeout() {
    return connectionTimeout;
  }

  public void setConnectionTimeout(int connectionTimeout) {
    this.connectionTimeout = connectionTimeout;
  }

  public int getSoTimeout() {
    return soTimeout;
  }

  public void setSoTimeout(int soTimeout) {
    this.soTimeout = soTimeout;
  }

  @Override
  public String getName() {
    return name;
  }

  public int getDb() {
    return db;
  }

  public boolean getSsl() {
      return ssl;
  }

  public SSLSocketFactory getSslSocketFactory() {
    return sslSocketFactory;
  }

  public SSLParameters getSslParameters() {
    return sslParameters;
  }

  public HostnameVerifier getHostnameVerifier() {
    return hostnameVerifier;
  }

  @Override
  public Redis createResource() {
    return new Redis(this);
  }
  
}
