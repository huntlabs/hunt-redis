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
 
module hunt.redis.RedisSentinelPool;

import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Protocol;
import hunt.redis.Redis;
import hunt.redis.RedisFactory;
import hunt.redis.RedisPoolAbstract;
import hunt.redis.RedisPubSub;

import hunt.Exceptions;
import hunt.collection.HashSet;
import hunt.collection.List;
import hunt.collection.Set;
import hunt.concurrency.thread;
import hunt.logging.ConsoleLogger;
import hunt.util.pool;
import hunt.util.ArrayHelper;

import core.atomic;
import core.thread;
import core.time;

import std.algorithm;
import std.conv;
import std.format;
import std.string;

/**
*/
// class RedisSentinelPool : RedisPoolAbstract {

//     protected GenericObjectPoolConfig poolConfig;

//     protected int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
//     protected int soTimeout = Protocol.DEFAULT_TIMEOUT;

//     protected string password;

//     protected int database = Protocol.DEFAULT_DATABASE;

//     protected string clientName;

//     protected Set!(MasterListener) masterListeners;

//     private RedisFactory factory;
//     private HostAndPort currentHostMaster;
    
//     private Object initPoolLock;

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig) {
//         this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, null,
//                 Protocol.DEFAULT_DATABASE);
//     }

//     this(string masterName, Set!(string) sentinels) {
//         this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, null,
//                 Protocol.DEFAULT_DATABASE);
//     }

//     this(string masterName, Set!(string) sentinels, string password) {
//         this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, password);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int timeout, string password) {
//         this(masterName, sentinels, poolConfig, timeout, password, Protocol.DEFAULT_DATABASE);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int timeout) {
//         this(masterName, sentinels, poolConfig, timeout, null, Protocol.DEFAULT_DATABASE);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, string password) {
//         this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, password);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int timeout, string password,
//             int database) {
//         this(masterName, sentinels, poolConfig, timeout, timeout, password, database);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int timeout, string password,
//             int database, string clientName) {
//         this(masterName, sentinels, poolConfig, timeout, timeout, password, database, clientName);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int timeout, int soTimeout,
//             string password, int database) {
//         this(masterName, sentinels, poolConfig, timeout, soTimeout, password, database, null);
//     }

//     this(string masterName, Set!(string) sentinels,
//             GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout,
//             string password, int database, string clientName) {
        
//         masterListeners = new HashSet!(MasterListener)();
//         initPoolLock = new Object();
//         this.poolConfig = poolConfig;
//         this.connectionTimeout = connectionTimeout;
//         this.soTimeout = soTimeout;
//         this.password = password;
//         this.database = database;
//         this.clientName = clientName;

//         HostAndPort master = initSentinels(sentinels, masterName);
//         initPool(master);
//     }

//     override void destroy() {
//         foreach(MasterListener m ; masterListeners) {
//             m.shutdown();
//         }

//         super.destroy();
//     }

//     HostAndPort getCurrentHostMaster() {
//         return currentHostMaster;
//     }

//     private void initPool(HostAndPort master) {
//         synchronized(initPoolLock){
//             if (master != currentHostMaster) {
//                 currentHostMaster = master;
//                 if (factory is null) {
//                     factory = new RedisFactory(master.getHost(), master.getPort(), connectionTimeout,
//                             soTimeout, password, database, clientName);
//                     initPool(poolConfig, factory);
//                 } else {
//                     factory.setHostAndPort(currentHostMaster);
//                     // although we clear the pool, we still have to check the
//                     // returned object
//                     // in getResource, this call only clears idle instances, not
//                     // borrowed instances
//                     internalPool.clear();
//                 }

//                 info("Created RedisPool to master at " ~ master.toString());
//             }
//         }
//     }

//     private HostAndPort initSentinels(Set!(string) sentinels, string masterName) {

//         HostAndPort master = null;
//         bool sentinelAvailable = false;

//         info("Trying to find master from available[] Sentinels...");

//         foreach(string sentinel ; sentinels) {
//             HostAndPort hap = HostAndPort.parseString(sentinel);

//             tracef("Connecting to Sentinel %s", hap);

//             Redis redis = null;
//             try {
//                 redis = new Redis(hap);

//                 List!(string) masterAddr = redis.sentinelGetMasterAddrByName(masterName);

//                 // connected to[] sentinel...
//                 sentinelAvailable = true;

//                 if (masterAddr is null || masterAddr.size() != 2) {
//                     warningf("Can not get master addr, master name: %s. Sentinel: %s", masterName, hap);
//                     continue;
//                 }

//                 master = toHostAndPort(masterAddr);
//                 tracef("Found Redis master at %s", master);
//                 break;
//             } catch (RedisException e) {
//                 // resolves #1036, it should handle RedisException there's another chance
//                 // of raising RedisDataException
//                 warningf(
//                     "Cannot get master address from sentinel running @ %s. Reason: %s. Trying next one.", hap,
//                     e.toString());
//             } finally {
//                 if (redis !is null) {
//                     redis.close();
//                 }
//             }
//         }

//         if (master is null) {
//             if (sentinelAvailable) {
//                 // can connect to sentinel, but master name seems to not
//                 // monitored
//                 throw new RedisException("Can connect to sentinel, but " ~ masterName
//                         ~ " seems to be not[] monitored...");
//             } else {
//                 throw new RedisConnectionException("All sentinels down, cannot determine where is "
//                         ~ masterName ~ " master is[] running...");
//             }
//         }

//         info("Redis master running at " ~ master.toString() ~ ", starting Sentinel[] listeners...");

//         foreach(string sentinel ; sentinels) {
//             HostAndPort hap = HostAndPort.parseString(sentinel);
//             MasterListener masterListener = new this(masterName, hap.getHost(), hap.getPort());
//             // whether MasterListener threads are alive or not, process can be stopped
//             masterListener.setDaemon(true);
//             masterListeners.add(masterListener);
//             masterListener.start();
//         }

//         return master;
//     }

//     private HostAndPort toHostAndPort(string[] getMasterAddrByNameResult) {
//         string host = getMasterAddrByNameResult[0];
//         int port = to!int(getMasterAddrByNameResult[1]);

//         return new HostAndPort(host, port);
//     }

//     private HostAndPort toHostAndPort(List!(string) getMasterAddrByNameResult) {
//         string host = getMasterAddrByNameResult.get(0);
//         int port = to!int(getMasterAddrByNameResult.get(1));

//         return new HostAndPort(host, port);
//     }

//     override
//     Redis getResource() {
//         while (true) {
//             Redis redis = super.getResource();
//             redis.setDataSource(this);

//             // get a reference because it can change concurrently
//             HostAndPort master = currentHostMaster;
//             HostAndPort connection = new HostAndPort(redis.getClient().getHost(), redis.getClient()
//                     .getPort());

//             if (master == connection) {
//                 // connected to the correct master
//                 return redis;
//             } else {
//                 returnBrokenResource(redis);
//             }
//         }
//     }

//     override
//     protected void returnBrokenResource(Redis resource) {
//         if (resource !is null) {
//             returnBrokenResourceObject(resource);
//         }
//     }

//     override
//     protected void returnResource(Redis resource) {
//         if (resource !is null) {
//             resource.resetState();
//             returnResourceObject(resource);
//         }
//     }

//     protected class MasterListener : ThreadEx {

//         protected string masterName;
//         protected string host;
//         protected int port;
//         protected long subscribeRetryWaitTimeMillis = 5000;
//         protected Redis j;
//         protected shared bool running = false;

//         protected this() {
//         }

//         this(string masterName, string host, int port) {
//             super(format("MasterListener-%s-[%s:%d]", masterName, host, port));
//             this.masterName = masterName;
//             this.host = host;
//             this.port = port;
//         }

//         this(string masterName, string host, int port,
//                 long subscribeRetryWaitTimeMillis) {
//             this(masterName, host, port);
//             this.subscribeRetryWaitTimeMillis = subscribeRetryWaitTimeMillis;
//         }

//         override
//         void run() {

//             running = true;

//             while (running) {

//                 j = new Redis(host, port);

//                 try {
//                     // double check that it is not being shutdown
//                     if (!running) {
//                         break;
//                     }
                    
//                     /*
//                      * Added code for active refresh
//                      */
//                     List!(string) masterAddr = j.sentinelGetMasterAddrByName(masterName);  
//                     if (masterAddr is null || masterAddr.size() != 2) {
//                         warningf("Can not get master addr, master name: %s. Sentinel: %s：%s.",masterName,host,port);
//                     }else{
//                             initPool(toHostAndPort(masterAddr)); 
//                     }

//                     j.subscribe(new class RedisPubSub {
//                         override
//                         void onMessage(string channel, string message) {
//                             tracef("Sentinel %s:%s published: %s.", host, port, message);

//                             string[] switchMasterMsg = message.split(" ");

//                             if (switchMasterMsg.length > 3) {

//                                 if (masterName == switchMasterMsg[0]) {
//                                     initPool(toHostAndPort([switchMasterMsg[3], switchMasterMsg[4]]));
//                                 } else {
//                                     tracef(
//                                         "Ignoring message on +switch-master for master name %s, our master name is %s",
//                                         switchMasterMsg[0], masterName);
//                                 }

//                             } else {
//                                 errorf(
//                                     "Invalid message received on Sentinel %s:%s on channel +switch-master: %s", host,
//                                     port, message);
//                             }
//                         }
//                     }, "+switch-master");

//                 } catch (RedisException e) {

//                     if (running) {
//                         errorf("Lost connection to Sentinel at %s:%s. Sleeping 5000ms and retrying.", host,
//                             port, e);
//                         try {
//                             Thread.sleep(subscribeRetryWaitTimeMillis.msecs);
//                         } catch (InterruptedException e1) {
//                             errorf("Sleep interrupted: ", e1);
//                         }
//                     } else {
//                         tracef("Unsubscribing from Sentinel at %s:%s", host, port);
//                     }
//                 } finally {
//                     j.close();
//                 }
//             }
//         }

//         void shutdown() {
//             try {
//                 tracef("Shutting down listener on %s:%s", host, port);
//                 running = false;
//                 // This isn't good, the Redis object is not thread safe
//                 if (j !is null) {
//                     j.disconnect();
//                 }
//             } catch (Exception e) {
//                 errorf("Caught exception while shutting down: ", e);
//             }
//         }
//     }
// }