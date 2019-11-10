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


deprecated("Using RedisClusterCommands instead.")
interface MultiKeyBinaryRedisClusterCommands {
    // long del(const(ubyte)[][] keys...);

    // long unlink(const(ubyte)[][] keys...);

    long exists(const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) blpop(int timeout, const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) brpop(int timeout, const(ubyte)[][] keys...);

    // List!(const(ubyte)[]) mget(const(ubyte)[][] keys...);

    // string mset(const(ubyte)[][] keysvalues...);

    // long msetnx(const(ubyte)[][] keysvalues...);

    // string rename(const(ubyte)[] oldkey, const(ubyte)[] newkey);

    // long renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey);

    // const(ubyte)[] rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey);

    // Set!(const(ubyte)[]) sdiff(const(ubyte)[][] keys...);

    // long sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // Set!(const(ubyte)[]) sinter(const(ubyte)[][] keys...);

    // long sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // long smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member);

    // long sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey);

    // long sort(const(ubyte)[] key, const(ubyte)[] dstkey);

    // Set!(const(ubyte)[]) sunion(const(ubyte)[][] keys...);

    // long sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...);

    // long zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

    // long zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

    // long zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...);

    // long zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...);

    // const(ubyte)[] brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout);

    // long publish(const(ubyte)[] channel, const(ubyte)[] message);

    // void subscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] channels...);

    // void psubscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] patterns...);

    // long bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...);

    // string pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...);

    // long pfcount(const(ubyte)[][] keys...);

    // long touch(const(ubyte)[][] keys...);

    // ScanResult!(const(ubyte)[]) scan(const(ubyte)[] cursor, ScanParams params);

    // Set!(const(ubyte)[]) keys(const(ubyte)[] pattern);
    
    // List!(const(ubyte)[]) xread(int count, long block, Map!(const(ubyte)[], const(ubyte)[]) streams);
    
    // List!(const(ubyte)[]) xreadGroup(const(ubyte)[] groupname, const(ubyte)[] consumer, int count, long block, bool noAck, Map!(const(ubyte)[], const(ubyte)[]) streams);
}
