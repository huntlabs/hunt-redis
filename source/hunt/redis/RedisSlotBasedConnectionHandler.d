module hunt.redis.RedisSlotBasedConnectionHandler;

import hunt.redis.RedisClusterConnectionHandler;

import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisPool;

import hunt.text.Common;

import hunt.collection.List;
import hunt.collection.Set;
import hunt.pool.impl.GenericObjectPoolConfig;


class RedisSlotBasedConnectionHandler : RedisClusterConnectionHandler {

  this(Set!(HostAndPort) nodes,
      GenericObjectPoolConfig poolConfig, int timeout) {
    this(nodes, poolConfig, timeout, timeout);
  }

  this(Set!(HostAndPort) nodes,
      GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, null);
  }

  this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, 
      int connectionTimeout, int soTimeout, string password) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, password);
  }

  this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, 
      int connectionTimeout, int soTimeout, string password, string clientName) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName);
  }

  // this(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, int connectionTimeout, 
  //       int soTimeout, string password, string clientName, 
  //       bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, 
  //       HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap portMap) {
          
  //   super(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, ssl, 
  //       sslSocketFactory, sslParameters, hostnameVerifier, portMap);
  // }

  override
  Redis getConnection() {
    // In antirez's redis-rb-cluster implementation,
    // getRandomConnection always return valid connection (able to
    // ping-pong)
    // or exception if all connections are invalid

    List!(RedisPool) pools = cache.getShuffledNodesPool();

    foreach(RedisPool pool ; pools) {
      Redis redis = null;
      try {
        redis = pool.getResource();

        if (redis is null) {
          continue;
        }

        string result = redis.ping();

        if (result.equalsIgnoreCase("pong")) return redis;

        redis.close();
      } catch (RedisException ex) {
        if (redis !is null) {
          redis.close();
        }
      }
    }

    throw new RedisNoReachableClusterNodeException("No reachable node in cluster");
  }

  override
  Redis getConnectionFromSlot(int slot) {
    RedisPool connectionPool = cache.getSlotPool(slot);
    if (connectionPool !is null) {
      // It can't guaranteed to get valid connection because of node
      // assignment
      return connectionPool.getResource();
    } else {
      renewSlotCache(); //It's abnormal situation for cluster mode, that we have just nothing for slot, try to rediscover state
      connectionPool = cache.getSlotPool(slot);
      if (connectionPool !is null) {
        return connectionPool.getResource();
      } else {
        //no choice, fallback to new connection to random node
        return getConnection();
      }
    }
  }
}
