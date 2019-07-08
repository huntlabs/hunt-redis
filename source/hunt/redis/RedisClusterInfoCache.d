module hunt.redis.RedisClusterInfoCache;

import hunt.collection.ArraryList;
import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.exceptions.RedisException;
import hunt.redis.util.SafeEncoder;

public class RedisClusterInfoCache {
  private final Map<String, RedisPool> nodes = new HashMap<String, RedisPool>();
  private final Map<Integer, RedisPool> slots = new HashMap<Integer, RedisPool>();

  private final ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
  private final Lock r = rwl.readLock();
  private final Lock w = rwl.writeLock();
  private volatile boolean rediscovering;
  private final GenericObjectPoolConfig poolConfig;

  private int connectionTimeout;
  private int soTimeout;
  private String password;
  private String clientName;

  private boolean ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;
  private RedisClusterHostAndPortMap hostAndPortMap;

  private static final int MASTER_NODE_INDEX = 2;

  public RedisClusterInfoCache(final GenericObjectPoolConfig poolConfig, int timeout) {
    this(poolConfig, timeout, timeout, null, null);
  }

  public RedisClusterInfoCache(final GenericObjectPoolConfig poolConfig,
      final int connectionTimeout, final int soTimeout, final String password, final String clientName) {
    this(poolConfig, connectionTimeout, soTimeout, password, clientName, false, null, null, null, null);
  }

  public RedisClusterInfoCache(final GenericObjectPoolConfig poolConfig,
      final int connectionTimeout, final int soTimeout, final String password, final String clientName,
      boolean ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters, 
      HostnameVerifier hostnameVerifier, RedisClusterHostAndPortMap hostAndPortMap) {
    this.poolConfig = poolConfig;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.password = password;
    this.clientName = clientName;
    this.ssl = ssl;
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
    this.hostAndPortMap = hostAndPortMap;
  }

