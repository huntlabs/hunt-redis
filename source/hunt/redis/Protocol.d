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
 
module hunt.redis.Protocol;

// import hunt.redis.commands.Command;
import hunt.redis.Exceptions;
import hunt.redis.HostAndPort;
import hunt.redis.util.RedisInputStream;
import hunt.redis.util.RedisOutputStream;
import hunt.redis.util.SafeEncoder;

import hunt.Byte;
import hunt.Exceptions;
import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.Long;
import hunt.String;
import hunt.text.StringUtils;

import std.conv;
import std.format;
import std.string;


/**
*/
final class Protocol {

    private enum string ASK_PREFIX = "ASK ";
    private enum string MOVED_PREFIX = "MOVED ";
    private enum string CLUSTERDOWN_PREFIX = "CLUSTERDOWN ";
    private enum string BUSY_PREFIX = "BUSY ";
    private enum string NOSCRIPT_PREFIX = "NOSCRIPT ";

    enum string DEFAULT_HOST = "localhost";
    enum int DEFAULT_PORT = 6379;
    enum int DEFAULT_SENTINEL_PORT = 26379;
    enum int DEFAULT_TIMEOUT = 2000;
    enum int DEFAULT_MAX_ATTEMPTS = 5;
    enum int DEFAULT_DATABASE = 0;

    enum string CHARSET = "UTF-8";

    enum byte DOLLAR_BYTE = '$';
    enum byte ASTERISK_BYTE = '*';
    enum byte PLUS_BYTE = '+';
    enum byte MINUS_BYTE = '-';
    enum byte COLON_BYTE = ':';

    enum string SENTINEL_MASTERS = "masters";
    enum string SENTINEL_GET_MASTER_ADDR_BY_NAME = "get-master-addr-by-name";
    enum string SENTINEL_RESET = "reset";
    enum string SENTINEL_SLAVES = "slaves";
    enum string SENTINEL_FAILOVER = "failover";
    enum string SENTINEL_MONITOR = "monitor";
    enum string SENTINEL_REMOVE = "remove";
    enum string SENTINEL_SET = "set";

    enum string CLUSTER_NODES = "nodes";
    enum string CLUSTER_MEET = "meet";
    enum string CLUSTER_RESET = "reset";
    enum string CLUSTER_ADDSLOTS = "addslots";
    enum string CLUSTER_DELSLOTS = "delslots";
    enum string CLUSTER_INFO = "info";
    enum string CLUSTER_GETKEYSINSLOT = "getkeysinslot";
    enum string CLUSTER_SETSLOT = "setslot";
    enum string CLUSTER_SETSLOT_NODE = "node";
    enum string CLUSTER_SETSLOT_MIGRATING = "migrating";
    enum string CLUSTER_SETSLOT_IMPORTING = "importing";
    enum string CLUSTER_SETSLOT_STABLE = "stable";
    enum string CLUSTER_FORGET = "forget";
    enum string CLUSTER_FLUSHSLOT = "flushslots";
    enum string CLUSTER_KEYSLOT = "keyslot";
    enum string CLUSTER_COUNTKEYINSLOT = "countkeysinslot";
    enum string CLUSTER_SAVECONFIG = "saveconfig";
    enum string CLUSTER_REPLICATE = "replicate";
    enum string CLUSTER_SLAVES = "slaves";
    enum string CLUSTER_FAILOVER = "failover";
    enum string CLUSTER_SLOTS = "slots";
    enum string PUBSUB_CHANNELS = "channels";
    enum string PUBSUB_NUMSUB = "numsub";
    enum string PUBSUB_NUM_PAT = "numpat";

    enum const(ubyte)[] BYTES_TRUE = cast(const(ubyte)[])"1";
    enum const(ubyte)[] BYTES_FALSE = cast(const(ubyte)[])"0";
    enum const(ubyte)[] BYTES_TILDE = cast(const(ubyte)[])"~";

    enum const(ubyte)[] POSITIVE_INFINITY_BYTES = cast(const(ubyte)[])"+inf";
    enum const(ubyte)[] NEGATIVE_INFINITY_BYTES = cast(const(ubyte)[])"-inf";

    private this() {
        // this prevent the class from instantiation
    }

    static void sendCommand(RedisOutputStream os, Command command,
            const(ubyte)[][] args...) {
        sendCommand(os, command.getRaw(), args);
    }

