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
 
module hunt.redis.commands.MultiKeyRedisClusterCommands;

import hunt.redis.BitOP;
import hunt.redis.RedisPubSub;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;

import hunt.collection.List;
import hunt.collection.Set;


interface MultiKeyRedisClusterCommands {
  long del(string[] keys...);

  long unlink(string[] keys...);

  long exists(string[] keys...);

  List!(string) blpop(int timeout, string[] keys...);

  List!(string) brpop(int timeout, string[] keys...);

  List!(string) mget(string[] keys...);

  string mset(string[] keysvalues...);

  long msetnx(string[] keysvalues...);

  string rename(string oldkey, string newkey);

  long renamenx(string oldkey, string newkey);

  string rpoplpush(string srckey, string dstkey);

  Set!(string) sdiff(string[] keys...);

  long sdiffstore(string dstkey, string[] keys...);

  Set!(string) sinter(string[] keys...);

  long sinterstore(string dstkey, string[] keys...);

  long smove(string srckey, string dstkey, string member);

  long sort(string key, SortingParams sortingParameters, string dstkey);

  long sort(string key, string dstkey);

  Set!(string) sunion(string[] keys...);

  long sunionstore(string dstkey, string[] keys...);

  long zinterstore(string dstkey, string[] sets...);

  long zinterstore(string dstkey, ZParams params, string[] sets...);

  long zunionstore(string dstkey, string[] sets...);

  long zunionstore(string dstkey, ZParams params, string[] sets...);

  string brpoplpush(string source, string destination, int timeout);

  long publish(string channel, string message);

  void subscribe(RedisPubSub redisPubSub, string[] channels...);

  void psubscribe(RedisPubSub redisPubSub, string[] patterns...);

  long bitop(BitOP op, string destKey, string[] srcKeys...);

  string pfmerge(string destkey, string[] sourcekeys...);

  long pfcount(string[] keys...);

  long touch(string[] keys...);

  ScanResult!(string) scan(string cursor, ScanParams params);

  Set!(string) keys(string pattern);
}
