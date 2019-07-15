module hunt.redis.commands.MultiKeyCommands;

import hunt.redis.BitOP;
import hunt.redis.StreamEntryID;
import hunt.redis.RedisPubSub;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.SortingParams;
import hunt.redis.StreamEntry;
import hunt.redis.ZParams;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.Long;

interface MultiKeyCommands {
  Long del(string[] keys...);

  Long unlink(string[] keys...);

  Long exists(string[] keys...);

  List!(string) blpop(int timeout, string[] keys...);

  List!(string) brpop(int timeout, string[] keys...);

  List!(string) blpop(string[] args...);

  List!(string) brpop(string[] args...);

  /**
   * Returns all the keys matching the glob-style pattern. For example if
   * you have in the database the keys "foo" and "foobar" the command "KEYS foo*" will return
   * "foo foobar".<br>
   * <strong>Warning:</strong> consider this as a command that should be used in production environments with <strong>extreme care</strong>.
   * It may ruin performance when it is executed against large databases.
   * This command is intended for debugging and special operations, such as changing your keyspace layout.
   * <strong>Don't use it in your regular application code.</strong>
   * If you're looking for a way to find keys in a subset of your keyspace, consider using {@link #scan(string, ScanParams)} or sets.
   * <p>
   * While the time complexity for this operation is O(N), the constant times are fairly low.
   * For example, Redis running on an entry level laptop can scan a 1 million key database in 40 milliseconds.
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
   * @see <a href="https://redis.io/commands/keys">Redis KEYS documentation</a>
   */
  Set!(string) keys(string pattern);

  List!(string) mget(string[] keys...);

  string mset(string[] keysvalues...);

  Long msetnx(string[] keysvalues...);

  string rename(string oldkey, string newkey);

  Long renamenx(string oldkey, string newkey);

  string rpoplpush(string srckey, string dstkey);

  Set!(string) sdiff(string[] keys...);

  Long sdiffstore(string dstkey, string[] keys...);

  Set!(string) sinter(string[] keys...);

  Long sinterstore(string dstkey, string[] keys...);

  Long smove(string srckey, string dstkey, string member);

  Long sort(string key, SortingParams sortingParameters, string dstkey);

  Long sort(string key, string dstkey);

  Set!(string) sunion(string[] keys...);

  Long sunionstore(string dstkey, string[] keys...);

  string watch(string[] keys...);

  string unwatch();

  Long zinterstore(string dstkey, string[] sets...);

  Long zinterstore(string dstkey, ZParams params, string[] sets...);

  Long zunionstore(string dstkey, string[] sets...);

  Long zunionstore(string dstkey, ZParams params, string[] sets...);

  string brpoplpush(string source, string destination, int timeout);

  Long publish(string channel, string message);

  void subscribe(RedisPubSub jedisPubSub, string[] channels...);

  void psubscribe(RedisPubSub jedisPubSub, string[] patterns...);

  string randomKey();

  Long bitop(BitOP op, string destKey, string[] srcKeys...);

  /**
   * @see #scan(string, ScanParams)
   * 
   * @param cursor
   * @return 
   */
  ScanResult!(string) scan(string cursor);

  /**
   * Iterates the set of keys in the currently selected Redis database.
   * <p>
   * Since this command allows for incremental iteration, returning only a small number of elements per call,
   * it can be used in production without the downside of commands like {@link #keys(string)} or
   * {@link RedisCommands#smembers(string)} )} that may block the server for a long time (even several seconds)
   * when called against big collections of keys or elements.
   * <p>
   * SCAN basic usage!(br)
   * SCAN is a cursor based iterator. This means that at every call of the command, the server returns an updated cursor
   * that the user needs to use as the cursor argument in the next call.
   * An iteration starts when the cursor is set to 0, and terminates when the cursor returned by the server is 0.
   * <p>
   * Scan guarantees!(br)
   * The SCAN command, and the other commands in the SCAN family, are able to provide to the user a set of guarantees
   * associated to full iterations.
   * <ul>
   * <li>A full iteration always retrieves all the elements that were present in the collection from the start to the
   * end of a full iteration. This means that if a given element is inside the collection when an iteration is started,
   * and is still there when an iteration terminates, then at some point SCAN returned it to the user.
   * <li>A full iteration never returns any element that was NOT present in the collection from the start to the end of
   * a full iteration. So if an element was removed before the start of an iteration, and is never added back to the
   * collection for all the time an iteration lasts, SCAN ensures that this element will never be returned.
   * </ul>
   * However because SCAN has very little state associated (just the cursor) it has the following drawbacks:
   * <ul>
   * <li>A given element may be returned multiple times. It is up to the application to handle the case of duplicated
   * elements, for example only using the returned elements in order to perform operations that are safe when re-applied
   * multiple times.
   * <li>Elements that were not constantly present in the collection during a full iteration, may be returned or not:
   * it is undefined.
   * </ul>
   * <p>
   * Time complexity: O(1) for every call. O(N) for a complete iteration, including enough command calls for the cursor
   * to return back to 0. N is the number of elements inside the DB.
   *
   * @param cursor The cursor.
   * @param params the scan parameters. For example a glob-style match pattern
   * @return the scan result with the results of this iteration and the new position of the cursor
   * @see <a href="https://redis.io/commands/scan">Redis SCAN documentation</a>
   */
  ScanResult!(string) scan(string cursor, ScanParams params);

  string pfmerge(string destkey, string[] sourcekeys...);

  long pfcount(string[] keys...);

  Long touch(string[] keys...);
  
  /**
   * XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] ID [ID ...]
   * 
   * @param key
   * @param count
   * @param block
   * @param streams
   * @return
   */
  List!(MapEntry!(string, List!(StreamEntry))) xread(int count, long block, MapEntry!(string, StreamEntryID)[] streams...);

  /**
   * XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] ID [ID ...]
   * 
   * @param key
   * @param groupname
   * @param cosumer
   * @param count
   * @param block
   * @param streams
   * @return
   */
  List!(MapEntry!(string, List!(StreamEntry))) xreadGroup(string groupname, string consumer, int count, 
        long block, bool noAck, MapEntry!(string, StreamEntryID)[] streams...);
}
