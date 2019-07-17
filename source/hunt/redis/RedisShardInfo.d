module hunt.redis.RedisShardInfo;

import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.Exceptions;
import hunt.redis.util.RedisURIHelper;
import hunt.redis.util.ShardInfo;
import hunt.redis.util.Sharded;

import hunt.net.util.HttpURI;

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
    // private SSLSocketFactory sslSocketFactory;
    // private SSLParameters sslParameters;
    // private HostnameVerifier hostnameVerifier;
    
    this(string host) {
        super(Sharded.DEFAULT_WEIGHT);
        HttpURI uri = HttpURI.create(host);
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

    // this(string host, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(host);
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

    this(string host, string name) {
        this(host, Protocol.DEFAULT_PORT, name);
    }

    this(HostAndPort hp) {
        this(hp.getHost(), hp.getPort());
    }

    this(string host, int port) {
        this(host, port, Protocol.DEFAULT_TIMEOUT);
    }

    this(string host, int port, bool ssl) {
        this(host, port, Protocol.DEFAULT_TIMEOUT, ssl);
    }

    // this(string host, int port, bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(string host, int port, string name) {
        this(host, port, Protocol.DEFAULT_TIMEOUT, name);
    }

    this(string host, int port, string name, bool ssl) {
        this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl);
    }

    // this(string host, int port, string name, bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(host, port, Protocol.DEFAULT_TIMEOUT, name, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int timeout) {
        this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
    }

    this(string host, int port, int timeout, bool ssl) {
        this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
    }

    // this(string host, int port, int timeout, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl, sslSocketFactory,
    //       sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int timeout, string name) {
        this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT);
        this.name = name;
    }

    this(string host, int port, int timeout, string name, bool ssl) {
        this(host, port, timeout, timeout, Sharded.DEFAULT_WEIGHT, ssl);
        this.name = name;
    }

    // this(string host, int port, int timeout, string name, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(host, port, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    //   this.name = name;
    // }

    this(string host, int port, int connectionTimeout, int soTimeout, int weight) {
        super(weight);
        this.host = host;
        this.port = port;
        this.connectionTimeout = connectionTimeout;
        this.soTimeout = soTimeout;
    }

    this(string host, int port, int connectionTimeout, int soTimeout, int weight,
            bool ssl) {
        super(weight);
        this.host = host;
        this.port = port;
        this.connectionTimeout = connectionTimeout;
        this.soTimeout = soTimeout;
        this.ssl = ssl;
    }

    // this(string host, int port, int connectionTimeout, int soTimeout, int weight,
    //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(host, port, connectionTimeout, soTimeout, weight, ssl);
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

    this(string host, string name, int port, int timeout, int weight) {
        this(host, port, timeout, timeout, weight);
        this.name = name;
    }

    this(string host, string name, int port, int timeout, int weight, bool ssl) {
        this(host, port, timeout, timeout, weight, ssl);
        this.name = name;
    }

    // this(string host, string name, int port, int timeout, int weight,
    //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(host, port, timeout, timeout, weight, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    //   this.name = name;
    // }

    // this(HttpURI uri) {
    //   super(Sharded.DEFAULT_WEIGHT);
    //   if (!RedisURIHelper.isValid(uri)) {
    //     throw new InvalidURIException(format(
    //       "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
    //   }

    //   this.host = uri.getHost();
    //   this.port = uri.getPort();
    //   this.password = RedisURIHelper.getPassword(uri);
    //   this.db = RedisURIHelper.getDBIndex(uri);
    //   this.ssl = RedisURIHelper.isRedisSSLScheme(uri);
    // }

    // this(HttpURI uri, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(uri);
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

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

    // SSLSocketFactory getSslSocketFactory() {
    //   return sslSocketFactory;
    // }

    // SSLParameters getSslParameters() {
    //   return sslParameters;
    // }

    // HostnameVerifier getHostnameVerifier() {
    //   return hostnameVerifier;
    // }

    override
    Redis createResource() {
        return new Redis(this);
    }
    
}
