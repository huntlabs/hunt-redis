module hunt.redis.RedisSentinelPool;

import hunt.util.ArrayHelper;
import hunt.collection.HashSet;
import hunt.collection.List;
import hunt.collection.Set;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.exceptions.RedisException;

class RedisSentinelPool : RedisPoolAbstract {

  protected GenericObjectPoolConfig poolConfig;

  protected int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
  protected int soTimeout = Protocol.DEFAULT_TIMEOUT;

  protected String password;

  protected int database = Protocol.DEFAULT_DATABASE;

  protected String clientName;

  protected Set!(MasterListener) masterListeners = new HashSet!(MasterListener)();

  protected Logger log = LoggerFactory.getLogger(getClass().getName());

  private volatile RedisFactory factory;
  private volatile HostAndPort currentHostMaster;
  
  private final Object initPoolLock = new Object();

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig) {
    this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, null,
        Protocol.DEFAULT_DATABASE);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels) {
    this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, null,
        Protocol.DEFAULT_DATABASE);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels, String password) {
    this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, password);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, int timeout, final String password) {
    this(masterName, sentinels, poolConfig, timeout, password, Protocol.DEFAULT_DATABASE);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, final int timeout) {
    this(masterName, sentinels, poolConfig, timeout, null, Protocol.DEFAULT_DATABASE);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, final String password) {
    this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, password);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, int timeout, final String password,
      final int database) {
    this(masterName, sentinels, poolConfig, timeout, timeout, password, database);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, int timeout, final String password,
      final int database, final String clientName) {
    this(masterName, sentinels, poolConfig, timeout, timeout, password, database, clientName);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, final int timeout, final int soTimeout,
      final String password, final int database) {
    this(masterName, sentinels, poolConfig, timeout, soTimeout, password, database, null);
  }

  RedisSentinelPool(String masterName, Set!(String) sentinels,
      final GenericObjectPoolConfig poolConfig, final int connectionTimeout, final int soTimeout,
      final String password, final int database, final String clientName) {
    this.poolConfig = poolConfig;
    this.connectionTimeout = connectionTimeout;
    this.soTimeout = soTimeout;
    this.password = password;
    this.database = database;
    this.clientName = clientName;

    HostAndPort master = initSentinels(sentinels, masterName);
    initPool(master);
  }

  override
  void destroy() {
    foreach(MasterListener m ; masterListeners) {
      m.shutdown();
    }

    super.destroy();
  }

  HostAndPort getCurrentHostMaster() {
    return currentHostMaster;
  }

  private void initPool(HostAndPort master) {
    synchronized(initPoolLock){
      if (!master == currentHostMaster) {
        currentHostMaster = master;
        if (factory == null) {
          factory = new RedisFactory(master.getHost(), master.getPort(), connectionTimeout,
              soTimeout, password, database, clientName);
          initPool(poolConfig, factory);
        } else {
          factory.setHostAndPort(currentHostMaster);
          // although we clear the pool, we still have to check the
          // returned object
          // in getResource, this call only clears idle instances, not
          // borrowed instances
          internalPool.clear();
        }

        log.info("Created RedisPool to master at " + master);
      }
    }
  }

  private HostAndPort initSentinels(Set!(String) sentinels, final String masterName) {

    HostAndPort master = null;
    bool sentinelAvailable = false;

    log.info("Trying to find master from available Sentinels...");

    foreach(String sentinel ; sentinels) {
      final HostAndPort hap = HostAndPort.parseString(sentinel);

      log.debug("Connecting to Sentinel {}", hap);

      Redis jedis = null;
      try {
        jedis = new Redis(hap);

        List!(String) masterAddr = jedis.sentinelGetMasterAddrByName(masterName);

        // connected to sentinel...
        sentinelAvailable = true;

        if (masterAddr == null || masterAddr.size() != 2) {
          log.warn("Can not get master addr, master name: {}. Sentinel: {}", masterName, hap);
          continue;
        }

        master = toHostAndPort(masterAddr);
        log.debug("Found Redis master at {}", master);
        break;
      } catch (RedisException e) {
        // resolves #1036, it should handle RedisException there's another chance
        // of raising RedisDataException
        log.warn(
          "Cannot get master address from sentinel running @ {}. Reason: {}. Trying next one.", hap,
          e.toString());
      } finally {
        if (jedis != null) {
          jedis.close();
        }
      }
    }

    if (master == null) {
      if (sentinelAvailable) {
        // can connect to sentinel, but master name seems to not
        // monitored
        throw new RedisException("Can connect to sentinel, but " + masterName
            + " seems to be not monitored...");
      } else {
        throw new RedisConnectionException("All sentinels down, cannot determine where is "
            + masterName + " master is running...");
      }
    }

    log.info("Redis master running at " + master + ", starting Sentinel listeners...");

    foreach(String sentinel ; sentinels) {
      final HostAndPort hap = HostAndPort.parseString(sentinel);
      MasterListener masterListener = new MasterListener(masterName, hap.getHost(), hap.getPort());
      // whether MasterListener threads are alive or not, process can be stopped
      masterListener.setDaemon(true);
      masterListeners.add(masterListener);
      masterListener.start();
    }

    return master;
  }

  private HostAndPort toHostAndPort(List!(String) getMasterAddrByNameResult) {
    String host = getMasterAddrByNameResult.get(0);
    int port = Integer.parseInt(getMasterAddrByNameResult.get(1));

    return new HostAndPort(host, port);
  }

  override
  Redis getResource() {
    while (true) {
      Redis jedis = super.getResource();
      jedis.setDataSource(this);

      // get a reference because it can change concurrently
      final HostAndPort master = currentHostMaster;
      final HostAndPort connection = new HostAndPort(jedis.getClient().getHost(), jedis.getClient()
          .getPort());

      if (master == connection) {
        // connected to the correct master
        return jedis;
      } else {
        returnBrokenResource(jedis);
      }
    }
  }

  override
  protected void returnBrokenResource(final Redis resource) {
    if (resource != null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
  protected void returnResource(final Redis resource) {
    if (resource != null) {
      resource.resetState();
      returnResourceObject(resource);
    }
  }

  protected class MasterListener : Thread {

    protected String masterName;
    protected String host;
    protected int port;
    protected long subscribeRetryWaitTimeMillis = 5000;
    protected volatile Redis j;
    protected AtomicBoolean running = new AtomicBoolean(false);

    protected MasterListener() {
    }

    MasterListener(String masterName, String host, int port) {
      super(String.format("MasterListener-%s-[%s:%d]", masterName, host, port));
      this.masterName = masterName;
      this.host = host;
      this.port = port;
    }

    MasterListener(String masterName, String host, int port,
        long subscribeRetryWaitTimeMillis) {
      this(masterName, host, port);
      this.subscribeRetryWaitTimeMillis = subscribeRetryWaitTimeMillis;
    }

    override
    void run() {

      running.set(true);

      while (running.get()) {

        j = new Redis(host, port);

        try {
          // double check that it is not being shutdown
          if (!running.get()) {
            break;
          }
          
          /*
           * Added code for active refresh
           */
          List!(String) masterAddr = j.sentinelGetMasterAddrByName(masterName);  
          if (masterAddr == null || masterAddr.size() != 2) {
            log.warn("Can not get master addr, master name: {}. Sentinel: {}：{}.",masterName,host,port);
          }else{
              initPool(toHostAndPort(masterAddr)); 
          }

          j.subscribe(new RedisPubSub() {
            override
            void onMessage(String channel, String message) {
              log.debug("Sentinel {}:{} published: {}.", host, port, message);

              String[] switchMasterMsg = message.split(" ");

              if (switchMasterMsg.length > 3) {

                if (masterName.equals(switchMasterMsg[0])) {
                  initPool(toHostAndPort(Arrays.asList(switchMasterMsg[3], switchMasterMsg[4])));
                } else {
                  log.debug(
                    "Ignoring message on +switch-master for master name {}, our master name is {}",
                    switchMasterMsg[0], masterName);
                }

              } else {
                log.error(
                  "Invalid message received on Sentinel {}:{} on channel +switch-master: {}", host,
                  port, message);
              }
            }
          }, "+switch-master");

        } catch (RedisException e) {

          if (running.get()) {
            log.error("Lost connection to Sentinel at {}:{}. Sleeping 5000ms and retrying.", host,
              port, e);
            try {
              Thread.sleep(subscribeRetryWaitTimeMillis);
            } catch (InterruptedException e1) {
              log.error("Sleep interrupted: ", e1);
            }
          } else {
            log.debug("Unsubscribing from Sentinel at {}:{}", host, port);
          }
        } finally {
          j.close();
        }
      }
    }

    void shutdown() {
      try {
        log.debug("Shutting down listener on {}:{}", host, port);
        running.set(false);
        // This isn't good, the Redis object is not thread safe
        if (j != null) {
          j.disconnect();
        }
      } catch (Exception e) {
        log.error("Caught exception while shutting down: ", e);
      }
    }
  }
}