module hunt.redis.Redis;

import hunt.redis.BinaryRedis;
import hunt.redis.BinaryRedisPubSub;
import hunt.redis.BitOP;
import hunt.redis.BitPosParams;
import hunt.redis.Client;
import hunt.redis.ClusterReset;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.HostAndPort;
import hunt.redis.ListPosition;
import hunt.redis.Module;
import hunt.redis.Pipeline;
import hunt.redis.Protocol;
import hunt.redis.RedisMonitor;
import hunt.redis.RedisPoolAbstract;
import hunt.redis.RedisPubSub;
import hunt.redis.RedisShardInfo;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntry;
import hunt.redis.StreamEntryID;
import hunt.redis.StreamPendingEntry;
import hunt.redis.Transaction;
import hunt.redis.Tuple;
import hunt.redis.ZParams;

import hunt.redis.commands.AdvancedRedisCommands;
import hunt.redis.commands.BasicCommands;
import hunt.redis.commands.ClusterCommands;
import hunt.redis.commands.RedisCommands;
import hunt.redis.commands.ModuleCommands;
import hunt.redis.commands.MultiKeyCommands;
import hunt.redis.Protocol;
import hunt.redis.commands.ScriptingCommands;
import hunt.redis.commands.SentinelCommands;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.params.MigrateParams;
import hunt.redis.params.SetParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;
import hunt.redis.util.Slowlog;

import hunt.collection;
import hunt.Exceptions;
import hunt.net.util.HttpURI;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

