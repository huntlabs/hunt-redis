module hunt.redis.BinaryRedisCluster;

import hunt.redis.commands.BinaryRedisClusterCommands;
import hunt.redis.commands.RedisClusterBinaryScriptingCommands;
import hunt.redis.commands.MultiKeyBinaryRedisClusterCommands;
import hunt.redis.commands.ProtocolCommand;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.RedisClusterHashTagUtil;
import hunt.redis.util.KeyMergeUtil;
import hunt.redis.util.SafeEncoder;

import hunt.util.Common;
import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.pool.impl.GenericObjectPoolConfig;

// class BinaryRedisCluster : BinaryRedisClusterCommands,
//     MultiKeyBinaryRedisClusterCommands, RedisClusterBinaryScriptingCommands, Closeable {

//   enum int HASHSLOTS = 16384;
//   protected enum int DEFAULT_TIMEOUT = 2000;
//   protected enum int DEFAULT_MAX_ATTEMPTS = 5;

//   protected int maxAttempts;

//   protected RedisClusterConnectionHandler connectionHandler;

//   this(Set!(HostAndPort) nodes, int timeout) {
//     this(nodes, timeout, DEFAULT_MAX_ATTEMPTS, new GenericObjectPoolConfig());
//   }

//   this(Set!(HostAndPort) nodes) {
//     this(nodes, DEFAULT_TIMEOUT);
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int timeout, int maxAttempts,
//       GenericObjectPoolConfig poolConfig) {
//     this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
//         timeout);
//     this.maxAttempts = maxAttempts;
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int connectionTimeout,
//                             int soTimeout, int maxAttempts, GenericObjectPoolConfig poolConfig) {
//     this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
//         connectionTimeout, soTimeout);
//     this.maxAttempts = maxAttempts;
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, string password, GenericObjectPoolConfig poolConfig) {
//     this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
//             connectionTimeout, soTimeout, password);
//     this.maxAttempts = maxAttempts;
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig) {
//     this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
//             connectionTimeout, soTimeout, password, clientName);
//     this.maxAttempts = maxAttempts;
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
//       bool ssl) {
//     this(jedisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig, ssl, null, null, null, null);
//   }

//   this(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, string password, string clientName, GenericObjectPoolConfig poolConfig,
//       bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
//     this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
//         connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier, hostAndPortMap);
//     this.maxAttempts = maxAttempts;
//   }

//   override
//   void close() {
//     if (connectionHandler !is null) {
//       connectionHandler.close();
//     }
//   }

//   Map!(string, RedisPool) getClusterNodes() {
//     return connectionHandler.getNodes();
//   }

//   Redis getConnectionFromSlot(int slot) {
// 	  return  this.connectionHandler.getConnectionFromSlot(slot);
//   }

//   override
//   string set(byte[] key, byte[] value) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.set(key, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   string set(byte[] key, byte[] value, SetParams params) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.set(key, value, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] get(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.get(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long exists(byte[] keys...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.exists(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Boolean exists(byte[] key) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.exists(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long persist(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.persist(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   string type(byte[] key) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.type(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] dump(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.dump(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   string restore(byte[] key, int ttl, byte[] serializedValue) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.restore(key, ttl, serializedValue);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long expire(byte[] key, int seconds) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.expire(key, seconds);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long pexpire(byte[] key, long milliseconds) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pexpire(key, milliseconds);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long expireAt(byte[] key, long unixTime) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.expireAt(key, unixTime);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long pexpireAt(byte[] key, long millisecondsTimestamp) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pexpireAt(key, millisecondsTimestamp);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long ttl(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.ttl(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long pttl(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pttl(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long touch(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.touch(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long touch(byte[] keys...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.touch(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Boolean setbit(byte[] key, long offset, bool value) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.setbit(key, offset, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Boolean setbit(byte[] key, long offset, byte[] value) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.setbit(key, offset, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Boolean getbit(byte[] key, long offset) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.getbit(key, offset);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long setrange(byte[] key, long offset, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.setrange(key, offset, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] getrange(byte[] key, long startOffset, long endOffset) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.getrange(key, startOffset, endOffset);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] getSet(byte[] key, byte[] value) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.getSet(key, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long setnx(byte[] key, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.setnx(key, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   string psetex(byte[] key, long milliseconds, byte[] value) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.psetex(key, milliseconds, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   string setex(byte[] key, int seconds, byte[] value) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.setex(key, seconds, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long decrBy(byte[] key, long decrement) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.decrBy(key, decrement);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long decr(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.decr(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long incrBy(byte[] key, long increment) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.incrBy(key, increment);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double incrByFloat(byte[] key, double increment) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.incrByFloat(key, increment);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long incr(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.incr(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long append(byte[] key, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.append(key, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] substr(byte[] key, int start, int end) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.substr(key, start, end);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hset(byte[] key, byte[] field, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hset(key, field, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hset(byte[] key, Map!(byte[], byte[]) hash) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hset(key, hash);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] hget(byte[] key, byte[] field) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.hget(key, field);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hsetnx(byte[] key, byte[] field, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hsetnx(key, field, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   string hmset(byte[] key, Map!(byte[], byte[]) hash) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.hmset(key, hash);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) hmget(byte[] key, byte[] fields...) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.hmget(key, fields);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hincrBy(byte[] key, byte[] field, long value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hincrBy(key, field, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double hincrByFloat(byte[] key, byte[] field, double value) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.hincrByFloat(key, field, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Boolean hexists(byte[] key, byte[] field) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.hexists(key, field);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hdel(byte[] key, byte[] field...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hdel(key, field);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hlen(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hlen(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) hkeys(byte[] key) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.hkeys(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Collection!(byte[]) hvals(byte[] key) {
//     return new RedisClusterCommand!(Collection!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Collection!(byte[]) execute(Redis connection) {
//         return connection.hvals(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Map!(byte[], byte[]) hgetAll(byte[] key) {
//     return new RedisClusterCommand!(Map!(byte[], byte[]))(connectionHandler, maxAttempts) {
//       override
//       Map!(byte[], byte[]) execute(Redis connection) {
//         return connection.hgetAll(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long rpush(byte[] key, byte[] args...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.rpush(key, args);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long lpush(byte[] key, byte[] args...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.lpush(key, args);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long llen(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.llen(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) lrange(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.lrange(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   string ltrim(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.ltrim(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] lindex(byte[] key, long index) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.lindex(key, index);
//       }
//     }.runBinary(key);
//   }

//   override
//   string lset(byte[] key, long index, byte[] value) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.lset(key, index, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long lrem(byte[] key, long count, byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.lrem(key, count, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] lpop(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.lpop(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] rpop(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.rpop(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long sadd(byte[] key, byte[] member...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sadd(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) smembers(byte[] key) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.smembers(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long srem(byte[] key, byte[] member...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.srem(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] spop(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.spop(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) spop(byte[] key, long count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.spop(key, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long scard(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.scard(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Boolean sismember(byte[] key, byte[] member) {
//     return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
//       override
//       Boolean execute(Redis connection) {
//         return connection.sismember(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   byte[] srandmember(byte[] key) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.srandmember(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long strlen(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.strlen(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zadd(byte[] key, double score, byte[] member) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zadd(key, score, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zadd(byte[] key, double score, byte[] member,
//       ZAddParams params) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zadd(key, score, member, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zadd(byte[] key, Map!(byte[], Double) scoreMembers) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zadd(key, scoreMembers);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zadd(key, scoreMembers, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrange(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrange(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zrem(byte[] key, byte[] members...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zrem(key, members);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double zincrby(byte[] key, double increment, byte[] member) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.zincrby(key, increment, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double zincrby(byte[] key, double increment, byte[] member,
//       ZIncrByParams params) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.zincrby(key, increment, member, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zrank(byte[] key, byte[] member) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zrank(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zrevrank(byte[] key, byte[] member) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zrevrank(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrange(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrange(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrangeWithScores(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrangeWithScores(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrevrangeWithScores(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrevrangeWithScores(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zcard(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zcard(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double zscore(byte[] key, byte[] member) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.zscore(key, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) sort(byte[] key) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.sort(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) sort(byte[] key, SortingParams sortingParameters) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.sort(key, sortingParameters);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zcount(byte[] key, double min, double max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zcount(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zcount(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zcount(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByScore(byte[] key, double min, double max) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByScore(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByScore(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByScore(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByScore(byte[] key, double max, double min) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByScore(key, max, min);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByScore(byte[] key, double min, double max,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByScore(key, min, max, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByScore(byte[] key, byte[] max, byte[] min) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByScore(key, max, min);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByScore(byte[] key, byte[] min, byte[] max,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByScore(key, min, max, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByScore(byte[] key, double max, double min,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByScore(key, max, min, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrangeByScoreWithScores(byte[] key, double min, double max) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrangeByScoreWithScores(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, double max, double min) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrevrangeByScoreWithScores(key, max, min);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrangeByScoreWithScores(byte[] key, double min, double max,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrangeByScoreWithScores(key, min, max, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByScore(byte[] key, byte[] max, byte[] min,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByScore(key, max, min, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrangeByScoreWithScores(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrevrangeByScoreWithScores(key, max, min);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrangeByScoreWithScores(key, min, max, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, double max,
//       double min, int offset, int count) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(Tuple) zrevrangeByScoreWithScores(byte[] key, byte[] max,
//       byte[] min, int offset, int count) {
//     return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       Set!(Tuple) execute(Redis connection) {
//         return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zremrangeByRank(byte[] key, long start, long stop) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zremrangeByRank(key, start, stop);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zremrangeByScore(byte[] key, double min, double max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zremrangeByScore(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zremrangeByScore(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zremrangeByScore(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long linsert(byte[] key, ListPosition where, byte[] pivot,
//       byte[] value) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.linsert(key, where, pivot, value);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long lpushx(byte[] key, byte[] arg...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.lpushx(key, arg);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long rpushx(byte[] key, byte[] arg...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.rpushx(key, arg);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long del(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.del(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long unlink(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.unlink(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long unlink(byte[] keys...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.unlink(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   byte[] echo(byte[] arg) {
//     // note that it'll be run from arbitary node
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.echo(arg);
//       }
//     }.runBinary(arg);
//   }

//   override
//   Long bitcount(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.bitcount(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long bitcount(byte[] key, long start, long end) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.bitcount(key, start, end);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long pfadd(byte[] key, byte[] elements...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pfadd(key, elements);
//       }
//     }.runBinary(key);
//   }

//   override
//   long pfcount(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pfcount(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) srandmember(byte[] key, int count) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.srandmember(key, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zlexcount(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zlexcount(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByLex(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByLex(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrangeByLex(byte[] key, byte[] min, byte[] max,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrangeByLex(key, min, max, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByLex(byte[] key, byte[] max, byte[] min) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByLex(key, max, min);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) zrevrangeByLex(byte[] key, byte[] max, byte[] min,
//       int offset, int count) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.zrevrangeByLex(key, max, min, offset, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long zremrangeByLex(byte[] key, byte[] min, byte[] max) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zremrangeByLex(key, min, max);
//       }
//     }.runBinary(key);
//   }

//   override
//   Object eval(byte[] script, byte[] keyCount, byte[] params...) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.eval(script, keyCount, params);
//       }
//     }.runBinary(Integer.parseInt(SafeEncoder.encode(keyCount)), params);
//   }

//   override
//   Object eval(byte[] script, int keyCount, byte[] params...) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.eval(script, keyCount, params);
//       }
//     }.runBinary(keyCount, params);
//   }

//   override
//   Object eval(byte[] script, List!(byte[]) keys, List!(byte[]) args) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.eval(script, keys, args);
//       }
//     }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
//   }

//   override
//   Object eval(byte[] script, byte[] sampleKey) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.eval(script);
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   Object evalsha(byte[] sha1, byte[] sampleKey) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.evalsha(sha1);
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   Object evalsha(byte[] sha1, List!(byte[]) keys, List!(byte[]) args) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.evalsha(sha1, keys, args);
//       }
//     }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
//   }

//   override
//   Object evalsha(byte[] sha1, int keyCount, byte[] params...) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection) {
//         return connection.evalsha(sha1, keyCount, params);
//       }
//     }.runBinary(keyCount, params);
//   }

//   override
//   List!(Long) scriptExists(byte[] sampleKey, byte[] sha1...) {
//     return new RedisClusterCommand!(List!(Long))(connectionHandler, maxAttempts) {
//       override
//       List!(Long) execute(Redis connection) {
//         return connection.scriptExists(sha1);
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   byte[] scriptLoad(byte[] script, byte[] sampleKey) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.scriptLoad(script);
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   string scriptFlush(byte[] sampleKey) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.scriptFlush();
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   string scriptKill(byte[] sampleKey) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.scriptKill();
//       }
//     }.runBinary(sampleKey);
//   }

//   override
//   Long del(byte[] keys...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.del(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   List!(byte[]) blpop(int timeout, byte[] keys...) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.blpop(timeout, keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   List!(byte[]) brpop(int timeout, byte[] keys...) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.brpop(timeout, keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   List!(byte[]) mget(byte[] keys...) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.mget(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   string mset(byte[] keysvalues...) {
//     byte[][] keys = new byte[keysvalues.length / 2][];

//     for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
//       keys[keyIdx] = keysvalues[keyIdx * 2];
//     }

//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.mset(keysvalues);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long msetnx(byte[] keysvalues...) {
//     byte[][] keys = new byte[keysvalues.length / 2][];

//     for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
//       keys[keyIdx] = keysvalues[keyIdx * 2];
//     }

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.msetnx(keysvalues);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   string rename(byte[] oldkey, byte[] newkey) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.rename(oldkey, newkey);
//       }
//     }.runBinary(2, oldkey, newkey);
//   }

//   override
//   Long renamenx(byte[] oldkey, byte[] newkey) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.renamenx(oldkey, newkey);
//       }
//     }.runBinary(2, oldkey, newkey);
//   }

//   override
//   byte[] rpoplpush(byte[] srckey, byte[] dstkey) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.rpoplpush(srckey, dstkey);
//       }
//     }.runBinary(2, srckey, dstkey);
//   }

//   override
//   Set!(byte[]) sdiff(byte[] keys...) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.sdiff(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long sdiffstore(byte[] dstkey, byte[] keys...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sdiffstore(dstkey, keys);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Set!(byte[]) sinter(byte[] keys...) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.sinter(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long sinterstore(byte[] dstkey, byte[] keys...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sinterstore(dstkey, keys);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long smove(byte[] srckey, byte[] dstkey, byte[] member) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.smove(srckey, dstkey, member);
//       }
//     }.runBinary(2, srckey, dstkey);
//   }

//   override
//   Long sort(byte[] key, SortingParams sortingParameters, byte[] dstkey) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sort(key, sortingParameters, dstkey);
//       }
//     }.runBinary(2, key, dstkey);
//   }

//   override
//   Long sort(byte[] key, byte[] dstkey) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sort(key, dstkey);
//       }
//     }.runBinary(2, key, dstkey);
//   }

//   override
//   Set!(byte[]) sunion(byte[] keys...) {
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.sunion(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long sunionstore(byte[] dstkey, byte[] keys...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.sunionstore(dstkey, keys);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long zinterstore(byte[] dstkey, byte[] sets...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zinterstore(dstkey, sets);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long zinterstore(byte[] dstkey, ZParams params, byte[] sets...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zinterstore(dstkey, params, sets);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long zunionstore(byte[] dstkey, byte[] sets...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zunionstore(dstkey, sets);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long zunionstore(byte[] dstkey, ZParams params, byte[] sets...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.zunionstore(dstkey, params, sets);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   byte[] brpoplpush(byte[] source, byte[] destination, int timeout) {
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.brpoplpush(source, destination, timeout);
//       }
//     }.runBinary(2, source, destination);
//   }

//   override
//   Long publish(byte[] channel, byte[] message) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.publish(channel, message);
//       }
//     }.runWithAnyNode();
//   }

//   override
//   void subscribe(BinaryRedisPubSub jedisPubSub, byte[] channels...) {
//     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
//       override
//       Integer execute(Redis connection) {
//         connection.subscribe(jedisPubSub, channels);
//         return 0;
//       }
//     }.runWithAnyNode();
//   }

//   override
//   void psubscribe(BinaryRedisPubSub jedisPubSub, byte[] patterns...) {
//     new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
//       override
//       Integer execute(Redis connection) {
//         connection.psubscribe(jedisPubSub, patterns);
//         return 0;
//       }
//     }.runWithAnyNode();
//   }

//   override
//   Long bitop(BitOP op, byte[] destKey, byte[] srcKeys...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(destKey, srcKeys);

//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.bitop(op, destKey, srcKeys);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   string pfmerge(byte[] destkey, byte[] sourcekeys...) {
//     byte[][] wholeKeys = KeyMergeUtil.merge(destkey, sourcekeys);

//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.pfmerge(destkey, sourcekeys);
//       }
//     }.runBinary(wholeKeys.length, wholeKeys);
//   }

//   override
//   Long pfcount(byte[] keys...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.pfcount(keys);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long geoadd(byte[] key, double longitude, double latitude,
//       byte[] member) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.geoadd(key, longitude, latitude, member);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.geoadd(key, memberCoordinateMap);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double geodist(byte[] key, byte[] member1, byte[] member2) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.geodist(key, member1, member2);
//       }
//     }.runBinary(key);
//   }

//   override
//   Double geodist(byte[] key, byte[] member1, byte[] member2,
//       GeoUnit unit) {
//     return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
//       override
//       Double execute(Redis connection) {
//         return connection.geodist(key, member1, member2, unit);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) geohash(byte[] key, byte[] members...) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.geohash(key, members);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoCoordinate) geopos(byte[] key, byte[] members...) {
//     return new RedisClusterCommand!(List!(GeoCoordinate))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoCoordinate) execute(Redis connection) {
//         return connection.geopos(key, members);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadius(byte[] key, double longitude,
//       double latitude, double radius, GeoUnit unit) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadius(key, longitude, latitude, radius, unit);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusReadonly(byte[] key, double longitude,
//       double latitude, double radius, GeoUnit unit) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusReadonly(key, longitude, latitude, radius, unit);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadius(byte[] key, double longitude,
//       double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadius(key, longitude, latitude, radius, unit, param);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusReadonly(byte[] key, double longitude,
//       double latitude, double radius, GeoUnit unit, GeoRadiusParam param) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusReadonly(key, longitude, latitude, radius, unit, param);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusByMember(byte[] key, byte[] member,
//       double radius, GeoUnit unit) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusByMember(key, member, radius, unit);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusByMemberReadonly(byte[] key, byte[] member,
//       double radius, GeoUnit unit) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusByMemberReadonly(key, member, radius, unit);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusByMember(byte[] key, byte[] member,
//       double radius, GeoUnit unit, GeoRadiusParam param) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusByMember(key, member, radius, unit, param);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(GeoRadiusResponse) georadiusByMemberReadonly(byte[] key, byte[] member,
//       double radius, GeoUnit unit, GeoRadiusParam param) {
//     return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
//       override
//       List!(GeoRadiusResponse) execute(Redis connection) {
//         return connection.georadiusByMemberReadonly(key, member, radius, unit, param);
//       }
//     }.runBinary(key);
//   }

//   override
//   Set!(byte[]) keys(byte[] pattern) {
//     if (pattern is null || pattern.length == 0) {
//       throw new IllegalArgumentException(this.getClass().getSimpleName()
//           ~ " only supports KEYS commands with non-empty patterns");
//     }
//     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(pattern)) {
//       throw new IllegalArgumentException(this.getClass().getSimpleName()
//           ~ " only supports KEYS commands with patterns containing hash-tags ( curly-brackets enclosed strings )");
//     }
//     return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       Set!(byte[]) execute(Redis connection) {
//         return connection.keys(pattern);
//       }
//     }.runBinary(pattern);
//   }

//   override
//   ScanResult!(byte[]) scan(byte[] cursor, ScanParams params) {

//     byte[] matchPattern = null;

//     if (params is null || (matchPattern = params.binaryMatch()) is null || matchPattern.length == 0) {
//       throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
//           ~ " only supports SCAN commands with non-empty MATCH patterns");
//     }

//     if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(matchPattern)) {
//       throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
//           ~ " only supports SCAN commands with MATCH patterns containing hash-tags ( curly-brackets enclosed strings )");
//     }

//     return new RedisClusterCommand!( ScanResult!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       ScanResult!(byte[]) execute(Redis connection) {
//         return connection.scan(cursor, params);
//       }
//     }.runBinary(matchPattern);
//   }
  
//   override
//   ScanResult!(MapEntry!(byte[], byte[])) hscan(byte[] key, byte[] cursor) {
//     return new RedisClusterCommand!(ScanResult!(MapEntry!(byte[], byte[])))(connectionHandler,
//                                                                           maxAttempts) {
//       override
//       ScanResult!(MapEntry!(byte[], byte[])) execute(Redis connection) {
//         return connection.hscan(key, cursor);
//       }
//     }.runBinary(key);
//   }

//   override
//   ScanResult!(MapEntry!(byte[], byte[])) hscan(byte[] key, byte[] cursor,
//       ScanParams params) {
//     return new RedisClusterCommand!(ScanResult!(MapEntry!(byte[], byte[])))(connectionHandler,
//                                                                           maxAttempts) {
//       override
//       ScanResult!(MapEntry!(byte[], byte[])) execute(Redis connection) {
//         return connection.hscan(key, cursor, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   ScanResult!(byte[]) sscan(byte[] key, byte[] cursor) {
//     return new RedisClusterCommand!(ScanResult!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       ScanResult!(byte[]) execute(Redis connection) {
//         return connection.sscan(key, cursor);
//       }
//     }.runBinary(key);
//   }

//   override
//   ScanResult!(byte[]) sscan(byte[] key, byte[] cursor, ScanParams params) {
//     return new RedisClusterCommand!(ScanResult!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       ScanResult!(byte[]) execute(Redis connection) {
//         return connection.sscan(key, cursor, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   ScanResult!(Tuple) zscan(byte[] key, byte[] cursor) {
//     return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       ScanResult!(Tuple) execute(Redis connection) {
//         return connection.zscan(key, cursor);
//       }
//     }.runBinary(key);
//   }

//   override
//   ScanResult!(Tuple) zscan(byte[] key, byte[] cursor, ScanParams params) {
//     return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
//       override
//       ScanResult!(Tuple) execute(Redis connection) {
//         return connection.zscan(key, cursor, params);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(Long) bitfield(byte[] key, byte[] arguments...) {
//     return new RedisClusterCommand!(List!(Long))(connectionHandler, maxAttempts) {
//       override
//       List!(Long) execute(Redis connection) {
//         return connection.bitfield(key, arguments);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long hstrlen(byte[] key, byte[] field) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.hstrlen(key, field);
//       }
//     }.runBinary(key);
//   }
  
//   override
//   byte[] xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength){
//     return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
//       override
//       byte[] execute(Redis connection) {
//         return connection.xadd(key, id, hash, maxLen, approximateLength);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long xlen(byte[] key) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.xlen(key);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) xrange(byte[] key, byte[] start, byte[] end, long count) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xrange(key, start, end, count);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) xrevrange(byte[] key, byte[] end, byte[] start, int count) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xrevrange(key, end, start, count);
//       }
//     }.runBinary(key);  
//   }

//   override
//   List!(byte[]) xread(int count, long block, Map!(byte[], byte[]) streams) {
//     byte[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
    
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xread(count, block, streams);
//       }
//     }.runBinary(keys.length, keys);  
//   }

//   override
//   Long xack(byte[] key, byte[] group, byte[] ids...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.xack(key, group, ids);
//       }
//     }.runBinary(key);   
//   }

//   override
//   string xgroupCreate(byte[] key, byte[] consumer, byte[] id, bool makeStream) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.xgroupCreate(key, consumer, id, makeStream);
//       }
//     }.runBinary(key);  
//   }

//   override
//   string xgroupSetID(byte[] key, byte[] consumer, byte[] id) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.xgroupSetID(key, consumer, id);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long xgroupDestroy(byte[] key, byte[] consumer) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.xgroupDestroy(key, consumer);
//       }
//     }.runBinary(key);
//   }

//   override
//   string xgroupDelConsumer(byte[] key, byte[] consumer, byte[] consumerName) {
//     return new RedisClusterCommand!(string)(connectionHandler, maxAttempts) {
//       override
//       string execute(Redis connection) {
//         return connection.xgroupDelConsumer(key, consumer, consumerName);
//       }
//     }.runBinary(key);
//   }

//   override
//     List!(byte[]) xreadGroup(byte[] groupname, byte[] consumer, int count, long block, 
//       bool noAck, Map!(byte[], byte[]) streams){
    
//     byte[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
    
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xreadGroup(groupname, consumer, count, block, noAck, streams);
//       }
//     }.runBinary(keys.length, keys);
//   }

//   override
//   Long xdel(byte[] key, byte[] ids...) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.xdel(key, ids);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long xtrim(byte[] key, long maxLen, bool approximateLength) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.xtrim(key, maxLen, approximateLength);
//       }
//     }.runBinary(key);
//   }
  
//   override
//   List!(byte[]) xpending(byte[] key, byte[] groupname, byte[] start, byte[] end, 
//       int count, byte[] consumername) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xpending(key, groupname, start, end, count, consumername);
//       }
//     }.runBinary(key);
//   }

//   override
//   List!(byte[]) xclaim(byte[] key, byte[] groupname, byte[] consumername, 
//       long minIdleTime, long newIdleTime, int retries, bool force, byte[][] ids) {
//     return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
//       override
//       List!(byte[]) execute(Redis connection) {
//         return connection.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
//       }
//     }.runBinary(key);
//   }

//   override
//   Long waitReplicas(byte[] key, int replicas, long timeout) {
//     return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
//       override
//       Long execute(Redis connection) {
//         return connection.waitReplicas(replicas, timeout);
//       }
//     }.runBinary(key);
//   }

//   override
//   Object sendCommand(byte[] sampleKey, ProtocolCommand cmd, byte[] args...) {
//     return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
//       override
//       Object execute(Redis connection){
//         return connection.sendCommand(cmd, args);
//       }
//     }.runBinary(sampleKey);
//   }
// }
