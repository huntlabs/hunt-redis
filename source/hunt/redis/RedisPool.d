/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.redis.RedisPool;

import hunt.redis.Redis;
import hunt.redis.RedisPoolAbstract;
import hunt.redis.RedisFactory;
import hunt.redis.Protocol;

import hunt.pool.impl.GenericObjectPool;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.redis.Exceptions;
import hunt.redis.util.RedisURIHelper;
import hunt.net.util.HttpURI;

class RedisPool : RedisPoolAbstract {

    this() {
        this(Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
    }

    this(GenericObjectPoolConfig poolConfig, string host) {
        this(poolConfig, host, Protocol.DEFAULT_PORT);
    }

    this(string host, int port) {
        this(new GenericObjectPoolConfig(), host, port);
    }

    this(string host) {
        HttpURI uri = new HttpURI(host);
        if (RedisURIHelper.isValid(uri)) {
            this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
                    Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null), new GenericObjectPoolConfig());
        } else {
            this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
                    Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
                    Protocol.DEFAULT_DATABASE, null), new GenericObjectPoolConfig());
        }
    }

    // this(string host, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   HttpURI uri = HttpURI.create(host);
    //   if (RedisURIHelper.isValid(uri)) {
    //     this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(uri,
    //         Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null, sslSocketFactory, sslParameters,
    //         hostnameVerifier), new GenericObjectPoolConfig());
    //   } else {
    //     this.internalPool = new GenericObjectPool!(Redis)(new RedisFactory(host,
    //         Protocol.DEFAULT_PORT, Protocol.DEFAULT_TIMEOUT, Protocol.DEFAULT_TIMEOUT, null,
    //         Protocol.DEFAULT_DATABASE, null, false, null, null, null), new GenericObjectPoolConfig());
    //   }
    // }

    this(HttpURI uri) {
        this(new GenericObjectPoolConfig(), uri);
    }

    // this(HttpURI uri, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(new GenericObjectPoolConfig(), uri, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(HttpURI uri, int timeout) {
        this(new GenericObjectPoolConfig(), uri, timeout);
    }

    // this(HttpURI uri, int timeout, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(new GenericObjectPoolConfig(), uri, timeout, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password) {
        this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password, bool ssl) {
        this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl);
    }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     int timeout, string password, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, host, port, timeout, password, Protocol.DEFAULT_DATABASE, ssl,
    //       sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port) {
        this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            bool ssl) {
        this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl);
    }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, host, port, Protocol.DEFAULT_TIMEOUT, ssl, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout) {
        this(poolConfig, host, port, timeout, null);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, bool ssl) {
        this(poolConfig, host, port, timeout, null, ssl);
    }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     int timeout, bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, host, port, timeout, null, ssl, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password, int database) {
        this(poolConfig, host, port, timeout, password, database, null);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password, int database, bool ssl) {
        this(poolConfig, host, port, timeout, password, database, null, ssl);
    }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     int timeout, string password, int database, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, host, port, timeout, password, database, null, ssl, sslSocketFactory,
    //       sslParameters, hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password, int database, string clientName) {
        this(poolConfig, host, port, timeout, timeout, password, database, clientName);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int timeout, string password, int database, string clientName,
            bool ssl) {
        this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl);
    }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     int timeout, string password, int database, string clientName,
    //     bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, host, port, timeout, timeout, password, database, clientName, ssl,
    //       sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    // this(GenericObjectPoolConfig poolConfig, string host, int port,
    //     int connectionTimeout, int soTimeout, string password, int database,
    //     string clientName, bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
    //       database, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier));
    // }

    this(GenericObjectPoolConfig poolConfig) {
        this(poolConfig, Protocol.DEFAULT_HOST, Protocol.DEFAULT_PORT);
    }

    this(string host, int port, bool ssl) {
        this(new GenericObjectPoolConfig(), host, port, ssl);
    }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int connectionTimeout, int soTimeout, string password, int database,
            string clientName) {
        super(poolConfig, new RedisFactory(host, port, connectionTimeout, soTimeout, password,
                database, clientName));
    }

    // this(string host, int port, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(new GenericObjectPoolConfig(), host, port, ssl, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, string host, int port,
            int connectionTimeout, int soTimeout, string password, int database,
            string clientName, bool ssl) {
        // this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName, ssl,
        //     null, null, null);
        this(poolConfig, host, port, connectionTimeout, soTimeout, password, database, clientName);    
    }

    this(GenericObjectPoolConfig poolConfig, HttpURI uri) {
        this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT);
    }

    // this(GenericObjectPoolConfig poolConfig, HttpURI uri,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, uri, Protocol.DEFAULT_TIMEOUT, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, HttpURI uri, int timeout) {
        this(poolConfig, uri, timeout, timeout);
    }

    // this(GenericObjectPoolConfig poolConfig, HttpURI uri, int timeout,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(poolConfig, uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(GenericObjectPoolConfig poolConfig, HttpURI uri,
            int connectionTimeout, int soTimeout) {
        super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null));
    }

    // this(GenericObjectPoolConfig poolConfig, HttpURI uri,
    //     int connectionTimeout, int soTimeout, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   super(poolConfig, new RedisFactory(uri, connectionTimeout, soTimeout, null, sslSocketFactory,
    //       sslParameters, hostnameVerifier));
    // }

    override
    Redis getResource() {
        Redis redis = super.getResource();
        redis.setDataSource(this);
        return redis;
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
