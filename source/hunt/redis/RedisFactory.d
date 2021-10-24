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
 
module hunt.redis.RedisFactory;

// import hunt.pool.PooledObject;
// import hunt.pool.PooledObjectFactory;
// import hunt.pool.impl.DefaultPooledObject;

// import hunt.redis.BinaryRedis;
// import hunt.redis.Exceptions;
// import hunt.redis.HostAndPort;
// import hunt.redis.Redis;
// import hunt.redis.util.RedisURIHelper;

// import hunt.logging.ConsoleLogger;
// import hunt.net.util.HttpURI;

// import std.format;
// import std.range;

// /**
//  * PoolableObjectFactory custom impl.
//  */
// class RedisFactory : PooledObjectFactory!(Redis) {
//     private HostAndPort hostAndPort; 
//     private int connectionTimeout;
//     private int soTimeout;
//     private string password;
//     private int database;
//     private string clientName;
//     private bool ssl;
//     // private SSLSocketFactory sslSocketFactory;
//     // private SSLParameters sslParameters;
//     // private HostnameVerifier hostnameVerifier;

//     this(string host, int port, int connectionTimeout, int soTimeout,
//             string password, int database, string clientName) {
//         this.hostAndPort = new HostAndPort(host, port);
//         this.connectionTimeout = connectionTimeout;
//         this.soTimeout = soTimeout;
//         this.password = password;
//         this.database = database;
//         this.clientName = clientName;
//         this.ssl = false;
//     }

//     this(HttpURI uri, int connectionTimeout, int soTimeout, string clientName) {
//         if (!RedisURIHelper.isValid(uri)) {
//             throw new InvalidURIException(format(
//                     "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
//         }

//         this.hostAndPort = new HostAndPort(uri.getHost(), uri.getPort());
//         this.connectionTimeout = connectionTimeout;
//         this.soTimeout = soTimeout;
//         this.password = RedisURIHelper.getPassword(uri);
//         this.database = RedisURIHelper.getDBIndex(uri);
//         this.clientName = clientName;
//         this.ssl = false; //RedisURIHelper.isRedisSSLScheme(uri);
//     }

//     void setHostAndPort(HostAndPort hostAndPort) {
//         this.hostAndPort = hostAndPort;
//     }

//     void activateObject(IPooledObject pooledRedis) {
//         Redis redis = (cast(PooledObject!Redis)pooledRedis).getObject();
//         if (redis.getDB() != database) {
//             redis.select(database);
//         }
//     }

//     void destroyObject(IPooledObject pooledRedis) {
//         Redis redis = (cast(PooledObject!Redis)pooledRedis).getObject();
//         if (redis.isConnected()) {
//             try {
//                 try {
//                     redis.quit();
//                 } catch (Exception e) {
//                 }
//                 redis.disconnect();
//             } catch (Exception e) {

//             }
//         }

//     }

//     IPooledObject makeObject() {
//         HostAndPort hostAndPort = this.hostAndPort;
        
//         version(HUNT_REDIS_DEBUG) infof("%s", hostAndPort.toString());
//         Redis redis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(),
//                 connectionTimeout, soTimeout, ssl);

//         try {
//             redis.connect();

//             if (!password.empty) {
//                 redis.auth(password);
//             }

//             if (database != 0) {
//                 redis.select(database);
//             }
//             if (clientName !is null) {
//                 redis.clientSetname(clientName);
//             }
//         } catch (RedisException je) {
//             debug warning(je.msg);
//             version(HUNT_DEBUG) warning(je);
//             redis.close();
//             throw je;
//         }

//         return new DefaultPooledObject!(Redis)(redis);

//     }

//     void passivateObject(IPooledObject pooledRedis) {
//         // TODO maybe should select db 0? Not sure right now.
//     }

//     bool validateObject(IPooledObject pooledRedis) {
//         BinaryRedis redis = cast(BinaryRedis)(cast(PooledObject!Redis)pooledRedis).getObject();
//         try {
//             HostAndPort hostAndPort = this.hostAndPort;

//             string connectionHost = redis.getClient().getHost();
//             int connectionPort = redis.getClient().getPort();

//             return hostAndPort.getHost() == connectionHost && hostAndPort.getPort() == connectionPort
//                 && redis.isConnected() && redis.ping() == "PONG";
//         } catch (Exception e) {
//             return false;
//         }
//     }
// }
