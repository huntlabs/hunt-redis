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

module hunt.redis.RedisClusterConnectionHandler;

import hunt.redis.Redis;
import hunt.redis.RedisClusterInfoCache;
import hunt.redis.RedisPool;

import hunt.util.Common;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;

abstract class RedisClusterConnectionHandler : Closeable {
    protected RedisClusterInfoCache cache;

    this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig,
            int connectionTimeout, int soTimeout, string password) {
        this(nodes, poolConfig, connectionTimeout, soTimeout, password, null);
    }

    this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig,
            int connectionTimeout, int soTimeout, string password, string clientName) {
        // this(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, false, null, null, null, null);

        this.cache = new RedisClusterInfoCache(poolConfig, connectionTimeout,
                soTimeout, password, clientName);
        initializeSlotsCache(nodes, poolConfig, connectionTimeout, soTimeout,
                password, clientName, false);
    }

    //   this(Set!(HostAndPort) nodes,
    //       GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, string password, string clientName,
    //       bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //       HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap portMap) {
    //     this.cache = new RedisClusterInfoCache(poolConfig, connectionTimeout, soTimeout, password, clientName,
    //         ssl, sslSocketFactory, sslParameters, hostnameVerifier, portMap);
    //     initializeSlotsCache(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    //   }

    abstract Redis getConnection();

    abstract Redis getConnectionFromSlot(int slot);

    Redis getConnectionFromNode(HostAndPort node) {
        return cache.setupNodeIfNotExist(node).getResource();
    }

    Map!(string, RedisPool) getNodes() {
        return cache.getNodes();
    }

    //   private void initializeSlotsCache(Set!(HostAndPort) startNodes, GenericObjectPoolConfig poolConfig,
    //       int connectionTimeout, int soTimeout, string password, string clientName,
    //       bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, HostnameVerifier hostnameVerifier) 

    private void initializeSlotsCache(Set!(HostAndPort) startNodes, GenericObjectPoolConfig poolConfig,
            int connectionTimeout, int soTimeout, string password, string clientName, bool ssl) {
        foreach (HostAndPort hostAndPort; startNodes) {
            Redis redis = null;
            try {
                // redis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(), connectionTimeout, soTimeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
                redis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(),
                        connectionTimeout, soTimeout, ssl);
                if (password !is null) {
                    redis.auth(password);
                }
                if (clientName !is null) {
                    redis.clientSetname(clientName);
                }
                cache.discoverClusterNodesAndSlots(redis);
                break;
            } catch (RedisConnectionException e) {
                // try next nodes
            } finally {
                if (redis !is null) {
                    redis.close();
                }
            }
        }
    }

    void renewSlotCache() {
        cache.renewClusterSlots(null);
    }

    void renewSlotCache(Redis redis) {
        cache.renewClusterSlots(redis);
    }

    override void close() {
        cache.reset();
    }
}
