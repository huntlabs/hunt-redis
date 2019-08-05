## Hunt Redis
A powerfull redis client for D Programming Language. Port from java [Jedis](https://github.com/xetorthio/jedis) project.

## So what can I do with Redis?
All of the following redis features are supported:

- Sorting
- Connection handling
- Commands operating on any kind of values
- Commands operating on string values
- Commands operating on hashes
- Commands operating on lists
- Commands operating on sets
- Commands operating on sorted sets
- Transactions
- Pipelining
- Publish/Subscribe
- Persistence control commands
- Remote server control commands
- Connection pooling
- Sharding (MD5, MurmurHash)
- Key-tags for sharding
- Sharding with pipelining
- Scripting with pipelining
- Redis Cluster

## To use it just:
    
```D
Redis redis = new Redis("localhost");
redis.set("foo", "bar");
string value = redis.get("foo");
```

## Redis Cluster

Redis cluster [specification](http://redis.io/topics/cluster-spec) (still under development) is implemented

```D
Set!(HostAndPort) redisClusterNodes = new HashSet!(HostAndPort)();
//Redis Cluster will attempt to discover cluster nodes automatically
redisClusterNodes.add(new HostAndPort("127.0.0.1", 7379));
RedisCluster rc = new RedisCluster(redisClusterNodes);
rc.set("foo", "bar");
string value = rc.get("foo");
```
