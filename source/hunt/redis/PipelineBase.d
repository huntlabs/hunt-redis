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

  protected abstract Client getClient(byte[] key);

  override
  Response!(Long) append(string key, string value) {
    getClient(key).append(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) append(byte[] key, byte[] value) {
    getClient(key).append(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(List!(string)) blpop(string key) {
    string[] temp = new string[1];
    temp[0] = key;
    getClient(key).blpop(temp);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(string)) brpop(string key) {
    string[] temp = new string[1];
    temp[0] = key;
    getClient(key).brpop(temp);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) blpop(byte[] key) {
    byte[][] temp = new byte[][1];
    temp[0] = key;
    getClient(key).blpop(temp);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(List!(byte[])) brpop(byte[] key) {
    byte[][] temp = new byte[][1];
    temp[0] = key;
    getClient(key).brpop(temp);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(Long) decr(string key) {
    getClient(key).decr(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) decr(byte[] key) {
    getClient(key).decr(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) decrBy(string key, long decrement) {
    getClient(key).decrBy(key, decrement);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) decrBy(byte[] key, long decrement) {
    getClient(key).decrBy(key, decrement);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) del(string key) {
    getClient(key).del(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) del(byte[] key) {
    getClient(key).del(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) unlink(string key) {
    getClient(key).unlink(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) unlink(byte[] key) {
    getClient(key).unlink(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) echo(string string) {
    getClient(string).echo(string);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) echo(byte[] string) {
    getClient(string).echo(string);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Boolean) exists(string key) {
    getClient(key).exists(key);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Boolean) exists(byte[] key) {
    getClient(key).exists(key);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Long) expire(string key, int seconds) {
    getClient(key).expire(key, seconds);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) expire(byte[] key, int seconds) {
    getClient(key).expire(key, seconds);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) expireAt(string key, long unixTime) {
    getClient(key).expireAt(key, unixTime);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) expireAt(byte[] key, long unixTime) {
    getClient(key).expireAt(key, unixTime);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) get(string key) {
    getClient(key).get(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) get(byte[] key) {
    getClient(key).get(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Boolean) getbit(string key, long offset) {
    getClient(key).getbit(key, offset);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Boolean) getbit(byte[] key, long offset) {
    getClient(key).getbit(key, offset);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Long) bitpos(string key, bool value) {
    return bitpos(key, value, new BitPosParams());
  }

  override
  Response!(Long) bitpos(string key, bool value, BitPosParams params) {
    getClient(key).bitpos(key, value, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) bitpos(byte[] key, bool value) {
    return bitpos(key, value, new BitPosParams());
  }

  override
  Response!(Long) bitpos(byte[] key, bool value, BitPosParams params) {
    getClient(key).bitpos(key, value, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) getrange(string key, long startOffset, long endOffset) {
    getClient(key).getrange(key, startOffset, endOffset);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) getSet(string key, string value) {
    getClient(key).getSet(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) getSet(byte[] key, byte[] value) {
    getClient(key).getSet(key, value);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(byte[]) getrange(byte[] key, long startOffset, long endOffset) {
    getClient(key).getrange(key, startOffset, endOffset);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Long) hdel(string key, string[] field...) {
    getClient(key).hdel(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hdel(byte[] key, byte[][] field...) {
    getClient(key).hdel(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Boolean) hexists(string key, string field) {
    getClient(key).hexists(key, field);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Boolean) hexists(byte[] key, byte[] field) {
    getClient(key).hexists(key, field);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(string) hget(string key, string field) {
    getClient(key).hget(key, field);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) hget(byte[] key, byte[] field) {
    getClient(key).hget(key, field);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Map!(string, string)) hgetAll(string key) {
    getClient(key).hgetAll(key);
    return getResponse(BuilderFactory.STRING_MAP);
  }

  override
  Response!(Map!(byte[], byte[])) hgetAll(byte[] key) {
    getClient(key).hgetAll(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_MAP);
  }

  override
  Response!(Long) hincrBy(string key, string field, long value) {
    getClient(key).hincrBy(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hincrBy(byte[] key, byte[] field, long value) {
    getClient(key).hincrBy(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Set!(string)) hkeys(string key) {
    getClient(key).hkeys(key);
    return getResponse(BuilderFactory.STRING_SET);
  }

  override
  Response!(Set!(byte[])) hkeys(byte[] key) {
    getClient(key).hkeys(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Long) hlen(string key) {
    getClient(key).hlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hlen(byte[] key) {
    getClient(key).hlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(List!(string)) hmget(string key, string[] fields...) {
    getClient(key).hmget(key, fields);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) hmget(byte[] key, byte[][] fields...) {
    getClient(key).hmget(key, fields);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(string) hmset(string key, Map!(string, string) hash) {
    getClient(key).hmset(key, hash);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) hmset(byte[] key, Map!(byte[], byte[]) hash) {
    getClient(key).hmset(key, hash);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) hset(string key, string field, string value) {
    getClient(key).hset(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hset(byte[] key, byte[] field, byte[] value) {
    getClient(key).hset(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hset(string key, Map!(string, string) hash) {
    getClient(key).hset(key, hash);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hset(byte[] key, Map!(byte[], byte[]) hash) {
    getClient(key).hset(key, hash);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hsetnx(string key, string field, string value) {
    getClient(key).hsetnx(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hsetnx(byte[] key, byte[] field, byte[] value) {
    getClient(key).hsetnx(key, field, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(List!(string)) hvals(string key) {
    getClient(key).hvals(key);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) hvals(byte[] key) {
    getClient(key).hvals(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(Long) incr(string key) {
    getClient(key).incr(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) incr(byte[] key) {
    getClient(key).incr(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) incrBy(string key, long increment) {
    getClient(key).incrBy(key, increment);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) incrBy(byte[] key, long increment) {
    getClient(key).incrBy(key, increment);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) lindex(string key, long index) {
    getClient(key).lindex(key, index);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) lindex(byte[] key, long index) {
    getClient(key).lindex(key, index);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Long) linsert(string key, ListPosition where, string pivot, string value) {
    getClient(key).linsert(key, where, pivot, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) linsert(byte[] key, ListPosition where, byte[] pivot, byte[] value) {
    getClient(key).linsert(key, where, pivot, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) llen(string key) {
    getClient(key).llen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) llen(byte[] key) {
    getClient(key).llen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) lpop(string key) {
    getClient(key).lpop(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) lpop(byte[] key) {
    getClient(key).lpop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Long) lpush(string key, string[] string...) {
    getClient(key).lpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) lpush(byte[] key, byte[][] string...) {
    getClient(key).lpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) lpushx(string key, string[] string...) {
    getClient(key).lpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) lpushx(byte[] key, byte[][] bytes...) {
    getClient(key).lpushx(key, bytes);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(List!(string)) lrange(string key, long start, long stop) {
    getClient(key).lrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) lrange(byte[] key, long start, long stop) {
    getClient(key).lrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(Long) lrem(string key, long count, string value) {
    getClient(key).lrem(key, count, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) lrem(byte[] key, long count, byte[] value) {
    getClient(key).lrem(key, count, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) lset(string key, long index, string value) {
    getClient(key).lset(key, index, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) lset(byte[] key, long index, byte[] value) {
    getClient(key).lset(key, index, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) ltrim(string key, long start, long stop) {
    getClient(key).ltrim(key, start, stop);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) ltrim(byte[] key, long start, long stop) {
    getClient(key).ltrim(key, start, stop);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) move(string key, int dbIndex) {
    getClient(key).move(key, dbIndex);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) move(byte[] key, int dbIndex) {
    getClient(key).move(key, dbIndex);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) persist(string key) {
    getClient(key).persist(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) persist(byte[] key) {
    getClient(key).persist(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) rpop(string key) {
    getClient(key).rpop(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) rpop(byte[] key) {
    getClient(key).rpop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Long) rpush(string key, string[] string...) {
    getClient(key).rpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) rpush(byte[] key, byte[][] string...) {
    getClient(key).rpush(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) rpushx(string key, string[] string...) {
    getClient(key).rpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) rpushx(byte[] key, byte[][] string...) {
    getClient(key).rpushx(key, string);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) sadd(string key, string[] member...) {
    getClient(key).sadd(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) sadd(byte[] key, byte[][] member...) {
    getClient(key).sadd(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) scard(string key) {
    getClient(key).scard(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) scard(byte[] key) {
    getClient(key).scard(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) set(string key, string value) {
    getClient(key).set(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) set(byte[] key, byte[] value) {
    getClient(key).set(key, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) set(string key, string value, SetParams params) {
    getClient(key).set(key, value, params);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) set(byte[] key, byte[] value, SetParams params) {
    getClient(key).set(key, value, params);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Boolean) setbit(string key, long offset, bool value) {
    getClient(key).setbit(key, offset, value);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Boolean) setbit(byte[] key, long offset, byte[] value) {
    getClient(key).setbit(key, offset, value);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(string) setex(string key, int seconds, string value) {
    getClient(key).setex(key, seconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) setex(byte[] key, int seconds, byte[] value) {
    getClient(key).setex(key, seconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) setnx(string key, string value) {
    getClient(key).setnx(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) setnx(byte[] key, byte[] value) {
    getClient(key).setnx(key, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) setrange(string key, long offset, string value) {
    getClient(key).setrange(key, offset, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) setrange(byte[] key, long offset, byte[] value) {
    getClient(key).setrange(key, offset, value);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Boolean) sismember(string key, string member) {
    getClient(key).sismember(key, member);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Boolean) sismember(byte[] key, byte[] member) {
    getClient(key).sismember(key, member);
    return getResponse(BuilderFactory.BOOLEAN);
  }

  override
  Response!(Set!(string)) smembers(string key) {
    getClient(key).smembers(key);
    return getResponse(BuilderFactory.STRING_SET);
  }

  override
  Response!(Set!(byte[])) smembers(byte[] key) {
    getClient(key).smembers(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(List!(string)) sort(string key) {
    getClient(key).sort(key);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) sort(byte[] key) {
    getClient(key).sort(key);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(List!(string)) sort(string key, SortingParams sortingParameters) {
    getClient(key).sort(key, sortingParameters);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(byte[])) sort(byte[] key, SortingParams sortingParameters) {
    getClient(key).sort(key, sortingParameters);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(string) spop(string key) {
    getClient(key).spop(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Set!(string)) spop(string key, long count) {
    getClient(key).spop(key, count);
    return getResponse(BuilderFactory.STRING_SET);
  }

  override
  Response!(byte[]) spop(byte[] key) {
    getClient(key).spop(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Set!(byte[])) spop(byte[] key, long count) {
    getClient(key).spop(key, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(string) srandmember(string key) {
    getClient(key).srandmember(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(List!(string)) srandmember(string key, int count) {
    getClient(key).srandmember(key, count);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(byte[]) srandmember(byte[] key) {
    getClient(key).srandmember(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(List!(byte[])) srandmember(byte[] key, int count) {
    getClient(key).srandmember(key, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(Long) srem(string key, string[] member...) {
    getClient(key).srem(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) srem(byte[] key, byte[][] member...) {
    getClient(key).srem(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) strlen(string key) {
    getClient(key).strlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) strlen(byte[] key) {
    getClient(key).strlen(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) substr(string key, int start, int end) {
    getClient(key).substr(key, start, end);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) substr(byte[] key, int start, int end) {
    getClient(key).substr(key, start, end);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) touch(string key) {
    getClient(key).touch(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) touch(byte[] key) {
    getClient(key).touch(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) ttl(string key) {
    getClient(key).ttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) ttl(byte[] key) {
    getClient(key).ttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) type(string key) {
    getClient(key).type(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) type(byte[] key) {
    getClient(key).type(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) zadd(string key, double score, string member) {
    getClient(key).zadd(key, score, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(string key, double score, string member, ZAddParams params) {
    getClient(key).zadd(key, score, member, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(string key, Map!(string, Double) scoreMembers) {
    getClient(key).zadd(key, scoreMembers);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(string key, Map!(string, Double) scoreMembers, ZAddParams params) {
    getClient(key).zadd(key, scoreMembers, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(byte[] key, double score, byte[] member) {
    getClient(key).zadd(key, score, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(byte[] key, double score, byte[] member, ZAddParams params) {
    getClient(key).zadd(key, score, member, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(byte[] key, Map!(byte[], Double) scoreMembers) {
    getClient(key).zadd(key, scoreMembers);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zadd(byte[] key, Map!(byte[], Double) scoreMembers, ZAddParams params) {
    getClient(key).zadd(key, scoreMembers, params);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcard(string key) {
    getClient(key).zcard(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcard(byte[] key) {
    getClient(key).zcard(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcount(string key, double min, double max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcount(string key, string min, string max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcount(byte[] key, double min, double max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zcount(byte[] key, byte[] min, byte[] max) {
    getClient(key).zcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Double) zincrby(string key, double increment, string member) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) zincrby(string key, double increment, string member, ZIncrByParams params) {
    getClient(key).zincrby(key, increment, member, params);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) zincrby(byte[] key, double increment, byte[] member) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) zincrby(byte[] key, double increment, byte[] member, ZIncrByParams params) {
    getClient(key).zincrby(key, increment, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Set!(string)) zrange(string key, long start, long stop) {
    getClient(key).zrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrange(byte[] key, long start, long stop) {
    getClient(key).zrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByScore(string key, double min, double max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrangeByScore(byte[] key, double min, double max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByScore(string key, string min, string max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrangeByScore(byte[] key, byte[] min, byte[] max) {
    getClient(key).zrangeByScore(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByScore(string key, double min, double max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByScore(string key, string min, string max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrangeByScore(byte[] key, double min, double max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(byte[])) zrangeByScore(byte[] key, byte[] min, byte[] max, int offset,
      int count) {
    getClient(key).zrangeByScore(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, double min, double max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max) {
    getClient(key).zrangeByScoreWithScores(key, min, max);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, double min, double max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(string key, string min, string max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, double min, double max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeByScoreWithScores(byte[] key, byte[] min, byte[] max,
      int offset, int count) {
    getClient(key).zrangeByScoreWithScores(key, min, max, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, double max, double min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, byte[] max, byte[] min) {
    getClient(key).zrevrangeByScore(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByScore(string key, double max, double min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByScore(string key, string max, string min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, double max, double min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByScore(byte[] key, byte[] max, byte[] min, int offset,
      int count) {
    getClient(key).zrevrangeByScore(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, double max, double min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, double max, double min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(string key, string max, string min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, double max, double min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeByScoreWithScores(byte[] key, byte[] max, byte[] min,
      int offset, int count) {
    getClient(key).zrevrangeByScoreWithScores(key, max, min, offset, count);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeWithScores(string key, long start, long stop) {
    getClient(key).zrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrangeWithScores(byte[] key, long start, long stop) {
    getClient(key).zrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Long) zrank(string key, string member) {
    getClient(key).zrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zrank(byte[] key, byte[] member) {
    getClient(key).zrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zrem(string key, string[] members...) {
    getClient(key).zrem(key, members);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zrem(byte[] key, byte[][] members...) {
    getClient(key).zrem(key, members);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByRank(string key, long start, long stop) {
    getClient(key).zremrangeByRank(key, start, stop);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByRank(byte[] key, long start, long stop) {
    getClient(key).zremrangeByRank(key, start, stop);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByScore(string key, double min, double max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByScore(string key, string min, string max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByScore(byte[] key, double min, double max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByScore(byte[] key, byte[] min, byte[] max) {
    getClient(key).zremrangeByScore(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Set!(string)) zrevrange(string key, long start, long stop) {
    getClient(key).zrevrange(key, start, stop);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrange(byte[] key, long start, long stop) {
    getClient(key).zrevrange(key, start, stop);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeWithScores(string key, long start, long stop) {
    getClient(key).zrevrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Set!(Tuple)) zrevrangeWithScores(byte[] key, long start, long stop) {
    getClient(key).zrevrangeWithScores(key, start, stop);
    return getResponse(BuilderFactory.TUPLE_ZSET);
  }

  override
  Response!(Long) zrevrank(string key, string member) {
    getClient(key).zrevrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zrevrank(byte[] key, byte[] member) {
    getClient(key).zrevrank(key, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Double) zscore(string key, string member) {
    getClient(key).zscore(key, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) zscore(byte[] key, byte[] member) {
    getClient(key).zscore(key, member);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Long) zlexcount(byte[] key, byte[] min, byte[] max) {
    getClient(key).zlexcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zlexcount(string key, string min, string max) {
    getClient(key).zlexcount(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Set!(byte[])) zrangeByLex(byte[] key, byte[] min, byte[] max) {
    getClient(key).zrangeByLex(key, min, max);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByLex(string key, string min, string max) {
    getClient(key).zrangeByLex(key, min, max);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrangeByLex(byte[] key, byte[] min, byte[] max,
      int offset, int count) {
    getClient(key).zrangeByLex(key, min, max, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrangeByLex(string key, string min, string max,
      int offset, int count) {
    getClient(key).zrangeByLex(key, min, max, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByLex(byte[] key, byte[] max, byte[] min) {
    getClient(key).zrevrangeByLex(key, max, min);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min) {
    getClient(key).zrevrangeByLex(key, max, min);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Set!(byte[])) zrevrangeByLex(byte[] key, byte[] max, byte[] min,
      int offset, int count) {
    getClient(key).zrevrangeByLex(key, max, min, offset, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
  }

  override
  Response!(Set!(string)) zrevrangeByLex(string key, string max, string min,
      int offset, int count) {
    getClient(key).zrevrangeByLex(key, max, min, offset, count);
    return getResponse(BuilderFactory.STRING_ZSET);
  }

  override
  Response!(Long) zremrangeByLex(byte[] key, byte[] min, byte[] max) {
    getClient(key).zremrangeByLex(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) zremrangeByLex(string key, string min, string max) {
    getClient(key).zremrangeByLex(key, min, max);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) bitcount(string key) {
    getClient(key).bitcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) bitcount(string key, long start, long end) {
    getClient(key).bitcount(key, start, end);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) bitcount(byte[] key) {
    getClient(key).bitcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) bitcount(byte[] key, long start, long end) {
    getClient(key).bitcount(key, start, end);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(byte[]) dump(string key) {
    getClient(key).dump(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(byte[]) dump(byte[] key) {
    getClient(key).dump(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(string) migrate(string host, int port,
      string key, int destinationDb, int timeout) {
    getClient(key).migrate(host, port, key, destinationDb, timeout);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) migrate(string host, int port,
      byte[] key, int destinationDb, int timeout) {
    getClient(key).migrate(host, port, key, destinationDb, timeout);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Long) objectRefcount(string key) {
    getClient(key).objectRefcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) objectRefcount(byte[] key) {
    getClient(key).objectRefcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) objectEncoding(string key) {
    getClient(key).objectEncoding(key);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(byte[]) objectEncoding(byte[] key) {
    getClient(key).objectEncoding(key);
    return getResponse(BuilderFactory.BYTE_ARRAY);
  }

  override
  Response!(Long) objectIdletime(string key) {
    getClient(key).objectIdletime(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) objectIdletime(byte[] key) {
    getClient(key).objectIdletime(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pexpire(string key, long milliseconds) {
    getClient(key).pexpire(key, milliseconds);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pexpire(byte[] key, long milliseconds) {
    getClient(key).pexpire(key, milliseconds);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pexpireAt(string key, long millisecondsTimestamp) {
    getClient(key).pexpireAt(key, millisecondsTimestamp);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pexpireAt(byte[] key, long millisecondsTimestamp) {
    getClient(key).pexpireAt(key, millisecondsTimestamp);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pttl(string key) {
    getClient(key).pttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pttl(byte[] key) {
    getClient(key).pttl(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(string) restore(string key, int ttl, byte[] serializedValue) {
    getClient(key).restore(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) restore(byte[] key, int ttl, byte[] serializedValue) {
    getClient(key).restore(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) restoreReplace(string key, int ttl, byte[] serializedValue) {
    getClient(key).restoreReplace(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) restoreReplace(byte[] key, int ttl, byte[] serializedValue) {
    getClient(key).restoreReplace(key, ttl, serializedValue);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Double) incrByFloat(string key, double increment) {
    getClient(key).incrByFloat(key, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) incrByFloat(byte[] key, double increment) {
    getClient(key).incrByFloat(key, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(string) psetex(string key, long milliseconds, string value) {
    getClient(key).psetex(key, milliseconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(string) psetex(byte[] key, long milliseconds, byte[] value) {
    getClient(key).psetex(key, milliseconds, value);
    return getResponse(BuilderFactory.STRING);
  }

  override
  Response!(Double) hincrByFloat(string key, string field, double increment) {
    getClient(key).hincrByFloat(key, field, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) hincrByFloat(byte[] key, byte[] field, double increment) {
    getClient(key).hincrByFloat(key, field, increment);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Long) pfadd(byte[] key, byte[][] elements...) {
    getClient(key).pfadd(key, elements);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pfcount(byte[] key) {
    getClient(key).pfcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pfadd(string key, string[] elements...) {
    getClient(key).pfadd(key, elements);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) pfcount(string key) {
    getClient(key).pfcount(key);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) geoadd(byte[] key, double longitude, double latitude, byte[] member) {
    getClient(key).geoadd(key, longitude, latitude, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) geoadd(byte[] key, Map!(byte[], GeoCoordinate) memberCoordinateMap) {
    getClient(key).geoadd(key, memberCoordinateMap);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) geoadd(string key, double longitude, double latitude, string member) {
    getClient(key).geoadd(key, longitude, latitude, member);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
    getClient(key).geoadd(key, memberCoordinateMap);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Double) geodist(byte[] key, byte[] member1, byte[] member2) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) geodist(byte[] key, byte[] member1, byte[] member2, GeoUnit unit) {
    getClient(key).geodist(key, member1, member2, unit);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) geodist(string key, string member1, string member2) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(Double) geodist(string key, string member1, string member2, GeoUnit unit) {
    getClient(key).geodist(key, member1, member2);
    return getResponse(BuilderFactory.DOUBLE);
  }

  override
  Response!(List!(byte[])) geohash(byte[] key, byte[][] members...) {
    getClient(key).geohash(key, members);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
  }

  override
  Response!(List!(string)) geohash(string key, string[] members...) {
    getClient(key).geohash(key, members);
    return getResponse(BuilderFactory.STRING_LIST);
  }

  override
  Response!(List!(GeoCoordinate)) geopos(byte[] key, byte[][] members...) {
    getClient(key).geopos(key, members);
    return getResponse(BuilderFactory.GEO_COORDINATE_LIST);
  }

  override
  Response!(List!(GeoCoordinate)) geopos(string key, string[] members...) {
    getClient(key).geopos(key, members);
    return getResponse(BuilderFactory.GEO_COORDINATE_LIST);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadius(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadius(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadius(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(byte[] key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadius(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadius(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadius(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusReadonly(string key, double longitude, double latitude,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusReadonly(key, longitude, latitude, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(byte[] key, byte[] member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMember(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(byte[] key, byte[] member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(byte[] key, byte[] member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMember(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(byte[] key, byte[] member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMember(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member,
      double radius, GeoUnit unit) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMember(string key, string member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMember(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(GeoRadiusResponse)) georadiusByMemberReadonly(string key, string member,
      double radius, GeoUnit unit, GeoRadiusParam param) {
    getClient(key).georadiusByMemberReadonly(key, member, radius, unit, param);
    return getResponse(BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT);
  }

  override
  Response!(List!(Long)) bitfield(string key, string[] elements...) {
    getClient(key).bitfield(key, elements);
    return getResponse(BuilderFactory.LONG_LIST);
  }

  override
  Response!(List!(Long)) bitfield(byte[] key, byte[][] elements...) {
    getClient(key).bitfield(key, elements);
    return getResponse(BuilderFactory.LONG_LIST);
  }

  override
  Response!(Long) hstrlen(string key, string field) {
    getClient(key).hstrlen(key, field);
    return getResponse(BuilderFactory.LONG);
  }

  override
  Response!(Long) hstrlen(byte[] key, byte[] field) {
    getClient(key).hstrlen(key, field);
    return getResponse(BuilderFactory.LONG);
  }
  
  override
  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash){
    return xadd(key, id, hash, Long.MAX_VALUE, true);    
  }
  
  override
  Response!(byte[]) xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash){
    return xadd(key, id, hash, Long.MAX_VALUE, true);
  }


  override
  Response!(StreamEntryID) xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength){
    getClient(key).xadd(key, id, hash, maxLen, approximateLength);
    return getResponse(BuilderFactory.STREAM_ENTRY_ID);    
  }
  

  override
  Response!(byte[]) xadd(byte[] key, byte[] id, Map!(byte[], byte[]) hash, long maxLen, bool approximateLength){
    getClient(key).xadd(key, id, hash, maxLen, approximateLength);
    return getResponse(BuilderFactory.BYTE_ARRAY);        
  }

  
  override
  Response!(Long) xlen(string key){
    getClient(key).xlen(key);
    return getResponse(BuilderFactory.LONG);
  }
  
  override
  Response!(Long) xlen(byte[] key){
    getClient(key).xlen(key);
    return getResponse(BuilderFactory.LONG);    
  }

  override
  Response!(List!(StreamEntry)) xrange(string key, StreamEntryID start, StreamEntryID end, int count){
    getClient(key).xrange(key, start, end, count);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);        
  }

  override
  Response!(List!(byte[])) xrange(byte[] key, byte[] start, byte[] end, int count){
    getClient(key).xrange(key, start, end, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);            
  }

  override
  Response!(List!(StreamEntry)) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count){
    getClient(key).xrevrange(key, start, end, count);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);            
  }

  override
  Response!(List!(byte[])) xrevrange(byte[] key, byte[] end, byte[] start, int count){
    getClient(key).xrevrange(key, start, end, count);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);                
  }

   
  override
  Response!(Long) xack(string key, string group,  StreamEntryID[] ids...){
    getClient(key).xack(key, group, ids);
    return getResponse(BuilderFactory.LONG);                
  }
  
  override
  Response!(Long) xack(byte[] key, byte[] group,  byte[][] ids...){
    getClient(key).xack(key, group, ids);
    return getResponse(BuilderFactory.LONG);                    
  }
  
  override
  Response!(string) xgroupCreate( string key, string groupname, StreamEntryID id, bool makeStream){
    getClient(key).xgroupCreate(key, groupname, id, makeStream);
    return getResponse(BuilderFactory.STRING);
  }
  
  override
  Response!(string) xgroupCreate(byte[] key, byte[] groupname, byte[] id, bool makeStream){
    getClient(key).xgroupCreate(key, groupname, id, makeStream);
    return getResponse(BuilderFactory.STRING);    
  }
  
  override
  Response!(string) xgroupSetID( string key, string groupname, StreamEntryID id){
    getClient(key).xgroupSetID(key, groupname, id);
    return getResponse(BuilderFactory.STRING);
  }
  
  override
  Response!(string) xgroupSetID(byte[] key, byte[] groupname, byte[] id){
    getClient(key).xgroupSetID(key, groupname, id);
    return getResponse(BuilderFactory.STRING);    
  }
  
  override
  Response!(Long) xgroupDestroy( string key, string groupname){
    getClient(key).xgroupDestroy(key, groupname);
    return getResponse(BuilderFactory.LONG);
  }
  
  override
  Response!(Long) xgroupDestroy(byte[] key, byte[] groupname){
    getClient(key).xgroupDestroy(key, groupname);
    return getResponse(BuilderFactory.LONG);
  }
  
  override
  Response!(string) xgroupDelConsumer( string key, string groupname, string consumername){
    getClient(key).xgroupDelConsumer(key, groupname, consumername);
    return getResponse(BuilderFactory.STRING);
  }
  
  override
  Response!(string) xgroupDelConsumer(byte[] key, byte[] groupname, byte[] consumername){
    getClient(key).xgroupDelConsumer(key, groupname, consumername);
    return getResponse(BuilderFactory.STRING);    
  }

  override
  Response!(List!(StreamPendingEntry)) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end, int count, string consumername){
    getClient(key).xpending(key, groupname, start, end, count, consumername);
    return getResponse(BuilderFactory.STREAM_PENDING_ENTRY_LIST);        
  }
  
  override
  Response!(List!(StreamPendingEntry)) xpending(byte[] key, byte[] groupname, byte[] start, byte[] end, int count, byte[] consumername){
    getClient(key).xpending(key, groupname, start, end, count, consumername);
    return getResponse(BuilderFactory.STREAM_PENDING_ENTRY_LIST);            
  }

  
  override
  Response!(Long) xdel( string key, StreamEntryID[] ids...){
    getClient(key).xdel(key, ids);
    return getResponse(BuilderFactory.LONG);        
  }

  override
  Response!(Long) xdel(byte[] key, byte[][] ids...){
    getClient(key).xdel(key, ids);
    return getResponse(BuilderFactory.LONG);            
  }
  
  override
  Response!(Long) xtrim( string key, long maxLen, bool approximateLength){
    getClient(key).xtrim(key, maxLen, approximateLength);
    return getResponse(BuilderFactory.LONG);        
  }
  
  override
  Response!(Long) xtrim(byte[] key, long maxLen, bool approximateLength){
    getClient(key).xtrim(key, maxLen, approximateLength);
    return getResponse(BuilderFactory.LONG);            
  }
 
  override
  Response!(List!(StreamEntry)) xclaim( string key, string group, string consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, StreamEntryID[] ids...){
    getClient(key).xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
    return getResponse(BuilderFactory.STREAM_ENTRY_LIST);        
  }
 
  override
  Response!(List!(byte[])) xclaim(byte[] key, byte[] group, byte[] consumername, long minIdleTime, 
      long newIdleTime, int retries, bool force, byte[][] ids...){
    getClient(key).xclaim(key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
    return getResponse(BuilderFactory.BYTE_ARRAY_LIST);            
  }

  override
  Response!(Object) sendCommand(ProtocolCommand cmd, string[] args...){
    string key = args.length > 0 ? args[0] : cmd.to!string();
    getClient(key).sendCommand(cmd, args);
    return getResponse(BuilderFactory.OBJECT);
  }

  override
  Response!(Object) sendCommand(ProtocolCommand cmd, byte[][] args...){
    byte[] key = args.length > 0 ? args[0] : cast(byte[])(cmd.to!string());
    getClient(key).sendCommand(cmd, args);
    return getResponse(BuilderFactory.OBJECT);
  }
}