    private static void sendCommand(RedisOutputStream os, const(ubyte)[] command,
            const(ubyte)[][] args...) {
        try {
            os.write(ASTERISK_BYTE);
            os.writeIntCrLf(cast(int)args.length + 1);
            os.write(DOLLAR_BYTE);
            os.writeIntCrLf(cast(int)command.length);
            os.write(cast(byte[])command);
            os.writeCrLf();

            foreach (const(ubyte)[] arg ; args) {
                os.write(DOLLAR_BYTE);
                os.writeIntCrLf(cast(int)arg.length);
                os.write(cast(byte[])arg);
                os.writeCrLf();
            }
        } catch (IOException e) {
            throw new RedisConnectionException(e);
        }
    }

    private static void processError(RedisInputStream inputStream) {
        string message = inputStream.readLine();
        // TODO: I'm not sure if this is the best way to do this.
        // Maybe Read only first 5 bytes instead?
        if (message.startsWith(MOVED_PREFIX)) {
            string[] movedInfo = parseTargetHostAndSlot(message);
            throw new RedisMovedDataException(message, new HostAndPort(movedInfo[1],
                    to!int(movedInfo[2])), to!int(movedInfo[0]));
        } else if (message.startsWith(ASK_PREFIX)) {
            string[] askInfo = parseTargetHostAndSlot(message);
            throw new RedisAskDataException(message, new HostAndPort(askInfo[1],
                    to!int(askInfo[2])), to!int(askInfo[0]));
        } else if (message.startsWith(CLUSTERDOWN_PREFIX)) {
            throw new RedisClusterException(message);
        } else if (message.startsWith(BUSY_PREFIX)) {
            throw new RedisBusyException(message);
        } else if (message.startsWith(NOSCRIPT_PREFIX) ) {
            throw new RedisNoScriptException(message);
        }
        throw new RedisDataException(message);
    }

    static string readErrorLineIfPossible(RedisInputStream inputStream) {
        byte b = inputStream.readByte();
        // if buffer contains other type of response, just ignore.
        if (b != MINUS_BYTE) {
            return null;
        }
        return inputStream.readLine();
    }

    private static string[] parseTargetHostAndSlot(string clusterRedirectResponse) {
        string[] response = new string[3];
        string[] messageInfo = clusterRedirectResponse.split(" ");
        string[] targetHostAndPort = HostAndPort.extractParts(messageInfo[2]);
        response[0] = messageInfo[1];
        response[1] = targetHostAndPort[0];
        response[2] = targetHostAndPort[1];
        return response;
    }

    private static Object process(RedisInputStream inputStream) {
        byte b = inputStream.readByte();
        switch(b) {
        case PLUS_BYTE:
            return new Bytes(processStatusCodeReply(inputStream));
        case DOLLAR_BYTE:
            return new Bytes(processBulkReply(inputStream));
        case ASTERISK_BYTE:
            return cast(Object)processMultiBulkReply(inputStream);
        case COLON_BYTE:
            return new Long(processInteger(inputStream));
        case MINUS_BYTE:
            processError(inputStream);
            return null;
        default:
            throw new RedisConnectionException(format("Unknown reply: %s", cast(char) b));
        }
    }

    private static byte[] processStatusCodeReply(RedisInputStream inputStream) {
        return inputStream.readLineBytes();
    }

    private static byte[] processBulkReply(RedisInputStream inputStream) {
        int len = inputStream.readIntCrLf();
        if (len == -1) {
            return null;
        }

        byte[] read = new byte[len];
        int offset = 0;
        while (offset < len) {
            int size = inputStream.read(read, offset, (len - offset));
            if (size == -1) throw new RedisConnectionException(
                    "It seems like server has closed the connection.");
            offset += size;
        }

        // read 2 more bytes for the command delimiter
        inputStream.readByte();
        inputStream.readByte();

        return read;
    }

    private static long processInteger(RedisInputStream inputStream) {
        return inputStream.readLongCrLf();
    }

    private static List!(Object) processMultiBulkReply(RedisInputStream inputStream) {
        int num = inputStream.readIntCrLf();
        if (num == -1) {
            return null;
        }
        List!(Object) ret = new ArrayList!(Object)(num);
        for (int i = 0; i < num; i++) {
            try {
                ret.add(process(inputStream));
            } catch (RedisDataException e) {
                ret.add(e);
            }
        }
        return ret;
    }

    static Object read(RedisInputStream inputStream) {
        return process(inputStream);
    }

    static const(ubyte)[] toByteArray(bool value) {
        return value ? BYTES_TRUE : BYTES_FALSE;
    }

    static const(ubyte)[] toByteArray(int value) {
        return cast(const(ubyte)[])to!string(value);
    }

    static const(ubyte)[] toByteArray(long value) {
        return cast(const(ubyte)[])to!string(value);
    }

