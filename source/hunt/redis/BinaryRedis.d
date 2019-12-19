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
 
module hunt.redis.BinaryRedis;

import hunt.redis.BinaryRedisPubSub;
import hunt.redis.BitOP;
import hunt.redis.BitPosParams;
import hunt.redis.Client;
import hunt.redis.BuilderFactory;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.HostAndPort;
import hunt.redis.ListPosition;
import hunt.redis.Pipeline;
import hunt.redis.Protocol;
import hunt.redis.RedisMonitor;
import hunt.redis.RedisShardInfo;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.Transaction;
import hunt.redis.Tuple;
import hunt.redis.ZParams;

import hunt.redis.commands.AdvancedBinaryRedisCommands;
import hunt.redis.commands.BasicCommands;
import hunt.redis.commands.BinaryRedisCommands;
import hunt.redis.commands.BinaryScriptingCommands;
import hunt.redis.commands.MultiKeyBinaryCommands;
import hunt.redis.Protocol;
import hunt.redis.Exceptions;
import hunt.redis.params.ClientKillParams;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.RedisByteHashMap;
import hunt.redis.util.RedisURIHelper;

import hunt.net.util.HttpURI;
import hunt.collection;
import hunt.Exceptions;
import hunt.util.Common;

import hunt.Byte;
import hunt.Double;
// import hunt.long;

import std.format;
import std.range;

// MultiKeyBinaryCommands,
/**
 * 
 */
