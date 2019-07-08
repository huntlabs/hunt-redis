
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

To use it just:
    
```java
Redis jedis = new Redis("localhost");
jedis.set("foo", "bar");
String value = jedis.get("foo");
```

## Redis Cluster

Redis cluster [specification](http://redis.io/topics/cluster-spec) (still under development) is implemented

```java
Set<HostAndPort> jedisClusterNodes = new HashSet<HostAndPort>();
//Redis Cluster will attempt to discover cluster nodes automatically
jedisClusterNodes.add(new HostAndPort("127.0.0.1", 7379));
RedisCluster jc = new RedisCluster(jedisClusterNodes);
jc.set("foo", "bar");
String value = jc.get("foo");
```
