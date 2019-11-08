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
 
module hunt.redis.RedisClusterInfoCache;

import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.RedisClusterHostAndPortMap;
import hunt.redis.Redis;
import hunt.redis.RedisPool;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;
import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.logging.ConsoleLogger;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.Byte;
import hunt.Long;
import hunt.Integer;
import hunt.String;

import core.sync.mutex;
import core.sync.condition;
import std.conv;

class RedisClusterInfoCache {
    private Map!(string, RedisPool) nodes;
    private Map!(int, RedisPool) slots;

    private Mutex mutex;
    // private Object.Monitor r;
    // private Object.Monitor w;
    private bool rediscovering;
    private GenericObjectPoolConfig poolConfig;

    private int connectionTimeout;
    private int soTimeout;
    private string password;
    private string clientName;

    private bool ssl;
//   private SSLSocketFactory sslSocketFactory;
//   private SSLParameters sslParameters;
//   private HostnameVerifier hostnameVerifier;
    private RedisClusterHostAndPortMap hostAndPortMap;

    private enum int MASTER_NODE_INDEX = 2;

    this(GenericObjectPoolConfig poolConfig, int timeout) {
        this(poolConfig, timeout, timeout, null, null);
    }

    this(GenericObjectPoolConfig poolConfig,
            int connectionTimeout, int soTimeout, string password, string clientName) {
        // this(poolConfig, connectionTimeout, soTimeout, password, clientName, false, null, null, null, null);

        nodes = new HashMap!(string, RedisPool)();
        slots = new HashMap!(int, RedisPool)();
        mutex = new Mutex();

        this.poolConfig = poolConfig;
        this.connectionTimeout = connectionTimeout;
        this.soTimeout = soTimeout;
        this.password = password;
        this.clientName = clientName;
        this.ssl = false;
        // this.sslSocketFactory = sslSocketFactory;
        // this.sslParameters = sslParameters;
        // this.hostnameVerifier = hostnameVerifier;
        this.hostAndPortMap = null;    
    }

//   this(GenericObjectPoolConfig poolConfig,
//       int connectionTimeout, int soTimeout, string password, string clientName,
//       bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, 
//       HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
//     this.poolConfig = poolConfig;
//     this.connectionTimeout = connectionTimeout;
//     this.soTimeout = soTimeout;
//     this.password = password;
//     this.clientName = clientName;
//     this.ssl = ssl;
//     this.sslSocketFactory = sslSocketFactory;
//     this.sslParameters = sslParameters;
//     this.hostnameVerifier = hostnameVerifier;
//     this.hostAndPortMap = hostAndPortMap;
//   }

    void discoverClusterNodesAndSlots(Redis redis) {
        mutex.lock();
        scope(exit) mutex.unlock();

        try {
            reset(); 
            List!(Object) slots = redis.clusterSlots();

            foreach(Object slotInfoObj ; slots) {
                List!(Object) slotInfo = cast(List!(Object)) slotInfoObj;

                if (slotInfo.size() <= MASTER_NODE_INDEX) {
                    continue;
                }

                List!(int) slotNums = getAssignedSlotArray(slotInfo);

                // hostInfos
                int size = slotInfo.size();
                for (int i = MASTER_NODE_INDEX; i < size; i++) {
                    List!(Object) hostInfos = cast(List!(Object)) slotInfo.get(i);
                    if (hostInfos.size() <= 0) {
                        continue;
                    }

                    HostAndPort targetNode = generateHostAndPort(hostInfos);
                    setupNodeIfNotExist(targetNode);
                    if (i == MASTER_NODE_INDEX) {
                        assignSlotsToNode(slotNums, targetNode);
                    }
                }
            }
        } catch(Throwable ex) {
            debug warning(ex.msg);
            version(HUNT_REDIS_DEBUG) warning(ex);
        }
    }

    void renewClusterSlots(Redis redis) {
        //If rediscovering is already in process - no need to start one more same rediscovering, just return
        if (!rediscovering) {
            mutex.lock();
            scope(exit) mutex.unlock();

            try {
                if (!rediscovering) {
                    rediscovering = true;

                    try {
                        if (redis !is null) {
                            try {
                                discoverClusterSlots(redis);
                                return;
                            } catch (RedisException ex) {
                                //try nodes from all pools
                                debug warning(ex.msg);
                                version(HUNT_REDIS_DEBUG) warning(ex);
                            }
                        }

                        foreach(RedisPool jp ; getShuffledNodesPool()) {
                            Redis j = null;
                            try {
                                j = jp.getResource();
                                discoverClusterSlots(j);
                                return;
                            } catch (RedisConnectionException ex) {
                                // try next nodes
                                debug warning(ex.msg);
                                version(HUNT_REDIS_DEBUG) warning(ex);
                            } finally {
                                if (j !is null) {
                                    j.close();
                                }
                            }
                        }
                    } finally {
                        rediscovering = false;      
                    }
                }
            } catch(Exception ex) {
                debug warning(ex.msg);
                version(HUNT_REDIS_DEBUG) warning(ex);
            }
        }
    }

