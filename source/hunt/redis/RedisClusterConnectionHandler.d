module hunt.redis.RedisClusterConnectionHandler;

import java.io.Closeable;
import hunt.collection.Map;
import hunt.collection.Set;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisConnectionException;

abstract class RedisClusterConnectionHandler : Closeable {
  protected final RedisClusterInfoCache cache;

  RedisClusterConnectionHandler(Set!(HostAndPort) nodes,
      final GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password) {
    this(nodes, poolConfig, connectionTimeout, soTimeout, password, null);
  }

  RedisClusterConnectionHandler(Set!(HostAndPort) nodes,
      final GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password, String clientName) {
    this(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, false, null, null, null, null);
  }

  RedisClusterConnectionHandler(Set!(HostAndPort) nodes,
      final GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout, String password, String clientName,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap portMap) {
    this.cache = new RedisClusterInfoCache(poolConfig, connectionTimeout, soTimeout, password, clientName,
        ssl, sslSocketFactory, sslParameters, hostnameVerifier, portMap);
    initializeSlotsCache(nodes, poolConfig, connectionTimeout, soTimeout, password, clientName, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
  }

  abstract Redis getConnection();

  abstract Redis getConnectionFromSlot(int slot);

  Redis getConnectionFromNode(HostAndPort node) {
    return cache.setupNodeIfNotExist(node).getResource();
  }
  
  Map!(String, RedisPool) getNodes() {
    return cache.getNodes();
  }

  private void initializeSlotsCache(Set!(HostAndPort) startNodes, GenericObjectPoolConfig poolConfig,
      int connectionTimeout, int soTimeout, String password, String clientName,
      bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    foreach(HostAndPort hostAndPort ; startNodes) {
      Redis jedis = null;
      try {
        jedis = new Redis(hostAndPort.getHost(), hostAndPort.getPort(), connectionTimeout, soTimeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
        if (password != null) {
          jedis.auth(password);
        }
        if (clientName != null) {
          jedis.clientSetname(clientName);
        }
        cache.discoverClusterNodesAndSlots(jedis);
        break;
      } catch (RedisConnectionException e) {
        // try next nodes
      } finally {
        if (jedis != null) {
          jedis.close();
        }
      }
    }
  }

  void renewSlotCache() {
    cache.renewClusterSlots(null);
  }

  void renewSlotCache(Redis jedis) {
    cache.renewClusterSlots(jedis);
  }

  override
  void close() {
    cache.reset();
  }
}