    static const(ubyte)[] toByteArray(double value) {
        if (value == double.infinity) {
            return POSITIVE_INFINITY_BYTES;
        } else if (value == -double.infinity) {
            return NEGATIVE_INFINITY_BYTES;
        } else {
            return cast(const(ubyte)[])to!string(value);
        }
    }    

// dfmt off
    static enum Command {
        PING, SET, GET, QUIT, EXISTS, DEL, UNLINK, TYPE, FLUSHDB, KEYS, RANDOMKEY, RENAME, RENAMENX,
        RENAMEX, DBSIZE, EXPIRE, EXPIREAT, TTL, SELECT, MOVE, FLUSHALL, GETSET, MGET, SETNX, SETEX,
        MSET, MSETNX, DECRBY, DECR, INCRBY, INCR, APPEND, SUBSTR, HSET, HGET, HSETNX, HMSET, HMGET,
        HINCRBY, HEXISTS, HDEL, HLEN, HKEYS, HVALS, HGETALL, RPUSH, LPUSH, LLEN, LRANGE, LTRIM, LINDEX,
        LSET, LREM, LPOP, RPOP, RPOPLPUSH, SADD, SMEMBERS, SREM, SPOP, SMOVE, SCARD, SISMEMBER, SINTER,
        SINTERSTORE, SUNION, SUNIONSTORE, SDIFF, SDIFFSTORE, SRANDMEMBER, ZADD, ZRANGE, ZREM, ZINCRBY,
        ZRANK, ZREVRANK, ZREVRANGE, ZCARD, ZSCORE, MULTI, DISCARD, EXEC, WATCH, UNWATCH, SORT, BLPOP,
        BRPOP, AUTH, SUBSCRIBE, PUBLISH, UNSUBSCRIBE, PSUBSCRIBE, PUNSUBSCRIBE, PUBSUB, ZCOUNT,
        ZRANGEBYSCORE, ZREVRANGEBYSCORE, ZREMRANGEBYRANK, ZREMRANGEBYSCORE, ZUNIONSTORE, ZINTERSTORE,
        ZLEXCOUNT, ZRANGEBYLEX, ZREVRANGEBYLEX, ZREMRANGEBYLEX, SAVE, BGSAVE, BGREWRITEAOF, LASTSAVE,
        SHUTDOWN, INFO, MONITOR, SLAVEOF, CONFIG, STRLEN, SYNC, LPUSHX, PERSIST, RPUSHX, ECHO, LINSERT,
        DEBUG, BRPOPLPUSH, SETBIT, GETBIT, BITPOS, SETRANGE, GETRANGE, EVAL, EVALSHA, SCRIPT, SLOWLOG,
        OBJECT, BITCOUNT, BITOP, SENTINEL, DUMP, RESTORE, PEXPIRE, PEXPIREAT, PTTL, INCRBYFLOAT,
        PSETEX, CLIENT, TIME, MIGRATE, HINCRBYFLOAT, SCAN, HSCAN, SSCAN, ZSCAN, WAIT, CLUSTER, ASKING,
        PFADD, PFCOUNT, PFMERGE, READONLY, GEOADD, GEODIST, GEOHASH, GEOPOS, GEORADIUS, GEORADIUS_RO,
        GEORADIUSBYMEMBER, GEORADIUSBYMEMBER_RO, MODULE, BITFIELD, HSTRLEN, TOUCH, SWAPDB, MEMORY,
        XADD, XLEN, XDEL, XTRIM, XRANGE, XREVRANGE, XREAD, XACK, XGROUP, XREADGROUP, XPENDING, XCLAIM
    }

    static enum Keyword {
        AGGREGATE, ALPHA, ASC, BY, DESC, GET, LIMIT, MESSAGE, NO, NOSORT, PMESSAGE, PSUBSCRIBE,
        PUNSUBSCRIBE, OK, ONE, QUEUED, SET, STORE, SUBSCRIBE, UNSUBSCRIBE, WEIGHTS, WITHSCORES,
        RESETSTAT, REWRITE, RESET, FLUSH, EXISTS, LOAD, KILL, LEN, REFCOUNT, ENCODING, IDLETIME,
        GETNAME, SETNAME, LIST, MATCH, COUNT, PING, PONG, UNLOAD, REPLACE, KEYS, PAUSE, DOCTOR, 
        BLOCK, NOACK, STREAMS, KEY, CREATE, MKSTREAM, SETID, DESTROY, DELCONSUMER, MAXLEN, GROUP, 
        IDLE, TIME, RETRYCOUNT, FORCE
    }

// dfmt on    
}


alias ProtocolCommand = Protocol.Command;
alias ProtocolKeyword = Protocol.Keyword;


const(ubyte)[] getRaw(ProtocolKeyword k) {
    return cast(const(ubyte)[])k.to!string();
}

const(ubyte)[] getRaw(ProtocolCommand c) {
    return cast(const(ubyte)[])c.to!string();
}

