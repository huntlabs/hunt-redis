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

  Response!(Long) del(const(ubyte)[][] keys...);

  Response!(Long) unlink(const(ubyte)[][] keys...);

  Response!(Long) exists(const(ubyte)[][] keys...);

  Response!(List!(const(ubyte)[])) blpop(const(ubyte)[][] args...);

  Response!(List!(const(ubyte)[])) brpop(const(ubyte)[][] args...);

  Response!(Set!(const(ubyte)[])) keys(const(ubyte)[] pattern);

  Response!(List!(const(ubyte)[])) mget(const(ubyte)[][] keys...);

  Response!(string) mset(const(ubyte)[][] keysvalues...);

  Response!(Long) msetnx(const(ubyte)[][] keysvalues...);

  Response!(string) rename(const(ubyte)[] oldkey, const(ubyte)[] newkey);

  Response!(Long) renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey);

  Response!(const(ubyte)[]) rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey);

  Response!(Set!(const(ubyte)[])) sdiff(const(ubyte)[][] keys...);

  Response!(Long) sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

  Response!(Set!(const(ubyte)[])) sinter(const(ubyte)[][] keys...);

  Response!(Long) sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

  Response!(Long) smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member);

  Response!(Long) sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey);

  Response!(Long) sort(const(ubyte)[] key, const(ubyte)[] dstkey);

  Response!(Set!(const(ubyte)[])) sunion(const(ubyte)[][] keys...);

  Response!(Long) sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

  Response!(string) watch(const(ubyte)[][] keys...);

  Response!(Long) zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

  Response!(Long) zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

  Response!(Long) zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

  Response!(Long) zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

  Response!(const(ubyte)[]) brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout);

  Response!(Long) publish(const(ubyte)[] channel, const(ubyte)[] message);

  Response!(const(ubyte)[]) randomKeyBinary();

  Response!(Long) bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...);

  Response!(string) pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...);

  Response!(Long) pfcount(const(ubyte)[][] keys...);

  Response!(Long) touch(const(ubyte)[][] keys...);

  Response!(string) migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, const(ubyte)[][] keys...);
}
