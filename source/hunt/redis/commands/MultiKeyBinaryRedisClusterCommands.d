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
 
module hunt.redis.commands.MultiKeyBinaryRedisClusterCommands;

import hunt.redis.BinaryRedisPubSub;
import hunt.redis.BitOP;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Long;

interface MultiKeyBinaryRedisClusterCommands {
    // Long del(const(ubyte)[][] keys...);

    // Long unlink(const(ubyte)[][] keys...);

    // Long exists(const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) blpop(int timeout, const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) brpop(int timeout, const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) mget(const(ubyte)[][] keys...);

    // string mset(const(ubyte)[][] keysvalues...);

    // Long msetnx(const(ubyte)[][] keysvalues...);

    // string rename(const(ubyte)[] oldkey, const(ubyte)[] newkey);

    // Long renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey);

    // const(ubyte)[] rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey);

    // Set!(const(ubyte)[]) sdiff(const(ubyte)[][] keys...);

    // Long sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // Set!(const(ubyte)[]) sinter(const(ubyte)[][] keys...);

    // Long sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // Long smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member);

    // Long sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey);

    // Long sort(const(ubyte)[] key, const(ubyte)[] dstkey);

    // Set!(const(ubyte)[]) sunion(const(ubyte)[][] keys...);

    // Long sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // Long zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

    // Long zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

    // Long zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

    // Long zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

    // const(ubyte)[] brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout);

    // Long publish(const(ubyte)[] channel, const(ubyte)[] message);

    // void subscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] channels...);

    // void psubscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] patterns...);

    // Long bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...);

    // string pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...);

    // Long pfcount(const(ubyte)[][] keys...);

    // Long touch(const(ubyte)[][] keys...);

    // ScanResult!(const(ubyte)[]) scan(const(ubyte)[] cursor, ScanParams params);

    // Set!(const(ubyte)[]) keys(const(ubyte)[] pattern);
    
    // List!(const(ubyte)[]) xread(int count, long block, Map!(const(ubyte)[], const(ubyte)[]) streams);
    
    // List!(const(ubyte)[]) xreadGroup(const(ubyte)[] groupname, const(ubyte)[] consumer, int count, long block, bool noAck, Map!(const(ubyte)[], const(ubyte)[]) streams);
}