  public void discoverClusterNodesAndSlots(Redis jedis) {
    w.lock();

    try {
      reset();
      List<Object> slots = jedis.clusterSlots();

      for (Object slotInfoObj : slots) {
        List<Object> slotInfo = (List<Object>) slotInfoObj;

        if (slotInfo.size() <= MASTER_NODE_INDEX) {
          continue;
        }

        List<Integer> slotNums = getAssignedSlotArray(slotInfo);

        // hostInfos
        int size = slotInfo.size();
        for (int i = MASTER_NODE_INDEX; i < size; i++) {
          List<Object> hostInfos = (List<Object>) slotInfo.get(i);
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
    } finally {
      w.unlock();
    }
  }

  public void renewClusterSlots(Redis jedis) {
    //If rediscovering is already in process - no need to start one more same rediscovering, just return
    if (!rediscovering) {
      try {
        w.lock();
        if (!rediscovering) {
          rediscovering = true;

          try {
            if (jedis != null) {
              try {
                discoverClusterSlots(jedis);
                return;
              } catch (RedisException e) {
                //try nodes from all pools
              }
            }

            for (RedisPool jp : getShuffledNodesPool()) {
              Redis j = null;
              try {
                j = jp.getResource();
                discoverClusterSlots(j);
                return;
              } catch (RedisConnectionException e) {
                // try next nodes
              } finally {
                if (j != null) {
                  j.close();
                }
              }
            }
          } finally {
            rediscovering = false;      
          }
        }
      } finally {
        w.unlock();
      }
    }
  }

  private void discoverClusterSlots(Redis jedis) {
    List<Object> slots = jedis.clusterSlots();
    this.slots.clear();

    for (Object slotInfoObj : slots) {
      List<Object> slotInfo = (List<Object>) slotInfoObj;

      if (slotInfo.size() <= MASTER_NODE_INDEX) {
        continue;
      }

      List<Integer> slotNums = getAssignedSlotArray(slotInfo);

      // hostInfos
      List<Object> hostInfos = (List<Object>) slotInfo.get(MASTER_NODE_INDEX);
      if (hostInfos.isEmpty()) {
        continue;
      }

      // at this time, we just use master, discard slave information
      HostAndPort targetNode = generateHostAndPort(hostInfos);
      assignSlotsToNode(slotNums, targetNode);
    }
  }

  private HostAndPort generateHostAndPort(List<Object> hostInfos) {
    String host = SafeEncoder.encode((byte[]) hostInfos.get(0));
    int port = ((Long) hostInfos.get(1)).intValue();
    if (ssl && hostAndPortMap != null) {
      HostAndPort hostAndPort = hostAndPortMap.getSSLHostAndPort(host, port);
      if (hostAndPort != null) {
        return hostAndPort;
      }
    }
    return new HostAndPort(host, port);
  }

  public RedisPool setupNodeIfNotExist(HostAndPort node) {
    w.lock();
    try {
      String nodeKey = getNodeKey(node);
      RedisPool existingPool = nodes.get(nodeKey);
      if (existingPool != null) return existingPool;

      RedisPool nodePool = new RedisPool(poolConfig, node.getHost(), node.getPort(),
          connectionTimeout, soTimeout, password, 0, clientName, 
          ssl, sslSocketFactory, sslParameters, hostnameVerifier);
      nodes.put(nodeKey, nodePool);
      return nodePool;
    } finally {
      w.unlock();
    }
  }

  public void assignSlotToNode(int slot, HostAndPort targetNode) {
    w.lock();
    try {
      RedisPool targetPool = setupNodeIfNotExist(targetNode);
      slots.put(slot, targetPool);
    } finally {
      w.unlock();
    }
  }

  public void assignSlotsToNode(List<Integer> targetSlots, HostAndPort targetNode) {
    w.lock();
    try {
      RedisPool targetPool = setupNodeIfNotExist(targetNode);
      for (Integer slot : targetSlots) {
        slots.put(slot, targetPool);
      }
    } finally {
      w.unlock();
    }
  }

  public RedisPool getNode(String nodeKey) {
    r.lock();
    try {
      return nodes.get(nodeKey);
    } finally {
      r.unlock();
    }
  }

  public RedisPool getSlotPool(int slot) {
    r.lock();
    try {
      return slots.get(slot);
    } finally {
      r.unlock();
    }
  }

  public Map<String, RedisPool> getNodes() {
    r.lock();
    try {
      return new HashMap<String, RedisPool>(nodes);
    } finally {
      r.unlock();
    }
  }

  public List<RedisPool> getShuffledNodesPool() {
    r.lock();
    try {
      List<RedisPool> pools = new ArrayList<RedisPool>(nodes.values());
      Collections.shuffle(pools);
      return pools;
    } finally {
      r.unlock();
    }
  }

  /**
   * Clear discovered nodes collections and gently release allocated resources
   */
  public void reset() {
    w.lock();
    try {
      for (RedisPool pool : nodes.values()) {
        try {
          if (pool != null) {
            pool.destroy();
          }
        } catch (Exception e) {
          // pass
        }
      }
      nodes.clear();
      slots.clear();
    } finally {
      w.unlock();
    }
  }

  public static String getNodeKey(HostAndPort hnp) {
    return hnp.getHost() + ":" + hnp.getPort();
  }

  public static String getNodeKey(Client client) {
    return client.getHost() + ":" + client.getPort();
  }

  public static String getNodeKey(Redis jedis) {
    return getNodeKey(jedis.getClient());
  }

  private List<Integer> getAssignedSlotArray(List<Object> slotInfo) {
    List<Integer> slotNums = new ArrayList<Integer>();
    for (int slot = ((Long) slotInfo.get(0)).intValue(); slot <= ((Long) slotInfo.get(1))
        .intValue(); slot++) {
      slotNums.add(slot);
    }
    return slotNums;
  }
}
