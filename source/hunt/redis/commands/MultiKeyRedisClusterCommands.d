module hunt.redis.commands.MultiKeyRedisClusterCommands;

import hunt.redis.BitOP;
import hunt.redis.RedisPubSub;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;

import hunt.collection.List;
import hunt.collection.Set;

public interface MultiKeyRedisClusterCommands {
  Long del(string keys...);

  Long unlink(string keys...);

  Long exists(string keys...);

  List!(string) blpop(int timeout, string keys...);

  List!(string) brpop(int timeout, string keys...);

  List!(string) mget(string keys...);

  string mset(string keysvalues...);

  Long msetnx(string keysvalues...);

  string rename(string oldkey, string newkey);

  Long renamenx(string oldkey, string newkey);

  string rpoplpush(string srckey, string dstkey);

  Set!(string) sdiff(string keys...);

  Long sdiffstore(string dstkey, string keys...);

  Set!(string) sinter(string keys...);

  Long sinterstore(string dstkey, string keys...);

  Long smove(string srckey, string dstkey, string member);

  Long sort(string key, SortingParams sortingParameters, string dstkey);

  Long sort(string key, string dstkey);

  Set!(string) sunion(string keys...);

  Long sunionstore(string dstkey, string keys...);

  Long zinterstore(string dstkey, string sets...);

  Long zinterstore(string dstkey, ZParams params, string sets...);

  Long zunionstore(string dstkey, string sets...);

  Long zunionstore(string dstkey, ZParams params, string sets...);

  string brpoplpush(string source, string destination, int timeout);

  Long publish(string channel, string message);

  void subscribe(RedisPubSub jedisPubSub, string channels...);

  void psubscribe(RedisPubSub jedisPubSub, string patterns...);

  Long bitop(BitOP op, string destKey, string srcKeys...);

  string pfmerge(string destkey, string sourcekeys...);

  long pfcount(string keys...);

  Long touch(string keys...);

  ScanResult!(string) scan(string cursor, ScanParams params);

  Set!(string) keys(string pattern);
}