class BinaryRedis : BasicCommands, BinaryRedisCommands, 
        AdvancedBinaryRedisCommands, BinaryScriptingCommands, Closeable {
    protected Client client = null;
    protected Transaction transaction = null;
    protected Pipeline pipeline = null;

    this() {
        client = new Client();
    }

    this(string host) {
        HttpURI uri = new HttpURI(host);
        if (RedisURIHelper.isValid(uri)) {
            initializeClientFromURI(uri);
        } else {
            client = new Client(host);
        }
    }

    this(HostAndPort hp) {
        this(hp.getHost(), hp.getPort());
    }

    this(string host, int port) {
        client = new Client(host, port);
    }

    this(string host, int port, bool ssl) {
        client = new Client(host, port, ssl);
    }

    // this(string host, int port, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   client = new Client(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int timeout) {
        this(host, port, timeout, timeout);
    }

    this(string host, int port, int timeout, bool ssl) {
        this(host, port, timeout, timeout, ssl);
    }

    // this(string host, int port, int timeout, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this(host, port, timeout, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int connectionTimeout,
            int soTimeout) {
        client = new Client(host, port);
        client.setConnectionTimeout(connectionTimeout);
        client.setSoTimeout(soTimeout);
    }

    this(string host, int port, int connectionTimeout,
            int soTimeout, bool ssl) {
        client = new Client(host, port, ssl);
        client.setConnectionTimeout(connectionTimeout);
        client.setSoTimeout(soTimeout);
    }

    // this(string host, int port, int connectionTimeout,
    //     int soTimeout, bool ssl, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   client = new Client(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    //   client.setConnectionTimeout(connectionTimeout);
    //   client.setSoTimeout(soTimeout);
    // }

    this(RedisShardInfo shardInfo) {
        // client = new Client(shardInfo.getHost(), shardInfo.getPort(), shardInfo.getSsl(),
        //     shardInfo.getSslSocketFactory(), shardInfo.getSslParameters(),
        //     shardInfo.getHostnameVerifier());
        client = new Client(shardInfo.getHost(), shardInfo.getPort(), shardInfo.getSsl());    
        client.setConnectionTimeout(shardInfo.getConnectionTimeout());
        client.setSoTimeout(shardInfo.getSoTimeout());
        client.setPassword(shardInfo.getPassword());
        client.setDb(shardInfo.getDb());
    }

    this(HttpURI uri) {
        initializeClientFromURI(uri);
    }

    // this(HttpURI uri, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   initializeClientFromURI(uri, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(HttpURI uri, int timeout) {
        this(uri, timeout, timeout);
    }

    // this(HttpURI uri, int timeout, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   this(uri, timeout, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(HttpURI uri, int connectionTimeout, int soTimeout) {
        initializeClientFromURI(uri);
        client.setConnectionTimeout(connectionTimeout);
        client.setSoTimeout(soTimeout);
    }

    // this(HttpURI uri, int connectionTimeout, int soTimeout,
    //     SSLSocketFactory sslSocketFactory,SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   initializeClientFromURI(uri, sslSocketFactory, sslParameters, hostnameVerifier);
    //   client.setConnectionTimeout(connectionTimeout);
    //   client.setSoTimeout(soTimeout);
    // }

    override string toString() {
        return format("%s:%d", client.getHost(), client.getPort());
    }

    private void initializeClientFromURI(HttpURI uri) {
        // initializeClientFromURI(uri, null, null, null);
     if (!RedisURIHelper.isValid(uri)) {
            throw new InvalidURIException(format(
                "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
        }

        client = new Client(uri.getHost(), uri.getPort(), false);

        string password = RedisURIHelper.getPassword(uri);
        if (password !is null) {
            client.auth(password);
            client.getStatusCodeReply();
        }

        int dbIndex = RedisURIHelper.getDBIndex(uri);
        if (dbIndex > 0) {
            client.select(dbIndex);
            client.getStatusCodeReply();
            client.setDb(dbIndex);
        }    
    }

    // private void initializeClientFromURI(HttpURI uri, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   if (!RedisURIHelper.isValid(uri)) {
    //     throw new InvalidURIException(format(
    //       "Cannot open Redis connection due invalid HttpURI. %s", uri.toString()));
    //   }

    //   client = new Client(uri.getHost(), uri.getPort(), RedisURIHelper.isRedisSSLScheme(uri),
    //     sslSocketFactory, sslParameters, hostnameVerifier);

    //   string password = RedisURIHelper.getPassword(uri);
    //   if (password !is null) {
    //     client.auth(password);
    //     client.getStatusCodeReply();
    //   }

    //   int dbIndex = RedisURIHelper.getDBIndex(uri);
    //   if (dbIndex > 0) {
    //     client.select(dbIndex);
    //     client.getStatusCodeReply();
    //     client.setDb(dbIndex);
    //   }
    // }

    // override
    string ping() {
        checkIsInMultiOrPipeline();
        client.ping();
        return client.getStatusCodeReply();
    }

    /**
     * Works same as <tt>ping()</tt> but returns argument message instead of <tt>PONG</tt>.
     * @param message
     * @return message
     */
    const(ubyte)[] ping(const(ubyte)[] message) {
        checkIsInMultiOrPipeline();
        client.ping(message);
        return client.getBinaryBulkReply();
    }

    /**
     * Set the string value as value of the key. The string can't be longer than 1073741824 bytes (1
     * GB).
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param value
     * @return Status code reply
     */
    // override
    string set(const(ubyte)[] key, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.set(key, value);
        return client.getStatusCodeReply();
    }

    /**
     * Set the string value as value of the key. The string can't be longer than 1073741824 bytes (1
     * GB).
     * @param key
     * @param value
     * @param params
     * @return Status code reply
     */
    // override
    string set(const(ubyte)[] key, const(ubyte)[] value, SetParams params) {
        checkIsInMultiOrPipeline();
        client.set(key, value, params);
        return client.getStatusCodeReply();
    }

    /**
     * Get the value of the specified key. If the key does not exist the special value 'nil' is
     * returned. If the value stored at key is not a string an error is returned because GET can only
     * handle string values.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @return Bulk reply
     */
    // override
    const(ubyte)[] get(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.get(key);
        return client.getBinaryBulkReply();
    }

    /**
     * Ask the server to silently close the connection.
     */
    // override
    string quit() {
        checkIsInMultiOrPipeline();
        client.quit();
        string quitReturn = client.getStatusCodeReply();
        client.disconnect();
        return quitReturn;
    }

    /**
     * Test if the specified keys exist. The command returns the number of keys exist.
     * Time complexity: O(N)
     * @param keys
     * @return Integer reply, specifically: an integer greater than 0 if one or more keys exist,
     *         0 if none of the specified keys exist.
     */
    // override
    long exists(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.exists(keys);
        return client.getIntegerReply();
    }

    /**
     * Test if the specified key exists. The command returns true if the key exists, otherwise false is
     * returned. Note that even keys set with an empty string as value will return true. Time
     * complexity: O(1)
     * @param key
     * @return bool reply, true if the key exists, otherwise false
     */
    // override
    bool exists(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.exists(key);
        return client.getIntegerReply() == 1;
    }

    /**
     * Remove the specified keys. If a given key does not exist no operation is performed for this
     * key. The command returns the number of keys removed. Time complexity: O(1)
     * @param keys
     * @return Integer reply, specifically: an integer greater than 0 if one or more keys were removed
     *         0 if none of the specified key existed
     */
    // override
    long del(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.del(keys);
        return client.getIntegerReply();
    }

    // override
    long del(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.del(key);
        return client.getIntegerReply();
    }

    /**
     * This command is very similar to DEL: it removes the specified keys. Just like DEL a key is
     * ignored if it does not exist. However the command performs the actual memory reclaiming in a
     * different thread, so it is not blocking, while DEL is. This is where the command name comes
     * from: the command just unlinks the keys from the keyspace. The actual removal will happen later
     * asynchronously.
     * <p>
     * Time complexity: O(1) for each key removed regardless of its size. Then the command does O(N)
     * work in a different thread in order to reclaim memory, where N is the number of allocations the
     * deleted objects where composed of.
     * @param keys
     * @return Integer reply: The number of keys that were unlinked
     */
    // override
    long unlink(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.unlink(keys);
        return client.getIntegerReply();
    }

    // override
    long unlink(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.unlink(key);
        return client.getIntegerReply();
    }

    /**
     * Return the type of the value stored at key in form of a string. The type can be one of "none",
     * "string", "list", "set". "none" is returned if the key does not exist. Time complexity: O(1)
     * @param key
     * @return Status code reply, specifically: "none" if the key does not exist "string" if the key
     *         contains a string value "list" if the key contains a List value "set" if the key
     *         contains a Set value "zset" if the key contains a Sorted Set value "hash" if the key
     *         contains a Hash value
     */
    // override
    string type(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.type(key);
        return client.getStatusCodeReply();
    }

    /**
     * Delete all the keys of the currently selected DB. This command never fails.
     * @return Status code reply
     */
    // override
    string flushDB() {
        checkIsInMultiOrPipeline();
        client.flushDB();
        return client.getStatusCodeReply();
    }

    /**
     * Returns all the keys matching the glob-style pattern as space separated strings. For example if
     * you have in the database the keys "foo" and "foobar" the command "KEYS foo*" will return
     * "foo foobar".
     * <p>
     * Note that while the time complexity for this operation is O(n) the constant times are pretty
     * low. For example Redis running on an entry level laptop can scan a 1 million keys database in
     * 40 milliseconds. <b>Still it's better to consider this one of the slow commands that may ruin
     * the DB performance if not used with care.</b>
     * <p>
     * In other words this command is intended only for debugging and special operations like creating
     * a script to change the DB schema. Don't use it in your normal code. Use Redis Sets in order to
     * group together a subset of objects.
     * <p>
     * Glob style patterns examples:
     * <ul>
     * <li>h?llo will match hello hallo hhllo
     * <li>h*llo will match hllo heeeello
     * <li>h[ae]llo will match hello and hallo, but not hillo
     * </ul>
     * <p>
     * Use \ to escape special chars if you want to match them verbatim.
     * <p>
     * Time complexity: O(n) (with n being the number of keys in the DB, and assuming keys and pattern
     * of limited length)
     * @param pattern
     * @return Multi bulk reply
     */
    // override
    Set!(const(ubyte)[]) keys(const(ubyte)[] pattern) {
        checkIsInMultiOrPipeline();
        client.keys(pattern);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * Return a randomly selected key from the currently selected DB.
     * <p>
     * Time complexity: O(1)
     * @return Single line reply, specifically the randomly selected key or an empty string is the
     *         database is empty
     */
    // override
    const(ubyte)[] randomBinaryKey() {
        checkIsInMultiOrPipeline();
        client.randomKey();
        return client.getBinaryBulkReply();
    }

    /**
     * Atomically renames the key oldkey to newkey. If the source and destination name are the same an
     * error is returned. If newkey already exists it is overwritten.
     * <p>
     * Time complexity: O(1)
     * @param oldkey
     * @param newkey
     * @return Status code repy
     */
    // override
    string rename(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        checkIsInMultiOrPipeline();
        client.rename(oldkey, newkey);
        return client.getStatusCodeReply();
    }

    /**
     * Rename oldkey into newkey but fails if the destination key newkey already exists.
     * <p>
     * Time complexity: O(1)
     * @param oldkey
     * @param newkey
     * @return Integer reply, specifically: 1 if the key was renamed 0 if the target key already exist
     */
    // override
    long renamenx(const(ubyte)[] oldkey, const(ubyte)[] newkey) {
        checkIsInMultiOrPipeline();
        client.renamenx(oldkey, newkey);
        return client.getIntegerReply();
    }

    /**
     * Return the number of keys in the currently selected database.
     * @return Integer reply
     */
    // override
    long dbSize() {
        checkIsInMultiOrPipeline();
        client.dbSize();
        return client.getIntegerReply();
    }

    /**
     * Set a timeout on the specified key. After the timeout the key will be automatically deleted by
     * the server. A key with an associated timeout is said to be volatile in Redis terminology.
     * <p>
     * Volatile keys are stored on disk like the other keys, the timeout is persistent too like all the
     * other aspects of the dataset. Saving a dataset containing expires and stopping the server does
     * not stop the flow of time as Redis stores on disk the time when the key will no longer be
     * available as Unix time, and not the remaining seconds.
     * <p>
     * Since Redis 2.1.3 you can update the value of the timeout of a key already having an expire
     * set. It is also possible to undo the expire at all turning the key into a normal key using the
     * {@link #persist(const(ubyte)[]) PERSIST} command.
     * <p>
     * Time complexity: O(1)
     * @see <a href="http://redis.io/commands/expire">Expire Command</a>
     * @param key
     * @param seconds
     * @return Integer reply, specifically: 1: the timeout was set. 0: the timeout was not set since
     *         the key already has an associated timeout (this may happen only in Redis versions &lt;
     *         2.1.3, Redis &gt;= 2.1.3 will happily update the timeout), or the key does not exist.
     */
    // override
    long expire(const(ubyte)[] key, int seconds) {
        checkIsInMultiOrPipeline();
        client.expire(key, seconds);
        return client.getIntegerReply();
    }

    /**
     * EXPIREAT works exactly like {@link #expire(const(ubyte)[], int) EXPIRE} but instead to get the number of
     * seconds representing the Time To Live of the key as a second argument (that is a relative way
     * of specifying the TTL), it takes an absolute one in the form of a UNIX timestamp (Number of
     * seconds elapsed since 1 Gen 1970).
     * <p>
     * EXPIREAT was introduced in order to implement the Append Only File persistence mode so that
     * EXPIRE commands are automatically translated into EXPIREAT commands for the append only file.
     * Of course EXPIREAT can also used by programmers that need a way to simply specify that a given
     * key should expire at a given time in the future.
     * <p>
     * Since Redis 2.1.3 you can update the value of the timeout of a key already having an expire
     * set. It is also possible to undo the expire at all turning the key into a normal key using the
     * {@link #persist(const(ubyte)[]) PERSIST} command.
     * <p>
     * Time complexity: O(1)
     * @see <a href="http://redis.io/commands/expire">Expire Command</a>
     * @param key
     * @param unixTime
     * @return Integer reply, specifically: 1: the timeout was set. 0: the timeout was not set since
     *         the key already has an associated timeout (this may happen only in Redis versions &lt;
     *         2.1.3, Redis &gt;= 2.1.3 will happily update the timeout), or the key does not exist.
     */
    // override
    long expireAt(const(ubyte)[] key, long unixTime) {
        checkIsInMultiOrPipeline();
        client.expireAt(key, unixTime);
        return client.getIntegerReply();
    }

    /**
     * The TTL command returns the remaining time to live in seconds of a key that has an
     * {@link #expire(const(ubyte)[], int) EXPIRE} set. This introspection capability allows a Redis client to
     * check how many seconds a given key will continue to be part of the dataset.
     * @param key
     * @return Integer reply, returns the remaining time to live in seconds of a key that has an
     *         EXPIRE. If the Key does not exists or does not have an associated expire, -1 is
     *         returned.
     */
    // override
    long ttl(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.ttl(key);
        return client.getIntegerReply();
    }

    /**
     * Alters the last access time of a key(s). A key is ignored if it does not exist.
     * Time complexity: O(N) where N is the number of keys that will be touched.
     * @param keys
     * @return Integer reply: The number of keys that were touched.
     */
    // override
    long touch(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.touch(keys);
        return client.getIntegerReply();
    }

    // override
    long touch(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.touch(key);
        return client.getIntegerReply();
    }

    /**
     * Select the DB with having the specified zero-based numeric index. For default every new client
     * connection is automatically selected to DB 0.
     * @param index
     * @return Status code reply
     */
    // override
    string select(int index) {
        checkIsInMultiOrPipeline();
        client.select(index);
        string statusCodeReply = client.getStatusCodeReply();
        client.setDb(index);

        return statusCodeReply;
    }

    // override
    string swapDB(int index1, int index2) {
        checkIsInMultiOrPipeline();
        client.swapDB(index1, index2);
        return client.getStatusCodeReply();
    }

    /**
     * Move the specified key from the currently selected DB to the specified destination DB. Note
     * that this command returns 1 only if the key was successfully moved, and 0 if the target key was
     * already there or if the source key was not found at all, so it is possible to use MOVE as a
     * locking primitive.
     * @param key
     * @param dbIndex
     * @return Integer reply, specifically: 1 if the key was moved 0 if the key was not moved because
     *         already present on the target DB or was not found in the current DB.
     */
    // override
    long move(const(ubyte)[] key, int dbIndex) {
        checkIsInMultiOrPipeline();
        client.move(key, dbIndex);
        return client.getIntegerReply();
    }

    /**
     * Delete all the keys of all the existing databases, not just the currently selected one. This
     * command never fails.
     * @return Status code reply
     */
    // override
    string flushAll() {
        checkIsInMultiOrPipeline();
        client.flushAll();
        return client.getStatusCodeReply();
    }

    /**
     * GETSET is an atomic set this value and return the old value command. Set key to the string
     * value and return the old value stored at key. The string can't be longer than 1073741824 bytes
     * (1 GB).
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param value
     * @return Bulk reply
     */
    // override
    const(ubyte)[] getSet(const(ubyte)[] key, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.getSet(key, value);
        return client.getBinaryBulkReply();
    }

    /**
     * Get the values of all the specified keys. If one or more keys don't exist or is not of type
     * string, a 'nil' value is returned instead of the value of the specified key, but the operation
     * never fails.
     * <p>
     * Time complexity: O(1) for every key
     * @param keys
     * @return Multi bulk reply
     */
    // override
    List!(const(ubyte)[]) mget(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.mget(keys);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * SETNX works exactly like {@link #set(const(ubyte)[], const(ubyte)[]) SET} with the only difference that if the
     * key already exists no operation is performed. SETNX actually means "SET if Not eXists".
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param value
     * @return Integer reply, specifically: 1 if the key was set 0 if the key was not set
     */
    // override
    long setnx(const(ubyte)[] key, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.setnx(key, value);
        return client.getIntegerReply();
    }

    /**
     * The command is exactly equivalent to the following group of commands:
     * {@link #set(const(ubyte)[], const(ubyte)[]) SET} + {@link #expire(const(ubyte)[], int) EXPIRE}. The operation is
     * atomic.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param seconds
     * @param value
     * @return Status code reply
     */
    // override
    string setex(const(ubyte)[] key, int seconds, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.setex(key, seconds, value);
        return client.getStatusCodeReply();
    }

    /**
     * Set the the respective keys to the respective values. MSET will replace old values with new
     * values, while {@link #msetnx(const(ubyte)[]...) MSETNX} will not perform any operation at all even if
     * just a single key already exists.
     * <p>
     * Because of this semantic MSETNX can be used in order to set different keys representing
     * different fields of an unique logic object in a way that ensures that either all the fields or
     * none at all are set.
     * <p>
     * Both MSET and MSETNX are atomic operations. This means that for instance if the keys A and B
     * are modified, another client talking to Redis can either see the changes to both A and B at
     * once, or no modification at all.
     * @see #msetnx(const(ubyte)[]...)
     * @param keysvalues
     * @return Status code reply Basically +OK as MSET can't fail
     */
    // override
    string mset(const(ubyte)[][] keysvalues...) {
        checkIsInMultiOrPipeline();
        client.mset(keysvalues);
        return client.getStatusCodeReply();
    }

    /**
     * Set the the respective keys to the respective values. {@link #mset(const(ubyte)[]...) MSET} will
     * replace old values with new values, while MSETNX will not perform any operation at all even if
     * just a single key already exists.
     * <p>
     * Because of this semantic MSETNX can be used in order to set different keys representing
     * different fields of an unique logic object in a way that ensures that either all the fields or
     * none at all are set.
     * <p>
     * Both MSET and MSETNX are atomic operations. This means that for instance if the keys A and B
     * are modified, another client talking to Redis can either see the changes to both A and B at
     * once, or no modification at all.
     * @see #mset(const(ubyte)[]...)
     * @param keysvalues
     * @return Integer reply, specifically: 1 if the all the keys were set 0 if no key was set (at
     *         least one key already existed)
     */
    // override
    long msetnx(const(ubyte)[][] keysvalues...) {
        checkIsInMultiOrPipeline();
        client.msetnx(keysvalues);
        return client.getIntegerReply();
    }

    /**
     * DECRBY work just like {@link #decr(const(ubyte)[]) INCR} but instead to decrement by 1 the decrement is
     * integer.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incr(const(ubyte)[])
     * @see #decr(const(ubyte)[])
     * @see #incrBy(const(ubyte)[], long)
     * @param key
     * @param decrement
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    // override
    long decrBy(const(ubyte)[] key, long decrement) {
        checkIsInMultiOrPipeline();
        client.decrBy(key, decrement);
        return client.getIntegerReply();
    }

    /**
     * Decrement the number stored at key by one. If the key does not exist or contains a value of a
     * wrong type, set the key to the value of "0" before to perform the decrement operation.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incr(const(ubyte)[])
     * @see #incrBy(const(ubyte)[], long)
     * @see #decrBy(const(ubyte)[], long)
     * @param key
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    // override
    long decr(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.decr(key);
        return client.getIntegerReply();
    }

    /**
     * INCRBY work just like {@link #incr(const(ubyte)[]) INCR} but instead to increment by 1 the increment is
     * integer.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incr(const(ubyte)[])
     * @see #decr(const(ubyte)[])
     * @see #decrBy(const(ubyte)[], long)
     * @param key
     * @param increment
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    // override
    long incrBy(const(ubyte)[] key, long increment) {
        checkIsInMultiOrPipeline();
        client.incrBy(key, increment);
        return client.getIntegerReply();
    }

    /**
     * INCRBYFLOAT work just like {@link #incrBy(const(ubyte)[], long)} INCRBY} but increments by floats
     * instead of integers.
     * <p>
     * INCRBYFLOAT commands are limited to double precision floating point values.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "double" types.
     * Simply the string stored at the key is parsed as a base double precision floating point value,
     * incremented, and then converted back as a string. There is no DECRYBYFLOAT but providing a
     * negative value will work as expected.
     * <p>
     * Time complexity: O(1)
     * @see #incr(const(ubyte)[])
     * @see #decr(const(ubyte)[])
     * @see #decrBy(const(ubyte)[], long)
     * @param key the key to increment
     * @param increment the value to increment by
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    // override
    Double incrByFloat(const(ubyte)[] key, double increment) {
        checkIsInMultiOrPipeline();
        client.incrByFloat(key, increment);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    /**
     * Increment the number stored at key by one. If the key does not exist or contains a value of a
     * wrong type, set the key to the value of "0" before to perform the increment operation.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incrBy(const(ubyte)[], long)
     * @see #decr(const(ubyte)[])
     * @see #decrBy(const(ubyte)[], long)
     * @param key
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    // override
    long incr(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.incr(key);
        return client.getIntegerReply();
    }

    /**
     * If the key already exists and is a string, this command appends the provided value at the end
     * of the string. If the key does not exist it is created and set as an empty string, so APPEND
     * will be very similar to SET in this special case.
     * <p>
     * Time complexity: O(1). The amortized time complexity is O(1) assuming the appended value is
     * small and the already present value is of any size, since the dynamic string library used by
     * Redis will double the free space available on every reallocation.
     * @param key
     * @param value
     * @return Integer reply, specifically the total length of the string after the append operation.
     */
    // override
    long append(const(ubyte)[] key, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.append(key, value);
        return client.getIntegerReply();
    }

    /**
     * Return a subset of the string from offset start to offset end (both offsets are inclusive).
     * Negative offsets can be used in order to provide an offset starting from the end of the string.
     * So -1 means the last char, -2 the penultimate and so forth.
     * <p>
     * The function handles out of range requests without raising an error, but just limiting the
     * resulting range to the actual length of the string.
     * <p>
     * Time complexity: O(start+n) (with start being the start index and n the total length of the
     * requested range). Note that the lookup part of this command is O(1) so for small strings this
     * is actually an O(1) command.
     * @param key
     * @param start
     * @param end
     * @return Bulk reply
     */
    // override
    const(ubyte)[] substr(const(ubyte)[] key, int start, int end) {
        checkIsInMultiOrPipeline();
        client.substr(key, start, end);
        return client.getBinaryBulkReply();
    }

    /**
     * Set the specified hash field to the specified value.
     * <p>
     * If key does not exist, a new key holding a hash is created.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param field
     * @param value
     * @return If the field already exists, and the HSET just produced an update of the value, 0 is
     *         returned, otherwise if a new field is created 1 is returned.
     */
    // override
    long hset(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.hset(key, field, value);
        return client.getIntegerReply();
    }

    // override
    long hset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
        checkIsInMultiOrPipeline();
        client.hset(key, hash);
        return client.getIntegerReply();
    }

    /**
     * If key holds a hash, retrieve the value associated to the specified field.
     * <p>
     * If the field is not found or the key does not exist, a special 'nil' value is returned.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param field
     * @return Bulk reply
     */
    // // override
    const(ubyte)[] hget(const(ubyte)[] key, const(ubyte)[] field) {
        checkIsInMultiOrPipeline();
        client.hget(key, field);
        return client.getBinaryBulkReply();
    }

    /**
     * Set the specified hash field to the specified value if the field not exists. <b>Time
     * complexity:</b> O(1)
     * @param key
     * @param field
     * @param value
     * @return If the field already exists, 0 is returned, otherwise if a new field is created 1 is
     *         returned.
     */
    // // override
    long hsetnx(const(ubyte)[] key, const(ubyte)[] field, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.hsetnx(key, field, value);
        return client.getIntegerReply();
    }

    /**
     * Set the respective fields to the respective values. HMSET replaces old values with new values.
     * <p>
     * If key does not exist, a new key holding a hash is created.
     * <p>
     * <b>Time complexity:</b> O(N) (with N being the number of fields)
     * @param key
     * @param hash
     * @return Always OK because HMSET can't fail
     */
    // override
    string hmset(const(ubyte)[] key, Map!(const(ubyte)[], const(ubyte)[]) hash) {
        checkIsInMultiOrPipeline();
        client.hmset(key, hash);
        return client.getStatusCodeReply();
    }

    /**
     * Retrieve the values associated to the specified fields.
     * <p>
     * If some of the specified fields do not exist, nil values are returned. Non existing keys are
     * considered like empty hashes.
     * <p>
     * <b>Time complexity:</b> O(N) (with N being the number of fields)
     * @param key
     * @param fields
     * @return Multi Bulk Reply specifically a list of all the values associated with the specified
     *         fields, in the same order of the request.
     */
    // override
    List!(const(ubyte)[]) hmget(const(ubyte)[] key, const(ubyte)[][] fields...) {
        checkIsInMultiOrPipeline();
        client.hmget(key, fields);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Increment the number stored at field in the hash at key by value. If key does not exist, a new
     * key holding a hash is created. If field does not exist or holds a string, the value is set to 0
     * before applying the operation. Since the value argument is signed you can use this command to
     * perform both increments and decrements.
     * <p>
     * The range of values supported by HINCRBY is limited to 64 bit signed integers.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param field
     * @param value
     * @return Integer reply The new value at field after the increment operation.
     */
    // override
    long hincrBy(const(ubyte)[] key, const(ubyte)[] field, long value) {
        checkIsInMultiOrPipeline();
        client.hincrBy(key, field, value);
        return client.getIntegerReply();
    }

    /**
     * Increment the number stored at field in the hash at key by a double precision floating point
     * value. If key does not exist, a new key holding a hash is created. If field does not exist or
     * holds a string, the value is set to 0 before applying the operation. Since the value argument
     * is signed you can use this command to perform both increments and decrements.
     * <p>
     * The range of values supported by HINCRBYFLOAT is limited to double precision floating point
     * values.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param field
     * @param value
     * @return Double precision floating point reply The new value at field after the increment
     *         operation.
     */
    // override
    Double hincrByFloat(const(ubyte)[] key, const(ubyte)[] field, double value) {
        checkIsInMultiOrPipeline();
        client.hincrByFloat(key, field, value);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    /**
     * Test for existence of a specified field in a hash. <b>Time complexity:</b> O(1)
     * @param key
     * @param field
     * @return Return true if the hash stored at key contains the specified field. Return false if the key is
     *         not found or the field is not present.
     */
    // override
    bool hexists(const(ubyte)[] key, const(ubyte)[] field) {
        checkIsInMultiOrPipeline();
        client.hexists(key, field);
        return client.getIntegerReply() == 1;
    }

    /**
     * Remove the specified field from an hash stored at key.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param fields
     * @return If the field was present in the hash it is deleted and 1 is returned, otherwise 0 is
     *         returned and no operation is performed.
     */
    // override
    long hdel(const(ubyte)[] key, const(ubyte)[][] fields...) {
        checkIsInMultiOrPipeline();
        client.hdel(key, fields);
        return client.getIntegerReply();
    }

    /**
     * Return the number of items in a hash.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @return The number of entries (fields) contained in the hash stored at key. If the specified
     *         key does not exist, 0 is returned assuming an empty hash.
     */
    // override
    long hlen(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.hlen(key);
        return client.getIntegerReply();
    }

    /**
     * Return all the fields in a hash.
     * <p>
     * <b>Time complexity:</b> O(N), where N is the total number of entries
     * @param key
     * @return All the fields names contained into a hash.
     */
    // override
    Set!(const(ubyte)[]) hkeys(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.hkeys(key);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * Return all the values in a hash.
     * <p>
     * <b>Time complexity:</b> O(N), where N is the total number of entries
     * @param key
     * @return All the fields values contained into a hash.
     */
    // override
    List!(const(ubyte)[]) hvals(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.hvals(key);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Return all the fields and associated values in a hash.
     * <p>
     * <b>Time complexity:</b> O(N), where N is the total number of entries
     * @param key
     * @return All the fields and values contained into a hash.
     */
    // override
    Map!(const(ubyte)[], const(ubyte)[]) hgetAll(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.hgetAll(key);
        List!(const(ubyte)[]) flatHash = client.getBinaryMultiBulkReply();
        Map!(const(ubyte)[], const(ubyte)[]) hash = new RedisByteHashMap();
        InputRange!(const(ubyte)[]) iterator = flatHash.iterator();
        while(!iterator.empty()) {
            const(ubyte)[] k = iterator.front();
            iterator.popFront();
            const(ubyte)[] v = iterator.front();
            iterator.popFront();
            hash.put(k, v);
        }

        return hash;
    }

    /**
     * Add the string value to the head (LPUSH) or tail (RPUSH) of the list stored at key. If the key
     * does not exist an empty list is created just before the append operation. If the key exists but
     * is not a List an error is returned.
     * <p>
     * Time complexity: O(1)
     * @see BinaryRedis#rpush(const(ubyte)[], const(ubyte)[]...)
     * @param key
     * @param strings
     * @return Integer reply, specifically, the number of elements inside the list after the push
     *         operation.
     */
    // override
    long rpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
        checkIsInMultiOrPipeline();
        client.rpush(key, strings);
        return client.getIntegerReply();
    }

    /**
     * Add the string value to the head (LPUSH) or tail (RPUSH) of the list stored at key. If the key
     * does not exist an empty list is created just before the append operation. If the key exists but
     * is not a List an error is returned.
     * <p>
     * Time complexity: O(1)
     * @see BinaryRedis#rpush(const(ubyte)[], const(ubyte)[]...)
     * @param key
     * @param strings
     * @return Integer reply, specifically, the number of elements inside the list after the push
     *         operation.
     */
    // override
    long lpush(const(ubyte)[] key, const(ubyte)[][] strings...) {
        checkIsInMultiOrPipeline();
        client.lpush(key, strings);
        return client.getIntegerReply();
    }

    /**
     * Return the length of the list stored at the specified key. If the key does not exist zero is
     * returned (the same behaviour as for empty lists). If the value stored at key is not a list an
     * error is returned.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @return The length of the list.
     */
    // override
    long llen(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.llen(key);
        return client.getIntegerReply();
    }

    /**
     * Return the specified elements of the list stored at the specified key. Start and end are
     * zero-based indexes. 0 is the first element of the list (the list head), 1 the next element and
     * so on.
     * <p>
     * For example LRANGE foobar 0 2 will return the first three elements of the list.
     * <p>
     * start and end can also be negative numbers indicating offsets from the end of the list. For
     * example -1 is the last element of the list, -2 the penultimate element and so on.
     * <p>
     * <b>Consistency with range functions in various programming languages</b>
     * <p>
     * Note that if you have a list of numbers from 0 to 100, LRANGE 0 10 will return 11 elements,
     * that is, rightmost item is included. This may or may not be consistent with behavior of
     * range-related functions in your programming language of choice (think Ruby's Range.new,
     * Array#slice or Python's range() function).
     * <p>
     * LRANGE behavior is consistent with one of Tcl.
     * <p>
     * <b>Out-of-range indexes</b>
     * <p>
     * Indexes out of range will not produce an error: if start is over the end of the list, or start
     * &gt; end, an empty list is returned. If end is over the end of the list Redis will threat it
     * just like the last element of the list.
     * <p>
     * Time complexity: O(start+n) (with n being the length of the range and start being the start
     * offset)
     * @param key
     * @param start
     * @param stop
     * @return Multi bulk reply, specifically a list of elements in the specified range.
     */
    // override
    List!(const(ubyte)[]) lrange(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.lrange(key, start, stop);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Trim an existing list so that it will contain only the specified range of elements specified.
     * Start and end are zero-based indexes. 0 is the first element of the list (the list head), 1 the
     * next element and so on.
     * <p>
     * For example LTRIM foobar 0 2 will modify the list stored at foobar key so that only the first
     * three elements of the list will remain.
     * <p>
     * start and end can also be negative numbers indicating offsets from the end of the list. For
     * example -1 is the last element of the list, -2 the penultimate element and so on.
     * <p>
     * Indexes out of range will not produce an error: if start is over the end of the list, or start
     * &gt; end, an empty list is left as value. If end over the end of the list Redis will threat it
     * just like the last element of the list.
     * <p>
     * Hint: the obvious use of LTRIM is together with LPUSH/RPUSH. For example:
     * <p>
     * {@code lpush("mylist", "someelement"); ltrim("mylist", 0, 99); * }
     * <p>
     * The above two commands will push elements in the list taking care that the list will not grow
     * without limits. This is very useful when using Redis to store logs for example. It is important
     * to note that when used in this way LTRIM is an O(1) operation because in the average case just
     * one element is removed from the tail of the list.
     * <p>
     * Time complexity: O(n) (with n being len of list - len of range)
     * @param key
     * @param start
     * @param stop
     * @return Status code reply
     */
    // override
    string ltrim(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.ltrim(key, start, stop);
        return client.getStatusCodeReply();
    }

    /**
     * Return the specified element of the list stored at the specified key. 0 is the first element, 1
     * the second and so on. Negative indexes are supported, for example -1 is the last element, -2
     * the penultimate and so on.
     * <p>
     * If the value stored at key is not of list type an error is returned. If the index is out of
     * range a 'nil' reply is returned.
     * <p>
     * Note that even if the average time complexity is O(n) asking for the first or the last element
     * of the list is O(1).
     * <p>
     * Time complexity: O(n) (with n being the length of the list)
     * @param key
     * @param index
     * @return Bulk reply, specifically the requested element
     */
    // override
    const(ubyte)[] lindex(const(ubyte)[] key, long index) {
        checkIsInMultiOrPipeline();
        client.lindex(key, index);
        return client.getBinaryBulkReply();
    }

    /**
     * Set a new value as the element at index position of the List at key.
     * <p>
     * Out of range indexes will generate an error.
     * <p>
     * Similarly to other list commands accepting indexes, the index can be negative to access
     * elements starting from the end of the list. So -1 is the last element, -2 is the penultimate,
     * and so forth.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(N) (with N being the length of the list), setting the first or last elements of the list is
     * O(1).
     * @see #lindex(const(ubyte)[], long)
     * @param key
     * @param index
     * @param value
     * @return Status code reply
     */
    // override
    string lset(const(ubyte)[] key, long index, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.lset(key, index, value);
        return client.getStatusCodeReply();
    }

    /**
     * Remove the first count occurrences of the value element from the list. If count is zero all the
     * elements are removed. If count is negative elements are removed from tail to head, instead to
     * go from head to tail that is the normal behaviour. So for example LREM with count -2 and hello
     * as value to remove against the list (a,b,c,hello,x,hello,hello) will leave the list
     * (a,b,c,hello,x). The number of removed elements is returned as an integer, see below for more
     * information about the returned value. Note that non existing keys are considered like empty
     * lists by LREM, so LREM against non existing keys will always return 0.
     * <p>
     * Time complexity: O(N) (with N being the length of the list)
     * @param key
     * @param count
     * @param value
     * @return Integer Reply, specifically: The number of removed elements if the operation succeeded
     */
    // override
    long lrem(const(ubyte)[] key, long count, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.lrem(key, count, value);
        return client.getIntegerReply();
    }

    /**
     * Atomically return and remove the first (LPOP) or last (RPOP) element of the list. For example
     * if the list contains the elements "a","b","c" LPOP will return "a" and the list will become
     * "b","c".
     * <p>
     * If the key does not exist or the list is already empty the special value 'nil' is returned.
     * @see #rpop(const(ubyte)[])
     * @param key
     * @return Bulk reply
     */
    // override
    const(ubyte)[] lpop(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.lpop(key);
        return client.getBinaryBulkReply();
    }

    /**
     * Atomically return and remove the first (LPOP) or last (RPOP) element of the list. For example
     * if the list contains the elements "a","b","c" LPOP will return "a" and the list will become
     * "b","c".
     * <p>
     * If the key does not exist or the list is already empty the special value 'nil' is returned.
     * @see #lpop(const(ubyte)[])
     * @param key
     * @return Bulk reply
     */
    // override
    const(ubyte)[] rpop(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.rpop(key);
        return client.getBinaryBulkReply();
    }

    /**
     * Atomically return and remove the last (tail) element of the srckey list, and push the element
     * as the first (head) element of the dstkey list. For example if the source list contains the
     * elements "a","b","c" and the destination list contains the elements "foo","bar" after an
     * RPOPLPUSH command the content of the two lists will be "a","b" and "c","foo","bar".
     * <p>
     * If the key does not exist or the list is already empty the special value 'nil' is returned. If
     * the srckey and dstkey are the same the operation is equivalent to removing the last element
     * from the list and pushing it as first element of the list, so it's a "list rotation" command.
     * <p>
     * Time complexity: O(1)
     * @param srckey
     * @param dstkey
     * @return Bulk reply
     */
    // override
    const(ubyte)[] rpoplpush(const(ubyte)[] srckey, const(ubyte)[] dstkey) {
        checkIsInMultiOrPipeline();
        client.rpoplpush(srckey, dstkey);
        return client.getBinaryBulkReply();
    }

    /**
     * Add the specified member to the set value stored at key. If member is already a member of the
     * set no operation is performed. If key does not exist a new set with the specified member as
     * sole member is created. If the key exists but does not hold a set value an error is returned.
     * <p>
     * Time complexity O(1)
     * @param key
     * @param members
     * @return Integer reply, specifically: 1 if the new element was added 0 if the element was
     *         already a member of the set
     */
    // override
    long sadd(const(ubyte)[] key, const(ubyte)[][] members...) {
        checkIsInMultiOrPipeline();
        client.sadd(key, members);
        return client.getIntegerReply();
    }

    /**
     * Return all the members (elements) of the set value stored at key. This is just syntax glue for
     * {@link #sinter(const(ubyte)[]...)} SINTER}.
     * <p>
     * Time complexity O(N)
     * @param key the key of the set
     * @return Multi bulk reply
     */
    // override
    Set!(const(ubyte)[]) smembers(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.smembers(key);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * Remove the specified member from the set value stored at key. If member was not a member of the
     * set no operation is performed. If key does not hold a set value an error is returned.
     * <p>
     * Time complexity O(1)
     * @param key the key of the set
     * @param member the set member to remove
     * @return Integer reply, specifically: 1 if the new element was removed 0 if the new element was
     *         not a member of the set
     */
    // override
    long srem(const(ubyte)[] key, const(ubyte)[][] member...) {
        checkIsInMultiOrPipeline();
        client.srem(key, member);
        return client.getIntegerReply();
    }

    /**
     * Remove a random element from a Set returning it as return value. If the Set is empty or the key
     * does not exist, a nil object is returned.
     * <p>
     * The {@link #srandmember(const(ubyte)[])} command does a similar work but the returned element is not
     * removed from the Set.
     * <p>
     * Time complexity O(1)
     * @param key
     * @return Bulk reply
     */
    // override
    const(ubyte)[] spop(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.spop(key);
        return client.getBinaryBulkReply();
    }

    // override
    Set!(const(ubyte)[]) spop(const(ubyte)[] key, long count) {
        checkIsInMultiOrPipeline();
        client.spop(key, count);
        List!(const(ubyte)[]) members = client.getBinaryMultiBulkReply();
        if (members is null) return null;
        return new SetFromList!(const(ubyte)[])(members);
    }

    /**
     * Move the specified member from the set at srckey to the set at dstkey. This operation is
     * atomic, in every given moment the element will appear to be in the source or destination set
     * for accessing clients.
     * <p>
     * If the source set does not exist or does not contain the specified element no operation is
     * performed and zero is returned, otherwise the element is removed from the source set and added
     * to the destination set. On success one is returned, even if the element was already present in
     * the destination set.
     * <p>
     * An error is raised if the source or destination keys contain a non Set value.
     * <p>
     * Time complexity O(1)
     * @param srckey
     * @param dstkey
     * @param member
     * @return Integer reply, specifically: 1 if the element was moved 0 if the element was not found
     *         on the first set and no operation was performed
     */
    // override
    long smove(const(ubyte)[] srckey, const(ubyte)[] dstkey, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.smove(srckey, dstkey, member);
        return client.getIntegerReply();
    }

    /**
     * Return the set cardinality (number of elements). If the key does not exist 0 is returned, like
     * for empty sets.
     * @param key
     * @return Integer reply, specifically: the cardinality (number of elements) of the set as an
     *         integer.
     */
    // override
    long scard(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.scard(key);
        return client.getIntegerReply();
    }

    /**
     * Return true if member is a member of the set stored at key, otherwise false is returned.
     * <p>
     * Time complexity O(1)
     * @param key
     * @param member
     * @return bool reply, specifically: true if the element is a member of the set false if the element
     *         is not a member of the set OR if the key does not exist
     */
    // override
    bool sismember(const(ubyte)[] key, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.sismember(key, member);
        return client.getIntegerReply() == 1;
    }

    /**
     * Return the members of a set resulting from the intersection of all the sets hold at the
     * specified keys. Like in {@link #lrange(const(ubyte)[], long, long)} LRANGE} the result is sent to the
     * client as a multi-bulk reply (see the protocol specification for more information). If just a
     * single key is specified, then this command produces the same result as
     * {@link #smembers(const(ubyte)[]) SMEMBERS}. Actually SMEMBERS is just syntax sugar for SINTER.
     * <p>
     * Non existing keys are considered like empty sets, so if one of the keys is missing an empty set
     * is returned (since the intersection with an empty set always is an empty set).
     * <p>
     * Time complexity O(N*M) worst case where N is the cardinality of the smallest set and M the
     * number of sets
     * @param keys
     * @return Multi bulk reply, specifically the list of common elements.
     */
    // override
    Set!(const(ubyte)[]) sinter(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sinter(keys);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * This commanad works exactly like {@link #sinter(const(ubyte)[]...) SINTER} but instead of being returned
     * the resulting set is stored as dstkey.
     * <p>
     * Time complexity O(N*M) worst case where N is the cardinality of the smallest set and M the
     * number of sets
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    // override
    long sinterstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sinterstore(dstkey, keys);
        return client.getIntegerReply();
    }

    /**
     * Return the members of a set resulting from the union of all the sets hold at the specified
     * keys. Like in {@link #lrange(const(ubyte)[], long, long)} LRANGE} the result is sent to the client as a
     * multi-bulk reply (see the protocol specification for more information). If just a single key is
     * specified, then this command produces the same result as {@link #smembers(const(ubyte)[]) SMEMBERS}.
     * <p>
     * Non existing keys are considered like empty sets.
     * <p>
     * Time complexity O(N) where N is the total number of elements in all the provided sets
     * @param keys
     * @return Multi bulk reply, specifically the list of common elements.
     */
    // override
    Set!(const(ubyte)[]) sunion(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sunion(keys);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * This command works exactly like {@link #sunion(const(ubyte)[]...) SUNION} but instead of being returned
     * the resulting set is stored as dstkey. Any existing value in dstkey will be over-written.
     * <p>
     * Time complexity O(N) where N is the total number of elements in all the provided sets
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    // override
    long sunionstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sunionstore(dstkey, keys);
        return client.getIntegerReply();
    }

    /**
     * Return the difference between the Set stored at key1 and all the Sets key2, ..., keyN
     * <p>
     * <b>Example:</b>
     * 
     * <pre>
     * key1 = [x, a, b, c]
     * key2 = [c]
     * key3 = [a, d]
     * SDIFF key1,key2,key3 =&gt; [x, b]
     * </pre>
     * 
     * Non existing keys are considered like empty sets.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(N) with N being the total number of elements of all the sets
     * @param keys
     * @return Return the members of a set resulting from the difference between the first set
     *         provided and all the successive sets.
     */
    // override
    Set!(const(ubyte)[]) sdiff(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sdiff(keys);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * This command works exactly like {@link #sdiff(const(ubyte)[]...) SDIFF} but instead of being returned
     * the resulting set is stored in dstkey.
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    // override
    long sdiffstore(const(ubyte)[] dstkey, const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.sdiffstore(dstkey, keys);
        return client.getIntegerReply();
    }

    /**
     * Return a random element from a Set, without removing the element. If the Set is empty or the
     * key does not exist, a nil object is returned.
     * <p>
     * The SPOP command does a similar work but the returned element is popped (removed) from the Set.
     * <p>
     * Time complexity O(1)
     * @param key
     * @return Bulk reply
     */
    // override
    const(ubyte)[] srandmember(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.srandmember(key);
        return client.getBinaryBulkReply();
    }

    // override
    List!(const(ubyte)[]) srandmember(const(ubyte)[] key, int count) {
        checkIsInMultiOrPipeline();
        client.srandmember(key, count);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Add the specified member having the specified score to the sorted set stored at key. If member
     * is already a member of the sorted set the score is updated, and the element reinserted in the
     * right position to ensure sorting. If key does not exist a new sorted set with the specified
     * member as sole member is created. If the key exists but does not hold a sorted set value an
     * error is returned.
     * <p>
     * The score value can be the string representation of a double precision floating point number.
     * <p>
     * Time complexity O(log(N)) with N being the number of elements in the sorted set
     * @param key
     * @param score
     * @param member
     * @return Integer reply, specifically: 1 if the new element was added 0 if the element was
     *         already a member of the sorted set and the score was updated
     */
    // override
    long zadd(const(ubyte)[] key, double score, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.zadd(key, score, member);
        return client.getIntegerReply();
    }

    // override
    long zadd(const(ubyte)[] key, double score, const(ubyte)[] member, ZAddParams params) {
        checkIsInMultiOrPipeline();
        client.zadd(key, score, member, params);
        return client.getIntegerReply();
    }

    // override
    long zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers) {
        checkIsInMultiOrPipeline();
        client.zadd(key, scoreMembers);
        return client.getIntegerReply();
    }

    // override
    long zadd(const(ubyte)[] key, Map!(const(ubyte)[], double) scoreMembers, ZAddParams params) {
        checkIsInMultiOrPipeline();
        client.zadd(key, scoreMembers, params);
        return client.getIntegerReply();
    }

    // override
    const(ubyte)[][] zrange(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrange(key, start, stop);
        // return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
        List!(const(ubyte)[]) r = client.getBinaryMultiBulkReply();
        return r.toArray();
    }

    /**
     * Remove the specified member from the sorted set value stored at key. If member was not a member
     * of the set no operation is performed. If key does not not hold a set value an error is
     * returned.
     * <p>
     * Time complexity O(log(N)) with N being the number of elements in the sorted set
     * @param key
     * @param members
     * @return Integer reply, specifically: 1 if the new element was removed 0 if the new element was
     *         not a member of the set
     */
    // override
    long zrem(const(ubyte)[] key, const(ubyte)[][] members...) {
        checkIsInMultiOrPipeline();
        client.zrem(key, members);
        return client.getIntegerReply();
    }

    /**
     * If member already exists in the sorted set adds the increment to its score and updates the
     * position of the element in the sorted set accordingly. If member does not already exist in the
     * sorted set it is added with increment as score (that is, like if the previous score was
     * virtually zero). If key does not exist a new sorted set with the specified member as sole
     * member is created. If the key exists but does not hold a sorted set value an error is returned.
     * <p>
     * The score value can be the string representation of a double precision floating point number.
     * It's possible to provide a negative value to perform a decrement.
     * <p>
     * For an introduction to sorted sets check the Introduction to Redis data types page.
     * <p>
     * Time complexity O(log(N)) with N being the number of elements in the sorted set
     * @param key
     * @param increment
     * @param member
     * @return The new score
     */
    // override
    double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.zincrby(key, increment, member);
        Double r = BuilderFactory.DOUBLE.build(client.getOne());
        return r.value();
    }

    // override
    double zincrby(const(ubyte)[] key, double increment, const(ubyte)[] member, ZIncrByParams params) {
        checkIsInMultiOrPipeline();
        client.zincrby(key, increment, member, params);
        Double r = BuilderFactory.DOUBLE.build(client.getOne());
        return r.value();
    }

    /**
     * Return the rank (or index) or member in the sorted set at key, with scores being ordered from
     * low to high.
     * <p>
     * When the given member does not exist in the sorted set, the special value 'nil' is returned.
     * The returned rank (or index) of the member is 0-based for both commands.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))
     * @see #zrevrank(const(ubyte)[], const(ubyte)[])
     * @param key
     * @param member
     * @return Integer reply or a nil bulk reply, specifically: the rank of the element as an integer
     *         reply if the element exists. A nil bulk reply if there is no such element.
     */
    // override
    long zrank(const(ubyte)[] key, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.zrank(key, member);
        return client.getIntegerReply();
    }

    /**
     * Return the rank (or index) or member in the sorted set at key, with scores being ordered from
     * high to low.
     * <p>
     * When the given member does not exist in the sorted set, the special value 'nil' is returned.
     * The returned rank (or index) of the member is 0-based for both commands.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))
     * @see #zrank(const(ubyte)[], const(ubyte)[])
     * @param key
     * @param member
     * @return Integer reply or a nil bulk reply, specifically: the rank of the element as an integer
     *         reply if the element exists. A nil bulk reply if there is no such element.
     */
    // override
    long zrevrank(const(ubyte)[] key, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.zrevrank(key, member);
        return client.getIntegerReply();
    }

    // override
    Set!(const(ubyte)[]) zrevrange(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrevrange(key, start, stop);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(Tuple) zrangeWithScores(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrangeWithScores(key, start, stop);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrevrangeWithScores(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrevrangeWithScores(key, start, stop);
        return getTupledSet();
    }

    /**
     * Return the sorted set cardinality (number of elements). If the key does not exist 0 is
     * returned, like for empty sorted sets.
     * <p>
     * Time complexity O(1)
     * @param key
     * @return the cardinality (number of elements) of the set as an integer.
     */
    // override
    long zcard(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.zcard(key);
        return client.getIntegerReply();
    }

    /**
     * Return the score of the specified element of the sorted set at key. If the specified element
     * does not exist in the sorted set, or the key does not exist at all, a special 'nil' value is
     * returned.
     * <p>
     * <b>Time complexity:</b> O(1)
     * @param key
     * @param member
     * @return the score
     */
    // override
    Double zscore(const(ubyte)[] key, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.zscore(key, member);
        string score = client.getBulkReply();
        return (score !is null ? new Double(score) : null);
    }

    Transaction multi() {
        client.multi();
        client.getOne(); // expected OK
        transaction = new Transaction(client);
        return transaction;
    }

    protected void checkIsInMultiOrPipeline() {
        if (client.isInMulti()) {
            throw new RedisDataException(
                    "Cannot use Redis when in Multi. Please use Transaction or reset jedis state.");
        } else if (pipeline !is null && pipeline.hasPipelinedResponse()) {
            throw new RedisDataException(
                    "Cannot use Redis when in Pipeline. Please use Pipeline or reset jedis state .");
        }
    }

    void connect() {
        client.connect();
    }

    void disconnect() {
        client.disconnect();
    }

    void resetState() {
        if (client.isConnected()) {
            if (transaction !is null) {
                transaction.close();
            }

            if (pipeline !is null) {
                pipeline.close();
            }

            client.resetState();
        }

        transaction = null;
        pipeline = null;
    }

    // override
    string watch(const(ubyte)[][] keys...) {
        client.watch(keys);
        return client.getStatusCodeReply();
    }

    // override
    string unwatch() {
        client.unwatch();
        return client.getStatusCodeReply();
    }

    // override
    void close() {
        client.close();
    }

    /**
     * Sort a Set or a List.
     * <p>
     * Sort the elements contained in the List, Set, or Sorted Set value at key. By default sorting is
     * numeric with elements being compared as double precision floating point numbers. This is the
     * simplest form of SORT.
     * @see #sort(const(ubyte)[], const(ubyte)[])
     * @see #sort(const(ubyte)[], SortingParams)
     * @see #sort(const(ubyte)[], SortingParams, const(ubyte)[])
     * @param key
     * @return Assuming the Set/List at key contains a list of numbers, the return value will be the
     *         list of numbers ordered from the smallest to the biggest number.
     */
    // override
    List!(const(ubyte)[]) sort(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.sort(key);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Sort a Set or a List accordingly to the specified parameters.
     * <p>
     * <b>examples:</b>
     * <p>
     * Given are the following sets and key/values:
     * 
     * <pre>
     * x = [1, 2, 3]
     * y = [a, b, c]
     * 
     * k1 = z
     * k2 = y
     * k3 = x
     * 
     * w1 = 9
     * w2 = 8
     * w3 = 7
     * </pre>
     * 
     * Sort Order:
     * 
     * <pre>
     * sort(x) or sort(x, sp.asc())
     * -&gt; [1, 2, 3]
     * 
     * sort(x, sp.desc())
     * -&gt; [3, 2, 1]
     * 
     * sort(y)
     * -&gt; [c, a, b]
     * 
     * sort(y, sp.alpha())
     * -&gt; [a, b, c]
     * 
     * sort(y, sp.alpha().desc())
     * -&gt; [c, a, b]
     * </pre>
     * 
     * Limit (e.g. for Pagination):
     * 
     * <pre>
     * sort(x, sp.limit(0, 2))
     * -&gt; [1, 2]
     * 
     * sort(y, sp.alpha().desc().limit(1, 2))
     * -&gt; [b, a]
     * </pre>
     * 
     * Sorting by external keys:
     * 
     * <pre>
     * sort(x, sb.by(w*))
     * -&gt; [3, 2, 1]
     * 
     * sort(x, sb.by(w*).desc())
     * -&gt; [1, 2, 3]
     * </pre>
     * 
     * Getting external keys:
     * 
     * <pre>
     * sort(x, sp.by(w*).get(k*))
     * -&gt; [x, y, z]
     * 
     * sort(x, sp.by(w*).get(#).get(k*))
     * -&gt; [3, x, 2, y, 1, z]
     * </pre>
     * @see #sort(const(ubyte)[])
     * @see #sort(const(ubyte)[], SortingParams, const(ubyte)[])
     * @param key
     * @param sortingParameters
     * @return a list of sorted elements.
     */
    // override
    List!(const(ubyte)[]) sort(const(ubyte)[] key, SortingParams sortingParameters) {
        checkIsInMultiOrPipeline();
        client.sort(key, sortingParameters);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * BLPOP (and BRPOP) is a blocking list pop primitive. You can see this commands as blocking
     * versions of LPOP and RPOP able to block if the specified keys don't exist or contain empty
     * lists.
     * <p>
     * The following is a description of the exact semantic. We describe BLPOP but the two commands
     * are identical, the only difference is that BLPOP pops the element from the left (head) of the
     * list, and BRPOP pops from the right (tail).
     * <p>
     * <b>Non blocking behavior</b>
     * <p>
     * When BLPOP is called, if at least one of the specified keys contain a non empty list, an
     * element is popped from the head of the list and returned to the caller together with the name
     * of the key (BLPOP returns a two elements array, the first element is the key, the second the
     * popped value).
     * <p>
     * Keys are scanned from left to right, so for instance if you issue BLPOP list1 list2 list3 0
     * against a dataset where list1 does not exist but list2 and list3 contain non empty lists, BLPOP
     * guarantees to return an element from the list stored at list2 (since it is the first non empty
     * list starting from the left).
     * <p>
     * <b>Blocking behavior</b>
     * <p>
     * If none of the specified keys exist or contain non empty lists, BLPOP blocks until some other
     * client performs a LPUSH or an RPUSH operation against one of the lists.
     * <p>
     * Once new data is present on one of the lists, the client finally returns with the name of the
     * key unblocking it and the popped value.
     * <p>
     * When blocking, if a non-zero timeout is specified, the client will unblock returning a nil
     * special value if the specified amount of seconds passed without a push operation against at
     * least one of the specified keys.
     * <p>
     * The timeout argument is interpreted as an integer value. A timeout of zero means instead to
     * block forever.
     * <p>
     * <b>Multiple clients blocking for the same keys</b>
     * <p>
     * Multiple clients can block for the same key. They are put into a queue, so the first to be
     * served will be the one that started to wait earlier, in a first-blpopping first-served fashion.
     * <p>
     * <b>blocking POP inside a MULTI/EXEC transaction</b>
     * <p>
     * BLPOP and BRPOP can be used with pipelining (sending multiple commands and reading the replies
     * in batch), but it does not make sense to use BLPOP or BRPOP inside a MULTI/EXEC block (a Redis
     * transaction).
     * <p>
     * The behavior of BLPOP inside MULTI/EXEC when the list is empty is to return a multi-bulk nil
     * reply, exactly what happens when the timeout is reached. If you like science fiction, think at
     * it like if inside MULTI/EXEC the time will flow at infinite speed :)
     * <p>
     * Time complexity: O(1)
     * @see #brpop(int, const(ubyte)[]...)
     * @param timeout
     * @param keys
     * @return BLPOP returns a two-elements array via a multi bulk reply in order to return both the
     *         unblocking key and the popped value.
     *         <p>
     *         When a non-zero timeout is specified, and the BLPOP operation timed out, the return
     *         value is a nil multi bulk reply. Most client values will return false or nil
     *         accordingly to the programming language used.
     */
    // override
    List!(const(ubyte)[]) blpop(int timeout, const(ubyte)[][] keys...) {
        return blpop(getArgsAddTimeout(timeout, keys));
    }

    private const(ubyte)[][] getArgsAddTimeout(int timeout, const(ubyte)[][] keys) {
        int size = cast(int)keys.length;
        const(ubyte)[][] args = new const(ubyte)[][size + 1];
        for (int at = 0; at != size; ++at) {
            args[at] = keys[at];
        }
        args[size] = Protocol.toByteArray(timeout);
        return args;
    }

    /**
     * Sort a Set or a List accordingly to the specified parameters and store the result at dstkey.
     * @see #sort(const(ubyte)[], SortingParams)
     * @see #sort(const(ubyte)[])
     * @see #sort(const(ubyte)[], const(ubyte)[])
     * @param key
     * @param sortingParameters
     * @param dstkey
     * @return The number of elements of the list at dstkey.
     */
    // override
    long sort(const(ubyte)[] key, SortingParams sortingParameters, const(ubyte)[] dstkey) {
        checkIsInMultiOrPipeline();
        client.sort(key, sortingParameters, dstkey);
        return client.getIntegerReply();
    }

    /**
     * Sort a Set or a List and Store the Result at dstkey.
     * <p>
     * Sort the elements contained in the List, Set, or Sorted Set value at key and store the result
     * at dstkey. By default sorting is numeric with elements being compared as double precision
     * floating point numbers. This is the simplest form of SORT.
     * @see #sort(const(ubyte)[])
     * @see #sort(const(ubyte)[], SortingParams)
     * @see #sort(const(ubyte)[], SortingParams, const(ubyte)[])
     * @param key
     * @param dstkey
     * @return The number of elements of the list at dstkey.
     */
    // override
    long sort(const(ubyte)[] key, const(ubyte)[] dstkey) {
        checkIsInMultiOrPipeline();
        client.sort(key, dstkey);
        return client.getIntegerReply();
    }

    /**
     * BLPOP (and BRPOP) is a blocking list pop primitive. You can see this commands as blocking
     * versions of LPOP and RPOP able to block if the specified keys don't exist or contain empty
     * lists.
     * <p>
     * The following is a description of the exact semantic. We describe BLPOP but the two commands
     * are identical, the only difference is that BLPOP pops the element from the left (head) of the
     * list, and BRPOP pops from the right (tail).
     * <p>
     * <b>Non blocking behavior</b>
     * <p>
     * When BLPOP is called, if at least one of the specified keys contain a non empty list, an
     * element is popped from the head of the list and returned to the caller together with the name
     * of the key (BLPOP returns a two elements array, the first element is the key, the second the
     * popped value).
     * <p>
     * Keys are scanned from left to right, so for instance if you issue BLPOP list1 list2 list3 0
     * against a dataset where list1 does not exist but list2 and list3 contain non empty lists, BLPOP
     * guarantees to return an element from the list stored at list2 (since it is the first non empty
     * list starting from the left).
     * <p>
     * <b>Blocking behavior</b>
     * <p>
     * If none of the specified keys exist or contain non empty lists, BLPOP blocks until some other
     * client performs a LPUSH or an RPUSH operation against one of the lists.
     * <p>
     * Once new data is present on one of the lists, the client finally returns with the name of the
     * key unblocking it and the popped value.
     * <p>
     * When blocking, if a non-zero timeout is specified, the client will unblock returning a nil
     * special value if the specified amount of seconds passed without a push operation against at
     * least one of the specified keys.
     * <p>
     * The timeout argument is interpreted as an integer value. A timeout of zero means instead to
     * block forever.
     * <p>
     * <b>Multiple clients blocking for the same keys</b>
     * <p>
     * Multiple clients can block for the same key. They are put into a queue, so the first to be
     * served will be the one that started to wait earlier, in a first-blpopping first-served fashion.
     * <p>
     * <b>blocking POP inside a MULTI/EXEC transaction</b>
     * <p>
     * BLPOP and BRPOP can be used with pipelining (sending multiple commands and reading the replies
     * in batch), but it does not make sense to use BLPOP or BRPOP inside a MULTI/EXEC block (a Redis
     * transaction).
     * <p>
     * The behavior of BLPOP inside MULTI/EXEC when the list is empty is to return a multi-bulk nil
     * reply, exactly what happens when the timeout is reached. If you like science fiction, think at
     * it like if inside MULTI/EXEC the time will flow at infinite speed :)
     * <p>
     * Time complexity: O(1)
     * @see #blpop(int, const(ubyte)[]...)
     * @param timeout
     * @param keys
     * @return BLPOP returns a two-elements array via a multi bulk reply in order to return both the
     *         unblocking key and the popped value.
     *         <p>
     *         When a non-zero timeout is specified, and the BLPOP operation timed out, the return
     *         value is a nil multi bulk reply. Most client values will return false or nil
     *         accordingly to the programming language used.
     */
    // override
    List!(const(ubyte)[]) brpop(int timeout, const(ubyte)[][] keys...) {
        return brpop(getArgsAddTimeout(timeout, keys));
    }

    // override
    List!(const(ubyte)[]) blpop(const(ubyte)[][] args...) {
        checkIsInMultiOrPipeline();
        client.blpop(args);
        client.setTimeoutInfinite();
        try {
            return client.getBinaryMultiBulkReply();
        } finally {
            client.rollbackTimeout();
        }
    }

    // override
    List!(const(ubyte)[]) brpop(const(ubyte)[][] args...) {
        checkIsInMultiOrPipeline();
        client.brpop(args);
        client.setTimeoutInfinite();
        try {
            return client.getBinaryMultiBulkReply();
        } finally {
            client.rollbackTimeout();
        }
    }

    /**
     * Request for authentication in a password protected Redis server. A Redis server can be
     * instructed to require a password before to allow clients to issue commands. This is done using
     * the requirepass directive in the Redis configuration file. If the password given by the client
     * is correct the server replies with an OK status code reply and starts accepting commands from
     * the client. Otherwise an error is returned and the clients needs to try a new password. Note
     * that for the high performance nature of Redis it is possible to try a lot of passwords in
     * parallel in very short time, so make sure to generate a strong and very long password so that
     * this attack is infeasible.
     * @param password
     * @return Status code reply
     */
    // override
    string auth(string password) {
        checkIsInMultiOrPipeline();
        client.auth(password);
        return client.getStatusCodeReply();
    }

    Pipeline pipelined() {
        pipeline = new Pipeline();
        pipeline.setClient(client);
        return pipeline;
    }

    // override
    long zcount(const(ubyte)[] key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zcount(key, min, max);
        return client.getIntegerReply();
    }

    // override
    long zcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zcount(key, min, max);
        return client.getIntegerReply();
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(const(ubyte)[], double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(const(ubyte)[], double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(const(ubyte)[], double, double) ZRANGEBYSCORE} but instead of returning the
     * actual elements in the specified interval, it just returns the number of matching elements.
     * <p>
     * <b>Exclusive intervals and infinity</b>
     * <p>
     * min and max can be -inf and +inf, so that you are not required to know what's the greatest or
     * smallest element in order to take, for instance, elements "up to a given value".
     * <p>
     * Also while the interval is for default closed (inclusive) it's possible to specify open
     * intervals prefixing the score with a "(" character, so for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (1.3 5}
     * <p>
     * Will return all the values with score &gt; 1.3 and &lt;= 5, while for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (5 (10}
     * <p>
     * Will return all the values with score &gt; 5 and &lt; 10 (5 and 10 excluded).
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))+O(M) with N being the number of elements in the sorted set and M the number of
     * elements returned by the command, so if M is constant (for instance you always ask for the
     * first ten elements with LIMIT) you can consider it O(log(N))
     * @see #zrangeByScore(const(ubyte)[], double, double)
     * @see #zrangeByScore(const(ubyte)[], double, double, int, int)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double, int, int)
     * @see #zcount(const(ubyte)[], double, double)
     * @param key
     * @param min
     * @param max
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    // override
    Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(const(ubyte)[], double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(const(ubyte)[], double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(const(ubyte)[], double, double) ZRANGEBYSCORE} but instead of returning the
     * actual elements in the specified interval, it just returns the number of matching elements.
     * <p>
     * <b>Exclusive intervals and infinity</b>
     * <p>
     * min and max can be -inf and +inf, so that you are not required to know what's the greatest or
     * smallest element in order to take, for instance, elements "up to a given value".
     * <p>
     * Also while the interval is for default closed (inclusive) it's possible to specify open
     * intervals prefixing the score with a "(" character, so for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (1.3 5}
     * <p>
     * Will return all the values with score &gt; 1.3 and &lt;= 5, while for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (5 (10}
     * <p>
     * Will return all the values with score &gt; 5 and &lt; 10 (5 and 10 excluded).
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))+O(M) with N being the number of elements in the sorted set and M the number of
     * elements returned by the command, so if M is constant (for instance you always ask for the
     * first ten elements with LIMIT) you can consider it O(log(N))
     * @see #zrangeByScore(const(ubyte)[], double, double)
     * @see #zrangeByScore(const(ubyte)[], double, double, int, int)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double, int, int)
     * @see #zcount(const(ubyte)[], double, double)
     * @param key
     * @param min
     * @param max
     * @param offset
     * @param count
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    // override
    Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, double min, double max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(const(ubyte)[], double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(const(ubyte)[], double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(const(ubyte)[], double, double) ZRANGEBYSCORE} but instead of returning the
     * actual elements in the specified interval, it just returns the number of matching elements.
     * <p>
     * <b>Exclusive intervals and infinity</b>
     * <p>
     * min and max can be -inf and +inf, so that you are not required to know what's the greatest or
     * smallest element in order to take, for instance, elements "up to a given value".
     * <p>
     * Also while the interval is for default closed (inclusive) it's possible to specify open
     * intervals prefixing the score with a "(" character, so for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (1.3 5}
     * <p>
     * Will return all the values with score &gt; 1.3 and &lt;= 5, while for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (5 (10}
     * <p>
     * Will return all the values with score &gt; 5 and &lt; 10 (5 and 10 excluded).
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))+O(M) with N being the number of elements in the sorted set and M the number of
     * elements returned by the command, so if M is constant (for instance you always ask for the
     * first ten elements with LIMIT) you can consider it O(log(N))
     * @see #zrangeByScore(const(ubyte)[], double, double)
     * @see #zrangeByScore(const(ubyte)[], double, double, int, int)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double, int, int)
     * @see #zcount(const(ubyte)[], double, double)
     * @param key
     * @param min
     * @param max
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    // override
    Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max);
        return getTupledSet();
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(const(ubyte)[], double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(const(ubyte)[], double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(const(ubyte)[], double, double) ZRANGEBYSCORE} but instead of returning the
     * actual elements in the specified interval, it just returns the number of matching elements.
     * <p>
     * <b>Exclusive intervals and infinity</b>
     * <p>
     * min and max can be -inf and +inf, so that you are not required to know what's the greatest or
     * smallest element in order to take, for instance, elements "up to a given value".
     * <p>
     * Also while the interval is for default closed (inclusive) it's possible to specify open
     * intervals prefixing the score with a "(" character, so for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (1.3 5}
     * <p>
     * Will return all the values with score &gt; 1.3 and &lt;= 5, while for instance:
     * <p>
     * {@code ZRANGEBYSCORE zset (5 (10}
     * <p>
     * Will return all the values with score &gt; 5 and &lt; 10 (5 and 10 excluded).
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))+O(M) with N being the number of elements in the sorted set and M the number of
     * elements returned by the command, so if M is constant (for instance you always ask for the
     * first ten elements with LIMIT) you can consider it O(log(N))
     * @see #zrangeByScore(const(ubyte)[], double, double)
     * @see #zrangeByScore(const(ubyte)[], double, double, int, int)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double)
     * @see #zrangeByScoreWithScores(const(ubyte)[], double, double, int, int)
     * @see #zcount(const(ubyte)[], double, double)
     * @param key
     * @param min
     * @param max
     * @param offset
     * @param count
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    // override
    Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, double min, double max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max, offset, count);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max, offset, count);
        return getTupledSet();
    }

    protected Set!(Tuple) getTupledSet() {
        List!(const(ubyte)[]) membersWithScores = client.getBinaryMultiBulkReply();
        if (membersWithScores.isEmpty()) {
            return Collections.emptySet!(Tuple)();
        }
        Set!(Tuple) set = new LinkedHashSet!(Tuple)(membersWithScores.size() / 2, 1.0f);
        InputRange!(const(ubyte)[]) iterator = membersWithScores.iterator();
        while (!iterator.empty()) {
            const(ubyte)[] first = iterator.front(); iterator.popFront();
            const(ubyte)[] second = iterator.front(); iterator.popFront();
            Double d = BuilderFactory.DOUBLE.build(new Bytes(cast(byte[])second));
            set.add(new Tuple(first, d.value()));
        }
        return set;
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, double max, double min,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByScore(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max, double min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, double max,
            double min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min, offset, count);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min);
        return getTupledSet();
    }

    // override
    Set!(Tuple) zrevrangeByScoreWithScores(const(ubyte)[] key, const(ubyte)[] max,
            const(ubyte)[] min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min, offset, count);
        return getTupledSet();
    }

    /**
     * Remove all elements in the sorted set at key with rank between start and end. Start and end are
     * 0-based with rank 0 being the element with the lowest score. Both start and end can be negative
     * numbers, where they indicate offsets starting at the element with the highest rank. For
     * example: -1 is the element with the highest score, -2 the element with the second highest score
     * and so forth.
     * <p>
     * <b>Time complexity:</b> O(log(N))+O(M) with N being the number of elements in the sorted set
     * and M the number of elements removed by the operation
     * @param key
     * @param start
     * @param stop
     * @return
     */
    // override
    long zremrangeByRank(const(ubyte)[] key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zremrangeByRank(key, start, stop);
        return client.getIntegerReply();
    }

    /**
     * Remove all the elements in the sorted set at key with a score between min and max (including
     * elements with score equal to min or max).
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))+O(M) with N being the number of elements in the sorted set and M the number of
     * elements removed by the operation
     * @param key
     * @param min
     * @param max
     * @return Integer reply, specifically the number of elements removed.
     */
    // override
    long zremrangeByScore(const(ubyte)[] key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByScore(key, min, max);
        return client.getIntegerReply();
    }

    // override
    long zremrangeByScore(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByScore(key, min, max);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(const(ubyte)[], const(ubyte)[]...)} ZINTERSTORE} command requires
     * an element to be present in each of the given inputs to be inserted in the result. The {@link
     * #zunionstore(const(ubyte)[], const(ubyte)[]...)} command inserts all elements across all inputs.
     * <p>
     * Using the WEIGHTS option, it is possible to add weight to each input sorted set. This means
     * that the score of each element in the sorted set is first multiplied by this weight before
     * being passed to the aggregation. When this option is not given, all weights default to 1.
     * <p>
     * With the AGGREGATE option, it's possible to specify how the results of the union or
     * intersection are aggregated. This option defaults to SUM, where the score of an element is
     * summed across the inputs where it exists. When this option is set to be either MIN or MAX, the
     * resulting set will contain the minimum or maximum score of an element across the inputs where
     * it exists.
     * <p>
     * <b>Time complexity:</b> O(N) + O(M log(M)) with N being the sum of the sizes of the input
     * sorted sets, and M being the number of elements in the resulting sorted set
     * @see #zunionstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zunionstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @param dstkey
     * @param sets
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    // override
    long zunionstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        checkIsInMultiOrPipeline();
        client.zunionstore(dstkey, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(const(ubyte)[], const(ubyte)[]...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The {@link
     * #zunionstore(const(ubyte)[], const(ubyte)[]...) ZUNIONSTORE} command inserts all elements across all inputs.
     * <p>
     * Using the WEIGHTS option, it is possible to add weight to each input sorted set. This means
     * that the score of each element in the sorted set is first multiplied by this weight before
     * being passed to the aggregation. When this option is not given, all weights default to 1.
     * <p>
     * With the AGGREGATE option, it's possible to specify how the results of the union or
     * intersection are aggregated. This option defaults to SUM, where the score of an element is
     * summed across the inputs where it exists. When this option is set to be either MIN or MAX, the
     * resulting set will contain the minimum or maximum score of an element across the inputs where
     * it exists.
     * <p>
     * <b>Time complexity:</b> O(N) + O(M log(M)) with N being the sum of the sizes of the input
     * sorted sets, and M being the number of elements in the resulting sorted set
     * @see #zunionstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zunionstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @param dstkey
     * @param sets
     * @param params
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    // override
    long zunionstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        checkIsInMultiOrPipeline();
        client.zunionstore(dstkey, params, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(const(ubyte)[], const(ubyte)[]...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The {@link
     * #zunionstore(const(ubyte)[], const(ubyte)[]...) ZUNIONSTORE} command inserts all elements across all inputs.
     * <p>
     * Using the WEIGHTS option, it is possible to add weight to each input sorted set. This means
     * that the score of each element in the sorted set is first multiplied by this weight before
     * being passed to the aggregation. When this option is not given, all weights default to 1.
     * <p>
     * With the AGGREGATE option, it's possible to specify how the results of the union or
     * intersection are aggregated. This option defaults to SUM, where the score of an element is
     * summed across the inputs where it exists. When this option is set to be either MIN or MAX, the
     * resulting set will contain the minimum or maximum score of an element across the inputs where
     * it exists.
     * <p>
     * <b>Time complexity:</b> O(N) + O(M log(M)) with N being the sum of the sizes of the input
     * sorted sets, and M being the number of elements in the resulting sorted set
     * @see #zunionstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zunionstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @param dstkey
     * @param sets
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    // override
    long zinterstore(const(ubyte)[] dstkey, const(ubyte)[][] sets...) {
        checkIsInMultiOrPipeline();
        client.zinterstore(dstkey, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(const(ubyte)[], const(ubyte)[]...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The {@link
     * #zunionstore(const(ubyte)[], const(ubyte)[]...) ZUNIONSTORE} command inserts all elements across all inputs.
     * <p>
     * Using the WEIGHTS option, it is possible to add weight to each input sorted set. This means
     * that the score of each element in the sorted set is first multiplied by this weight before
     * being passed to the aggregation. When this option is not given, all weights default to 1.
     * <p>
     * With the AGGREGATE option, it's possible to specify how the results of the union or
     * intersection are aggregated. This option defaults to SUM, where the score of an element is
     * summed across the inputs where it exists. When this option is set to be either MIN or MAX, the
     * resulting set will contain the minimum or maximum score of an element across the inputs where
     * it exists.
     * <p>
     * <b>Time complexity:</b> O(N) + O(M log(M)) with N being the sum of the sizes of the input
     * sorted sets, and M being the number of elements in the resulting sorted set
     * @see #zunionstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zunionstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], const(ubyte)[]...)
     * @see #zinterstore(const(ubyte)[], ZParams, const(ubyte)[]...)
     * @param dstkey
     * @param sets
     * @param params
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    // override
    long zinterstore(const(ubyte)[] dstkey, ZParams params, const(ubyte)[][] sets...) {
        checkIsInMultiOrPipeline();
        client.zinterstore(dstkey, params, sets);
        return client.getIntegerReply();
    }

    // override
    long zlexcount(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zlexcount(key, min, max);
        return client.getIntegerReply();
    }

    // override
    Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zrangeByLex(key, min, max);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByLex(key, min, max, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByLex(key, max, min);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    Set!(const(ubyte)[]) zrevrangeByLex(const(ubyte)[] key, const(ubyte)[] max, const(ubyte)[] min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByLex(key, max, min, offset, count);
        return new SetFromList!(const(ubyte)[])(client.getBinaryMultiBulkReply());
    }

    // override
    long zremrangeByLex(const(ubyte)[] key, const(ubyte)[] min, const(ubyte)[] max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByLex(key, min, max);
        return client.getIntegerReply();
    }

    /**
     * Synchronously save the DB on disk.
     * <p>
     * Save the whole dataset on disk (this means that all the databases are saved, as well as keys
     * with an EXPIRE set (the expire is preserved). The server hangs while the saving is not
     * completed, no connection is served in the meanwhile. An OK code is returned when the DB was
     * fully stored in disk.
     * <p>
     * The background variant of this command is {@link #bgsave() BGSAVE} that is able to perform the
     * saving in the background while the server continues serving other clients.
     * <p>
     * @return Status code reply
     */
    // override
    string save() {
        client.save();
        return client.getStatusCodeReply();
    }

    /**
     * Asynchronously save the DB on disk.
     * <p>
     * Save the DB in background. The OK code is immediately returned. Redis forks, the parent
     * continues to server the clients, the child saves the DB on disk then exit. A client my be able
     * to check if the operation succeeded using the LASTSAVE command.
     * @return Status code reply
     */
    // override
    string bgsave() {
        client.bgsave();
        return client.getStatusCodeReply();
    }

    /**
     * Rewrite the append only file in background when it gets too big. Please for detailed
     * information about the Redis Append Only File check the <a
     * href="http://redis.io/topics/persistence#append-only-file">Append Only File Howto</a>.
     * <p>
     * BGREWRITEAOF rewrites the Append Only File in background when it gets too big. The Redis Append
     * Only File is a Journal, so every operation modifying the dataset is logged in the Append Only
     * File (and replayed at startup). This means that the Append Only File always grows. In order to
     * rebuild its content the BGREWRITEAOF creates a new version of the append only file starting
     * directly form the dataset in memory in order to guarantee the generation of the minimal number
     * of commands needed to rebuild the database.
     * <p>
     * @return Status code reply
     */
    // override
    string bgrewriteaof() {
        client.bgrewriteaof();
        return client.getStatusCodeReply();
    }

    /**
     * Return the UNIX time stamp of the last successfully saving of the dataset on disk.
     * <p>
     * Return the UNIX TIME of the last DB save executed with success. A client may check if a
     * {@link #bgsave() BGSAVE} command succeeded reading the LASTSAVE value, then issuing a BGSAVE
     * command and checking at regular intervals every N seconds if LASTSAVE changed.
     * @return Integer reply, specifically an UNIX time stamp.
     */
    // override
    long lastsave() {
        client.lastsave();
        return client.getIntegerReply();
    }

    /**
     * Synchronously save the DB on disk, then shutdown the server.
     * <p>
     * Stop all the clients, save the DB, then quit the server. This commands makes sure that the DB
     * is switched off without the lost of any data. This is not guaranteed if the client uses simply
     * {@link #save() SAVE} and then {@link #quit() QUIT} because other clients may alter the DB data
     * between the two commands.
     * @return Status code reply on error. On success nothing is returned since the server quits and
     *         the connection is closed.
     */
    // override
    string shutdown() {
        client.shutdown();
        string status;
        try {
            status = client.getStatusCodeReply();
        } catch (RedisException ex) {
            status = null;
        }
        return status;
    }

    /**
     * Provide information and statistics about the server.
     * <p>
     * The info command returns different information and statistics about the server in an format
     * that's simple to parse by computers and easy to read by humans.
     * <p>
     * <b>Format of the returned string:</b>
     * <p>
     * All the fields are in the form field:value
     * 
     * <pre>
     * edis_version:0.07
     * connected_clients:1
     * connected_slaves:0
     * used_memory:3187
     * changes_since_last_save:0
     * last_save_time:1237655729
     * total_connections_received:1
     * total_commands_processed:1
     * uptime_in_seconds:25
     * uptime_in_days:0
     * </pre>
     * 
     * <b>Notes</b>
     * <p>
     * used_memory is returned in bytes, and is the total number of bytes allocated by the program
     * using malloc.
     * <p>
     * uptime_in_days is redundant since the uptime in seconds contains already the full uptime
     * information, this field is only mainly present for humans.
     * <p>
     * changes_since_last_save does not refer to the number of key changes, but to the number of
     * operations that produced some kind of change in the dataset.
     * <p>
     * @return Bulk reply
     */
    // override
    string info() {
        client.info();
        return client.getBulkReply();
    }

    // override
    string info(string section) {
        client.info(section);
        return client.getBulkReply();
    }

    /**
     * Dump all the received requests in real time.
     * <p>
     * MONITOR is a debugging command that outputs the whole sequence of commands received by the
     * Redis server. is very handy in order to understand what is happening into the database. This
     * command is used directly via telnet.
     * @param jedisMonitor
     */
    void monitor(RedisMonitor jedisMonitor) {
        client.monitor();
        client.getStatusCodeReply();
        jedisMonitor.proceed(client);
    }

    /**
     * Change the replication settings.
     * <p>
     * The SLAVEOF command can change the replication settings of a slave on the fly. If a Redis
     * server is already acting as slave, the command SLAVEOF NO ONE will turn off the replication
     * turning the Redis server into a MASTER. In the proper form SLAVEOF hostname port will make the
     * server a slave of the specific server listening at the specified hostname and port.
     * <p>
     * If a server is already a slave of some master, SLAVEOF hostname port will stop the replication
     * against the old server and start the synchronization against the new one discarding the old
     * dataset.
     * <p>
     * The form SLAVEOF no one will stop replication turning the server into a MASTER but will not
     * discard the replication. So if the old master stop working it is possible to turn the slave
     * into a master and set the application to use the new master in read/write. Later when the other
     * Redis server will be fixed it can be configured in order to work as slave.
     * <p>
     * @param host
     * @param port
     * @return Status code reply
     */
    // override
    string slaveof(string host, int port) {
        client.slaveof(host, port);
        return client.getStatusCodeReply();
    }

    // override
    string slaveofNoOne() {
        client.slaveofNoOne();
        return client.getStatusCodeReply();
    }

    /**
     * Retrieve the configuration of a running Redis server. Not all the configuration parameters are
     * supported.
     * <p>
     * CONFIG GET returns the current configuration parameters. This sub command only accepts a single
     * argument, that is glob style pattern. All the configuration parameters matching this parameter
     * are reported as a list of key-value pairs.
     * <p>
     * <b>Example:</b>
     * 
     * <pre>
     * $ redis-cli config get '*'
     * 1. "dbfilename"
     * 2. "dump.rdb"
     * 3. "requirepass"
     * 4. (nil)
     * 5. "masterauth"
     * 6. (nil)
     * 7. "maxmemory"
     * 8. "0\n"
     * 9. "appendfsync"
     * 10. "everysec"
     * 11. "save"
     * 12. "3600 1 300 100 60 10000"
     * 
     * $ redis-cli config get 'm*'
     * 1. "masterauth"
     * 2. (nil)
     * 3. "maxmemory"
     * 4. "0\n"
     * </pre>
     * @param pattern
     * @return Bulk reply.
     */
    // override
    List!(const(ubyte)[]) configGet(const(ubyte)[] pattern) {
        checkIsInMultiOrPipeline();
        client.configGet(pattern);
        return client.getBinaryMultiBulkReply();
    }

    /**
     * Reset the stats returned by INFO
     * @return
     */
    // override
    string configResetStat() {
        checkIsInMultiOrPipeline();
        client.configResetStat();
        return client.getStatusCodeReply();
    }

    /**
     * The CONFIG REWRITE command rewrites the redis.conf file the server was started with, applying
     * the minimal changes needed to make it reflect the configuration currently used by the server,
     * which may be different compared to the original one because of the use of the CONFIG SET command.
     * 
     * The rewrite is performed in a very conservative way:
     * <ul>
     * <li>Comments and the overall structure of the original redis.conf are preserved as much as possible.</li>
     * <li>If an option already exists in the old redis.conf file, it will be rewritten at the same position (line number).</li>
     * <li>If an option was not already present, but it is set to its default value, it is not added by the rewrite process.</li>
     * <li>If an option was not already present, but it is set to a non-default value, it is appended at the end of the file.</li>
     * <li>Non used lines are blanked. For instance if you used to have multiple save directives, but
     * the current configuration has fewer or none as you disabled RDB persistence, all the lines will be blanked.</li>
     * </ul>
     * 
     * CONFIG REWRITE is also able to rewrite the configuration file from scratch if the original one
     * no longer exists for some reason. However if the server was started without a configuration
     * file at all, the CONFIG REWRITE will just return an error.
     * @return OK when the configuration was rewritten properly. Otherwise an error is returned.
     */
    // override
    string configRewrite() {
        checkIsInMultiOrPipeline();
        client.configRewrite();
        return client.getStatusCodeReply();
    }

    /**
     * Alter the configuration of a running Redis server. Not all the configuration parameters are
     * supported.
     * <p>
     * The list of configuration parameters supported by CONFIG SET can be obtained issuing a
     * {@link #configGet(const(ubyte)[]) CONFIG GET *} command.
     * <p>
     * The configuration set using CONFIG SET is immediately loaded by the Redis server that will
     * start acting as specified starting from the next command.
     * <p>
     * <b>Parameters value format</b>
     * <p>
     * The value of the configuration parameter is the same as the one of the same parameter in the
     * Redis configuration file, with the following exceptions:
     * <p>
     * <ul>
     * <li>The save parameter is a list of space-separated integers. Every pair of integers specify the
     * time and number of changes limit to trigger a save. For instance the command CONFIG SET save
     * "3600 10 60 10000" will configure the server to issue a background saving of the RDB file every
     * 3600 seconds if there are at least 10 changes in the dataset, and every 60 seconds if there are
     * at least 10000 changes. To completely disable automatic snapshots just set the parameter as an
     * empty string.
     * <li>All the integer parameters representing memory are returned and accepted only using bytes
     * as unit.
     * </ul>
     * @param parameter
     * @param value
     * @return Status code reply
     */
    // override
    const(ubyte)[] configSet(const(ubyte)[] parameter, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.configSet(parameter, value);
        return client.getBinaryBulkReply();
    }

    bool isConnected() {
        return client.isConnected();
    }

    // override
    long strlen(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.strlen(key);
        return client.getIntegerReply();
    }

    void sync() {
        client.sync();
    }

    // override
    long lpushx(const(ubyte)[] key, const(ubyte)[][] string...) {
        checkIsInMultiOrPipeline();
        client.lpushx(key, string);
        return client.getIntegerReply();
    }

    /**
     * Undo a {@link #expire(const(ubyte)[], int) expire} at turning the expire key into a normal key.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @return Integer reply, specifically: 1: the key is now persist. 0: the key is not persist (only
     *         happens when key not set).
     */
    // override
    long persist(const(ubyte)[] key) {
        client.persist(key);
        return client.getIntegerReply();
    }

    // override
    long rpushx(const(ubyte)[] key, const(ubyte)[][] string...) {
        checkIsInMultiOrPipeline();
        client.rpushx(key, string);
        return client.getIntegerReply();
    }

    // override
    const(ubyte)[] echo(const(ubyte)[] string) {
        checkIsInMultiOrPipeline();
        client.echo(string);
        return client.getBinaryBulkReply();
    }

    // override
    long linsert(const(ubyte)[] key, ListPosition where, const(ubyte)[] pivot,
            const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.linsert(key, where, pivot, value);
        return client.getIntegerReply();
    }

    // // override
    // string debug(DebugParams params) {
    //   client.debug(params);
    //   return client.getStatusCodeReply();
    // }

    Client getClient() {
        return client;
    }

    /**
     * Pop a value from a list, push it to another list and return it; or block until one is available
     * @param source
     * @param destination
     * @param timeout
     * @return the element
     */
    // override
    const(ubyte)[] brpoplpush(const(ubyte)[] source, const(ubyte)[] destination, int timeout) {
        client.brpoplpush(source, destination, timeout);
        client.setTimeoutInfinite();
        try {
            return client.getBinaryBulkReply();
        } finally {
            client.rollbackTimeout();
        }
    }

    /**
     * Sets or clears the bit at offset in the string value stored at key
     * @param key
     * @param offset
     * @param value
     * @return
     */
    // override
    bool setbit(const(ubyte)[] key, long offset, bool value) {
        checkIsInMultiOrPipeline();
        client.setbit(key, offset, value);
        return client.getIntegerReply() == 1;
    }

    // override
    bool setbit(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.setbit(key, offset, value);
        return client.getIntegerReply() == 1;
    }

    /**
     * Returns the bit value at offset in the string value stored at key
     * @param key
     * @param offset
     * @return
     */
    // override
    bool getbit(const(ubyte)[] key, long offset) {
        checkIsInMultiOrPipeline();
        client.getbit(key, offset);
        return client.getIntegerReply() == 1;
    }

    long bitpos(const(ubyte)[] key, bool value) {
        return bitpos(key, value, new BitPosParams());
    }

    long bitpos(const(ubyte)[] key, bool value, BitPosParams params) {
        checkIsInMultiOrPipeline();
        client.bitpos(key, value, params);
        return client.getIntegerReply();
    }

    // override
    long setrange(const(ubyte)[] key, long offset, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.setrange(key, offset, value);
        return client.getIntegerReply();
    }

    // override
    const(ubyte)[] getrange(const(ubyte)[] key, long startOffset, long endOffset) {
        checkIsInMultiOrPipeline();
        client.getrange(key, startOffset, endOffset);
        return client.getBinaryBulkReply();
    }

    // override
    long publish(const(ubyte)[] channel, const(ubyte)[] message) {
        checkIsInMultiOrPipeline();
        client.publish(channel, message);
        return client.getIntegerReply();
    }

    // override
    void subscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] channels...) {
        client.setTimeoutInfinite();
        try {
            jedisPubSub.proceed(client, channels);
        } finally {
            client.rollbackTimeout();
        }
    }

    // override
    void psubscribe(BinaryRedisPubSub jedisPubSub, const(ubyte)[][] patterns...) {
        client.setTimeoutInfinite();
        try {
            jedisPubSub.proceedWithPatterns(client, patterns);
        } finally {
            client.rollbackTimeout();
        }
    }

    // override
    int getDB() {
        return client.getDB();
    }

    /**
     * Evaluates scripts using the Lua interpreter built into Redis starting from version 2.6.0.
     * <p>
     * @param script
     * @param keys
     * @param args
     * @return Script result
     */
    // override
    Object eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
        return eval(script, Protocol.toByteArray(keys.size()), getParamsWithBinary(keys, args));
    }

    static const(ubyte)[][] getParamsWithBinary(List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
        int keyCount = keys.size();
        int argCount = args.size();
        const(ubyte)[][] params = new const(ubyte)[][keyCount + argCount];

        for (int i = 0; i < keyCount; i++)
            params[i] = keys.get(i);

        for (int i = 0; i < argCount; i++)
            params[keyCount + i] = args.get(i);

        return params;
    }

    // override
    Object eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...) {
        client.setTimeoutInfinite();
        try {
            client.eval(script, keyCount, params);
            return client.getOne();
        } finally {
            client.rollbackTimeout();
        }
    }

    // override
    Object eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...) {
        return eval(script, Protocol.toByteArray(keyCount), params);
    }

    // override
    Object eval(const(ubyte)[] script) {
        return eval(script, 0);
    }

    // override
    Object evalsha(const(ubyte)[] sha1) {
        return evalsha(sha1, 0);
    }

    // override
    Object evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args) {
        return evalsha(sha1, keys.size(), getParamsWithBinary(keys, args));
    }

    // override
    Object evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...) {
        client.setTimeoutInfinite();
        try {
            client.evalsha(sha1, keyCount, params);
            return client.getOne();
        } finally {
            client.rollbackTimeout();
        }
    }

    // override
    string scriptFlush() {
        client.scriptFlush();
        return client.getStatusCodeReply();
    }

    long scriptExists(const(ubyte)[] sha1) {
        const(ubyte)[][] a = new const(ubyte)[][1];
        a[0] = sha1;
        return scriptExists(a).get(0);
    }

    // override
    List!(long) scriptExists(const(ubyte)[][] sha1...) {
        client.scriptExists(sha1);
        return client.getIntegerMultiBulkReply();
    }

    // override
    const(ubyte)[] scriptLoad(const(ubyte)[] script) {
        client.scriptLoad(script);
        return client.getBinaryBulkReply();
    }

    // override
    string scriptKill() {
        client.scriptKill();
        return client.getStatusCodeReply();
    }

    // override
    string slowlogReset() {
        client.slowlogReset();
        return client.getBulkReply();
    }

    // override
    long slowlogLen() {
        client.slowlogLen();
        return client.getIntegerReply();
    }

    // override
    List!(const(ubyte)[]) slowlogGetBinary() {
        client.slowlogGet();
        return client.getBinaryMultiBulkReply();
    }

    // override
    List!(const(ubyte)[]) slowlogGetBinary(long entries) {
        client.slowlogGet(entries);
        return client.getBinaryMultiBulkReply();
    }

    // override
    long objectRefcount(const(ubyte)[] key) {
        client.objectRefcount(key);
        return client.getIntegerReply();
    }

    // override
    const(ubyte)[] objectEncoding(const(ubyte)[] key) {
        client.objectEncoding(key);
        return client.getBinaryBulkReply();
    }

    // override
    long objectIdletime(const(ubyte)[] key) {
        client.objectIdletime(key);
        return client.getIntegerReply();
    }

    // override
    long bitcount(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.bitcount(key);
        return client.getIntegerReply();
    }

    // override
    long bitcount(const(ubyte)[] key, long start, long end) {
        checkIsInMultiOrPipeline();
        client.bitcount(key, start, end);
        return client.getIntegerReply();
    }

    // override
    long bitop(BitOP op, const(ubyte)[] destKey, const(ubyte)[][] srcKeys...) {
        checkIsInMultiOrPipeline();
        client.bitop(op, destKey, srcKeys);
        return client.getIntegerReply();
    }

    // override
    const(ubyte)[] dump(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.dump(key);
        return client.getBinaryBulkReply();
    }

    // override
    string restore(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        checkIsInMultiOrPipeline();
        client.restore(key, ttl, serializedValue);
        return client.getStatusCodeReply();
    }

    // override
    string restoreReplace(const(ubyte)[] key, int ttl, const(ubyte)[] serializedValue) {
        checkIsInMultiOrPipeline();
        client.restoreReplace(key, ttl, serializedValue);
        return client.getStatusCodeReply();
    }

    /**
     * Set a timeout on the specified key. After the timeout the key will be automatically deleted by
     * the server. A key with an associated timeout is said to be volatile in Redis terminology.
     * <p>
     * Volatile keys are stored on disk like the other keys, the timeout is persistent too like all the
     * other aspects of the dataset. Saving a dataset containing expires and stopping the server does
     * not stop the flow of time as Redis stores on disk the time when the key will no longer be
     * available as Unix time, and not the remaining milliseconds.
     * <p>
     * Since Redis 2.1.3 you can update the value of the timeout of a key already having an expire
     * set. It is also possible to undo the expire at all turning the key into a normal key using the
     * {@link #persist(const(ubyte)[]) PERSIST} command.
     * <p>
     * Time complexity: O(1)
     * @see <a href="http://redis.io/commands/pexpire">PEXPIRE Command</a>
     * @param key
     * @param milliseconds
     * @return Integer reply, specifically: 1: the timeout was set. 0: the timeout was not set since
     *         the key already has an associated timeout (this may happen only in Redis versions <
     *         2.1.3, Redis >= 2.1.3 will happily update the timeout), or the key does not exist.
     */
    // override
    long pexpire(const(ubyte)[] key, long milliseconds) {
        checkIsInMultiOrPipeline();
        client.pexpire(key, milliseconds);
        return client.getIntegerReply();
    }

    // override
    long pexpireAt(const(ubyte)[] key, long millisecondsTimestamp) {
        checkIsInMultiOrPipeline();
        client.pexpireAt(key, millisecondsTimestamp);
        return client.getIntegerReply();
    }

    // override
    long pttl(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.pttl(key);
        return client.getIntegerReply();
    }

    /**
     * PSETEX works exactly like {@link #setex(const(ubyte)[], int, const(ubyte)[])} with the sole difference that the
     * expire time is specified in milliseconds instead of seconds. Time complexity: O(1)
     * @param key
     * @param milliseconds
     * @param value
     * @return Status code reply
     */
    // override
    string psetex(const(ubyte)[] key, long milliseconds, const(ubyte)[] value) {
        checkIsInMultiOrPipeline();
        client.psetex(key, milliseconds, value);
        return client.getStatusCodeReply();
    }

    // override
    const(ubyte)[] memoryDoctorBinary() {
        checkIsInMultiOrPipeline();
        client.memoryDoctor();
        return client.getBinaryBulkReply();
    }

    // override
    string clientKill(const(ubyte)[] ipPort) {
        checkIsInMultiOrPipeline();
        this.client.clientKill(ipPort);
        return this.client.getStatusCodeReply();
    }

    // override
    string clientKill(string ip, int port) {
        checkIsInMultiOrPipeline();
        this.client.clientKill(ip, port);
        return this.client.getStatusCodeReply();
    }

    // override
    long clientKill(ClientKillParams params) {
        checkIsInMultiOrPipeline();
        this.client.clientKill(params);
        return this.client.getIntegerReply();
    }

    // override
    const(ubyte)[] clientGetnameBinary() {
        checkIsInMultiOrPipeline();
        client.clientGetname();
        return client.getBinaryBulkReply();
    }

    // override
    const(ubyte)[] clientListBinary() {
        checkIsInMultiOrPipeline();
        client.clientList();
        return client.getBinaryBulkReply();
    }

    // override
    string clientSetname(const(ubyte)[] name) {
        checkIsInMultiOrPipeline();
        client.clientSetname(name);
        return client.getBulkReply();
    }

    string clientPause(long timeout) {
        checkIsInMultiOrPipeline();
        client.clientPause(timeout);
        return client.getBulkReply();
    }

    List!(string) time() {
        checkIsInMultiOrPipeline();
        client.time();
        return client.getMultiBulkReply();
    }

    // override
    string migrate(string host, int port, const(ubyte)[] key,
            int destinationDb, int timeout) {
        checkIsInMultiOrPipeline();
        client.migrate(host, port, key, destinationDb, timeout);
        return client.getStatusCodeReply();
    }

    // override
    string migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.migrate(host, port, destinationDB, timeout, params, keys);
        return client.getStatusCodeReply();
    }

    /**
     * Syncrhonous replication of Redis as described here: http://antirez.com/news/66 Since Java
     * Object class has implemented "wait" method, we cannot use it, so I had to change the name of
     * the method. Sorry :S
     */
    // override
    long waitReplicas(int replicas, long timeout) {
        checkIsInMultiOrPipeline();
        client.waitReplicas(replicas, timeout);
        return client.getIntegerReply();
    }

    // override
    long pfadd(const(ubyte)[] key, const(ubyte)[][] elements...) {
        checkIsInMultiOrPipeline();
        client.pfadd(key, elements);
        return client.getIntegerReply();
    }

    // override
    long pfcount(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.pfcount(key);
        return client.getIntegerReply();
    }

    // override
    string pfmerge(const(ubyte)[] destkey, const(ubyte)[][] sourcekeys...) {
        checkIsInMultiOrPipeline();
        client.pfmerge(destkey, sourcekeys);
        return client.getStatusCodeReply();
    }

    // override
    long pfcount(const(ubyte)[][] keys...) {
        checkIsInMultiOrPipeline();
        client.pfcount(keys);
        return client.getIntegerReply();
    }

    ScanResult!(const(ubyte)[]) scan(const(ubyte)[] cursor) {
        return scan(cursor, new ScanParams());
    }

    ScanResult!(const(ubyte)[]) scan(const(ubyte)[] cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.scan(cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // const(ubyte)[] newcursor = (const(ubyte)[]) result.get(0);
        // List!(const(ubyte)[]) rawResults = (List!(const(ubyte)[])) result.get(1);
        // return new ScanResult!(const(ubyte)[])(newcursor, rawResults);
        implementationMissing();
        return null;
    }

    // override
    ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor) {
        return hscan(key, cursor, new ScanParams());
    }

    // override
    ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[])) hscan(const(ubyte)[] key, const(ubyte)[] cursor,
            ScanParams params) {
        checkIsInMultiOrPipeline();
        client.hscan(key, cursor, params);
        // List!(Object) result = client.getObjectMultiBulkReply();
        // const(ubyte)[] newcursor = cast(const(ubyte)[]) result.get(0);
        // List!(MapEntry!(const(ubyte)[], const(ubyte)[])) results = new ArrayList!(MapEntry!(const(ubyte)[], const(ubyte)[]))();
        // List!(const(ubyte)[]) rawResults = cast(List!(const(ubyte)[])) result.get(1);
        // Iterator!(const(ubyte)[]) iterator = rawResults.iterator();
        // while (iterator.hasNext()) {
        //   results.add(new AbstractMap.SimpleEntry!(const(ubyte)[], const(ubyte)[])(iterator.next(), iterator.next()));
        // }
        // return new ScanResult!(MapEntry!(const(ubyte)[], const(ubyte)[]))(newcursor, results);

        implementationMissing();
        return null;
    }

    // override
    ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor) {
        return sscan(key, cursor, new ScanParams());
    }

    // override
    ScanResult!(const(ubyte)[]) sscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.sscan(key, cursor, params);
        // List!(Object) result = client.getObjectMultiBulkReply();
        // const(ubyte)[] newcursor = (const(ubyte)[]) result.get(0);
        // List!(const(ubyte)[]) rawResults = (List!(const(ubyte)[])) result.get(1);
        // return new ScanResult<>(newcursor, rawResults);

        implementationMissing();
        return null;    
    }

    // override
    ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor) {
        return zscan(key, cursor, new ScanParams());
    }

    // override
    ScanResult!(Tuple) zscan(const(ubyte)[] key, const(ubyte)[] cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.zscan(key, cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // const(ubyte)[] newcursor = (const(ubyte)[]) result.get(0);
        // List!(Tuple) results = new ArrayList<>();
        // List!(const(ubyte)[]) rawResults = (List!(const(ubyte)[])) result.get(1);
        // Iterator!(const(ubyte)[]) iterator = rawResults.iterator();
        // while (iterator.hasNext()) {
        //   results.add(new Tuple(iterator.next(), BuilderFactory.DOUBLE.build(iterator.next())));
        // }
        // return new ScanResult<>(newcursor, results);

        implementationMissing();
        return null;
    }

    // override
    long geoadd(const(ubyte)[] key, double longitude, double latitude, const(ubyte)[] member) {
        checkIsInMultiOrPipeline();
        client.geoadd(key, longitude, latitude, member);
        return client.getIntegerReply();
    }

    // override
    long geoadd(const(ubyte)[] key, Map!(const(ubyte)[], GeoCoordinate) memberCoordinateMap) {
        checkIsInMultiOrPipeline();
        client.geoadd(key, memberCoordinateMap);
        return client.getIntegerReply();
    }

    // override
    Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2) {
        checkIsInMultiOrPipeline();
        client.geodist(key, member1, member2);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    // override
    Double geodist(const(ubyte)[] key, const(ubyte)[] member1, const(ubyte)[] member2, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.geodist(key, member1, member2, unit);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    // override
    List!(const(ubyte)[]) geohash(const(ubyte)[] key, const(ubyte)[][] members...) {
        checkIsInMultiOrPipeline();
        client.geohash(key, members);
        return client.getBinaryMultiBulkReply();
    }

    // override
    List!(GeoCoordinate) geopos(const(ubyte)[] key, const(ubyte)[][] members...) {
        checkIsInMultiOrPipeline();
        client.geopos(key, members);
        return BuilderFactory.GEO_COORDINATE_LIST.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude,
            double radius, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadius(key, longitude, latitude, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
            double radius, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusReadonly(key, longitude, latitude, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadius(const(ubyte)[] key, double longitude, double latitude,
            double radius, GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadius(key, longitude, latitude, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadiusReadonly(const(ubyte)[] key, double longitude, double latitude,
            double radius, GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusReadonly(key, longitude, latitude, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }
    
    // override
    List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
            GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusByMember(key, member, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
            GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusByMemberReadonly(key, member, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadiusByMember(const(ubyte)[] key, const(ubyte)[] member, double radius,
            GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusByMember(key, member, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }

    // override
    List!(GeoRadiusResponse) georadiusByMemberReadonly(const(ubyte)[] key, const(ubyte)[] member, double radius,
            GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusByMemberReadonly(key, member, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(cast(Object)client.getObjectMultiBulkReply());
    }


    // override
    List!(long) bitfield(const(ubyte)[] key, const(ubyte)[][] arguments...) {
        checkIsInMultiOrPipeline();
        client.bitfield(key, arguments);
        return client.getIntegerMultiBulkReply();
    }

    // override
    long hstrlen(const(ubyte)[] key, const(ubyte)[] field) {
        checkIsInMultiOrPipeline();
        client.hstrlen(key, field);
        return client.getIntegerReply();
    }

    // override
    List!(const(ubyte)[]) xread(int count, long block, Map!(const(ubyte)[], const(ubyte)[]) streams) {
        checkIsInMultiOrPipeline();
        client.xread(count, block, streams);
        return client.getBinaryMultiBulkReply();
    }

    // override
    List!(const(ubyte)[]) xreadGroup(const(ubyte)[] groupname, const(ubyte)[] consumer, int count, long block, bool noAck,
            Map!(const(ubyte)[], const(ubyte)[]) streams) {
        checkIsInMultiOrPipeline();
        client.xreadGroup(groupname, consumer, count, block, noAck, streams);
        return client.getBinaryMultiBulkReply();  
    }

    // override
    const(ubyte)[] xadd(const(ubyte)[] key, const(ubyte)[] id, Map!(const(ubyte)[], const(ubyte)[]) hash, long maxLen, bool approximateLength) {
        checkIsInMultiOrPipeline();
        client.xadd(key, id, hash, maxLen, approximateLength);
        return client.getBinaryBulkReply();  
    }

    // override
    long xlen(const(ubyte)[] key) {
        checkIsInMultiOrPipeline();
        client.xlen(key);
        return client.getIntegerReply();  
    }

    // override
    List!(const(ubyte)[]) xrange(const(ubyte)[] key, const(ubyte)[] start, const(ubyte)[] end, long count) {
        checkIsInMultiOrPipeline();
        client.xrange(key, start, end, count);
        return client.getBinaryMultiBulkReply();  
    }

    // override
    List!(const(ubyte)[]) xrevrange(const(ubyte)[] key, const(ubyte)[] end, const(ubyte)[] start, int count) {
        checkIsInMultiOrPipeline();
        client.xrevrange(key, end, start, count);
        return client.getBinaryMultiBulkReply();  
    }

    // override
    long xack(const(ubyte)[] key, const(ubyte)[] group, const(ubyte)[][] ids...) {
        checkIsInMultiOrPipeline();
        client.xack(key, group, ids);
        return client.getIntegerReply();
    }

    // override
    string xgroupCreate(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id, bool makeStream) {
        checkIsInMultiOrPipeline();
        client.xgroupCreate(key, consumer, id, makeStream);
        return client.getStatusCodeReply();
    }

    // override
    string xgroupSetID(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] id) {
        checkIsInMultiOrPipeline();
        client.xgroupSetID(key, consumer, id);
        return client.getStatusCodeReply();
    }

    // override
    long xgroupDestroy(const(ubyte)[] key, const(ubyte)[] consumer) {
        checkIsInMultiOrPipeline();
        client.xgroupDestroy(key, consumer);
        return client.getIntegerReply();
    }

    // override
    string xgroupDelConsumer(const(ubyte)[] key, const(ubyte)[] consumer, const(ubyte)[] consumerName) {
        checkIsInMultiOrPipeline();
        client.xgroupDelConsumer(key, consumer, consumerName);
        return client.getStatusCodeReply();  
    }

    // override
    long xdel(const(ubyte)[] key, const(ubyte)[][] ids...) {
        checkIsInMultiOrPipeline();
        client.xdel(key, ids);
        return client.getIntegerReply();
    }

    // override
    long xtrim(const(ubyte)[] key, long maxLen, bool approximateLength) {
        checkIsInMultiOrPipeline();
        client.xtrim(key, maxLen, approximateLength);
        return client.getIntegerReply();
    }

    // override
    List!(const(ubyte)[]) xpending(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] start, const(ubyte)[] end, int count, const(ubyte)[] consumername) {
        checkIsInMultiOrPipeline();
        client.xpending(key, groupname, start, end, count, consumername);
        return client.getBinaryMultiBulkReply();  }

    // override
        List!(const(ubyte)[]) xclaim(const(ubyte)[] key, const(ubyte)[] groupname, const(ubyte)[] consumername, 
                                                 long minIdleTime, long newIdleTime, int retries, 
                                                 bool force, const(ubyte)[][] ids) {
        checkIsInMultiOrPipeline();
        client.xclaim(key, groupname, consumername, minIdleTime, newIdleTime, retries, force, ids);
        return client.getBinaryMultiBulkReply();  
    }

    // override
    Object sendCommand(ProtocolCommand cmd, const(ubyte)[][] args...) {
        client.sendCommand(cmd, args);
        return client.getOne();
    }
}




/**
 * A decorator to implement Set from List. Assume that given List do not contains duplicated
 * values. The resulting set displays the same ordering, concurrency, and performance
 * characteristics as the backing list. This class should be used only for Redis commands which
 * return Set result.
 * @param <E>
 */
class SetFromList(E) : AbstractSet!(E) { // , Serializable 
    private List!(E) list;

    this(List!(E) list) {
        if (list is null) {
            throw new NullPointerException("list");
        }
        this.list = list;
    }

    override
    void clear() {
        list.clear();
    }

    override
    int size() {
        return list.size();
    }

    override
    bool isEmpty() {
        return list.isEmpty();
    }

    override
    bool contains(E o) {
        return list.contains(o);
    }

    override
    bool remove(E o) {
        return list.remove(o);
    }

    override
    bool add(E e) {
        return !contains(e) && list.add(e);
    }

    // // override
    // Iterator!(E) iterator() {
    //   return list.iterator();
    // }

    override
    E[] toArray() {
        return list.toArray();
    }

    // // override
    // <T> T[] toArray(T[] a) {
    //   return list.toArray(a);
    // }

    override
    string toString() {
        return list.toString();
    }

    override
    size_t toHash() @trusted nothrow {
        return list.toHash();
    }

    override bool opEquals(Object o) {
        if (o is null) return false;
        if (o is this) return true;
        Set!E c = cast(Set!E) o;
            if(c is null) return false;

        if (c.size() != size()) {
            return false;
        }

        return containsAll(c);
    }

    override
    bool containsAll(Collection!E c) {
        return list.containsAll(c);
    }

    override
    bool removeAll(Collection!E c) {
        return list.removeAll(c);
    }

    override
    bool retainAll(Collection!E c) {
        return list.retainAll(c);
    }

    static SetFromList!(E) of(E)(List!(E) list) {
        return new SetFromList!E(list);
    }
}    