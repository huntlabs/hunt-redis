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
 
module hunt.redis.MultiKeyPipelineBase;

import hunt.redis.commands;
import hunt.redis.BinaryRedis;
import hunt.redis.BuilderFactory;
import hunt.redis.Client;
import hunt.redis.BitOP;
import hunt.redis.Client;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.ListPosition;
import hunt.redis.Module;
import hunt.redis.PipelineBase;
import hunt.redis.Redis;
import hunt.redis.Response;
import hunt.redis.SortingParams;
import hunt.redis.ZParams;
import hunt.redis.params.MigrateParams;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

abstract class MultiKeyPipelineBase : PipelineBase,
        MultiKeyBinaryRedisPipeline, MultiKeyCommandsPipeline, ClusterPipeline,
        BinaryScriptingCommandsPipeline, ScriptingCommandsPipeline, BasicRedisPipeline {

    protected Client client = null;

    Response!(List!(string)) brpop(string[] args...) {
        client.brpop(args);
        return getResponse(BuilderFactory.STRING_LIST);
    }
    alias brpop = PipelineBase.brpop;

    Response!(List!(string)) brpop(int timeout, string[] keys...) {
        client.brpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    Response!(List!(string)) blpop(string[] args...) {
        client.blpop(args);
        return getResponse(BuilderFactory.STRING_LIST);
    }
    alias blpop = PipelineBase.blpop;

    Response!(List!(string)) blpop(int timeout, string[] keys...) {
        client.blpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    Response!(Map!(string, string)) blpopMap(int timeout, string[] keys...) {
        client.blpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_MAP);
    }

    override
    Response!(List!(const(ubyte)[])) brpop(const(ubyte)[][] args...) {
        client.brpop(args);
        return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
    }

    Response!(List!(string)) brpop(int timeout, const(ubyte)[][] keys...) {
        client.brpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    Response!(Map!(string, string)) brpopMap(int timeout, string[] keys...) {
        client.blpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_MAP);
    }

    override
    Response!(List!(const(ubyte)[])) blpop(const(ubyte)[][] args...) {
        client.blpop(args);
        return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
    }

    Response!(List!(string)) blpop(int timeout, const(ubyte)[][] keys...) {
        client.blpop(timeout, keys);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    Response!(Long) del(string[] keys...) {
        client.del(keys);
        return getResponse(BuilderFactory.LONG);
    }
    alias del = PipelineBase.del;

    Response!(Long) del(const(ubyte)[][] keys...) {
        client.del(keys);
        return getResponse(BuilderFactory.LONG);
    }

    Response!(Long) unlink(string[] keys...) {
        client.unlink(keys);
        return getResponse(BuilderFactory.LONG);
    }
    alias unlink = PipelineBase.unlink;

    Response!(Long) unlink(const(ubyte)[][] keys...) {
        client.unlink(keys);
        return getResponse(BuilderFactory.LONG);
    }

    Response!(Long) exists(string[] keys...) {
        client.exists(keys);
        return getResponse(BuilderFactory.LONG);
    }
    alias exists = PipelineBase.exists;

    Response!(Long) exists(const(ubyte)[][] keys...) {
        client.exists(keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Set!(string)) keys(string pattern) {
        getClient(pattern).keys(pattern);
        return getResponse(BuilderFactory.STRING_SET);
    }

    override
    Response!(Set!(const(ubyte)[])) keys(const(ubyte)[] pattern) {
        getClient(pattern).keys(pattern);
        return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
    }

    override
    Response!(List!(string)) mget(string[] keys...) {
        client.mget(keys);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    override
    Response!(List!(const(ubyte)[])) mget(const(ubyte)[][] keys...) {
        client.mget(keys);
        return getResponse(BuilderFactory.BYTE_ARRAY_LIST);
    }

    override
    Response!(string) mset(string[] keysvalues...) {
        client.mset(keysvalues);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) mset(const(ubyte)[][] keysvalues...) {
        client.mset(keysvalues);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) msetnx(string[] keysvalues...) {
        client.msetnx(keysvalues);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) msetnx(const(ubyte)[][] keysvalues...) {
        client.msetnx(keysvalues);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) rename(string oldkey, string newkey) {
        client.rename(oldkey, newkey);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) rename(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        client.rename(oldkey, newkey);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) renamenx(string oldkey, string newkey) {
        client.renamenx(oldkey, newkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        client.renamenx(oldkey, newkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) rpoplpush(string srckey, string dstkey) {
        client.rpoplpush(srckey, dstkey);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(const(ubyte)[]) rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey) {
        client.rpoplpush(srckey, dstkey);
        return getResponse(BuilderFactory.BYTE_ARRAY);
    }

    override
    Response!(Set!(string)) sdiff(string[] keys...) {
        client.sdiff(keys);
        return getResponse(BuilderFactory.STRING_SET);
    }

    override
    Response!(Set!(const(ubyte)[])) sdiff(const(ubyte)[][] keys...) {
        client.sdiff(keys);
        return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
    }

    override
    Response!(Long) sdiffstore(string dstkey, string[] keys...) {
        client.sdiffstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        client.sdiffstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Set!(string)) sinter(string[] keys...) {
        client.sinter(keys);
        return getResponse(BuilderFactory.STRING_SET);
    }

    override
    Response!(Set!(const(ubyte)[])) sinter(const(ubyte)[][] keys...) {
        client.sinter(keys);
        return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
    }

    override
    Response!(Long) sinterstore(string dstkey, string[] keys...) {
        client.sinterstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        client.sinterstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) smove(string srckey, string dstkey, string member) {
        client.smove(srckey, dstkey, member);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member) {
        client.smove(srckey, dstkey, member);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sort(string key, SortingParams sortingParameters, string dstkey) {
        client.sort(key, sortingParameters, dstkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey) {
        client.sort(key, sortingParameters, dstkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sort(string key, string dstkey) {
        client.sort(key, dstkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sort(const(ubyte)[] key, const(ubyte)[] dstkey) {
        client.sort(key, dstkey);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Set!(string)) sunion(string[] keys...) {
        client.sunion(keys);
        return getResponse(BuilderFactory.STRING_SET);
    }

    override
    Response!(Set!(const(ubyte)[])) sunion(const(ubyte)[][] keys...) {
        client.sunion(keys);
        return getResponse(BuilderFactory.BYTE_ARRAY_ZSET);
    }

    override
    Response!(Long) sunionstore(string dstkey, string[] keys...) {
        client.sunionstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        client.sunionstore(dstkey, keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) watch(string[] keys...) {
        client.watch(keys);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) watch(const(ubyte)[][] keys...) {
        client.watch(keys);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) zinterstore(string dstkey, string[] sets...) {
        client.zinterstore(dstkey, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        client.zinterstore(dstkey, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zinterstore(string dstkey, ZParams params, string[] sets...) {
        client.zinterstore(dstkey, params, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        client.zinterstore(dstkey, params, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zunionstore(string dstkey, string[] sets...) {
        client.zunionstore(dstkey, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        client.zunionstore(dstkey, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zunionstore(string dstkey, ZParams params, string[] sets...) {
        client.zunionstore(dstkey, params, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        client.zunionstore(dstkey, params, sets);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) bgrewriteaof() {
        client.bgrewriteaof();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) bgsave() {
        client.bgsave();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(List!(string)) configGet(string pattern) {
        client.configGet(pattern);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    override
    Response!(string) configSet(string parameter, string value) {
        client.configSet(parameter, value);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) brpoplpush(string source, string destination, int timeout) {
        client.brpoplpush(source, destination, timeout);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(const(ubyte)[]) brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout) {
        client.brpoplpush(source, destination, timeout);
        return getResponse(BuilderFactory.BYTE_ARRAY);
    }

    override
    Response!(string) configResetStat() {
        client.configResetStat();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) save() {
        client.save();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) lastsave() {
        client.lastsave();
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) publish(string channel, string message) {
        client.publish(channel, message);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) publish(const(ubyte)[] channel, const(ubyte)[] message) {
        client.publish(channel, message);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) randomKey() {
        client.randomKey();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(const(ubyte)[]) randomKeyBinary() {
        client.randomKey();
        return getResponse(BuilderFactory.BYTE_ARRAY);
    }

    override
    Response!(string) flushDB() {
        client.flushDB();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) flushAll() {
        client.flushAll();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) info() {
        client.info();
        return getResponse(BuilderFactory.STRING);
    }

    Response!(string) info(string section) {
        client.info(section);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) dbSize() {
        client.dbSize();
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) shutdown() {
        client.shutdown();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) ping() {
        client.ping();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) select(int index) {
        client.select(index);
        Response!(string) response = getResponse(BuilderFactory.STRING);
        client.setDb(index);

        return response;
    }

    override
    Response!(string) swapDB(int index1, int index2) {
        client.swapDB(index1, index2);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Long) bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...) {
        client.bitop(op, destKey, srcKeys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(Long) bitop(BitOP op, string destKey, string[] srcKeys...) {
        client.bitop(op, destKey, srcKeys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) clusterNodes() {
        client.clusterNodes();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterMeet(string ip, int port) {
        client.clusterMeet(ip, port);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterAddSlots(int[] slots...) {
        client.clusterAddSlots(slots);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterDelSlots(int[] slots...) {
        client.clusterDelSlots(slots);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterInfo() {
        client.clusterInfo();
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(List!(string)) clusterGetKeysInSlot(int slot, int count) {
        client.clusterGetKeysInSlot(slot, count);
        return getResponse(BuilderFactory.STRING_LIST);
    }

    override
    Response!(string) clusterSetSlotNode(int slot, string nodeId) {
        client.clusterSetSlotNode(slot, nodeId);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterSetSlotMigrating(int slot, string nodeId) {
        client.clusterSetSlotMigrating(slot, nodeId);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) clusterSetSlotImporting(int slot, string nodeId) {
        client.clusterSetSlotImporting(slot, nodeId);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(Object) eval(string script) {
        return this.eval(script, 0, new string[0]);
    }

    override
    Response!(Object) eval(string script, List!(string) keys, List!(string) args) {
        string[] argv = Redis.getParams(keys, args);
        return this.eval(script, keys.size(), argv);
    }

    override
    Response!(Object) eval(string script, int keyCount, string[] params...) {
        getClient(script).eval(script, keyCount, params);
        return getResponse(BuilderFactory.EVAL_RESULT);
    }

    override
    Response!(Object) evalsha(string sha1) {
        return this.evalsha(sha1, 0, new string[0]);
    }

    override
    Response!(Object) evalsha(string sha1, List!(string) keys, List!(string) args) {
        string[] argv = Redis.getParams(keys, args);
        return this.evalsha(sha1, keys.size(), argv);
    }

    override
    Response!(Object) evalsha(string sha1, int keyCount, string[] params...) {
        getClient(sha1).evalsha(sha1, keyCount, params);
        return getResponse(BuilderFactory.EVAL_RESULT);
    }

    override
    Response!(Object) eval(const(ubyte)[] script) {
        return this.eval(script, 0);
    }

    override
    Response!(Object) eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...) {
        getClient(script).eval(script, keyCount, params);
        return getResponse(BuilderFactory.EVAL_BINARY_RESULT);
    }

    override
    Response!(Object) eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
        const(ubyte)[][] argv = BinaryRedis.getParamsWithBinary(keys, args);
        return this.eval(script, keys.size(), argv);
    }

    override
    Response!(Object) eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...) {
        getClient(script).eval(script, keyCount, params);
        return getResponse(BuilderFactory.EVAL_BINARY_RESULT);
    }

    override
    Response!(Object) evalsha(const(ubyte)[] sha1) {
        return this.evalsha(sha1, 0);
    }

    override
    Response!(Object) evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
        const(ubyte)[][] argv = BinaryRedis.getParamsWithBinary(keys, args);
        return this.evalsha(sha1, keys.size(), argv);
    }

    override
    Response!(Object) evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...) {
        getClient(sha1).evalsha(sha1, keyCount, params);
        return getResponse(BuilderFactory.EVAL_BINARY_RESULT);
    }

    Response!(Long) pfcount(string[] keys...) {
        client.pfcount(keys);
        return getResponse(BuilderFactory.LONG);
    }
    alias pfcount = PipelineBase.pfcount;

    Response!(Long) pfcount(const(ubyte)[][] keys...) {
        client.pfcount(keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...) {
        client.pfmerge(destkey, sourcekeys);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(string) pfmerge(string destkey, string[] sourcekeys...) {
        client.pfmerge(destkey, sourcekeys);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(List!(string)) time() {
        client.time();
        return getResponse(BuilderFactory.STRING_LIST);
    }

    Response!(Long) touch(string[] keys...) {
        client.touch(keys);
        return getResponse(BuilderFactory.LONG);
    }
    alias touch = PipelineBase.touch;

    Response!(Long) touch(const(ubyte)[][] keys...) {
        client.touch(keys);
        return getResponse(BuilderFactory.LONG);
    }

    override
    Response!(string) moduleUnload(string name) {
        client.moduleUnload(name);
        return getResponse(BuilderFactory.STRING);
    }

    override
    Response!(List!(Module)) moduleList() {
        client.moduleList();
        return getResponse(BuilderFactory.MODULE_LIST);
    }

    override
    Response!(string) moduleLoad(string path) {
        client.moduleLoad(path);
        return getResponse(BuilderFactory.STRING);
    }  
    
    Response!(string) migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, string[] keys...) {
        client.migrate(host, port, destinationDB, timeout, params, keys);
        return getResponse(BuilderFactory.STRING);
    }
    alias migrate = PipelineBase.migrate;

    Response!(string) migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, const(ubyte)[][] keys...) {
        client.migrate(host, port, destinationDB, timeout, params, keys);
        return getResponse(BuilderFactory.STRING);
    }

    override Response!string migrate(string host, int port, string key, int destinationDB, int timeout) {
        return super.migrate(host, port, key, destinationDB, timeout);
    }

    override
    Response!(Object) sendCommand(ProtocolCommand cmd, string[] args...){
        client.sendCommand(cmd, args);
        return getResponse(BuilderFactory.OBJECT);
    }
    
}
