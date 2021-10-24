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
 
module hunt.redis.RedisSlotBasedConnectionHandler;

import hunt.redis.RedisClusterConnectionHandler;

import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisPool;
import hunt.redis.RedisPoolOptions;

import hunt.text.Common;

import hunt.collection.List;
import hunt.collection.Set;
import hunt.util.pool;


class RedisSlotBasedConnectionHandler : RedisClusterConnectionHandler {

  this(HostAndPort[] nodes, RedisPoolOptions poolConfig) {
    super(nodes, poolConfig);
  }


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
        redis = pool.borrow();

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
      return connectionPool.borrow();
    } else {
      renewSlotCache(); //It's abnormal situation for cluster mode, that we have just nothing for slot, try to rediscover state
      connectionPool = cache.getSlotPool(slot);
      if (connectionPool !is null) {
        return connectionPool.borrow();
      } else {
        //no choice, fallback to new connection to random node
        return getConnection();
      }
    }
  }
}
