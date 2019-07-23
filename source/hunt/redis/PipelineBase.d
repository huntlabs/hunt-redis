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
 
module hunt.redis.PipelineBase;

import hunt.redis.BitPosParams;
import hunt.redis.BuilderFactory;
import hunt.redis.Client;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Queable;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntry;
import hunt.redis.StreamEntryID;
import hunt.redis.StreamPendingEntry;
import hunt.redis.Tuple;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.commands.BinaryRedisPipeline;
import hunt.redis.Protocol;
import hunt.redis.commands.RedisPipeline;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

import std.conv;

abstract class PipelineBase : Queable, BinaryRedisPipeline, RedisPipeline {

  protected abstract Client getClient(string key);

  protected abstract Client getClient(const(ubyte)[] key);

  // override
  Response!(Long) append(string key, string value) {
    getClient(key).append(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) append(const(ubyte)[] key, const(ubyte)[] value) {
    getClient(key).append(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(List!(string)) blpop(string key) {
    string[] temp = new string[1];
    temp[0] = key;
    getClient(key).blpop(temp);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(string)) brpop(string key) {
    string[] temp = new string[1];
    temp[0] = key;
    getClient(key).brpop(temp);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) blpop(const(ubyte)[] key) {
    const(ubyte)[][] temp = new const(ubyte)[][1];
    temp[0] = key;
    getClient(key).blpop(temp);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) brpop(const(ubyte)[] key) {
    const(ubyte)[][] temp = new const(ubyte)[][1];
    temp[0] = key;
    getClient(key).brpop(temp);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(Long) decr(string key) {
    getClient(key).decr(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) decr(const(ubyte)[] key) {
    getClient(key).decr(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) decrBy(string key, long decrement) {
    getClient(key).decrBy(key, decrement);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) decrBy(const(ubyte)[] key, long decrement) {
    getClient(key).decrBy(key, decrement);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) del(string key) {
    getClient(key).del(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) del(const(ubyte)[] key) {
    getClient(key).del(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) unlink(string key) {
    getClient(key).unlink(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) unlink(const(ubyte)[] key) {
    getClient(key).unlink(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) echo(string string) {
    getClient(string).echo(string);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) echo(const(ubyte)[] string) {
    getClient(string).echo(string);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Boolean) exists(string key) {
    getClient(key).exists(key);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Boolean) exists(const(ubyte)[] key) {
    getClient(key).exists(key);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Long) expire(string key, int seconds) {
    getClient(key).expire(key, seconds);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) expire(const(ubyte)[] key, int seconds) {
    getClient(key).expire(key, seconds);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) expireAt(string key, long unixTime) {
    getClient(key).expireAt(key, unixTime);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) expireAt(const(ubyte)[] key, long unixTime) {
    getClient(key).expireAt(key, unixTime);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) get(string key) {
    getClient(key).get(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) get(const(ubyte)[] key) {
    getClient(key).get(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Boolean) getbit(string key, long offset) {
    getClient(key).getbit(key, offset);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Boolean) getbit(const(ubyte)[] key, long offset) {
    getClient(key).getbit(key, offset);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Long) bitpos(string key, bool value) {
    return bitpos(key, value, new BitPosParams());
  }

  // override
  Response!(Long) bitpos(string key, bool value, BitPosParams params) {
    getClient(key).bitpos(key, value, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) bitpos(const(ubyte)[] key, bool value) {
    return bitpos(key, value, new BitPosParams());
  }

  // override
  Response!(Long) bitpos(const(ubyte)[] key, bool value, BitPosParams params) {
    getClient(key).bitpos(key, value, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) getrange(string key, long startOffset, long endOffset) {
    getClient(key).getrange(key, startOffset, endOffset);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) getSet(string key, string value) {
    getClient(key).getSet(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) getSet(const(ubyte)[] key, const(ubyte)[] value) {
    getClient(key).getSet(key, value);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(const(ubyte)[]) getrange(const(ubyte)[] key, long startOffset, long endOffset) {
    getClient(key).getrange(key, startOffset, endOffset);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Long) hdel(string key, string[] field...) {
    getClient(key).hdel(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hdel(const(ubyte)[] key, const(ubyte)[][] field...) {
    getClient(key).hdel(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Boolean) hexists(string key, string field) {
    getClient(key).hexists(key, field);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Boolean) hexists(const(ubyte)[] key, const(ubyte)[] field) {
    getClient(key).hexists(key, field);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(string) hget(string key, string field) {
    getClient(key).hget(key, field);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) hget(const(ubyte)[] key, const(ubyte)[] field) {
    getClient(key).hget(key, field);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Map!(string, string)) hgetAll(string key) {
    getClient(key).hgetAll(key);
    return getResponse(BuilderFactory.STRING_MAP);
  }

  // override
  Response!(Map!(const(ubyte)[], const(ubyte)[])) hgetAll(const(ubyte)[] key) {
    getClient(key).hgetAll(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_MAP);
  }

  // override
  Response!(Long) hincrBy(string key, string field, long value) {
    getClient(key).hincrBy(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value) {
    getClient(key).hincrBy(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Set!(string)) hkeys(string key) {
    getClient(key).hkeys(key);
    return getResponse(BuilderFactory.STRING_SET);
  }

  // override
  Response!(Set!(const(ubyte)[])) hkeys(const(ubyte)[] key) {
    getClient(key).hkeys(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Long) hlen(string key) {
    getClient(key).hlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hlen(const(ubyte)[] key) {
    getClient(key).hlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(List!(string)) hmget(string key, string[] fields...) {
    getClient(key).hmget(key, fields);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) hmget(const(ubyte)[] key, const(ubyte)[][] fields...) {
    getClient(key).hmget(key, fields);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(string) hmset(string key, Map!(string, string) hash) {
    getClient(key).hmset(key, hash);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
    getClient(key).hmset(key, hash);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) hset(string key, string field, string value) {
    getClient(key).hset(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
    getClient(key).hset(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hset(string key, Map!(string, string) hash) {
    getClient(key).hset(key, hash);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
    getClient(key).hset(key, hash);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hsetnx(string key, string field, string value) {
    getClient(key).hsetnx(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
    getClient(key).hsetnx(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(List!(string)) hvals(string key) {
    getClient(key).hvals(key);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) hvals(const(ubyte)[] key) {
    getClient(key).hvals(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(Long) incr(string key) {
    getClient(key).incr(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) incr(const(ubyte)[] key) {
    getClient(key).incr(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) incrBy(string key, long increment) {
    getClient(key).incrBy(key, increment);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) incrBy(const(ubyte)[] key, long increment) {
    getClient(key).incrBy(key, increment);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) lindex(string key, long index) {
    getClient(key).lindex(key, index);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) lindex(const(ubyte)[] key, long index) {
    getClient(key).lindex(key, index);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Long) linsert(string key, ListPosition where, string pivot, string value) {
    getClient(key).linsert(key, where, pivot, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot, const(ubyte)[] value) {
    getClient(key).linsert(key, where, pivot, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) llen(string key) {
    getClient(key).llen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) llen(const(ubyte)[] key) {
    getClient(key).llen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) lpop(string key) {
    getClient(key).lpop(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) lpop(const(ubyte)[] key) {
    getClient(key).lpop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Long) lpush(string key, string[] string...) {
    getClient(key).lpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) lpush(const(ubyte)[] key, const(ubyte)[][] string...) {
    getClient(key).lpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) lpushx(string key, string[] string...) {
    getClient(key).lpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) lpushx(const(ubyte)[] key, const(ubyte)[][] bytes...) {
    getClient(key).lpushx(key, bytes);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(List!(string)) lrange(string key, long start, long stop) {
    getClient(key).lrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) lrange(const(ubyte)[] key, long start, long stop) {
    getClient(key).lrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(Long) lrem(string key, long count, string value) {
    getClient(key).lrem(key, count, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) lrem(const(ubyte)[] key, long count, const(ubyte)[] value) {
    getClient(key).lrem(key, count, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) lset(string key, long index, string value) {
    getClient(key).lset(key, index, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) lset(const(ubyte)[] key, long index, const(ubyte)[] value) {
    getClient(key).lset(key, index, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) ltrim(string key, long start, long stop) {
    getClient(key).ltrim(key, start, stop);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) ltrim(const(ubyte)[] key, long start, long stop) {
    getClient(key).ltrim(key, start, stop);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) move(string key, int dbIndex) {
    getClient(key).move(key, dbIndex);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) move(const(ubyte)[] key, int dbIndex) {
    getClient(key).move(key, dbIndex);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) persist(string key) {
    getClient(key).persist(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) persist(const(ubyte)[] key) {
    getClient(key).persist(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) rpop(string key) {
    getClient(key).rpop(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) rpop(const(ubyte)[] key) {
    getClient(key).rpop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Long) rpush(string key, string[] string...) {
    getClient(key).rpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) rpush(const(ubyte)[] key, const(ubyte)[][] string...) {
    getClient(key).rpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) rpushx(string key, string[] string...) {
    getClient(key).rpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) rpushx(const(ubyte)[] key, const(ubyte)[][] string...) {
    getClient(key).rpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) sadd(string key, string[] member...) {
    getClient(key).sadd(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) sadd(const(ubyte)[] key, const(ubyte)[][] member...) {
    getClient(key).sadd(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) scard(string key) {
    getClient(key).scard(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) scard(const(ubyte)[] key) {
    getClient(key).scard(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) set(string key, string value) {
    getClient(key).set(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) set(const(ubyte)[] key, const(ubyte)[] value) {
    getClient(key).set(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) set(string key, string value, SetParams params) {
    getClient(key).set(key, value, params);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) set(const(ubyte)[] key, const(ubyte)[] value, SetParams params) {
    getClient(key).set(key, value, params);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Boolean) setbit(string key, long offset, bool value) {
    getClient(key).setbit(key, offset, value);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Boolean) setbit(const(ubyte)[] key, long offset, const(ubyte)[] value) {
    getClient(key).setbit(key, offset, value);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(string) setex(string key, int seconds, string value) {
    getClient(key).setex(key, seconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) setex(const(ubyte)[] key, int seconds, const(ubyte)[] value) {
    getClient(key).setex(key, seconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) setnx(string key, string value) {
    getClient(key).setnx(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) setnx(const(ubyte)[] key, const(ubyte)[] value) {
    getClient(key).setnx(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) setrange(string key, long offset, string value) {
    getClient(key).setrange(key, offset, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) setrange(const(ubyte)[] key, long offset, const(ubyte)[] value) {
    getClient(key).setrange(key, offset, value);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Boolean) sismember(string key, string member) {
    getClient(key).sismember(key, member);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Boolean) sismember(const(ubyte)[] key, const(ubyte)[] member) {
    getClient(key).sismember(key, member);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  // override
  Response!(Set!(string)) smembers(string key) {
    getClient(key).smembers(key);
    return getResponse(BuilderFactory.STRING_SET);
  }

  // override
  Response!(Set!(const(ubyte)[])) smembers(const(ubyte)[] key) {
    getClient(key).smembers(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(List!(string)) sort(string key) {
    getClient(key).sort(key);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) sort(const(ubyte)[] key) {
    getClient(key).sort(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(List!(string)) sort(string key, SortingParams sortingParameters) {
    getClient(key).sort(key, sortingParameters);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(const(ubyte)[])) sort(const(ubyte)[] key, SortingParams sortingParameters) {
    getClient(key).sort(key, sortingParameters);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(string) spop(string key) {
    getClient(key).spop(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Set!(string)) spop(string key, long count) {
    getClient(key).spop(key, count);
    return getResponse(BuilderFactory.STRING_SET);
  }

  // override
  Response!(const(ubyte)[]) spop(const(ubyte)[] key) {
    getClient(key).spop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Set!(const(ubyte)[])) spop(const(ubyte)[] key, long count) {
    getClient(key).spop(key, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(string) srandmember(string key) {
    getClient(key).srandmember(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(List!(string)) srandmember(string key, int count) {
    getClient(key).srandmember(key, count);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(const(ubyte)[]) srandmember(const(ubyte)[] key) {
    getClient(key).srandmember(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(List!(const(ubyte)[])) srandmember(const(ubyte)[] key, int count) {
    getClient(key).srandmember(key, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(Long) srem(string key, string[] member...) {
    getClient(key).srem(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) srem(const(ubyte)[] key, const(ubyte)[][] member...) {
    getClient(key).srem(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) strlen(string key) {
    getClient(key).strlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) strlen(const(ubyte)[] key) {
    getClient(key).strlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) substr(string key, int start, int end) {
    getClient(key).substr(key, start, end);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) substr(const(ubyte)[] key, int start, int end) {
    getClient(key).substr(key, start, end);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) touch(string key) {
    getClient(key).touch(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) touch(const(ubyte)[] key) {
    getClient(key).touch(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) ttl(string key) {
    getClient(key).ttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) ttl(const(ubyte)[] key) {
    getClient(key).ttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) type(string key) {
    getClient(key).type(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) type(const(ubyte)[] key) {
    getClient(key).type(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) zadd(string key, double score, string member) {
    getClient(key).zadd(key, score, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(string key, double score, string member, ZAddParams params) {
    getClient(key).zadd(key, score, member, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(string key, Map!(string, double) scoreMembers) {
    getClient(key).zadd(key, scoreMembers);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(string key, Map!(string, double) scoreMembers, ZAddParams params) {
    getClient(key).zadd(key, scoreMembers, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(const(ubyte)[] key, double score, const(ubyte)[] member) {
    getClient(key).zadd(key, score, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params) {
    getClient(key).zadd(key, score, member, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers) {
    getClient(key).zadd(key, scoreMembers);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers, ZAddParams params) {
    getClient(key).zadd(key, scoreMembers, params);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcard(string key) {
    getClient(key).zcard(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcard(const(ubyte)[] key) {
    getClient(key).zcard(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcount(string key, double min, double max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcount(string key, string min, string max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcount(const(ubyte)[] key, double min, double max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Double) zincrby(string key, double increment, string member) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) zincrby(string key, double increment, string member, ZIncrByParams params) {
    getClient(key).zincrby(key, increment, member, params);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Set!(string)) zrange(string key, long start, long stop) {
    getClient(key).zrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrange(const(ubyte)[] key, long start, long stop) {
    getClient(key).zrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByScore(string key, double min, double max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, double min, double max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByScore(string key, string min, string max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByScore(string key, double min, double max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByScore(string key, string min, string max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, double min, double max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, double max, double min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, double max, double min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeWithScores(string key, long start, long stop) {
    getClient(key).zrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrangeWithScores(const(ubyte)[] key, long start, long stop) {
    getClient(key).zrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Long) zrank(string key, string member) {
    getClient(key).zrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zrank(const(ubyte)[] key, const(ubyte)[] member) {
    getClient(key).zrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zrem(string key, string[] members...) {
    getClient(key).zrem(key, members);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zrem(const(ubyte)[] key, const(ubyte)[][] members...) {
    getClient(key).zrem(key, members);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByRank(string key, long start, long stop) {
    getClient(key).zremrangeByRank(key, start, stop);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByRank(const(ubyte)[] key, long start, long stop) {
    getClient(key).zremrangeByRank(key, start, stop);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByScore(string key, double min, double max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByScore(string key, string min, string max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByScore(const(ubyte)[] key, double min, double max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Set!(string)) zrevrange(string key, long start, long stop) {
    getClient(key).zrevrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrange(const(ubyte)[] key, long start, long stop) {
    getClient(key).zrevrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeWithScores(string key, long start, long stop) {
    getClient(key).zrevrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Set!(Tuple)) zrevrangeWithScores(const(ubyte)[] key, long start, long stop) {
    getClient(key).zrevrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  // override
  Response!(Long) zrevrank(string key, string member) {
    getClient(key).zrevrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zrevrank(const(ubyte)[] key, const(ubyte)[] member) {
    getClient(key).zrevrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Double) zscore(string key, string member) {
    getClient(key).zscore(key, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) zscore(const(ubyte)[] key, const(ubyte)[] member) {
    getClient(key).zscore(key, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Long) zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zlexcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zlexcount(string key, string min, string max) {
    getClient(key).zlexcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zrangeByLex(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByLex(string key, string min, string max) {
    getClient(key).zrangeByLex(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
      int offset, int count) {
    getClient(key).zrangeByLex(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrangeByLex(string key, string min, string max,
      int offset, int count) {
    getClient(key).zrangeByLex(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
    getClient(key).zrevrangeByLex(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min) {
    getClient(key).zrevrangeByLex(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Set!(const(ubyte)[])) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
      int offset, int count) {
    getClient(key).zrevrangeByLex(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  // override
  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min,
      int offset, int count) {
    getClient(key).zrevrangeByLex(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  // override
  Response!(Long) zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
    getClient(key).zremrangeByLex(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) zremrangeByLex(string key, string min, string max) {
    getClient(key).zremrangeByLex(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) bitcount(string key) {
    getClient(key).bitcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) bitcount(string key, long start, long end) {
    getClient(key).bitcount(key, start, end);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) bitcount(const(ubyte)[] key) {
    getClient(key).bitcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) bitcount(const(ubyte)[] key, long start, long end) {
    getClient(key).bitcount(key, start, end);
    return getResponse(BuilderFactory.LONG);
  }

  // // override
  Response!(const(ubyte)[]) dump(string key) {
    getClient(key).dump(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(const(ubyte)[]) dump(const(ubyte)[] key) {
    getClient(key).dump(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(string) migrate(string host, int port,
      string key, int destinationDb, int timeout) {
    getClient(key).migrate(host, port, key, destinationDb, timeout);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) migrate(string host, int port,
      const(ubyte)[] key, int destinationDb, int timeout) {
    getClient(key).migrate(host, port, key, destinationDb, timeout);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Long) objectRefcount(string key) {
    getClient(key).objectRefcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) objectRefcount(const(ubyte)[] key) {
    getClient(key).objectRefcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) objectEncoding(string key) {
    getClient(key).objectEncoding(key);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(const(ubyte)[]) objectEncoding(const(ubyte)[] key) {
    getClient(key).objectEncoding(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  // override
  Response!(Long) objectIdletime(string key) {
    getClient(key).objectIdletime(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) objectIdletime(const(ubyte)[] key) {
    getClient(key).objectIdletime(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pexpire(string key, long milliseconds) {
    getClient(key).pexpire(key, milliseconds);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pexpire(const(ubyte)[] key, long milliseconds) {
    getClient(key).pexpire(key, milliseconds);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pexpireAt(string key, long millisecondsTimestamp) {
    getClient(key).pexpireAt(key, millisecondsTimestamp);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pexpireAt(const(ubyte)[] key, long millisecondsTimestamp) {
    getClient(key).pexpireAt(key, millisecondsTimestamp);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pttl(string key) {
    getClient(key).pttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pttl(const(ubyte)[] key) {
    getClient(key).pttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(string) restore(string key, int ttl, const(ubyte)[] serializedValue) {
    getClient(key).restore(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
    getClient(key).restore(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) restoreReplace(string key, int ttl, const(ubyte)[] serializedValue) {
    getClient(key).restoreReplace(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
    getClient(key).restoreReplace(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Double) incrByFloat(string key, double increment) {
    getClient(key).incrByFloat(key, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) incrByFloat(const(ubyte)[] key, double increment) {
    getClient(key).incrByFloat(key, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(string) psetex(string key, long milliseconds, string value) {
    getClient(key).psetex(key, milliseconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(string) psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value) {
    getClient(key).psetex(key, milliseconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  // override
  Response!(Double) hincrByFloat(string key, string field, double increment) {
    getClient(key).hincrByFloat(key, field, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double increment) {
    getClient(key).hincrByFloat(key, field, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Long) pfadd(const(ubyte)[] key, const(ubyte)[][] elements...) {
    getClient(key).pfadd(key, elements);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pfcount(const(ubyte)[] key) {
    getClient(key).pfcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pfadd(string key, string[] elements...) {
    getClient(key).pfadd(key, elements);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) pfcount(string key) {
    getClient(key).pfcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member) {
    getClient(key).geoadd(key, longitude, latitude, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
    getClient(key).geoadd(key, memberCoordinateMap);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) geoadd(string key, double longitude, double latitude, string member) {
    getClient(key).geoadd(key, longitude, latitude, member);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
    getClient(key).geoadd(key, memberCoordinateMap);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Double) geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit) {
    getClient(key).geodist(key, member1, member2, unit);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) geodist(string key, string member1, string member2) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(Double) geodist(string key, string member1, string member2, GeoUnit unit) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  // override
  Response!(List!(const(ubyte)[])) geohash(const(ubyte)[] key, const(ubyte)[][] members...) {
    getClient(key).geohash(key, members);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  // override
  Response!(List!(string)) geohash(string key, string[] members...) {
    getClient(key).geohash(key, members);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  // override
  Response!(List!(GeoCoordinate)) geopos(const(ubyte)[] key, const(ubyte)[][] members...) {
    getClient(key).geopos(key, members);
    return getResponse(BuilderFactory.GEO_COORDINATE_LIST);
  }

  // override
  Response!(List!(GeoCoordinate)) geopos(string key, string[] members...) {
    getClient(key).geopos(key, members);
    return getResponse(BuilderFactory.GEO_COORDINATE_LIST);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadius(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadius(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadius(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadius(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadius(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadius(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMember(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMember(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMember(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMember(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  // override
  Response!(List!(Long)) bitfield(string key, string[] elements...) {
    getClient(key).bitfield(key, elements);
    return getResponse(BuilderFactory.LONG_LIST);
  }

  // override
  Response!(List!(Long)) bitfield(const(ubyte)[] key, const(ubyte)[][] elements...) {
    getClient(key).bitfield(key, elements);
    return getResponse(BuilderFactory.LONG_LIST);
  }

  // override
  Response!(Long) hstrlen(string key, string field) {
    getClient(key).hstrlen(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  // override
  Response!(Long) hstrlen(const(ubyte)[] key, const(ubyte)[] field) {
    getClient(key).hstrlen(key, field);
    return getResponse(BuilderFactory.LONG);
  }
  
  // override
  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash){
    return xadd(key, id, hash, Long.MAX_VALUE, true);    
  }
  
  // override
  Response!(const(ubyte)[]) xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash){
    return xadd(key, id, hash, Long.MAX_VALUE, true);
  }


  // override
  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength){
    getClient(key).xadd(key, id, hash, maxLen, approximateLength);
    return getResponse(BuilderFactory.STREAM_ENTRY_ID);    
  }
  

  // override
  Response!(const(ubyte)[]) xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength){
    getClient(key).xadd(key, id, hash, maxLen, approximateLength);
    return getResponse(BuilderFactory.BYTE_ARRAY);        
  }

  
  // override
  Response!(Long) xlen(string key){
    getClient(key).xlen(key);
    return getResponse(BuilderFactory.LONG);
  }
  
  // override
  Response!(Long) xlen(const(ubyte)[] key){
    getClient(key).xlen(key);
    return getResponse(BuilderFactory.LONG);    
  }

  // override
  Response!(List!(StreamEntry)) xrange(string key, StreamEntryID start, StreamEntryID end, int count){
    getClient(key).xrange(key, start, end, count);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);        
  }

  // override
  Response!(List!(const(ubyte)[])) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, int count){
    getClient(key).xrange(key, start, end, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);            
  }

  // override
  Response!(List!(StreamEntry)) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count){
    getClient(key).xrevrange(key, start, end, count);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);            
  }

  // override
  Response!(List!(const(ubyte)[])) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count){
    getClient(key).xrevrange(key, start, end, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);                
  }

   
  // override
  Response!(Long) xack(string key, string group,  StreamEntryID[] ids...){
    getClient(key).xack(key, group, ids);
    return getResponse(BuilderFactory.LONG);                
  }
  
  // override
  Response!(Long) xack(const(ubyte)[] key, const(ubyte)[] group,  const(ubyte)[][] ids...){
    getClient(key).xack(key, group, ids);
    return getResponse(BuilderFactory.LONG);                    
  }
  
  // override
  Response!(string) xgroupCreate( string key, string groupname, StreamEntryID id, bool makeStream){
    getClient(key).xgroupCreate(key, groupname, id, makeStream);
    return getResponse(BuilderFactory.STRING);
  }
  
  // override
  Response!(string) xgroupCreate(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id, bool makeStream){
    getClient(key).xgroupCreate(key, groupname, id, makeStream);
    return getResponse(BuilderFactory.STRING);    
  }
  
  // override
  Response!(string) xgroupSetID( string key, string groupname, StreamEntryID id){
    getClient(key).xgroupSetID(key, groupname, id);
    return getResponse(BuilderFactory.STRING);
  }
  
  // override
  Response!(string) xgroupSetID(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] id){
    getClient(key).xgroupSetID(key, groupname, id);
    return getResponse(BuilderFactory.STRING);    
  }
  
  // override
  Response!(Long) xgroupDestroy( string key, string groupname){
    getClient(key).xgroupDestroy(key, groupname);
    return getResponse(BuilderFactory.LONG);
  }
  
  // override
  Response!(Long) xgroupDestroy(const(ubyte)[] key, const(ubyte)[] groupname){
    getClient(key).xgroupDestroy(key, groupname);
    return getResponse(BuilderFactory.LONG);
  }
  
  // override
  Response!(string) xgroupDelConsumer( string key, string groupname, string consumername){
    getClient(key).xgroupDelConsumer(key, groupname, consumername);
    return getResponse(BuilderFactory.STRING);
  }
  
  // override
  Response!(string) xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername){
    getClient(key).xgroupDelConsumer(key, groupname, consumername);
    return getResponse(BuilderFactory.STRING);    
  }

  // override
  Response!(List!(StreamPendingEntry)) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername){
    getClient(key).xpending(key, groupname, start, end, count, consumername);
    return getResponse(BuilderFactory.STREAM_PENDING_ENTRY_LIST);        
  }
  
  // override
  Response!(List!(StreamPendingEntry)) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername){
    getClient(key).xpending(key, groupname, start, end, count, consumername);
    return getResponse(BuilderFactory.STREAM_PENDING_ENTRY_LIST);            
  }

  
  // override
  Response!(Long) xdel( string key, StreamEntryID[] ids...){
    getClient(key).xdel(key, ids);
    return getResponse(BuilderFactory.LONG);        
  }

  // override
  Response!(Long) xdel(const(ubyte)[] key, const(ubyte)[][] ids...){
    getClient(key).xdel(key, ids);
    return getResponse(BuilderFactory.LONG);            
  }
  
  // override
  Response!(Long) xtrim( string key, long maxLen, bool approximateLength){
    getClient(key).xtrim(key, maxLen, approximateLength);
    return getResponse(BuilderFactory.LONG);        
  }
  
  // override
  Response!(Long) xtrim(const(ubyte)[] key, long maxLen, bool approximateLength){
    getClient(key).xtrim(key, maxLen, approximateLength);
    return getResponse(BuilderFactory.LONG);            
  }
 
  // override
  Response!(List!(StreamEntry)) xclaim( string key, string group, string consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, StreamEntryID[] ids...){
    getClient(key).xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);        
  }
 
  // override
  Response!(List!(const(ubyte)[])) xclaim(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[] consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, const(ubyte)[][] ids...){
    getClient(key).xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);            
  }

  // override
  Response!(Object) sendCommand(ProtocolCommand cmd, string[] args...){
    string key = args.length > 0 ? args[0] : cmd.to!string();
    getClient(key).sendCommand(cmd, args);
    return getResponse(BuilderFactory.OBJECT);
  }

  // override
  Response!(Object) sendCommand(ProtocolCommand cmd, const(ubyte)[][] args...){
    const(ubyte)[] key = args.length > 0 ? args[0] : cast(const(ubyte)[])(cmd.to!string());
    getClient(key).sendCommand(cmd, args);
    return getResponse(BuilderFactory.OBJECT);
  }
}