    private void discoverClusterSlots(Redis redis) {
        List!(Object) slots = redis.clusterSlots();
        this.slots.clear();

        foreach(Object slotInfoObj ; slots) {
            List!(Object) slotInfo = cast(List!(Object)) slotInfoObj;

            if (slotInfo.size() <= MASTER_NODE_INDEX) {
                continue;
            }

            List!(int) slotNums = getAssignedSlotArray(slotInfo);

            // hostInfos
            List!(Object) hostInfos = cast(List!(Object)) slotInfo.get(MASTER_NODE_INDEX);
            if (hostInfos.isEmpty()) {
                continue;
            }

            // at this time, we just use master, discard slave information
            HostAndPort targetNode = generateHostAndPort(hostInfos);
            assignSlotsToNode(slotNums, targetNode);
        }
    }

    private HostAndPort generateHostAndPort(List!(Object) hostInfos) {
        Object info = hostInfos.get(0);

        Bytes infoBytes = cast(Bytes)info;
        if(infoBytes is null) {
            warningf("wrong cast: from %s to %s", typeid(info), typeid(Bytes));
        }
        string host = cast(string)infoBytes.value();
        int port = (cast(Long) hostInfos.get(1)).intValue();
        if (ssl && hostAndPortMap !is null) {
            HostAndPort hostAndPort = hostAndPortMap.getSSLHostAndPort(host, port);
            if (hostAndPort !is null) {
                return hostAndPort;
            }
        }
        version(HUNT_REDIS_DEBUG) tracef("%s:%d", host, port);
        return new HostAndPort(host, port);
    }

    RedisPool setupNodeIfNotExist(HostAndPort node) {
        mutex.lock();
        try {
            string nodeKey = getNodeKey(node);
            RedisPool existingPool = nodes.get(nodeKey);
            if (existingPool !is null) return existingPool;

            // RedisPool nodePool = new RedisPool(poolConfig, node.getHost(), node.getPort(),
            //         connectionTimeout, soTimeout, password, 0, clientName, 
            //         ssl, sslSocketFactory, sslParameters, hostnameVerifier);
            RedisPool nodePool = new RedisPool(poolConfig, node.getHost(), node.getPort(),
                    connectionTimeout, soTimeout, password, 0, clientName, 
                    ssl);            
            nodes.put(nodeKey, nodePool);
            return nodePool;
        } finally {
            mutex.unlock();
        }
    }

    void assignSlotToNode(int slot, HostAndPort targetNode) {
        mutex.lock();
        try {
            RedisPool targetPool = setupNodeIfNotExist(targetNode);
            slots.put(slot, targetPool);
        } finally {
            mutex.unlock();
        }
    }

    void assignSlotsToNode(List!(int) targetSlots, HostAndPort targetNode) {
        mutex.lock();
        try {
            RedisPool targetPool = setupNodeIfNotExist(targetNode);
            foreach(int slot ; targetSlots) {
                slots.put(slot, targetPool);
            }
        } finally {
            mutex.unlock();
        }
    }

    RedisPool getNode(string nodeKey) {
        mutex.lock();
        try {
            return nodes.get(nodeKey);
        } finally {
            mutex.unlock();
        }
    }

    RedisPool getSlotPool(int slot) {
        mutex.lock();
        try {
            return slots.get(slot);
        } finally {
            mutex.unlock();
        }
    }

    Map!(string, RedisPool) getNodes() {
        mutex.lock();
        try {
            return new HashMap!(string, RedisPool)(nodes);
        } finally {
            mutex.unlock();
        }
    }

    List!(RedisPool) getShuffledNodesPool() {
        mutex.lock();
        try {
            List!(RedisPool) pools = new ArrayList!(RedisPool)(nodes.values());
// TODO: Tasks pending completion -@zxp at 7/17/2019, 10:01:18 AM            
// 
            // Collections.shuffle(pools);
            return pools;
        } finally {
            mutex.unlock();
        }
    }

    /**
     * Clear discovered nodes collections and gently release allocated resources
     */
    void reset() {
        mutex.lock();
        scope(exit) {
            mutex.unlock();
        }
        
        doReset();
    }

    private void doReset() {
        foreach(RedisPool pool ; nodes.values()) {
            try {
                if (pool !is null) {
                    pool.destroy();
                }
            } catch (Exception ex) {
                // pass
                debug warning(ex.msg);
                version(HUNT_REDIS_DEBUG) warning(ex);                    
            }
        }
        nodes.clear();
        slots.clear();
    }

    static string getNodeKey(HostAndPort hnp) {
        return hnp.getHost() ~ ":" ~ hnp.getPort().to!string();
    }

    static string getNodeKey(Client client) {
        return client.getHost() ~ ":" ~ client.getPort().to!string();
    }

    static string getNodeKey(Redis redis) {
        return getNodeKey(redis.getClient());
    }

    private List!(int) getAssignedSlotArray(List!(Object) slotInfo) {
        List!(int) slotNums = new ArrayList!(int)();
        for (int slot = (cast(Long) slotInfo.get(0)).intValue(); slot <= (cast(Long) slotInfo.get(1))
                .intValue(); slot++) {
            slotNums.add(slot);
        }
        return slotNums;
    }
}
