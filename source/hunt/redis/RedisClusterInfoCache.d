module hunt.redis.RedisClusterInfoCache;

import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisPool;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;
import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.Long;
import hunt.Integer;

import core.sync.rwmutex;
import core.sync.condition;

class RedisClusterInfoCache {
  private Map!(string, RedisPool) nodes;
  private Map!(Integer, RedisPool) slots;

  private ReadWriteMutex rwl;
  private Object.Monitor r;
  private Object.Monitor w;
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
//   private RedisClusterHostAndPortMap hostAndPortMap;

  private enum int MASTER_NODE_INDEX = 2;

  this(GenericObjectPoolConfig poolConfig, int timeout) {
    this(poolConfig, timeout, timeout, null, null);
  }

  this(GenericObjectPoolConfig poolConfig,
      int connectionTimeout, int soTimeout, string password, string clientName) {
    // this(poolConfig, connectionTimeout, soTimeout, password, clientName, false, null, null, null, null);

    nodes = new HashMap!(string, RedisPool)();
    slots = new HashMap!(Integer, RedisPool)();
    rwl = new ReadWriteMutex();
    r = rwl.reader();
    w = rwl.writer();

    this.poolConfig = poolConfig;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.password = password;
    this.clientName = clientName;
    this.ssl = false;
    // this.sslSocketFactory = sslSocketFactory;
    // this.sslParameters = sslParameters;
    // this.hostnameVerifier = hostnameVerifier;
    // this.hostAndPortMap = hostAndPortMap;    
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

  void discoverClusterNodesAndSlots(Redis jedis) {
    w.lock();

    try {
      reset();
      List!(Object) slots = jedis.clusterSlots();

      foreach(Object slotInfoObj ; slots) {
        List!(Object) slotInfo = cast(List!(Object)) slotInfoObj;

        if (slotInfo.size() <= MASTER_NODE_INDEX) {
          continue;
        }

        List!(Integer) slotNums = getAssignedSlotArray(slotInfo);

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
    } finally {
      w.unlock();
    }
  }

  void renewClusterSlots(Redis jedis) {
    //If rediscovering is already in process - no need to start one more same rediscovering, just return
    if (!rediscovering) {
      try {
        w.lock();
        if (!rediscovering) {
          rediscovering = true;

          try {
            if (jedis !is null) {
              try {
                discoverClusterSlots(jedis);
                return;
              } catch (RedisException e) {
                //try nodes from all pools
              }
            }

            foreach(RedisPool jp ; getShuffledNodesPool()) {
              Redis j = null;
              try {
                j = jp.getResource();
                discoverClusterSlots(j);
                return;
              } catch (RedisConnectionException e) {
                // try next nodes
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
      } finally {
        w.unlock();
      }
    }
  }

  private void discoverClusterSlots(Redis jedis) {
    List!(Object) slots = jedis.clusterSlots();
    this.slots.clear();

    foreach(Object slotInfoObj ; slots) {
      List!(Object) slotInfo = cast(List!(Object)) slotInfoObj;

      if (slotInfo.size() <= MASTER_NODE_INDEX) {
        continue;
      }

      List!(Integer) slotNums = getAssignedSlotArray(slotInfo);

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
    string host = SafeEncoder.encode(cast(byte[]) hostInfos.get(0));
    int port = (cast(Long) hostInfos.get(1)).intValue();
    if (ssl && hostAndPortMap !is null) {
      HostAndPort hostAndPort = hostAndPortMap.getSSLHostAndPort(host, port);
      if (hostAndPort !is null) {
        return hostAndPort;
      }
    }
    return new HostAndPort(host, port);
  }

  RedisPool setupNodeIfNotExist(HostAndPort node) {
    w.lock();
    try {
      string nodeKey = getNodeKey(node);
      RedisPool existingPool = nodes.get(nodeKey);
      if (existingPool !is null) return existingPool;

      RedisPool nodePool = new RedisPool(poolConfig, node.getHost(), node.getPort(),
          connectionTimeout, soTimeout, password, 0, clientName, 
          ssl, sslSocketFactory, sslParameters, hostnameVerifier);
      nodes.put(nodeKey, nodePool);
      return nodePool;
    } finally {
      w.unlock();
    }
  }

  void assignSlotToNode(int slot, HostAndPort targetNode) {
    w.lock();
    try {
      RedisPool targetPool = setupNodeIfNotExist(targetNode);
      slots.put(slot, targetPool);
    } finally {
      w.unlock();
    }
  }

  void assignSlotsToNode(List!(Integer) targetSlots, HostAndPort targetNode) {
    w.lock();
    try {
      RedisPool targetPool = setupNodeIfNotExist(targetNode);
      foreach(Integer slot ; targetSlots) {
        slots.put(slot, targetPool);
      }
    } finally {
      w.unlock();
    }
  }

  RedisPool getNode(string nodeKey) {
    r.lock();
    try {
      return nodes.get(nodeKey);
    } finally {
      r.unlock();
    }
  }

  RedisPool getSlotPool(int slot) {
    r.lock();
    try {
      return slots.get(slot);
    } finally {
      r.unlock();
    }
  }

  Map!(string, RedisPool) getNodes() {
    r.lock();
    try {
      return new HashMap!(string, RedisPool)(nodes);
    } finally {
      r.unlock();
    }
  }

  List!(RedisPool) getShuffledNodesPool() {
    r.lock();
    try {
      List!(RedisPool) pools = new ArrayList!(RedisPool)(nodes.values());
      Collections.shuffle(pools);
      return pools;
    } finally {
      r.unlock();
    }
  }

  /**
   * Clear discovered nodes collections and gently release allocated resources
   */
  void reset() {
    w.lock();
    try {
      foreach(RedisPool pool ; nodes.values()) {
        try {
          if (pool !is null) {
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

  static string getNodeKey(HostAndPort hnp) {
    return hnp.getHost() ~ ":" ~ hnp.getPort();
  }

  static string getNodeKey(Client client) {
    return client.getHost() ~ ":" ~ client.getPort();
  }

  static string getNodeKey(Redis jedis) {
    return getNodeKey(jedis.getClient());
  }

  private List!(Integer) getAssignedSlotArray(List!(Object) slotInfo) {
    List!(Integer) slotNums = new ArrayList!(Integer)();
    for (int slot = (cast(Long) slotInfo.get(0)).intValue(); slot <= (cast(Long) slotInfo.get(1))
        .intValue(); slot++) {
      slotNums.add(slot);
    }
    return slotNums;
  }
}
