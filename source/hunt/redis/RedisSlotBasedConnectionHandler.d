module hunt.redis.RedisSlotBasedConnectionHandler;

import hunt.collection.List;
import hunt.collection.Set;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisException;
import hunt.redis.exceptions.RedisNoReachableClusterNodeException;

class RedisSlotBasedConnectionHandler : RedisClusterConnectionHandler {

  RedisSlotBasedConnectionHandler(Set!(HostAndPort) nodes,
      final GenericObjectPoolConfig poolConfig, int timeout) {
    this(nodes, poolConfig, timeout, timeout);
  }

  RedisSlotBasedConnectionHandler(Set!(HostAndPort) nodes,
      final GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, null);
  }

  RedisSlotBasedConnectionHandler(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, password);
  }

  RedisSlotBasedConnectionHandler(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password, String clientName) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName);
  }

  RedisSlotBasedConnectionHandler(Set!(HostAndPort) nodes, GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password, String clientName,
                                         bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap portMap) {
    super(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier, portMap);
  }

  override
  Redis getConnection() {
    // In antirez's redis-rb-cluster implementation,
    // getRandomConnection always return valid connection (able to
    // ping-pong)
    // or exception if all connections are invalid

    List!(RedisPool) pools = cache.getShuffledNodesPool();

    foreach(RedisPool pool ; pools) {
      Redis jedis = null;
      try {
        jedis = pool.getResource();

        if (jedis == null) {
          continue;
        }

        String result = jedis.ping();

        if (result.equalsIgnoreCase("pong")) return jedis;

        jedis.close();
      } catch (RedisException ex) {
        if (jedis != null) {
          jedis.close();
        }
      }
    }

    throw new RedisNoReachableClusterNodeException("No reachable node in cluster");
  }

  override
  Redis getConnectionFromSlot(int slot) {
    RedisPool connectionPool = cache.getSlotPool(slot);
    if (connectionPool != null) {
      // It can't guaranteed to get valid connection because of node
      // assignment
      return connectionPool.getResource();
    } else {
      renewSlotCache(); //It's abnormal situation for cluster mode, that we have just nothing for slot, try to rediscover state
      connectionPool = cache.getSlotPool(slot);
      if (connectionPool != null) {
        return connectionPool.getResource();
      } else {
        //no choice, fallback to new connection to random node
        return getConnection();
      }
    }
  }
}
