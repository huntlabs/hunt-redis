module hunt.redis.commands.MultiKeyCommandsPipeline;

import hunt.redis.BitOP;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;
import hunt.redis.params.MigrateParams;

import hunt.collection.List;
import hunt.collection.Set;

/**
 * Multikey related commands (these are split out because they are non-shardable)
 */
public interface MultiKeyCommandsPipeline {
  Response!(Long) del(string[] keys...);

  Response!(Long) unlink(string[] keys...);

  Response!(Long) exists(string[] keys...);

  Response!(List!(string)) blpop(string[] args...);

  Response!(List!(string)) brpop(string[] args...);

  Response!(Set!(string)) keys(string pattern);

  Response!(List!(string)) mget(string[] keys...);

  Response!(string) mset(string[] keysvalues...);

  Response!(Long) msetnx(string[] keysvalues...);

  Response!(string) rename(string oldkey, string newkey);

  Response!(Long) renamenx(string oldkey, string newkey);

  Response!(string) rpoplpush(string srckey, string dstkey);

  Response!(Set!(string)) sdiff(string[] keys...);

  Response!(Long) sdiffstore(string dstkey, string[] keys...);

  Response!(Set!(string)) sinter(string[] keys...);

  Response!(Long) sinterstore(string dstkey, string[] keys...);

  Response!(Long) smove(string srckey, string dstkey, string member);

  Response!(Long) sort(string key, SortingParams sortingParameters, string dstkey);

  Response!(Long) sort(string key, string dstkey);

  Response!(Set!(string)) sunion(string[] keys...);

  Response!(Long) sunionstore(string dstkey, string[] keys...);

  Response!(string) watch(string[] keys...);

  Response!(Long) zinterstore(string dstkey, string[] sets...);

  Response!(Long) zinterstore(string dstkey, ZParams params, string[] sets...);

  Response!(Long) zunionstore(string dstkey, string[] sets...);

  Response!(Long) zunionstore(string dstkey, ZParams params, string[] sets...);

  Response!(string) brpoplpush(string source, string destination, int timeout);

  Response!(Long) publish(string channel, string message);

  Response!(string) randomKey();

  Response!(Long) bitop(BitOP op, string destKey, string[] srcKeys...);

  Response!(string) pfmerge(string destkey, string[] sourcekeys...);

  Response!(Long) pfcount(string[] keys...);

  Response!(Long) touch(string[] keys...);

  Response!(string) migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, string[] keys...);
}
