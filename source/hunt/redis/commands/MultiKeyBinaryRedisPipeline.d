module hunt.redis.commands.MultiKeyBinaryRedisPipeline;

import hunt.redis.BitOP;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;
import hunt.redis.params.MigrateParams;

import hunt.collection.List;
import hunt.collection.Set;
import hunt.Long;

/**
 * Multikey related commands (these are split out because they are non-shardable)
 */
interface MultiKeyBinaryRedisPipeline {

  Response!(Long) del(byte[][] keys...);

  Response!(Long) unlink(byte[][] keys...);

  Response!(Long) exists(byte[][] keys...);

  Response!(List!(byte[])) blpop(byte[][] args...);

  Response!(List!(byte[])) brpop(byte[][] args...);

  Response!(Set!(byte[])) keys(byte[] pattern);

  Response!(List!(byte[])) mget(byte[][] keys...);

  Response!(string) mset(byte[][] keysvalues...);

  Response!(Long) msetnx(byte[][] keysvalues...);

  Response!(string) rename(byte[] oldkey, byte[] newkey);

  Response!(Long) renamenx(byte[] oldkey, byte[] newkey);

  Response!(byte[]) rpoplpush(byte[] srckey, byte[] dstkey);

  Response!(Set!(byte[])) sdiff(byte[][] keys...);

  Response!(Long) sdiffstore(byte[] dstkey, byte[][] keys...);

  Response!(Set!(byte[])) sinter(byte[][] keys...);

  Response!(Long) sinterstore(byte[] dstkey, byte[][] keys...);

  Response!(Long) smove(byte[] srckey, byte[] dstkey, byte[] member);

  Response!(Long) sort(byte[] key, SortingParams sortingParameters, byte[] dstkey);

  Response!(Long) sort(byte[] key, byte[] dstkey);

  Response!(Set!(byte[])) sunion(byte[][] keys...);

  Response!(Long) sunionstore(byte[] dstkey, byte[][] keys...);

  Response!(string) watch(byte[][] keys...);

  Response!(Long) zinterstore(byte[] dstkey, byte[][] sets...);

  Response!(Long) zinterstore(byte[] dstkey, ZParams params, byte[][] sets...);

  Response!(Long) zunionstore(byte[] dstkey, byte[][] sets...);

  Response!(Long) zunionstore(byte[] dstkey, ZParams params, byte[][] sets...);

  Response!(byte[]) brpoplpush(byte[] source, byte[] destination, int timeout);

  Response!(Long) publish(byte[] channel, byte[] message);

  Response!(byte[]) randomKeyBinary();

  Response!(Long) bitop(BitOP op, byte[] destKey, byte[][] srcKeys...);

  Response!(string) pfmerge(byte[] destkey, byte[][] sourcekeys...);

  Response!(Long) pfcount(byte[][] keys...);

  Response!(Long) touch(byte[][] keys...);

  Response!(string) migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, byte[][] keys...);
}