/**
*/
class Redis : BinaryRedis, RedisCommands, MultiKeyCommands,
        AdvancedRedisCommands, ScriptingCommands, BasicCommands, 
        ClusterCommands, SentinelCommands, ModuleCommands {

    protected RedisPoolAbstract dataSource = null;

    this() {
        super();
    }

    this(string host) {
        super(host);
    }

    this(HostAndPort hp) {
        super(hp);
    }

    this(string host, int port) {
        super(host, port);
    }

    this(string host, int port, bool ssl) {
        super(host, port, ssl);
    }

    // this(string host, int port, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(host, port, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int timeout) {
        super(host, port, timeout);
    }

    this(string host, int port, int timeout, bool ssl) {
        super(host, port, timeout, ssl);
    }

    // this(string host, int port, int timeout, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(host, port, timeout, ssl, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(string host, int port, int connectionTimeout, int soTimeout) {
        super(host, port, connectionTimeout, soTimeout);
    }

    this(string host, int port, int connectionTimeout, int soTimeout,
            bool ssl) {
        super(host, port, connectionTimeout, soTimeout, ssl);
    }

    // this(string host, int port, int connectionTimeout, int soTimeout,
    //     bool ssl, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(host, port, connectionTimeout, soTimeout, ssl, sslSocketFactory, sslParameters,
    //       hostnameVerifier);
    // }

    this(RedisShardInfo shardInfo) {
        super(shardInfo);
    }

    this(HttpURI uri) {
        super(uri);
    }

    // this(HttpURI uri, SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(uri, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(HttpURI uri, int timeout) {
        super(uri, timeout);
    }

    // this(HttpURI uri, int timeout, SSLSocketFactory sslSocketFactory,
    //     SSLParameters sslParameters, HostnameVerifier hostnameVerifier) {
    //   super(uri, timeout, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    this(HttpURI uri, int connectionTimeout, int soTimeout) {
        super(uri, connectionTimeout, soTimeout);
    }

    // this(HttpURI uri, int connectionTimeout, int soTimeout,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   super(uri, connectionTimeout, soTimeout, sslSocketFactory, sslParameters, hostnameVerifier);
    // }

    /**
     * Works same as <tt>ping()</tt> but returns argument message instead of <tt>PONG</tt>.
     * @param message
     * @return message
     */
    string ping(string message) {
        checkIsInMultiOrPipeline();
        client.ping(message);
        return client.getBulkReply();
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
    override
    string set(string key, string value) {
        checkIsInMultiOrPipeline();
        client.set(key, value);
        return client.getStatusCodeReply();
    }
    alias set = BinaryRedis.set;

    /**
     * Set the string value as value of the key. The string can't be longer than 1073741824 bytes (1
     * GB).
     * @param key
     * @param value
     * @param params NX|XX, NX -- Only set the key if it does not already exist. XX -- Only set the
     *          key if it already exist. EX|PX, expire time units: EX = seconds; PX = milliseconds
     * @return Status code reply
     */
    override
    string set(string key, string value, SetParams params) {
        checkIsInMultiOrPipeline();
        client.set(key, value, params);
        return client.getStatusCodeReply();
    }

    /**
     * Get the value of the specified key. If the key does not exist null is returned. If the value
     * stored at key is not a string an error is returned because GET can only handle string values.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @return Bulk reply
     */
    override
    string get(string key) {
        checkIsInMultiOrPipeline();
        client.get(key);
        return client.getBulkReply();
    }
    alias get = BinaryRedis.get;

    /**
     * Test if the specified keys exist. The command returns the number of keys exist.
     * Time complexity: O(N)
     * @param keys
     * @return Integer reply, specifically: an integer greater than 0 if one or more keys exist,
     *         0 if none of the specified keys exist.
     */
    override
    Long exists(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.exists(keys);
        return client.getIntegerReply();
    }
    alias exists = BinaryRedis.exists;

    /**
     * Test if the specified key exists. The command returns true if the key exists, otherwise false is
     * returned. Note that even keys set with an empty string as value will return true. Time
     * complexity: O(1)
     * @param key
     * @return Boolean reply, true if the key exists, otherwise false
     */
    // override
    bool exists(string key) {
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
    override
    Long del(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.del(keys);
        return client.getIntegerReply();
    }
    alias del = BinaryRedis.del;

    override
    Long del(string key) {
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
    override
    Long unlink(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.unlink(keys);
        return client.getIntegerReply();
    }

    override
    Long unlink(string key) {
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
    override
    string type(string key) {
        checkIsInMultiOrPipeline();
        client.type(key);
        return client.getStatusCodeReply();
    }
    alias type = BinaryRedis.type;

    override
    Set!(string) keys(string pattern) {
        checkIsInMultiOrPipeline();
        client.keys(pattern);
        return BuilderFactory.STRING_SET.build(client.getBinaryMultiBulkReply());
    }
    alias keys = BinaryRedis.keys;

    /**
     * Return a randomly selected key from the currently selected DB.
     * <p>
     * Time complexity: O(1)
     * @return Singe line reply, specifically the randomly selected key or an empty string is the
     *         database is empty
     */
    override
    string randomKey() {
        checkIsInMultiOrPipeline();
        client.randomKey();
        return client.getBulkReply();
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
    override
    string rename(string oldkey, string newkey) {
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
    Long hexistsrenamenx(string oldkey, string newkey) {
        checkIsInMultiOrPipeline();
        client.renamenx(oldkey, newkey);
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
     * {@link #persist(string) PERSIST} command.
     * <p>
     * Time complexity: O(1)
     * @see <a href="http://redis.io/commands/expire">Expire Command</a>
     * @param key
     * @param seconds
     * @return Integer reply, specifically: 1: the timeout was set. 0: the timeout was not set since
     *         the key already has an associated timeout (this may happen only in Redis versions &lt;
     *         2.1.3, Redis &gt;= 2.1.3 will happily update the timeout), or the key does not exist.
     */
    override
    Long expire(string key, int seconds) {
        checkIsInMultiOrPipeline();
        client.expire(key, seconds);
        return client.getIntegerReply();
    }

    /**
     * EXPIREAT works exactly like {@link #expire(string, int) EXPIRE} but instead to get the number of
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
     * {@link #persist(string) PERSIST} command.
     * <p>
     * Time complexity: O(1)
     * @see <a href="http://redis.io/commands/expire">Expire Command</a>
     * @param key
     * @param unixTime
     * @return Integer reply, specifically: 1: the timeout was set. 0: the timeout was not set since
     *         the key already has an associated timeout (this may happen only in Redis versions &lt;
     *         2.1.3, Redis &gt;= 2.1.3 will happily update the timeout), or the key does not exist.
     */
    override
    Long expireAt(string key, long unixTime) {
        checkIsInMultiOrPipeline();
        client.expireAt(key, unixTime);
        return client.getIntegerReply();
    }

    /**
     * The TTL command returns the remaining time to live in seconds of a key that has an
     * {@link #expire(string, int) EXPIRE} set. This introspection capability allows a Redis client to
     * check how many seconds a given key will continue to be part of the dataset.
     * @param key
     * @return Integer reply, returns the remaining time to live in seconds of a key that has an
     *         EXPIRE. In Redis 2.6 or older, if the Key does not exists or does not have an
     *         associated expire, -1 is returned. In Redis 2.8 or newer, if the Key does not have an
     *         associated expire, -1 is returned or if the Key does not exists, -2 is returned.
     */
    override
    Long ttl(string key) {
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
    override
    Long touch(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.touch(keys);
        return client.getIntegerReply();
    }

    override
    Long touch(string key) {
        checkIsInMultiOrPipeline();
        client.touch(key);
        return client.getIntegerReply();
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
    override
    Long move(string key, int dbIndex) {
        checkIsInMultiOrPipeline();
        client.move(key, dbIndex);
        return client.getIntegerReply();
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
    override
    string getSet(string key, string value) {
        checkIsInMultiOrPipeline();
        client.getSet(key, value);
        return client.getBulkReply();
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
    override
    List!(string) mget(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.mget(keys);
        return client.getMultiBulkReply();
    }

    /**
     * SETNX works exactly like {@link #set(string, string) SET} with the only difference that if the
     * key already exists no operation is performed. SETNX actually means "SET if Not eXists".
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param value
     * @return Integer reply, specifically: 1 if the key was set 0 if the key was not set
     */
    override
    Long setnx(string key, string value) {
        checkIsInMultiOrPipeline();
        client.setnx(key, value);
        return client.getIntegerReply();
    }

    /**
     * The command is exactly equivalent to the following group of commands:
     * {@link #set(string, string) SET} + {@link #expire(string, int) EXPIRE}. The operation is
     * atomic.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param seconds
     * @param value
     * @return Status code reply
     */
    override
    string setex(string key, int seconds, string value) {
        checkIsInMultiOrPipeline();
        client.setex(key, seconds, value);
        return client.getStatusCodeReply();
    }

    /**
     * Set the the respective keys to the respective values. MSET will replace old values with new
     * values, while {@link #msetnx(string...) MSETNX} will not perform any operation at all even if
     * just a single key already exists.
     * <p>
     * Because of this semantic MSETNX can be used in order to set different keys representing
     * different fields of an unique logic object in a way that ensures that either all the fields or
     * none at all are set.
     * <p>
     * Both MSET and MSETNX are atomic operations. This means that for instance if the keys A and B
     * are modified, another client talking to Redis can either see the changes to both A and B at
     * once, or no modification at all.
     * @see #msetnx(string...)
     * @param keysvalues
     * @return Status code reply Basically +OK as MSET can't fail
     */
    override
    string mset(string[] keysvalues...) {
        checkIsInMultiOrPipeline();
        client.mset(keysvalues);
        return client.getStatusCodeReply();
    }

    /**
     * Set the the respective keys to the respective values. {@link #mset(string...) MSET} will
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
     * @see #mset(string...)
     * @param keysvalues
     * @return Integer reply, specifically: 1 if the all the keys were set 0 if no key was set (at
     *         least one key already existed)
     */
    override
    Long msetnx(string[] keysvalues...) {
        checkIsInMultiOrPipeline();
        client.msetnx(keysvalues);
        return client.getIntegerReply();
    }

    /**
     * IDECRBY work just like {@link #decr(string) INCR} but instead to decrement by 1 the decrement
     * is integer.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incr(string)
     * @see #decr(string)
     * @see #incrBy(string, long)
     * @param key
     * @param decrement
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    override
    Long decrBy(string key, long decrement) {
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
     * @see #incr(string)
     * @see #incrBy(string, long)
     * @see #decrBy(string, long)
     * @param key
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    override
    Long decr(string key) {
        checkIsInMultiOrPipeline();
        client.decr(key);
        return client.getIntegerReply();
    }
    alias decr = BinaryRedis.decr;

    /**
     * INCRBY work just like {@link #incr(string) INCR} but instead to increment by 1 the increment is
     * integer.
     * <p>
     * INCR commands are limited to 64 bit signed integers.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "integer" types.
     * Simply the string stored at the key is parsed as a base 10 64 bit signed integer, incremented,
     * and then converted back as a string.
     * <p>
     * Time complexity: O(1)
     * @see #incr(string)
     * @see #decr(string)
     * @see #decrBy(string, long)
     * @param key
     * @param increment
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    override
    Long incrBy(string key, long increment) {
        checkIsInMultiOrPipeline();
        client.incrBy(key, increment);
        return client.getIntegerReply();
    }
    alias incrBy = BinaryRedis.incrBy;

    /**
     * INCRBYFLOAT
     * <p>
     * INCRBYFLOAT commands are limited to double precision floating point values.
     * <p>
     * Note: this is actually a string operation, that is, in Redis there are not "double" types.
     * Simply the string stored at the key is parsed as a base double precision floating point value,
     * incremented, and then converted back as a string. There is no DECRYBYFLOAT but providing a
     * negative value will work as expected.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param increment
     * @return Double reply, this commands will reply with the new value of key after the increment.
     */
    override
    Double incrByFloat(string key, double increment) {
        checkIsInMultiOrPipeline();
        client.incrByFloat(key, increment);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }
    alias incrByFloat = BinaryRedis.incrByFloat;

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
     * @see #incrBy(string, long)
     * @see #decr(string)
     * @see #decrBy(string, long)
     * @param key
     * @return Integer reply, this commands will reply with the new value of key after the increment.
     */
    override
    Long incr(string key) {
        checkIsInMultiOrPipeline();
        client.incr(key);
        return client.getIntegerReply();
    }
    alias incr = BinaryRedis.incr;

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
    override
    Long append(string key, string value) {
        checkIsInMultiOrPipeline();
        client.append(key, value);
        return client.getIntegerReply();
    }
    alias append = BinaryRedis.append;

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
    override
    string substr(string key, int start, int end) {
        checkIsInMultiOrPipeline();
        client.substr(key, start, end);
        return client.getBulkReply();
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
    override
    Long hset(string key, string field, string value) {
        checkIsInMultiOrPipeline();
        client.hset(key, field, value);
        return client.getIntegerReply();
    }

    override
    Long hset(string key, Map!(string, string) hash) {
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
    override
    string hget(string key, string field) {
        checkIsInMultiOrPipeline();
        client.hget(key, field);
        return client.getBulkReply();
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
    override
    Long hsetnx(string key, string field, string value) {
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
     * @return Return OK or Exception if hash is empty
     */
    override
    string hmset(string key, Map!(string, string) hash) {
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
    override
    List!(string) hmget(string key, string[] fields...) {
        checkIsInMultiOrPipeline();
        client.hmget(key, fields);
        return client.getMultiBulkReply();
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
    override
    Long hincrBy(string key, string field, long value) {
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
    override
    Double hincrByFloat(string key, string field, double value) {
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
    bool hexists(string key, string field) {
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
    override
    Long hdel(string key, string[] fields...) {
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
    override
    Long hlen(string key) {
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
    override
    Set!(string) hkeys(string key) {
        checkIsInMultiOrPipeline();
        client.hkeys(key);
        return BuilderFactory.STRING_SET.build(client.getBinaryMultiBulkReply());
    }

    /**
     * Return all the values in a hash.
     * <p>
     * <b>Time complexity:</b> O(N), where N is the total number of entries
     * @param key
     * @return All the fields values contained into a hash.
     */
    override
    List!(string) hvals(string key) {
        checkIsInMultiOrPipeline();
        client.hvals(key);
        List!(string) lresult = client.getMultiBulkReply();
        return lresult;
    }

    /**
     * Return all the fields and associated values in a hash.
     * <p>
     * <b>Time complexity:</b> O(N), where N is the total number of entries
     * @param key
     * @return All the fields and values contained into a hash.
     */
    override
    Map!(string, string) hgetAll(string key) {
        checkIsInMultiOrPipeline();
        client.hgetAll(key);
        return BuilderFactory.STRING_MAP.build(client.getBinaryMultiBulkReply());
    }

    /**
     * Add the string value to the head (LPUSH) or tail (RPUSH) of the list stored at key. If the key
     * does not exist an empty list is created just before the append operation. If the key exists but
     * is not a List an error is returned.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @param strings
     * @return Integer reply, specifically, the number of elements inside the list after the push
     *         operation.
     */
    override
    Long rpush(string key, string[] strings...) {
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
     * @param key
     * @param strings
     * @return Integer reply, specifically, the number of elements inside the list after the push
     *         operation.
     */
    override
    Long lpush(string key, string[] strings...) {
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
    override
    Long llen(string key) {
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
    override
    List!(string) lrange(string key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.lrange(key, start, stop);
        return client.getMultiBulkReply();
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
    override
    string ltrim(string key, long start, long stop) {
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
    override
    string lindex(string key, long index) {
        checkIsInMultiOrPipeline();
        client.lindex(key, index);
        return client.getBulkReply();
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
     * @see #lindex(string, long)
     * @param key
     * @param index
     * @param value
     * @return Status code reply
     */
    override
    string lset(string key, long index, string value) {
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
    override
    Long lrem(string key, long count, string value) {
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
     * @see #rpop(string)
     * @param key
     * @return Bulk reply
     */
    override
    string lpop(string key) {
        checkIsInMultiOrPipeline();
        client.lpop(key);
        return client.getBulkReply();
    }

    /**
     * Atomically return and remove the first (LPOP) or last (RPOP) element of the list. For example
     * if the list contains the elements "a","b","c" RPOP will return "c" and the list will become
     * "a","b".
     * <p>
     * If the key does not exist or the list is already empty the special value 'nil' is returned.
     * @see #lpop(string)
     * @param key
     * @return Bulk reply
     */
    override
    string rpop(string key) {
        checkIsInMultiOrPipeline();
        client.rpop(key);
        return client.getBulkReply();
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
    override
    string rpoplpush(string srckey, string dstkey) {
        checkIsInMultiOrPipeline();
        client.rpoplpush(srckey, dstkey);
        return client.getBulkReply();
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
    override
    Long sadd(string key, string[] members...) {
        checkIsInMultiOrPipeline();
        client.sadd(key, members);
        return client.getIntegerReply();
    }

    /**
     * Return all the members (elements) of the set value stored at key. This is just syntax glue for
     * {@link #sinter(string...) SINTER}.
     * <p>
     * Time complexity O(N)
     * @param key
     * @return Multi bulk reply
     */
    override
    Set!(string) smembers(string key) {
        checkIsInMultiOrPipeline();
        client.smembers(key);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    /**
     * Remove the specified member from the set value stored at key. If member was not a member of the
     * set no operation is performed. If key does not hold a set value an error is returned.
     * <p>
     * Time complexity O(1)
     * @param key
     * @param members
     * @return Integer reply, specifically: 1 if the new element was removed 0 if the new element was
     *         not a member of the set
     */
    override
    Long srem(string key, string[] members...) {
        checkIsInMultiOrPipeline();
        client.srem(key, members);
        return client.getIntegerReply();
    }

    /**
     * Remove a random element from a Set returning it as return value. If the Set is empty or the key
     * does not exist, a nil object is returned.
     * <p>
     * The {@link #srandmember(string)} command does a similar work but the returned element is not
     * removed from the Set.
     * <p>
     * Time complexity O(1)
     * @param key
     * @return Bulk reply
     */
    override
    string spop(string key) {
        checkIsInMultiOrPipeline();
        client.spop(key);
        return client.getBulkReply();
    }

    override
    Set!(string) spop(string key, long count) {
        checkIsInMultiOrPipeline();
        client.spop(key, count);
        List!(string) members = client.getMultiBulkReply();
        if (members is null) return null;
        return SetFromList.of(members);
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
    override
    Long smove(string srckey, string dstkey, string member) {
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
    override
    Long scard(string key) {
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
     * @return Boolean reply, specifically: true if the element is a member of the set false if the element
     *         is not a member of the set OR if the key does not exist
     */
    override
    Boolean sismember(string key, string member) {
        checkIsInMultiOrPipeline();
        client.sismember(key, member);
        return client.getIntegerReply() == 1;
    }

    /**
     * Return the members of a set resulting from the intersection of all the sets hold at the
     * specified keys. Like in {@link #lrange(string, long, long) LRANGE} the result is sent to the
     * client as a multi-bulk reply (see the protocol specification for more information). If just a
     * single key is specified, then this command produces the same result as
     * {@link #smembers(string) SMEMBERS}. Actually SMEMBERS is just syntax sugar for SINTER.
     * <p>
     * Non existing keys are considered like empty sets, so if one of the keys is missing an empty set
     * is returned (since the intersection with an empty set always is an empty set).
     * <p>
     * Time complexity O(N*M) worst case where N is the cardinality of the smallest set and M the
     * number of sets
     * @param keys
     * @return Multi bulk reply, specifically the list of common elements.
     */
    override
    Set!(string) sinter(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.sinter(keys);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    /**
     * This command works exactly like {@link #sinter(string...) SINTER} but instead of being returned
     * the resulting set is stored as dstkey.
     * <p>
     * Time complexity O(N*M) worst case where N is the cardinality of the smallest set and M the
     * number of sets
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    override
    Long sinterstore(string dstkey, string[] keys...) {
        checkIsInMultiOrPipeline();
        client.sinterstore(dstkey, keys);
        return client.getIntegerReply();
    }

    /**
     * Return the members of a set resulting from the union of all the sets hold at the specified
     * keys. Like in {@link #lrange(string, long, long) LRANGE} the result is sent to the client as a
     * multi-bulk reply (see the protocol specification for more information). If just a single key is
     * specified, then this command produces the same result as {@link #smembers(string) SMEMBERS}.
     * <p>
     * Non existing keys are considered like empty sets.
     * <p>
     * Time complexity O(N) where N is the total number of elements in all the provided sets
     * @param keys
     * @return Multi bulk reply, specifically the list of common elements.
     */
    override
    Set!(string) sunion(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.sunion(keys);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    /**
     * This command works exactly like {@link #sunion(string...) SUNION} but instead of being returned
     * the resulting set is stored as dstkey. Any existing value in dstkey will be over-written.
     * <p>
     * Time complexity O(N) where N is the total number of elements in all the provided sets
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    override
    Long sunionstore(string dstkey, string[] keys...) {
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
    override
    Set!(string) sdiff(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.sdiff(keys);
        return BuilderFactory.STRING_SET.build(client.getBinaryMultiBulkReply());
    }

    /**
     * This command works exactly like {@link #sdiff(string...) SDIFF} but instead of being returned
     * the resulting set is stored in dstkey.
     * @param dstkey
     * @param keys
     * @return Status code reply
     */
    override
    Long sdiffstore(string dstkey, string[] keys...) {
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
    override
    string srandmember(string key) {
        checkIsInMultiOrPipeline();
        client.srandmember(key);
        return client.getBulkReply();
    }

    override
    List!(string) srandmember(string key, int count) {
        checkIsInMultiOrPipeline();
        client.srandmember(key, count);
        return client.getMultiBulkReply();
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
    override
    Long zadd(string key, double score, string member) {
        checkIsInMultiOrPipeline();
        client.zadd(key, score, member);
        return client.getIntegerReply();
    }

    override
    Long zadd(string key, double score, string member,
            ZAddParams params) {
        checkIsInMultiOrPipeline();
        client.zadd(key, score, member, params);
        return client.getIntegerReply();
    }

    override
    Long zadd(string key, Map!(string, Double) scoreMembers) {
        checkIsInMultiOrPipeline();
        client.zadd(key, scoreMembers);
        return client.getIntegerReply();
    }

    override
    Long zadd(string key, Map!(string, Double) scoreMembers, ZAddParams params) {
        checkIsInMultiOrPipeline();
        client.zadd(key, scoreMembers, params);
        return client.getIntegerReply();
    }

    override
    Set!(string) zrange(string key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrange(key, start, stop);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
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
    override
    Long zrem(string key, string[] members...) {
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
    override
    Double zincrby(string key, double increment, string member) {
        checkIsInMultiOrPipeline();
        client.zincrby(key, increment, member);
        return BuilderFactory.DOUBLE.build(client.getOne());
    }

    override
    Double zincrby(string key, double increment, string member, ZIncrByParams params) {
        checkIsInMultiOrPipeline();
        client.zincrby(key, increment, member, params);
        return BuilderFactory.DOUBLE.build(client.getOne());
    }

    /**
     * Return the rank (or index) of member in the sorted set at key, with scores being ordered from
     * low to high.
     * <p>
     * When the given member does not exist in the sorted set, the special value 'nil' is returned.
     * The returned rank (or index) of the member is 0-based for both commands.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))
     * @see #zrevrank(string, string)
     * @param key
     * @param member
     * @return Integer reply or a nil bulk reply, specifically: the rank of the element as an integer
     *         reply if the element exists. A nil bulk reply if there is no such element.
     */
    override
    Long zrank(string key, string member) {
        checkIsInMultiOrPipeline();
        client.zrank(key, member);
        return client.getIntegerReply();
    }

    /**
     * Return the rank (or index) of member in the sorted set at key, with scores being ordered from
     * high to low.
     * <p>
     * When the given member does not exist in the sorted set, the special value 'nil' is returned.
     * The returned rank (or index) of the member is 0-based for both commands.
     * <p>
     * <b>Time complexity:</b>
     * <p>
     * O(log(N))
     * @see #zrank(string, string)
     * @param key
     * @param member
     * @return Integer reply or a nil bulk reply, specifically: the rank of the element as an integer
     *         reply if the element exists. A nil bulk reply if there is no such element.
     */
    override
    Long zrevrank(string key, string member) {
        checkIsInMultiOrPipeline();
        client.zrevrank(key, member);
        return client.getIntegerReply();
    }

    override
    Set!(string) zrevrange(string key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrevrange(key, start, stop);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(Tuple) zrangeWithScores(string key, long start, long stop) {
        checkIsInMultiOrPipeline();
        client.zrangeWithScores(key, start, stop);
        return getTupledSet();
    }

    override
    Set!(Tuple) zrevrangeWithScores(string key, long start, long stop) {
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
    override
    Long zcard(string key) {
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
    override
    Double zscore(string key, string member) {
        checkIsInMultiOrPipeline();
        client.zscore(key, member);
        return BuilderFactory.DOUBLE.build(client.getOne());
    }

    override
    string watch(string[] keys...) {
        client.watch(keys);
        return client.getStatusCodeReply();
    }

    /**
     * Sort a Set or a List.
     * <p>
     * Sort the elements contained in the List, Set, or Sorted Set value at key. By default sorting is
     * numeric with elements being compared as double precision floating point numbers. This is the
     * simplest form of SORT.
     * @see #sort(string, string)
     * @see #sort(string, SortingParams)
     * @see #sort(string, SortingParams, string)
     * @param key
     * @return Assuming the Set/List at key contains a list of numbers, the return value will be the
     *         list of numbers ordered from the smallest to the biggest number.
     */
    override
    List!(string) sort(string key) {
        checkIsInMultiOrPipeline();
        client.sort(key);
        return client.getMultiBulkReply();
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
     * @see #sort(string)
     * @see #sort(string, SortingParams, string)
     * @param key
     * @param sortingParameters
     * @return a list of sorted elements.
     */
    override
    List!(string) sort(string key, SortingParams sortingParameters) {
        checkIsInMultiOrPipeline();
        client.sort(key, sortingParameters);
        return client.getMultiBulkReply();
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
     * @see #brpop(int, string...)
     * @param timeout
     * @param keys
     * @return BLPOP returns a two-elements array via a multi bulk reply in order to return both the
     *         unblocking key and the popped value.
     *         <p>
     *         When a non-zero timeout is specified, and the BLPOP operation timed out, the return
     *         value is a nil multi bulk reply. Most client values will return false or nil
     *         accordingly to the programming language used.
     */
    override
    List!(string) blpop(int timeout, string[] keys...) {
        return blpop(getArgsAddTimeout(timeout, keys));
    }

    private string[] getArgsAddTimeout(int timeout, string[] keys) {
        int keyCount = keys.length;
        string[] args = new string[keyCount + 1];
        for (int at = 0; at != keyCount; ++at) {
            args[at] = keys[at];
        }

        args[keyCount] = string.valueOf(timeout);
        return args;
    }

    override
    List!(string) blpop(string[] args...) {
        checkIsInMultiOrPipeline();
        client.blpop(args);
        client.setTimeoutInfinite();
        try {
            return client.getMultiBulkReply();
        } finally {
            client.rollbackTimeout();
        }
    }

    override
    List!(string) brpop(string[] args...) {
        checkIsInMultiOrPipeline();
        client.brpop(args);
        client.setTimeoutInfinite();
        try {
            return client.getMultiBulkReply();
        } finally {
            client.rollbackTimeout();
        }
    }

    /**
     * Sort a Set or a List accordingly to the specified parameters and store the result at dstkey.
     * @see #sort(string, SortingParams)
     * @see #sort(string)
     * @see #sort(string, string)
     * @param key
     * @param sortingParameters
     * @param dstkey
     * @return The number of elements of the list at dstkey.
     */
    override
    Long sort(string key, SortingParams sortingParameters, string dstkey) {
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
     * @see #sort(string)
     * @see #sort(string, SortingParams)
     * @see #sort(string, SortingParams, string)
     * @param key
     * @param dstkey
     * @return The number of elements of the list at dstkey.
     */
    override
    Long sort(string key, string dstkey) {
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
     * @see #blpop(int, string...)
     * @param timeout
     * @param keys
     * @return BLPOP returns a two-elements array via a multi bulk reply in order to return both the
     *         unblocking key and the popped value.
     *         <p>
     *         When a non-zero timeout is specified, and the BLPOP operation timed out, the return
     *         value is a nil multi bulk reply. Most client values will return false or nil
     *         accordingly to the programming language used.
     */
    override
    List!(string) brpop(int timeout, string[] keys...) {
        return brpop(getArgsAddTimeout(timeout, keys));
    }

    override
    Long zcount(string key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zcount(key, min, max);
        return client.getIntegerReply();
    }

    override
    Long zcount(string key, string min, string max) {
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
     * Using the optional {@link #zrangeByScore(string, double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(string, double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(string, double, double) ZRANGEBYSCORE} but instead of returning the
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
     * @see #zrangeByScore(string, double, double)
     * @see #zrangeByScore(string, double, double, int, int)
     * @see #zrangeByScoreWithScores(string, double, double)
     * @see #zrangeByScoreWithScores(string, string, string)
     * @see #zrangeByScoreWithScores(string, double, double, int, int)
     * @see #zcount(string, double, double)
     * @param key
     * @param min a double or Double.NEGATIVE_INFINITY for "-inf"
     * @param max a double or Double.POSITIVE_INFINITY for "+inf"
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    override
    Set!(string) zrangeByScore(string key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrangeByScore(string key, string min, string max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(string, double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(string, double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(string, double, double) ZRANGEBYSCORE} but instead of returning the
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
     * @see #zrangeByScore(string, double, double)
     * @see #zrangeByScore(string, double, double, int, int)
     * @see #zrangeByScoreWithScores(string, double, double)
     * @see #zrangeByScoreWithScores(string, double, double, int, int)
     * @see #zcount(string, double, double)
     * @param key
     * @param min
     * @param max
     * @param offset
     * @param count
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    override
    Set!(string) zrangeByScore(string key, double min, double max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrangeByScore(string key, string min, string max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScore(key, min, max, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    /**
     * Return the all the elements in the sorted set at key with a score between min and max
     * (including elements with score equal to min or max).
     * <p>
     * The elements having the same score are returned sorted lexicographically as ASCII strings (this
     * follows from a property of Redis sorted sets and does not involve further computation).
     * <p>
     * Using the optional {@link #zrangeByScore(string, double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(string, double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(string, double, double) ZRANGEBYSCORE} but instead of returning the
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
     * @see #zrangeByScore(string, double, double)
     * @see #zrangeByScore(string, double, double, int, int)
     * @see #zrangeByScoreWithScores(string, double, double)
     * @see #zrangeByScoreWithScores(string, double, double, int, int)
     * @see #zcount(string, double, double)
     * @param key
     * @param min
     * @param max
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    override
    Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max);
        return getTupledSet();
    }

    override
    Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max) {
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
     * Using the optional {@link #zrangeByScore(string, double, double, int, int) LIMIT} it's possible
     * to get only a range of the matching elements in an SQL-alike way. Note that if offset is large
     * the commands needs to traverse the list for offset elements and this adds up to the O(M)
     * figure.
     * <p>
     * The {@link #zcount(string, double, double) ZCOUNT} command is similar to
     * {@link #zrangeByScore(string, double, double) ZRANGEBYSCORE} but instead of returning the
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
     * @see #zrangeByScore(string, double, double)
     * @see #zrangeByScore(string, double, double, int, int)
     * @see #zrangeByScoreWithScores(string, double, double)
     * @see #zrangeByScoreWithScores(string, double, double, int, int)
     * @see #zcount(string, double, double)
     * @param key
     * @param min
     * @param max
     * @param offset
     * @param count
     * @return Multi bulk reply specifically a list of elements in the specified score range.
     */
    override
    Set!(Tuple) zrangeByScoreWithScores(string key, double min, double max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max, offset, count);
        return getTupledSet();
    }

    override
    Set!(Tuple) zrangeByScoreWithScores(string key, string min, string max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByScoreWithScores(key, min, max, offset, count);
        return getTupledSet();
    }

    override
    Set!(string) zrevrangeByScore(string key, double max, double min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrevrangeByScore(string key, string max, string min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrevrangeByScore(string key, double max, double min,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(Tuple) zrevrangeByScoreWithScores(string key, double max, double min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min);
        return getTupledSet();
    }

    override
    Set!(Tuple) zrevrangeByScoreWithScores(string key, double max,
            double min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min, offset, count);
        return getTupledSet();
    }

    override
    Set!(Tuple) zrevrangeByScoreWithScores(string key, string max,
            string min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min, offset, count);
        return getTupledSet();
    }

    override
    Set!(string) zrevrangeByScore(string key, string max, string min,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScore(key, max, min, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(Tuple) zrevrangeByScoreWithScores(string key, string max, string min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByScoreWithScores(key, max, min);
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
    override
    Long zremrangeByRank(string key, long start, long stop) {
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
    override
    Long zremrangeByScore(string key, double min, double max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByScore(key, min, max);
        return client.getIntegerReply();
    }

    override
    Long zremrangeByScore(string key, string min, string max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByScore(key, min, max);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(string, string...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The
     * {@link #zunionstore(string, string...) ZUNIONSTORE} command inserts all elements across all
     * inputs.
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
     * @see #zunionstore(string, string...)
     * @see #zunionstore(string, ZParams, string...)
     * @see #zinterstore(string, string...)
     * @see #zinterstore(string, ZParams, string...)
     * @param dstkey
     * @param sets
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    override
    Long zunionstore(string dstkey, string[] sets...) {
        checkIsInMultiOrPipeline();
        client.zunionstore(dstkey, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(string, string...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The
     * {@link #zunionstore(string, string...) ZUNIONSTORE} command inserts all elements across all
     * inputs.
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
     * @see #zunionstore(string, string...)
     * @see #zunionstore(string, ZParams, string...)
     * @see #zinterstore(string, string...)
     * @see #zinterstore(string, ZParams, string...)
     * @param dstkey
     * @param sets
     * @param params
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    override
    Long zunionstore(string dstkey, ZParams params, string[] sets...) {
        checkIsInMultiOrPipeline();
        client.zunionstore(dstkey, params, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(string, string...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The
     * {@link #zunionstore(string, string...) ZUNIONSTORE} command inserts all elements across all
     * inputs.
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
     * @see #zunionstore(string, string...)
     * @see #zunionstore(string, ZParams, string...)
     * @see #zinterstore(string, string...)
     * @see #zinterstore(string, ZParams, string...)
     * @param dstkey
     * @param sets
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    override
    Long zinterstore(string dstkey, string[] sets...) {
        checkIsInMultiOrPipeline();
        client.zinterstore(dstkey, sets);
        return client.getIntegerReply();
    }

    /**
     * Creates a union or intersection of N sorted sets given by keys k1 through kN, and stores it at
     * dstkey. It is mandatory to provide the number of input keys N, before passing the input keys
     * and the other (optional) arguments.
     * <p>
     * As the terms imply, the {@link #zinterstore(string, string...) ZINTERSTORE} command requires an
     * element to be present in each of the given inputs to be inserted in the result. The
     * {@link #zunionstore(string, string...) ZUNIONSTORE} command inserts all elements across all
     * inputs.
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
     * @see #zunionstore(string, string...)
     * @see #zunionstore(string, ZParams, string...)
     * @see #zinterstore(string, string...)
     * @see #zinterstore(string, ZParams, string...)
     * @param dstkey
     * @param sets
     * @param params
     * @return Integer reply, specifically the number of elements in the sorted set at dstkey
     */
    override
    Long zinterstore(string dstkey, ZParams params, string[] sets...) {
        checkIsInMultiOrPipeline();
        client.zinterstore(dstkey, params, sets);
        return client.getIntegerReply();
    }

    override
    Long zlexcount(string key, string min, string max) {
        checkIsInMultiOrPipeline();
        client.zlexcount(key, min, max);
        return client.getIntegerReply();
    }

    override
    Set!(string) zrangeByLex(string key, string min, string max) {
        checkIsInMultiOrPipeline();
        client.zrangeByLex(key, min, max);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrangeByLex(string key, string min, string max,
            int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrangeByLex(key, min, max, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrevrangeByLex(string key, string max, string min) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByLex(key, max, min);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Set!(string) zrevrangeByLex(string key, string max, string min, int offset, int count) {
        checkIsInMultiOrPipeline();
        client.zrevrangeByLex(key, max, min, offset, count);
        List!(string) members = client.getMultiBulkReply();
        return SetFromList.of(members);
    }

    override
    Long zremrangeByLex(string key, string min, string max) {
        checkIsInMultiOrPipeline();
        client.zremrangeByLex(key, min, max);
        return client.getIntegerReply();
    }

    override
    Long strlen(string key) {
        checkIsInMultiOrPipeline();
        client.strlen(key);
        return client.getIntegerReply();
    }

    override
    Long lpushx(string key, string[] string...) {
        checkIsInMultiOrPipeline();
        client.lpushx(key, string);
        return client.getIntegerReply();
    }

    /**
     * Undo a {@link #expire(string, int) expire} at turning the expire key into a normal key.
     * <p>
     * Time complexity: O(1)
     * @param key
     * @return Integer reply, specifically: 1: the key is now persist. 0: the key is not persist (only
     *         happens when key not set).
     */
    override
    Long persist(string key) {
        client.persist(key);
        return client.getIntegerReply();
    }

    override
    Long rpushx(string key, string[] string...) {
        checkIsInMultiOrPipeline();
        client.rpushx(key, string);
        return client.getIntegerReply();
    }

    override
    string echo(string string) {
        checkIsInMultiOrPipeline();
        client.echo(string);
        return client.getBulkReply();
    }

    override
    Long linsert(string key, ListPosition where, string pivot,
            string value) {
        checkIsInMultiOrPipeline();
        client.linsert(key, where, pivot, value);
        return client.getIntegerReply();
    }

    /**
     * Pop a value from a list, push it to another list and return it; or block until one is available
     * @param source
     * @param destination
     * @param timeout
     * @return the element
     */
    override
    string brpoplpush(string source, string destination, int timeout) {
        client.brpoplpush(source, destination, timeout);
        client.setTimeoutInfinite();
        try {
            return client.getBulkReply();
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
    override
    Boolean setbit(string key, long offset, bool value) {
        checkIsInMultiOrPipeline();
        client.setbit(key, offset, value);
        return client.getIntegerReply() == 1;
    }

    override
    Boolean setbit(string key, long offset, string value) {
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
    override
    Boolean getbit(string key, long offset) {
        checkIsInMultiOrPipeline();
        client.getbit(key, offset);
        return client.getIntegerReply() == 1;
    }

    override
    Long setrange(string key, long offset, string value) {
        checkIsInMultiOrPipeline();
        client.setrange(key, offset, value);
        return client.getIntegerReply();
    }

    override
    string getrange(string key, long startOffset, long endOffset) {
        checkIsInMultiOrPipeline();
        client.getrange(key, startOffset, endOffset);
        return client.getBulkReply();
    }

    override
    Long bitpos(string key, bool value) {
        return bitpos(key, value, new BitPosParams());
    }

    override
    Long bitpos(string key, bool value, BitPosParams params) {
        checkIsInMultiOrPipeline();
        client.bitpos(key, value, params);
        return client.getIntegerReply();
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
    override
    List!(string) configGet(string pattern) {
        client.configGet(pattern);
        return client.getMultiBulkReply();
    }

    /**
     * Alter the configuration of a running Redis server. Not all the configuration parameters are
     * supported.
     * <p>
     * The list of configuration parameters supported by CONFIG SET can be obtained issuing a
     * {@link #configGet(string) CONFIG GET *} command.
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
    override
    string configSet(string parameter, string value) {
        client.configSet(parameter, value);
        return client.getStatusCodeReply();
    }

    override
    Object eval(string script, int keyCount, string[] params...) {
        client.setTimeoutInfinite();
        try {
            client.eval(script, keyCount, params);
            return getEvalResult();
        } finally {
            client.rollbackTimeout();
        }
    }

    override
    void subscribe(RedisPubSub jedisPubSub, string[] channels...) {
        client.setTimeoutInfinite();
        try {
            jedisPubSub.proceed(client, channels);
        } finally {
            client.rollbackTimeout();
        }
    }

    override
    Long publish(string channel, string message) {
        checkIsInMultiOrPipeline();
        connect();
        client.publish(channel, message);
        return client.getIntegerReply();
    }

    override
    void psubscribe(RedisPubSub jedisPubSub, string[] patterns...) {
        checkIsInMultiOrPipeline();
        client.setTimeoutInfinite();
        try {
            jedisPubSub.proceedWithPatterns(client, patterns);
        } finally {
            client.rollbackTimeout();
        }
    }

    protected static string[] getParams(List!(string) keys, List!(string) args) {
        int keyCount = keys.size();
        int argCount = args.size();

        string[] params = new string[keyCount + args.size()];

        for (int i = 0; i < keyCount; i++)
            params[i] = keys.get(i);

        for (int i = 0; i < argCount; i++)
            params[keyCount + i] = args.get(i);

        return params;
    }

    override
    Object eval(string script, List!(string) keys, List!(string) args) {
        return eval(script, keys.size(), getParams(keys, args));
    }

    override
    Object eval(string script) {
        return eval(script, 0);
    }

    override
    Object evalsha(string sha1) {
        return evalsha(sha1, 0);
    }

    private Object getEvalResult() {
        return evalResult(client.getOne());
    }

    private Object evalResult(Object result) {
        implementationMissing();
        return null;
        // if (result instanceof byte[]) return SafeEncoder.encode((byte[]) result);

        // if (result instanceof List<?>) {
        //   List<?> list = (List<?>) result;
        //   List!(Object) listResult = new ArrayList!(Object)(list.size());
        //   foreach(Object bin ; list) {
        //     listResult.add(evalResult(bin));
        //   }

        //   return listResult;
        // }

        // return result;
    }

    override
    Object evalsha(string sha1, List!(string) keys, List!(string) args) {
        return evalsha(sha1, keys.size(), getParams(keys, args));
    }

    override
    Object evalsha(string sha1, int keyCount, string[] params...) {
        checkIsInMultiOrPipeline();
        client.evalsha(sha1, keyCount, params);
        return getEvalResult();
    }

// FIXME: Needing refactor or cleanup -@zxp at 7/15/2019, 11:39:47 AM
// 
    // override
    // Boolean scriptExists(string sha1) {
    //   string[] a = new string[1];
    //   a[0] = sha1;
    //   return scriptExists(a).get(0);
    // }

    // override
    // List!(Boolean) scriptExists(string[] sha1...) {
    //   client.scriptExists(sha1);
    //   List!(Long) result = client.getIntegerMultiBulkReply();
    //   List!(Boolean) exists = new ArrayList!(Boolean)();

    //   foreach(Long value ; result)
    //     exists.add(value == 1);

    //   return exists;
    // }

    override
    string scriptLoad(string script) {
        client.scriptLoad(script);
        return client.getBulkReply();
    }

    override
    List!(Slowlog) slowlogGet() {
        client.slowlogGet();
        return Slowlog.from(client.getObjectMultiBulkReply());
    }

    override
    List!(Slowlog) slowlogGet(long entries) {
        client.slowlogGet(entries);
        return Slowlog.from(client.getObjectMultiBulkReply());
    }

    override
    Long objectRefcount(string key) {
        client.objectRefcount(key);
        return client.getIntegerReply();
    }

    override
    string objectEncoding(string key) {
        client.objectEncoding(key);
        return client.getBulkReply();
    }

    override
    Long objectIdletime(string key) {
        client.objectIdletime(key);
        return client.getIntegerReply();
    }

    override
    Long bitcount(string key) {
        checkIsInMultiOrPipeline();
        client.bitcount(key);
        return client.getIntegerReply();
    }

    override
    Long bitcount(string key, long start, long end) {
        checkIsInMultiOrPipeline();
        client.bitcount(key, start, end);
        return client.getIntegerReply();
    }

    override
    Long bitop(BitOP op, string destKey, string[] srcKeys...) {
        checkIsInMultiOrPipeline();
        client.bitop(op, destKey, srcKeys);
        return client.getIntegerReply();
    }

    /**
     * <pre>
     * redis 127.0.0.1:26381&gt; sentinel masters
     * 1)  1) "name"
     *     2) "mymaster"
     *     3) "ip"
     *     4) "127.0.0.1"
     *     5) "port"
     *     6) "6379"
     *     7) "runid"
     *     8) "93d4d4e6e9c06d0eea36e27f31924ac26576081d"
     *     9) "flags"
     *    10) "master"
     *    11) "pending-commands"
     *    12) "0"
     *    13) "last-ok-ping-reply"
     *    14) "423"
     *    15) "last-ping-reply"
     *    16) "423"
     *    17) "info-refresh"
     *    18) "6107"
     *    19) "num-slaves"
     *    20) "1"
     *    21) "num-other-sentinels"
     *    22) "2"
     *    23) "quorum"
     *    24) "2"
     * 
     * </pre>
     * @return
     */
    override
    List!(Map!(string, string)) sentinelMasters() {
        client.sentinel(Protocol.SENTINEL_MASTERS);
        List!(Object) reply = client.getObjectMultiBulkReply();

        List!(Map!(string, string)) masters = new ArrayList!(Map!(string, string))();
        // foreach(Object obj ; reply) {
        //   masters.add(BuilderFactory.STRING_MAP.build((List) obj));
        // }
        implementationMissing(false);
        return masters;
    }

    /**
     * <pre>
     * redis 127.0.0.1:26381&gt; sentinel get-master-addr-by-name mymaster
     * 1) "127.0.0.1"
     * 2) "6379"
     * </pre>
     * @param masterName
     * @return two elements list of strings : host and port.
     */
    override
    List!(string) sentinelGetMasterAddrByName(string masterName) {
        client.sentinel(Protocol.SENTINEL_GET_MASTER_ADDR_BY_NAME, masterName);
        List!(Object) reply = client.getObjectMultiBulkReply();
        return BuilderFactory.STRING_LIST.build(reply);
    }

    /**
     * <pre>
     * redis 127.0.0.1:26381&gt; sentinel reset mymaster
     * (integer) 1
     * </pre>
     * @param pattern
     * @return
     */
    override
    Long sentinelReset(string pattern) {
        client.sentinel(Protocol.SENTINEL_RESET, pattern);
        return client.getIntegerReply();
    }

    /**
     * <pre>
     * redis 127.0.0.1:26381&gt; sentinel slaves mymaster
     * 1)  1) "name"
     *     2) "127.0.0.1:6380"
     *     3) "ip"
     *     4) "127.0.0.1"
     *     5) "port"
     *     6) "6380"
     *     7) "runid"
     *     8) "d7f6c0ca7572df9d2f33713df0dbf8c72da7c039"
     *     9) "flags"
     *    10) "slave"
     *    11) "pending-commands"
     *    12) "0"
     *    13) "last-ok-ping-reply"
     *    14) "47"
     *    15) "last-ping-reply"
     *    16) "47"
     *    17) "info-refresh"
     *    18) "657"
     *    19) "master-link-down-time"
     *    20) "0"
     *    21) "master-link-status"
     *    22) "ok"
     *    23) "master-host"
     *    24) "localhost"
     *    25) "master-port"
     *    26) "6379"
     *    27) "slave-priority"
     *    28) "100"
     * </pre>
     * @param masterName
     * @return
     */
    override
    
    List!(Map!(string, string)) sentinelSlaves(string masterName) {
        client.sentinel(Protocol.SENTINEL_SLAVES, masterName);
        List!(Object) reply = client.getObjectMultiBulkReply();

        List!(Map!(string, string)) slaves = new ArrayList!(Map!(string, string))();
        // foreach(Object obj ; reply) {
        //   slaves.add(BuilderFactory.STRING_MAP.build((List) obj));
        // }
        implementationMissing(false);
        return slaves;
    }

    override
    string sentinelFailover(string masterName) {
        client.sentinel(Protocol.SENTINEL_FAILOVER, masterName);
        return client.getStatusCodeReply();
    }

    override
    string sentinelMonitor(string masterName, string ip, int port, int quorum) {
        client.sentinel(Protocol.SENTINEL_MONITOR, masterName, ip, string.valueOf(port),
            string.valueOf(quorum));
        return client.getStatusCodeReply();
    }

    override
    string sentinelRemove(string masterName) {
        client.sentinel(Protocol.SENTINEL_REMOVE, masterName);
        return client.getStatusCodeReply();
    }

    override
    string sentinelSet(string masterName, Map!(string, string) parameterMap) {
        int index = 0;
        int paramsLength = parameterMap.size() * 2 + 2;
        string[] params = new string[paramsLength];

        params[index++] = Protocol.SENTINEL_SET;
        params[index++] = masterName;
        foreach(Entry!(string, string) entry ; parameterMap.entrySet()) {
            params[index++] = entry.getKey();
            params[index++] = entry.getValue();
        }

        client.sentinel(params);
        return client.getStatusCodeReply();
    }

    override
    byte[] dump(string key) {
        checkIsInMultiOrPipeline();
        client.dump(key);
        return client.getBinaryBulkReply();
    }
    alias dump = BinaryRedis.dump;

    override
    string restore(string key, int ttl, byte[] serializedValue) {
        checkIsInMultiOrPipeline();
        client.restore(key, ttl, serializedValue);
        return client.getStatusCodeReply();
    }
    alias restore = BinaryRedis.restore;

    override
    string restoreReplace(string key, int ttl, byte[] serializedValue) {
        checkIsInMultiOrPipeline();
        client.restoreReplace(key, ttl, serializedValue);
        return client.getStatusCodeReply();
    }
    alias restoreReplace = BinaryRedis.restoreReplace;

    override
    Long pexpire(string key, long milliseconds) {
        checkIsInMultiOrPipeline();
        client.pexpire(key, milliseconds);
        return client.getIntegerReply();
    }
    alias pexpire = BinaryRedis.pexpire;

    override
    Long pexpireAt(string key, long millisecondsTimestamp) {
        checkIsInMultiOrPipeline();
        client.pexpireAt(key, millisecondsTimestamp);
        return client.getIntegerReply();
    }
    alias pexpireAt = BinaryRedis.pexpireAt;

    override
    Long pttl(string key) {
        checkIsInMultiOrPipeline();
        client.pttl(key);
        return client.getIntegerReply();
    }
    alias pttl = BinaryRedis.pttl;

    /**
     * PSETEX works exactly like {@link #setex(string, int, string)} with the sole difference that the
     * expire time is specified in milliseconds instead of seconds. Time complexity: O(1)
     * @param key
     * @param milliseconds
     * @param value
     * @return Status code reply
     */

    override
    string psetex(string key, long milliseconds, string value) {
        checkIsInMultiOrPipeline();
        client.psetex(key, milliseconds, value);
        return client.getStatusCodeReply();
    }
    alias psetex = BinaryRedis.psetex;

    override
    string clientKill(string ipPort) {
        checkIsInMultiOrPipeline();
        this.client.clientKill(ipPort);
        return this.client.getStatusCodeReply();
    }
    alias clientKill = BinaryRedis.clientKill;

    override
    string clientGetname() {
        checkIsInMultiOrPipeline();
        client.clientGetname();
        return client.getBulkReply();
    }

    override
    string clientList() {
        checkIsInMultiOrPipeline();
        client.clientList();
        return client.getBulkReply();
    }

    override
    string clientSetname(string name) {
        checkIsInMultiOrPipeline();
        client.clientSetname(name);
        return client.getStatusCodeReply();
    }

    override
    string migrate(string host, int port, string key,
            int destinationDb, int timeout) {
        checkIsInMultiOrPipeline();
        client.migrate(host, port, key, destinationDb, timeout);
        return client.getStatusCodeReply();
    }

    override
    string migrate(string host, int port, int destinationDB,
            int timeout, MigrateParams params, string[] keys...) {
        checkIsInMultiOrPipeline();
        client.migrate(host, port, destinationDB, timeout, params, keys);
        return client.getStatusCodeReply();
    }

    override
    ScanResult!(string) scan(string cursor) {
        return scan(cursor, new ScanParams());
    }

    override
    ScanResult!(string) scan(string cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.scan(cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // string newcursor = new string((byte[]) result.get(0));
        // List!(string) results = new ArrayList!(string)();
        // List!(byte[]) rawResults = (List!(byte[])) result.get(1);
        // foreach(byte[] bs ; rawResults) {
        //   results.add(SafeEncoder.encode(bs));
        // }
        // return new ScanResult!(string)(newcursor, results);

        implementationMissing();
        return null;    
    }

    override
    ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor) {
        return hscan(key, cursor, new ScanParams());
    }

    override
    ScanResult!(MapEntry!(string, string)) hscan(string key, string cursor,
            ScanParams params) {
        checkIsInMultiOrPipeline();
        client.hscan(key, cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // string newcursor = new string((byte[]) result.get(0));
        // List!(MapEntry!(string, string)) results = new ArrayList!(MapEntry!(string, string))();
        // List!(byte[]) rawResults = cast(List!(byte[])) result.get(1);
        // Iterator!(byte[]) iterator = rawResults.iterator();
        // while (iterator.hasNext()) {
        //   results.add(new AbstractMap.SimpleEntry!(string, string)(SafeEncoder.encode(iterator.next()),
        //       SafeEncoder.encode(iterator.next())));
        // }
        // return new ScanResult!(MapEntry!(string, string))(newcursor, results);

        implementationMissing();
        return null;
    }

    override
    ScanResult!(string) sscan(string key, string cursor) {
        return sscan(key, cursor, new ScanParams());
    }

    override
    ScanResult!(string) sscan(string key, string cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.sscan(key, cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // string newcursor = new string((byte[]) result.get(0));
        // List!(string) results = new ArrayList!(string)();
        // List!(byte[]) rawResults = (List!(byte[])) result.get(1);
        // foreach(byte[] bs ; rawResults) {
        //   results.add(SafeEncoder.encode(bs));
        // }
        // return new ScanResult!(string)(newcursor, results);
        implementationMissing();
        return null;

    }

    override
    ScanResult!(Tuple) zscan(string key, string cursor) {
        return zscan(key, cursor, new ScanParams());
    }

    override
    ScanResult!(Tuple) zscan(string key, string cursor, ScanParams params) {
        checkIsInMultiOrPipeline();
        client.zscan(key, cursor, params);
        List!(Object) result = client.getObjectMultiBulkReply();
        // string newcursor = new string((byte[]) result.get(0));
        // List!(Tuple) results = new ArrayList!(Tuple)();
        // List!(byte[]) rawResults = (List!(byte[])) result.get(1);
        // Iterator!(byte[]) iterator = rawResults.iterator();
        // while (iterator.hasNext()) {
        //   results.add(new Tuple(iterator.next(), BuilderFactory.DOUBLE.build(iterator.next())));
        // }
        // return new ScanResult!(Tuple)(newcursor, results);
        implementationMissing();
        return null;

    }

    override
    string clusterNodes() {
        checkIsInMultiOrPipeline();
        client.clusterNodes();
        return client.getBulkReply();
    }

    override
    string readonly() {
        client.readonly();
        return client.getStatusCodeReply();
    }

    override
    string clusterMeet(string ip, int port) {
        checkIsInMultiOrPipeline();
        client.clusterMeet(ip, port);
        return client.getStatusCodeReply();
    }

    override
    string clusterReset(ClusterReset resetType) {
        checkIsInMultiOrPipeline();
        client.clusterReset(resetType);
        return client.getStatusCodeReply();
    }

    override
    string clusterAddSlots(int[] slots...) {
        checkIsInMultiOrPipeline();
        client.clusterAddSlots(slots);
        return client.getStatusCodeReply();
    }

    override
    string clusterDelSlots(int[] slots...) {
        checkIsInMultiOrPipeline();
        client.clusterDelSlots(slots);
        return client.getStatusCodeReply();
    }

    override
    string clusterInfo() {
        checkIsInMultiOrPipeline();
        client.clusterInfo();
        return client.getStatusCodeReply();
    }

    override
    List!(string) clusterGetKeysInSlot(int slot, int count) {
        checkIsInMultiOrPipeline();
        client.clusterGetKeysInSlot(slot, count);
        return client.getMultiBulkReply();
    }

    override
    string clusterSetSlotNode(int slot, string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterSetSlotNode(slot, nodeId);
        return client.getStatusCodeReply();
    }

    override
    string clusterSetSlotMigrating(int slot, string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterSetSlotMigrating(slot, nodeId);
        return client.getStatusCodeReply();
    }

    override
    string clusterSetSlotImporting(int slot, string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterSetSlotImporting(slot, nodeId);
        return client.getStatusCodeReply();
    }

    override
    string clusterSetSlotStable(int slot) {
        checkIsInMultiOrPipeline();
        client.clusterSetSlotStable(slot);
        return client.getStatusCodeReply();
    }

    override
    string clusterForget(string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterForget(nodeId);
        return client.getStatusCodeReply();
    }

    override
    string clusterFlushSlots() {
        checkIsInMultiOrPipeline();
        client.clusterFlushSlots();
        return client.getStatusCodeReply();
    }

    override
    Long clusterKeySlot(string key) {
        checkIsInMultiOrPipeline();
        client.clusterKeySlot(key);
        return client.getIntegerReply();
    }

    override
    Long clusterCountKeysInSlot(int slot) {
        checkIsInMultiOrPipeline();
        client.clusterCountKeysInSlot(slot);
        return client.getIntegerReply();
    }

    override
    string clusterSaveConfig() {
        checkIsInMultiOrPipeline();
        client.clusterSaveConfig();
        return client.getStatusCodeReply();
    }

    override
    string clusterReplicate(string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterReplicate(nodeId);
        return client.getStatusCodeReply();
    }

    override
    List!(string) clusterSlaves(string nodeId) {
        checkIsInMultiOrPipeline();
        client.clusterSlaves(nodeId);
        return client.getMultiBulkReply();
    }

    override
    string clusterFailover() {
        checkIsInMultiOrPipeline();
        client.clusterFailover();
        return client.getStatusCodeReply();
    }

    override
    List!(Object) clusterSlots() {
        checkIsInMultiOrPipeline();
        client.clusterSlots();
        return client.getObjectMultiBulkReply();
    }

    string asking() {
        checkIsInMultiOrPipeline();
        client.asking();
        return client.getStatusCodeReply();
    }

    List!(string) pubsubChannels(string pattern) {
        checkIsInMultiOrPipeline();
        client.pubsubChannels(pattern);
        return client.getMultiBulkReply();
    }

    Long pubsubNumPat() {
        checkIsInMultiOrPipeline();
        client.pubsubNumPat();
        return client.getIntegerReply();
    }

    Map!(string, string) pubsubNumSub(string[] channels...) {
        checkIsInMultiOrPipeline();
        client.pubsubNumSub(channels);
        return BuilderFactory.PUBSUB_NUMSUB_MAP.build(client.getBinaryMultiBulkReply());
    }

    override
    void close() {
        if (dataSource !is null) {
            RedisPoolAbstract pool = this.dataSource;
            this.dataSource = null;
            if (client.isBroken()) {
                pool.returnBrokenResource(this);
            } else {
                pool.returnResource(this);
            }
        } else {
            super.close();
        }
    }

    void setDataSource(RedisPoolAbstract jedisPool) {
        this.dataSource = jedisPool;
    }

    override
    Long pfadd(string key, string[] elements...) {
        checkIsInMultiOrPipeline();
        client.pfadd(key, elements);
        return client.getIntegerReply();
    }

    override
    long pfcount(string key) {
        checkIsInMultiOrPipeline();
        client.pfcount(key);
        return client.getIntegerReply();
    }

    override
    long pfcount(string[] keys...) {
        checkIsInMultiOrPipeline();
        client.pfcount(keys);
        return client.getIntegerReply();
    }

    override
    string pfmerge(string destkey, string[] sourcekeys...) {
        checkIsInMultiOrPipeline();
        client.pfmerge(destkey, sourcekeys);
        return client.getStatusCodeReply();
    }

    override
    List!(string) blpop(int timeout, string key) {
        return blpop(key, string.valueOf(timeout));
    }

    override
    List!(string) brpop(int timeout, string key) {
        return brpop(key, string.valueOf(timeout));
    }

    override
    Long geoadd(string key, double longitude, double latitude, string member) {
        checkIsInMultiOrPipeline();
        client.geoadd(key, longitude, latitude, member);
        return client.getIntegerReply();
    }

    override
    Long geoadd(string key, Map!(string, GeoCoordinate) memberCoordinateMap) {
        checkIsInMultiOrPipeline();
        client.geoadd(key, memberCoordinateMap);
        return client.getIntegerReply();
    }

    override
    Double geodist(string key, string member1, string member2) {
        checkIsInMultiOrPipeline();
        client.geodist(key, member1, member2);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    override
    Double geodist(string key, string member1, string member2, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.geodist(key, member1, member2, unit);
        string dval = client.getBulkReply();
        return (dval !is null ? new Double(dval) : null);
    }

    override
    List!(string) geohash(string key, string[] members...) {
        checkIsInMultiOrPipeline();
        client.geohash(key, members);
        return client.getMultiBulkReply();
    }

    override
    List!(GeoCoordinate) geopos(string key, string[] members...) {
        checkIsInMultiOrPipeline();
        client.geopos(key, members);
        return BuilderFactory.GEO_COORDINATE_LIST.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude,
            double radius, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadius(key, longitude, latitude, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude,
            double radius, GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusReadonly(key, longitude, latitude, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadius(string key, double longitude, double latitude,
            double radius, GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadius(key, longitude, latitude, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusReadonly(string key, double longitude, double latitude,
            double radius, GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusReadonly(key, longitude, latitude, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius,
            GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusByMember(key, member, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius,
            GeoUnit unit) {
        checkIsInMultiOrPipeline();
        client.georadiusByMemberReadonly(key, member, radius, unit);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusByMember(string key, string member, double radius,
            GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusByMember(key, member, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    List!(GeoRadiusResponse) georadiusByMemberReadonly(string key, string member, double radius,
            GeoUnit unit, GeoRadiusParam param) {
        checkIsInMultiOrPipeline();
        client.georadiusByMemberReadonly(key, member, radius, unit, param);
        return BuilderFactory.GEORADIUS_WITH_PARAMS_RESULT.build(client.getObjectMultiBulkReply());
    }

    override
    string moduleLoad(string path) {
        client.moduleLoad(path);
        return client.getStatusCodeReply();
    }

    override
    string moduleUnload(string name) {
        client.moduleUnload(name);
        return client.getStatusCodeReply();
    }

    override
    List!(Module) moduleList() {
        client.moduleList();
        return BuilderFactory.MODULE_LIST.build(client.getObjectMultiBulkReply());
    }

    override
    List!(Long) bitfield(string key, string[] arguments...) {
        checkIsInMultiOrPipeline();
        client.bitfield(key, arguments);
        return client.getIntegerMultiBulkReply();
    }

    override
    Long hstrlen(string key, string field) {
        checkIsInMultiOrPipeline();
        client.hstrlen(key, field);
        return client.getIntegerReply();
    }

    override
    string memoryDoctor() {
        checkIsInMultiOrPipeline();
        client.memoryDoctor();
        return client.getBulkReply();
    }
            
    override
    StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash) {
        return xadd(key, id, hash, Long.MAX_VALUE, false);
    }
    
    override
    StreamEntryID xadd(string key, StreamEntryID id, Map!(string, string) hash, long maxLen, bool approximateLength) {
        checkIsInMultiOrPipeline();
        client.xadd(key, id, hash, maxLen, approximateLength);
        string result = client.getBulkReply();
        return new StreamEntryID(result);
    }

    override
    Long xlen(string key) {
        checkIsInMultiOrPipeline();
        client.xlen(key);
        return client.getIntegerReply();
    }

    /**
     * {@inheritDoc}
     */
    override
    List!(StreamEntry) xrange(string key, StreamEntryID start, StreamEntryID end, int count) {
        checkIsInMultiOrPipeline();
        client.xrange(key, start, end, count);
        return BuilderFactory.STREAM_ENTRY_LIST.build(client.getObjectMultiBulkReply());
    }
    
    /**
     * {@inheritDoc}
     */
    override
    List!(StreamEntry) xrevrange(string key, StreamEntryID end, StreamEntryID start, int count) {
        checkIsInMultiOrPipeline();
        client.xrevrange(key, end, start, count);
        return BuilderFactory.STREAM_ENTRY_LIST.build(client.getObjectMultiBulkReply());
    }


    /**
     * {@inheritDoc}
     */
    override
    List!(MapEntry!(string, List!(StreamEntry))) xread(int count, long block, MapEntry!(string, StreamEntryID)[] streams...) {
        checkIsInMultiOrPipeline();
        client.xread(count, block, streams);
        client.setTimeoutInfinite();
        
        try {
            List!(Object) streamsEntries = client.getObjectMultiBulkReply();
            if(streamsEntries is null) {
                return new ArrayList!(Entry!(string, List!(StreamEntry)))();
            }
            
            List!(Entry!(string, List!(StreamEntry))) result = 
                new ArrayList!(Entry!(string, List!(StreamEntry)))(streamsEntries.size());

            // foreach(Object streamObj ; streamsEntries) {
            //   List!(Object) stream = cast(List!(Object))streamObj;
            //   string streamId = SafeEncoder.encode((byte[])stream.get(0));
            //   List!(StreamEntry) streamEntries = BuilderFactory.STREAM_ENTRY_LIST.build(stream.get(1));
            //   result.add(new AbstractMap.SimpleEntry!(string, List!(StreamEntry))(streamId, streamEntries));
            // }
            implementationMissing(false);      
            return result;
        } finally {
            client.rollbackTimeout();
        }
    }

    /**
     * {@inheritDoc}
     */
    override
    long xack(string key, string group, StreamEntryID[] ids...) {
        checkIsInMultiOrPipeline();
        client.xack(key, group, ids);
        return client.getIntegerReply();
    }

    override
    string xgroupCreate(string key, string groupname, StreamEntryID id, bool makeStream) {
        checkIsInMultiOrPipeline();
        client.xgroupCreate(key, groupname, id, makeStream);
        return client.getStatusCodeReply();
    }

    override
    string xgroupSetID(string key, string groupname, StreamEntryID id) {
        checkIsInMultiOrPipeline();
        client.xgroupSetID(key, groupname, id);
        return client.getStatusCodeReply();
    }

    override
    long xgroupDestroy(string key, string groupname) {
        checkIsInMultiOrPipeline();
        client.xgroupDestroy(key, groupname);
        return client.getIntegerReply();
    }

    override
    string xgroupDelConsumer(string key, string groupname, string consumerName) {
        checkIsInMultiOrPipeline();
        client.xgroupDelConsumer(key, groupname, consumerName);
        return client.getStatusCodeReply();
    }

    override
    long xdel(string key, StreamEntryID[] ids...) {
        checkIsInMultiOrPipeline();
        client.xdel(key, ids);
        return client.getIntegerReply();
    }

    override
    long xtrim(string key, long maxLen, bool approximateLength) {
        checkIsInMultiOrPipeline();
        client.xtrim(key, maxLen, approximateLength);
        return client.getIntegerReply();
    }

    /**
     * {@inheritDoc}
     */
    override
    List!(MapEntry!(string, List!(StreamEntry))) xreadGroup(string groupname, string consumer, int count, long block,
            bool noAck, MapEntry!(string, StreamEntryID)[] streams...) {
        checkIsInMultiOrPipeline();
        client.xreadGroup(groupname, consumer, count, block, noAck, streams);

        List!(Object) streamsEntries = client.getObjectMultiBulkReply();
        if(streamsEntries is null) {
            return null;
        }
        
        List!(Entry!(string, List!(StreamEntry))) result = 
            new ArrayList!(Entry!(string, List!(StreamEntry)))(streamsEntries.size());

        // foreach(Object streamObj ; streamsEntries) {
        //   List!(Object) stream = (List!(Object))streamObj;
        //   string streamId = SafeEncoder.encode((byte[])stream.get(0));
        //   List!(StreamEntry) streamEntries = BuilderFactory.STREAM_ENTRY_LIST.build(stream.get(1));
        //   result.add(new AbstractMap.SimpleEntry!(string, List!(StreamEntry))(streamId, streamEntries));
        // }
        implementationMissing(false);
        return result;
    }

    override
    List!(StreamPendingEntry) xpending(string key, string groupname, StreamEntryID start, StreamEntryID end,
            int count, string consumername) {
        checkIsInMultiOrPipeline();
        client.xpending(key, groupname, start, end, count, consumername);

        // TODO handle consumername == NULL case
        
        return BuilderFactory.STREAM_PENDING_ENTRY_LIST.build(client.getObjectMultiBulkReply());
    }

    override
    List!(StreamEntry) xclaim(string key, string group, string consumername, long minIdleTime, long newIdleTime,
            int retries, bool force, StreamEntryID[] ids...) {
        
        checkIsInMultiOrPipeline();
        client.xclaim( key, group, consumername, minIdleTime, newIdleTime, retries, force, ids);
        
        return BuilderFactory.STREAM_ENTRY_LIST.build(client.getObjectMultiBulkReply());
    }

    override
    Object sendCommand(ProtocolCommand cmd, string[] args...) {
        client.sendCommand(cmd, args);
        return client.getOne();
    }
}
