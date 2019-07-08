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

import java.io.Closeable;
import hunt.collection.Collection;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

class BinaryRedisCluster : BinaryRedisClusterCommands,
    MultiKeyBinaryRedisClusterCommands, RedisClusterBinaryScriptingCommands, Closeable {

  enum int HASHSLOTS = 16384;
  protected enum int DEFAULT_TIMEOUT = 2000;
  protected enum int DEFAULT_MAX_ATTEMPTS = 5;

  protected int maxAttempts;

  protected RedisClusterConnectionHandler connectionHandler;

  BinaryRedisCluster(Set!(HostAndPort) nodes, int timeout) {
    this(nodes, timeout, DEFAULT_MAX_ATTEMPTS, new GenericObjectPoolConfig());
  }

  BinaryRedisCluster(Set!(HostAndPort) nodes) {
    this(nodes, DEFAULT_TIMEOUT);
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int timeout, int maxAttempts,
      final GenericObjectPoolConfig poolConfig) {
    this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
        timeout);
    this.maxAttempts = maxAttempts;
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int connectionTimeout,
                            int soTimeout, int maxAttempts, final GenericObjectPoolConfig poolConfig) {
    this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
        connectionTimeout, soTimeout);
    this.maxAttempts = maxAttempts;
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, String password, GenericObjectPoolConfig poolConfig) {
    this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
            connectionTimeout, soTimeout, password);
    this.maxAttempts = maxAttempts;
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, String password, String clientName, GenericObjectPoolConfig poolConfig) {
    this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
            connectionTimeout, soTimeout, password, clientName);
    this.maxAttempts = maxAttempts;
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, String password, String clientName, GenericObjectPoolConfig poolConfig,
      bool ssl) {
    this(jedisClusterNode, connectionTimeout, soTimeout, maxAttempts, password, clientName, poolConfig, ssl, null, null, null, null);
  }

  BinaryRedisCluster(Set!(HostAndPort) jedisClusterNode, int connectionTimeout, int soTimeout, int maxAttempts, String password, String clientName, GenericObjectPoolConfig poolConfig,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
    this.connectionHandler = new RedisSlotBasedConnectionHandler(jedisClusterNode, poolConfig,
        connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier, hostAndPortMap);
    this.maxAttempts = maxAttempts;
  }

  override
  void close() {
    if (connectionHandler != null) {
      connectionHandler.close();
    }
  }

  Map!(String, RedisPool) getClusterNodes() {
    return connectionHandler.getNodes();
  }

  Redis getConnectionFromSlot(int slot) {
	  return  this.connectionHandler.getConnectionFromSlot(slot);
  }

  override
  String set(final byte[] key, final byte[] value) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.set(key, value);
      }
    }.runBinary(key);
  }

  override
  String set(final byte[] key, final byte[] value, final SetParams params) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.set(key, value, params);
      }
    }.runBinary(key);
  }

  override
  byte[] get(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.get(key);
      }
    }.runBinary(key);
  }

  override
  Long exists(final byte[] keys...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.exists(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Boolean exists(final byte[] key) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.exists(key);
      }
    }.runBinary(key);
  }

  override
  Long persist(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.persist(key);
      }
    }.runBinary(key);
  }

  override
  String type(final byte[] key) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.type(key);
      }
    }.runBinary(key);
  }

  override
  byte[] dump(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.dump(key);
      }
    }.runBinary(key);
  }

  override
  String restore(final byte[] key, final int ttl, final byte[] serializedValue) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.restore(key, ttl, serializedValue);
      }
    }.runBinary(key);
  }

  override
  Long expire(final byte[] key, final int seconds) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.expire(key, seconds);
      }
    }.runBinary(key);
  }

  override
  Long pexpire(final byte[] key, final long milliseconds) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pexpire(key, milliseconds);
      }
    }.runBinary(key);
  }

  override
  Long expireAt(final byte[] key, final long unixTime) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.expireAt(key, unixTime);
      }
    }.runBinary(key);
  }

  override
  Long pexpireAt(final byte[] key, final long millisecondsTimestamp) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pexpireAt(key, millisecondsTimestamp);
      }
    }.runBinary(key);
  }

  override
  Long ttl(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.ttl(key);
      }
    }.runBinary(key);
  }

  override
  Long pttl(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pttl(key);
      }
    }.runBinary(key);
  }

  override
  Long touch(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.touch(key);
      }
    }.runBinary(key);
  }

  override
  Long touch(final byte[] keys...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.touch(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Boolean setbit(final byte[] key, final long offset, final bool value) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.setbit(key, offset, value);
      }
    }.runBinary(key);
  }

  override
  Boolean setbit(final byte[] key, final long offset, final byte[] value) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.setbit(key, offset, value);
      }
    }.runBinary(key);
  }

  override
  Boolean getbit(final byte[] key, final long offset) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.getbit(key, offset);
      }
    }.runBinary(key);
  }

  override
  Long setrange(final byte[] key, final long offset, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.setrange(key, offset, value);
      }
    }.runBinary(key);
  }

  override
  byte[] getrange(final byte[] key, final long startOffset, final long endOffset) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.getrange(key, startOffset, endOffset);
      }
    }.runBinary(key);
  }

  override
  byte[] getSet(final byte[] key, final byte[] value) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.getSet(key, value);
      }
    }.runBinary(key);
  }

  override
  Long setnx(final byte[] key, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.setnx(key, value);
      }
    }.runBinary(key);
  }

  override
  String psetex(final byte[] key, final long milliseconds, final byte[] value) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.psetex(key, milliseconds, value);
      }
    }.runBinary(key);
  }

  override
  String setex(final byte[] key, final int seconds, final byte[] value) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.setex(key, seconds, value);
      }
    }.runBinary(key);
  }

  override
  Long decrBy(final byte[] key, final long decrement) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.decrBy(key, decrement);
      }
    }.runBinary(key);
  }

  override
  Long decr(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.decr(key);
      }
    }.runBinary(key);
  }

  override
  Long incrBy(final byte[] key, final long increment) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.incrBy(key, increment);
      }
    }.runBinary(key);
  }

  override
  Double incrByFloat(final byte[] key, final double increment) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.incrByFloat(key, increment);
      }
    }.runBinary(key);
  }

  override
  Long incr(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.incr(key);
      }
    }.runBinary(key);
  }

  override
  Long append(final byte[] key, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.append(key, value);
      }
    }.runBinary(key);
  }

  override
  byte[] substr(final byte[] key, final int start, final int end) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.substr(key, start, end);
      }
    }.runBinary(key);
  }

  override
  Long hset(final byte[] key, final byte[] field, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hset(key, field, value);
      }
    }.runBinary(key);
  }

  override
  Long hset(final byte[] key, final Map!(byte[], byte[]) hash) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hset(key, hash);
      }
    }.runBinary(key);
  }

  override
  byte[] hget(final byte[] key, final byte[] field) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.hget(key, field);
      }
    }.runBinary(key);
  }

  override
  Long hsetnx(final byte[] key, final byte[] field, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hsetnx(key, field, value);
      }
    }.runBinary(key);
  }

  override
  String hmset(final byte[] key, final Map!(byte[], byte[]) hash) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.hmset(key, hash);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) hmget(final byte[] key, final byte[] fields...) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.hmget(key, fields);
      }
    }.runBinary(key);
  }

  override
  Long hincrBy(final byte[] key, final byte[] field, final long value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hincrBy(key, field, value);
      }
    }.runBinary(key);
  }

  override
  Double hincrByFloat(final byte[] key, final byte[] field, final double value) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.hincrByFloat(key, field, value);
      }
    }.runBinary(key);
  }

  override
  Boolean hexists(final byte[] key, final byte[] field) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.hexists(key, field);
      }
    }.runBinary(key);
  }

  override
  Long hdel(final byte[] key, final byte[] field...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hdel(key, field);
      }
    }.runBinary(key);
  }

  override
  Long hlen(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hlen(key);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) hkeys(final byte[] key) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.hkeys(key);
      }
    }.runBinary(key);
  }

  override
  Collection!(byte[]) hvals(final byte[] key) {
    return new RedisClusterCommand!(Collection!(byte[]))(connectionHandler, maxAttempts) {
      override
      Collection!(byte[]) execute(Redis connection) {
        return connection.hvals(key);
      }
    }.runBinary(key);
  }

  override
  Map!(byte[], byte[]) hgetAll(final byte[] key) {
    return new RedisClusterCommand!(Map!(byte[], byte[]))(connectionHandler, maxAttempts) {
      override
      Map!(byte[], byte[]) execute(Redis connection) {
        return connection.hgetAll(key);
      }
    }.runBinary(key);
  }

  override
  Long rpush(final byte[] key, final byte[] args...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.rpush(key, args);
      }
    }.runBinary(key);
  }

  override
  Long lpush(final byte[] key, final byte[] args...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.lpush(key, args);
      }
    }.runBinary(key);
  }

  override
  Long llen(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.llen(key);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) lrange(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.lrange(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  String ltrim(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.ltrim(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  byte[] lindex(final byte[] key, final long index) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.lindex(key, index);
      }
    }.runBinary(key);
  }

  override
  String lset(final byte[] key, final long index, final byte[] value) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.lset(key, index, value);
      }
    }.runBinary(key);
  }

  override
  Long lrem(final byte[] key, final long count, final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.lrem(key, count, value);
      }
    }.runBinary(key);
  }

  override
  byte[] lpop(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.lpop(key);
      }
    }.runBinary(key);
  }

  override
  byte[] rpop(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.rpop(key);
      }
    }.runBinary(key);
  }

  override
  Long sadd(final byte[] key, final byte[] member...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sadd(key, member);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) smembers(final byte[] key) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.smembers(key);
      }
    }.runBinary(key);
  }

  override
  Long srem(final byte[] key, final byte[] member...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.srem(key, member);
      }
    }.runBinary(key);
  }

  override
  byte[] spop(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.spop(key);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) spop(final byte[] key, final long count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.spop(key, count);
      }
    }.runBinary(key);
  }

  override
  Long scard(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.scard(key);
      }
    }.runBinary(key);
  }

  override
  Boolean sismember(final byte[] key, final byte[] member) {
    return new RedisClusterCommand!(Boolean)(connectionHandler, maxAttempts) {
      override
      Boolean execute(Redis connection) {
        return connection.sismember(key, member);
      }
    }.runBinary(key);
  }

  override
  byte[] srandmember(final byte[] key) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.srandmember(key);
      }
    }.runBinary(key);
  }

  override
  Long strlen(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.strlen(key);
      }
    }.runBinary(key);
  }

  override
  Long zadd(final byte[] key, final double score, final byte[] member) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zadd(key, score, member);
      }
    }.runBinary(key);
  }

  override
  Long zadd(final byte[] key, final double score, final byte[] member,
      final ZAddParams params) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zadd(key, score, member, params);
      }
    }.runBinary(key);
  }

  override
  Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zadd(key, scoreMembers);
      }
    }.runBinary(key);
  }

  override
  Long zadd(final byte[] key, final Map!(byte[], Double) scoreMembers, final ZAddParams params) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zadd(key, scoreMembers, params);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrange(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrange(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  Long zrem(final byte[] key, final byte[] members...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zrem(key, members);
      }
    }.runBinary(key);
  }

  override
  Double zincrby(final byte[] key, final double increment, final byte[] member) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.zincrby(key, increment, member);
      }
    }.runBinary(key);
  }

  override
  Double zincrby(final byte[] key, final double increment, final byte[] member,
      final ZIncrByParams params) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.zincrby(key, increment, member, params);
      }
    }.runBinary(key);
  }

  override
  Long zrank(final byte[] key, final byte[] member) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zrank(key, member);
      }
    }.runBinary(key);
  }

  override
  Long zrevrank(final byte[] key, final byte[] member) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zrevrank(key, member);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrange(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrange(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrangeWithScores(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrangeWithScores(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrevrangeWithScores(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrevrangeWithScores(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  Long zcard(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zcard(key);
      }
    }.runBinary(key);
  }

  override
  Double zscore(final byte[] key, final byte[] member) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.zscore(key, member);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) sort(final byte[] key) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.sort(key);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) sort(final byte[] key, final SortingParams sortingParameters) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.sort(key, sortingParameters);
      }
    }.runBinary(key);
  }

  override
  Long zcount(final byte[] key, final double min, final double max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zcount(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Long zcount(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zcount(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByScore(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByScore(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByScore(key, max, min);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final double min, final double max,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByScore(key, min, max, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByScore(key, max, min);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByScore(final byte[] key, final byte[] min, final byte[] max,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByScore(key, min, max, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final double max, final double min,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByScore(key, max, min, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrangeByScoreWithScores(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max, final double min) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrevrangeByScoreWithScores(key, max, min);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final double min, final double max,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrangeByScoreWithScores(key, min, max, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByScore(final byte[] key, final byte[] max, final byte[] min,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByScore(key, max, min, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrangeByScoreWithScores(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max, final byte[] min) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrevrangeByScoreWithScores(key, max, min);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrangeByScoreWithScores(final byte[] key, final byte[] min, final byte[] max,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrangeByScoreWithScores(key, min, max, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final double max,
      final double min, final int offset, final int count) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(Tuple) zrevrangeByScoreWithScores(final byte[] key, final byte[] max,
      final byte[] min, final int offset, final int count) {
    return new RedisClusterCommand!(Set!(Tuple))(connectionHandler, maxAttempts) {
      override
      Set!(Tuple) execute(Redis connection) {
        return connection.zrevrangeByScoreWithScores(key, max, min, offset, count);
      }
    }.runBinary(key);
  }

  override
  Long zremrangeByRank(final byte[] key, final long start, final long stop) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zremrangeByRank(key, start, stop);
      }
    }.runBinary(key);
  }

  override
  Long zremrangeByScore(final byte[] key, final double min, final double max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zremrangeByScore(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Long zremrangeByScore(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zremrangeByScore(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Long linsert(final byte[] key, final ListPosition where, final byte[] pivot,
      final byte[] value) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.linsert(key, where, pivot, value);
      }
    }.runBinary(key);
  }

  override
  Long lpushx(final byte[] key, final byte[] arg...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.lpushx(key, arg);
      }
    }.runBinary(key);
  }

  override
  Long rpushx(final byte[] key, final byte[] arg...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.rpushx(key, arg);
      }
    }.runBinary(key);
  }

  override
  Long del(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.del(key);
      }
    }.runBinary(key);
  }

  override
  Long unlink(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.unlink(key);
      }
    }.runBinary(key);
  }

  override
  Long unlink(final byte[] keys...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.unlink(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  byte[] echo(final byte[] arg) {
    // note that it'll be run from arbitary node
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.echo(arg);
      }
    }.runBinary(arg);
  }

  override
  Long bitcount(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.bitcount(key);
      }
    }.runBinary(key);
  }

  override
  Long bitcount(final byte[] key, final long start, final long end) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.bitcount(key, start, end);
      }
    }.runBinary(key);
  }

  override
  Long pfadd(final byte[] key, final byte[] elements...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pfadd(key, elements);
      }
    }.runBinary(key);
  }

  override
  long pfcount(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pfcount(key);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) srandmember(final byte[] key, final int count) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.srandmember(key, count);
      }
    }.runBinary(key);
  }

  override
  Long zlexcount(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zlexcount(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByLex(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrangeByLex(final byte[] key, final byte[] min, final byte[] max,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrangeByLex(key, min, max, offset, count);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByLex(key, max, min);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) zrevrangeByLex(final byte[] key, final byte[] max, final byte[] min,
      final int offset, final int count) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.zrevrangeByLex(key, max, min, offset, count);
      }
    }.runBinary(key);
  }

  override
  Long zremrangeByLex(final byte[] key, final byte[] min, final byte[] max) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zremrangeByLex(key, min, max);
      }
    }.runBinary(key);
  }

  override
  Object eval(final byte[] script, final byte[] keyCount, final byte[] params...) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.eval(script, keyCount, params);
      }
    }.runBinary(Integer.parseInt(SafeEncoder.encode(keyCount)), params);
  }

  override
  Object eval(final byte[] script, final int keyCount, final byte[] params...) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.eval(script, keyCount, params);
      }
    }.runBinary(keyCount, params);
  }

  override
  Object eval(final byte[] script, final List!(byte[]) keys, final List!(byte[]) args) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.eval(script, keys, args);
      }
    }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
  }

  override
  Object eval(final byte[] script, final byte[] sampleKey) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.eval(script);
      }
    }.runBinary(sampleKey);
  }

  override
  Object evalsha(final byte[] sha1, final byte[] sampleKey) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.evalsha(sha1);
      }
    }.runBinary(sampleKey);
  }

  override
  Object evalsha(final byte[] sha1, final List!(byte[]) keys, final List!(byte[]) args) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.evalsha(sha1, keys, args);
      }
    }.runBinary(keys.size(), keys.toArray(new byte[keys.size()][]));
  }

  override
  Object evalsha(final byte[] sha1, final int keyCount, final byte[] params...) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection) {
        return connection.evalsha(sha1, keyCount, params);
      }
    }.runBinary(keyCount, params);
  }

  override
  List!(Long) scriptExists(final byte[] sampleKey, final byte[] sha1...) {
    return new RedisClusterCommand!(List!(Long))(connectionHandler, maxAttempts) {
      override
      List!(Long) execute(Redis connection) {
        return connection.scriptExists(sha1);
      }
    }.runBinary(sampleKey);
  }

  override
  byte[] scriptLoad(final byte[] script, final byte[] sampleKey) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.scriptLoad(script);
      }
    }.runBinary(sampleKey);
  }

  override
  String scriptFlush(final byte[] sampleKey) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.scriptFlush();
      }
    }.runBinary(sampleKey);
  }

  override
  String scriptKill(final byte[] sampleKey) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.scriptKill();
      }
    }.runBinary(sampleKey);
  }

  override
  Long del(final byte[] keys...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.del(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  List!(byte[]) blpop(final int timeout, final byte[] keys...) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.blpop(timeout, keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  List!(byte[]) brpop(final int timeout, final byte[] keys...) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.brpop(timeout, keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  List!(byte[]) mget(final byte[] keys...) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.mget(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  String mset(final byte[] keysvalues...) {
    byte[][] keys = new byte[keysvalues.length / 2][];

    for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
      keys[keyIdx] = keysvalues[keyIdx * 2];
    }

    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.mset(keysvalues);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long msetnx(final byte[] keysvalues...) {
    byte[][] keys = new byte[keysvalues.length / 2][];

    for (int keyIdx = 0; keyIdx < keys.length; keyIdx++) {
      keys[keyIdx] = keysvalues[keyIdx * 2];
    }

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.msetnx(keysvalues);
      }
    }.runBinary(keys.length, keys);
  }

  override
  String rename(final byte[] oldkey, final byte[] newkey) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.rename(oldkey, newkey);
      }
    }.runBinary(2, oldkey, newkey);
  }

  override
  Long renamenx(final byte[] oldkey, final byte[] newkey) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.renamenx(oldkey, newkey);
      }
    }.runBinary(2, oldkey, newkey);
  }

  override
  byte[] rpoplpush(final byte[] srckey, final byte[] dstkey) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.rpoplpush(srckey, dstkey);
      }
    }.runBinary(2, srckey, dstkey);
  }

  override
  Set!(byte[]) sdiff(final byte[] keys...) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.sdiff(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long sdiffstore(final byte[] dstkey, final byte[] keys...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sdiffstore(dstkey, keys);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Set!(byte[]) sinter(final byte[] keys...) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.sinter(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long sinterstore(final byte[] dstkey, final byte[] keys...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sinterstore(dstkey, keys);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long smove(final byte[] srckey, final byte[] dstkey, final byte[] member) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.smove(srckey, dstkey, member);
      }
    }.runBinary(2, srckey, dstkey);
  }

  override
  Long sort(final byte[] key, final SortingParams sortingParameters, final byte[] dstkey) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sort(key, sortingParameters, dstkey);
      }
    }.runBinary(2, key, dstkey);
  }

  override
  Long sort(final byte[] key, final byte[] dstkey) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sort(key, dstkey);
      }
    }.runBinary(2, key, dstkey);
  }

  override
  Set!(byte[]) sunion(final byte[] keys...) {
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.sunion(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long sunionstore(final byte[] dstkey, final byte[] keys...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, keys);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.sunionstore(dstkey, keys);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long zinterstore(final byte[] dstkey, final byte[] sets...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zinterstore(dstkey, sets);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long zinterstore(final byte[] dstkey, final ZParams params, final byte[] sets...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zinterstore(dstkey, params, sets);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long zunionstore(final byte[] dstkey, final byte[] sets...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zunionstore(dstkey, sets);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long zunionstore(final byte[] dstkey, final ZParams params, final byte[] sets...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(dstkey, sets);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.zunionstore(dstkey, params, sets);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  byte[] brpoplpush(final byte[] source, final byte[] destination, final int timeout) {
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.brpoplpush(source, destination, timeout);
      }
    }.runBinary(2, source, destination);
  }

  override
  Long publish(final byte[] channel, final byte[] message) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.publish(channel, message);
      }
    }.runWithAnyNode();
  }

  override
  void subscribe(final BinaryRedisPubSub jedisPubSub, final byte[] channels...) {
    new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
      override
      Integer execute(Redis connection) {
        connection.subscribe(jedisPubSub, channels);
        return 0;
      }
    }.runWithAnyNode();
  }

  override
  void psubscribe(final BinaryRedisPubSub jedisPubSub, final byte[] patterns...) {
    new RedisClusterCommand!(Integer)(connectionHandler, maxAttempts) {
      override
      Integer execute(Redis connection) {
        connection.psubscribe(jedisPubSub, patterns);
        return 0;
      }
    }.runWithAnyNode();
  }

  override
  Long bitop(final BitOP op, final byte[] destKey, final byte[] srcKeys...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(destKey, srcKeys);

    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.bitop(op, destKey, srcKeys);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  String pfmerge(final byte[] destkey, final byte[] sourcekeys...) {
    byte[][] wholeKeys = KeyMergeUtil.merge(destkey, sourcekeys);

    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.pfmerge(destkey, sourcekeys);
      }
    }.runBinary(wholeKeys.length, wholeKeys);
  }

  override
  Long pfcount(final byte[] keys...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.pfcount(keys);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long geoadd(final byte[] key, final double longitude, final double latitude,
      final byte[] member) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.geoadd(key, longitude, latitude, member);
      }
    }.runBinary(key);
  }

  override
  Long geoadd(final byte[] key, final Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.geoadd(key, memberCoordinateMap);
      }
    }.runBinary(key);
  }

  override
  Double geodist(final byte[] key, final byte[] member1, final byte[] member2) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.geodist(key, member1, member2);
      }
    }.runBinary(key);
  }

  override
  Double geodist(final byte[] key, final byte[] member1, final byte[] member2,
      final GeoUnit unit) {
    return new RedisClusterCommand!(Double)(connectionHandler, maxAttempts) {
      override
      Double execute(Redis connection) {
        return connection.geodist(key, member1, member2, unit);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) geohash(final byte[] key, final byte[] members...) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.geohash(key, members);
      }
    }.runBinary(key);
  }

  override
  List!(GeoCoordinate) geopos(final byte[] key, final byte[] members...) {
    return new RedisClusterCommand!(List!(GeoCoordinate))(connectionHandler, maxAttempts) {
      override
      List!(GeoCoordinate) execute(Redis connection) {
        return connection.geopos(key, members);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude,
      final double latitude, final double radius, final GeoUnit unit) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadius(key, longitude, latitude, radius, unit);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude,
      final double latitude, final double radius, final GeoUnit unit) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusReadonly(key, longitude, latitude, radius, unit);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadius(final byte[] key, final double longitude,
      final double latitude, final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadius(key, longitude, latitude, radius, unit, param);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusReadonly(final byte[] key, final double longitude,
      final double latitude, final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusReadonly(key, longitude, latitude, radius, unit, param);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member,
      final double radius, final GeoUnit unit) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusByMember(key, member, radius, unit);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member,
      final double radius, final GeoUnit unit) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusByMemberReadonly(key, member, radius, unit);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusByMember(final byte[] key, final byte[] member,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusByMember(key, member, radius, unit, param);
      }
    }.runBinary(key);
  }

  override
  List!(GeoRadiusResponse) georadiusByMemberReadonly(final byte[] key, final byte[] member,
      final double radius, final GeoUnit unit, final GeoRadiusParam param) {
    return new RedisClusterCommand!(List!(GeoRadiusResponse))(connectionHandler, maxAttempts) {
      override
      List!(GeoRadiusResponse) execute(Redis connection) {
        return connection.georadiusByMemberReadonly(key, member, radius, unit, param);
      }
    }.runBinary(key);
  }

  override
  Set!(byte[]) keys(final byte[] pattern) {
    if (pattern == null || pattern.length == 0) {
      throw new IllegalArgumentException(this.getClass().getSimpleName()
          + " only supports KEYS commands with non-empty patterns");
    }
    if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(pattern)) {
      throw new IllegalArgumentException(this.getClass().getSimpleName()
          + " only supports KEYS commands with patterns containing hash-tags ( curly-brackets enclosed strings )");
    }
    return new RedisClusterCommand!(Set!(byte[]))(connectionHandler, maxAttempts) {
      override
      Set!(byte[]) execute(Redis connection) {
        return connection.keys(pattern);
      }
    }.runBinary(pattern);
  }

  override
  ScanResult!(byte[]) scan(final byte[] cursor, final ScanParams params) {

    byte[] matchPattern = null;

    if (params == null || (matchPattern = params.binaryMatch()) == null || matchPattern.length == 0) {
      throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
          + " only supports SCAN commands with non-empty MATCH patterns");
    }

    if (!RedisClusterHashTagUtil.isClusterCompliantMatchPattern(matchPattern)) {
      throw new IllegalArgumentException(BinaryRedisCluster.class.getSimpleName()
          + " only supports SCAN commands with MATCH patterns containing hash-tags ( curly-brackets enclosed strings )");
    }

    return new RedisClusterCommand!( ScanResult!(byte[]))(connectionHandler, maxAttempts) {
      override
      ScanResult!(byte[]) execute(Redis connection) {
        return connection.scan(cursor, params);
      }
    }.runBinary(matchPattern);
  }
  
  override
  ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor) {
    return new RedisClusterCommand<ScanResult<Map.Entry!(byte[], byte[])>>(connectionHandler,
                                                                          maxAttempts) {
      override
      ScanResult<Map.Entry!(byte[], byte[])> execute(Redis connection) {
        return connection.hscan(key, cursor);
      }
    }.runBinary(key);
  }

  override
  ScanResult<Map.Entry!(byte[], byte[])> hscan(final byte[] key, final byte[] cursor,
      final ScanParams params) {
    return new RedisClusterCommand<ScanResult<Map.Entry!(byte[], byte[])>>(connectionHandler,
                                                                          maxAttempts) {
      override
      ScanResult<Map.Entry!(byte[], byte[])> execute(Redis connection) {
        return connection.hscan(key, cursor, params);
      }
    }.runBinary(key);
  }

  override
  ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor) {
    return new RedisClusterCommand!(ScanResult!(byte[]))(connectionHandler, maxAttempts) {
      override
      ScanResult!(byte[]) execute(Redis connection) {
        return connection.sscan(key, cursor);
      }
    }.runBinary(key);
  }

  override
  ScanResult!(byte[]) sscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    return new RedisClusterCommand!(ScanResult!(byte[]))(connectionHandler, maxAttempts) {
      override
      ScanResult!(byte[]) execute(Redis connection) {
        return connection.sscan(key, cursor, params);
      }
    }.runBinary(key);
  }

  override
  ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor) {
    return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
      override
      ScanResult!(Tuple) execute(Redis connection) {
        return connection.zscan(key, cursor);
      }
    }.runBinary(key);
  }

  override
  ScanResult!(Tuple) zscan(final byte[] key, final byte[] cursor, final ScanParams params) {
    return new RedisClusterCommand!(ScanResult!(Tuple))(connectionHandler, maxAttempts) {
      override
      ScanResult!(Tuple) execute(Redis connection) {
        return connection.zscan(key, cursor, params);
      }
    }.runBinary(key);
  }

  override
  List!(Long) bitfield(final byte[] key, final byte[] arguments...) {
    return new RedisClusterCommand!(List!(Long))(connectionHandler, maxAttempts) {
      override
      List!(Long) execute(Redis connection) {
        return connection.bitfield(key, arguments);
      }
    }.runBinary(key);
  }

  override
  Long hstrlen(final byte[] key, final byte[] field) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.hstrlen(key, field);
      }
    }.runBinary(key);
  }
  
  override
  byte[] xadd(final byte[] key, final byte[] id, final Map!(byte[], byte[]) hash, final long maxLen, final bool approximateLength){
    return new RedisClusterCommand!(byte[])(connectionHandler, maxAttempts) {
      override
      byte[] execute(Redis connection) {
        return connection.xadd(key, id, hash, maxLen, approximateLength);
      }
    }.runBinary(key);
  }

  override
  Long xlen(final byte[] key) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.xlen(key);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) xrange(final byte[] key, final byte[] start, final byte[] end, final long count) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xrange(key, start, end, count);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) xrevrange(final byte[] key, final byte[] end, final byte[] start, final int count) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xrevrange(key, end, start, count);
      }
    }.runBinary(key);  
  }

  override
  List!(byte[]) xread(final int count, final long block, final Map!(byte[], byte[]) streams) {
    byte[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
    
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xread(count, block, streams);
      }
    }.runBinary(keys.length, keys);  
  }

  override
  Long xack(final byte[] key, final byte[] group, final byte[] ids...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.xack(key, group, ids);
      }
    }.runBinary(key);   
  }

  override
  String xgroupCreate(final byte[] key, final byte[] consumer, final byte[] id, final bool makeStream) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.xgroupCreate(key, consumer, id, makeStream);
      }
    }.runBinary(key);  
  }

  override
  String xgroupSetID(final byte[] key, final byte[] consumer, final byte[] id) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.xgroupSetID(key, consumer, id);
      }
    }.runBinary(key);
  }

  override
  Long xgroupDestroy(final byte[] key, final byte[] consumer) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.xgroupDestroy(key, consumer);
      }
    }.runBinary(key);
  }

  override
  String xgroupDelConsumer(final byte[] key, final byte[] consumer, final byte[] consumerName) {
    return new RedisClusterCommand!(String)(connectionHandler, maxAttempts) {
      override
      String execute(Redis connection) {
        return connection.xgroupDelConsumer(key, consumer, consumerName);
      }
    }.runBinary(key);
  }

  override
    List!(byte[]) xreadGroup(final byte[] groupname, final byte[] consumer, final int count, final long block, 
      final bool noAck, final Map!(byte[], byte[]) streams){
    
    byte[][] keys = streams.keySet().toArray(new byte[streams.size()][]);
    
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xreadGroup(groupname, consumer, count, block, noAck, streams);
      }
    }.runBinary(keys.length, keys);
  }

  override
  Long xdel(final byte[] key, final byte[] ids...) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.xdel(key, ids);
      }
    }.runBinary(key);
  }

  override
  Long xtrim(final byte[] key, final long maxLen, final bool approximateLength) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.xtrim(key, maxLen, approximateLength);
      }
    }.runBinary(key);
  }
  
  override
  List!(byte[]) xpending(final byte[] key, final byte[] groupname, final byte[] start, final byte[] end, 
      final int count, final byte[] consumername) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xpending(key, groupname, start, end, count, consumername);
      }
    }.runBinary(key);
  }

  override
  List!(byte[]) xclaim(final byte[] key, final byte[] groupname, final byte[] consumername, 
      final long minIdleTime, final long newIdleTime, final int retries, final bool force, final byte[][] ids) {
    return new RedisClusterCommand!(List!(byte[]))(connectionHandler, maxAttempts) {
      override
      List!(byte[]) execute(Redis connection) {
        return connection.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
      }
    }.runBinary(key);
  }

  override
  Long waitReplicas(final byte[] key, final int replicas, final long timeout) {
    return new RedisClusterCommand!(Long)(connectionHandler, maxAttempts) {
      override
      Long execute(Redis connection) {
        return connection.waitReplicas(replicas, timeout);
      }
    }.runBinary(key);
  }

  override
  Object sendCommand(final byte[] sampleKey, final ProtocolCommand cmd, final byte[] args...) {
    return new RedisClusterCommand!(Object)(connectionHandler, maxAttempts) {
      override
      Object execute(Redis connection){
        return connection.sendCommand(cmd, args);
      }
    }.runBinary(sampleKey);
  }
}
