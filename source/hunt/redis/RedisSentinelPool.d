module hunt.redis.RedisSentinelPool;

import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Protocol;
import hunt.redis.Redis;
import hunt.redis.RedisFactory;
import hunt.redis.RedisPoolAbstract;

import hunt.util.ArrayHelper;
import hunt.collection.HashSet;
import hunt.collection.List;
import hunt.collection.Set;

import hunt.logging.ConsoleLogger;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.concurrency.thread;


/**
*/
class RedisSentinelPool : RedisPoolAbstract {

  protected GenericObjectPoolConfig poolConfig;

  protected int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
  protected int soTimeout = Protocol.DEFAULT_TIMEOUT;

  protected string password;

  protected int database = Protocol.DEFAULT_DATABASE;

  protected string clientName;

  protected Set!(MasterListener) masterListeners = new HashSet!(MasterListener)();

  private RedisFactory factory;
  private HostAndPort currentHostMaster;
  
  private Object initPoolLock = new Object();

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig) {
    this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, null,
        Protocol.DEFAULT_DATABASE);
  }

  this(string masterName, Set!(string) sentinels) {
    this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, null,
        Protocol.DEFAULT_DATABASE);
  }

  this(string masterName, Set!(string) sentinels, string password) {
    this(masterName, sentinels, new GenericObjectPoolConfig(), Protocol.DEFAULT_TIMEOUT, password);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int timeout, string password) {
    this(masterName, sentinels, poolConfig, timeout, password, Protocol.DEFAULT_DATABASE);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int timeout) {
    this(masterName, sentinels, poolConfig, timeout, null, Protocol.DEFAULT_DATABASE);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, string password) {
    this(masterName, sentinels, poolConfig, Protocol.DEFAULT_TIMEOUT, password);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int timeout, string password,
      int database) {
    this(masterName, sentinels, poolConfig, timeout, timeout, password, database);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int timeout, string password,
      int database, string clientName) {
    this(masterName, sentinels, poolConfig, timeout, timeout, password, database, clientName);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int timeout, int soTimeout,
      string password, int database) {
    this(masterName, sentinels, poolConfig, timeout, soTimeout, password, database, null);
  }

  this(string masterName, Set!(string) sentinels,
      GenericObjectPoolConfig poolConfig, int connectionTimeout, int soTimeout,
      string password, int database, string clientName) {
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
        if (factory is null) {
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

        log.info("Created RedisPool to master at " ~ master);
      }
    }
  }

  private HostAndPort initSentinels(Set!(string) sentinels, string masterName) {

    HostAndPort master = null;
    bool sentinelAvailable = false;

    log.info("Trying to find master from available[] Sentinels...");

    foreach(string sentinel ; sentinels) {
      HostAndPort hap = HostAndPort.parseString(sentinel);

      tracef("Connecting to Sentinel %s", hap);

      Redis jedis = null;
      try {
        jedis = new Redis(hap);

        List!(string) masterAddr = jedis.sentinelGetMasterAddrByName(masterName);

        // connected to[] sentinel...
        sentinelAvailable = true;

        if (masterAddr is null || masterAddr.size() != 2) {
          warningf("Can not get master addr, master name: %s. Sentinel: %s", masterName, hap);
          continue;
        }

        master = toHostAndPort(masterAddr);
        tracef("Found Redis master at %s", master);
        break;
      } catch (RedisException e) {
        // resolves #1036, it should handle RedisException there's another chance
        // of raising RedisDataException
        warningf(
          "Cannot get master address from sentinel running @ %s. Reason: %s. Trying next one.", hap,
          e.toString());
      } finally {
        if (jedis !is null) {
          jedis.close();
        }
      }
    }

    if (master is null) {
      if (sentinelAvailable) {
        // can connect to sentinel, but master name seems to not
        // monitored
        throw new RedisException("Can connect to sentinel, but " ~ masterName
            ~ " seems to be not[] monitored...");
      } else {
        throw new RedisConnectionException("All sentinels down, cannot determine where is "
            + masterName ~ " master is[] running...");
      }
    }

    log.info("Redis master running at " ~ master ~ ", starting Sentinel[] listeners...");

    foreach(string sentinel ; sentinels) {
      HostAndPort hap = HostAndPort.parseString(sentinel);
      MasterListener masterListener = new this(masterName, hap.getHost(), hap.getPort());
      // whether MasterListener threads are alive or not, process can be stopped
      masterListener.setDaemon(true);
      masterListeners.add(masterListener);
      masterListener.start();
    }

    return master;
  }

  private HostAndPort toHostAndPort(List!(string) getMasterAddrByNameResult) {
    string host = getMasterAddrByNameResult.get(0);
    int port = Integer.parseInt(getMasterAddrByNameResult.get(1));

    return new HostAndPort(host, port);
  }

  override
  Redis getResource() {
    while (true) {
      Redis jedis = super.getResource();
      jedis.setDataSource(this);

      // get a reference because it can change concurrently
      HostAndPort master = currentHostMaster;
      HostAndPort connection = new HostAndPort(jedis.getClient().getHost(), jedis.getClient()
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
  protected void returnBrokenResource(Redis resource) {
    if (resource !is null) {
      returnBrokenResourceObject(resource);
    }
  }

  override
  protected void returnResource(Redis resource) {
    if (resource !is null) {
      resource.resetState();
      returnResourceObject(resource);
    }
  }

  protected class MasterListener : ThreadEx {

    protected string masterName;
    protected string host;
    protected int port;
    protected long subscribeRetryWaitTimeMillis = 5000;
    protected Redis j;
    protected shared bool running = false;

    protected this() {
    }

    this(string masterName, string host, int port) {
      super(string.format("MasterListener-%s-[%s:%d]", masterName, host, port));
      this.masterName = masterName;
      this.host = host;
      this.port = port;
    }

    this(string masterName, string host, int port,
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
          List!(string) masterAddr = j.sentinelGetMasterAddrByName(masterName);  
          if (masterAddr is null || masterAddr.size() != 2) {
            warningf("Can not get master addr, master name: %s. Sentinel: %s：%s.",masterName,host,port);
          }else{
              initPool(toHostAndPort(masterAddr)); 
          }

          j.subscribe(new class RedisPubSub {
            override
            void onMessage(string channel, string message) {
              tracef("Sentinel %s:%s published: %s.", host, port, message);

              string[] switchMasterMsg = message.split(" ");

              if (switchMasterMsg.length > 3) {

                if (masterName.equals(switchMasterMsg[0])) {
                  initPool(toHostAndPort(Arrays.asList(switchMasterMsg[3], switchMasterMsg[4])));
                } else {
                  tracef(
                    "Ignoring message on +switch-master for master name %s, our master name is %s",
                    switchMasterMsg[0], masterName);
                }

              } else {
                errorf(
                  "Invalid message received on Sentinel %s:%s on channel +switch-master: %s", host,
                  port, message);
              }
            }
          }, "+switch-master");

        } catch (RedisException e) {

          if (running.get()) {
            errorf("Lost connection to Sentinel at %s:%s. Sleeping 5000ms and retrying.", host,
              port, e);
            try {
              Thread.sleep(subscribeRetryWaitTimeMillis);
            } catch (InterruptedException e1) {
              errorf("Sleep interrupted: ", e1);
            }
          } else {
            tracef("Unsubscribing from Sentinel at %s:%s", host, port);
          }
        } finally {
          j.close();
        }
      }
    }

    void shutdown() {
      try {
        tracef("Shutting down listener on %s:%s", host, port);
        running.set(false);
        // This isn't good, the Redis object is not thread safe
        if (j !is null) {
          j.disconnect();
        }
      } catch (Exception e) {
        errorf("Caught exception while shutting down: ", e);
      }
    }
  }
}