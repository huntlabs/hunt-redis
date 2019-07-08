module hunt.redis.util.Sharded;

import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.LInkedHashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.SortedMap;
import hunt.collection.TreeMap;

import std.regex;

class Sharded!(R, S extends ShardInfo!(R)) {

  enum int DEFAULT_WEIGHT = 1;
  private TreeMap!(Long, S) nodes;
  private Hashing algo;
  private Map!(ShardInfo!(R), R) resources = new LinkedHashMap!(ShardInfo!(R), R)();

  /**
   * The default pattern used for extracting a key tag. The pattern must have a group (between
   * parenthesis), which delimits the tag to be hashed. A null pattern avoids applying the regular
   * expression for each lookup, improving performance a little bit is key tags aren't being used.
   */
  private Pattern tagPattern = null;
  // the tag is anything between {}
  static Pattern DEFAULT_KEY_TAG_PATTERN = Pattern.compile("\\{(.+?)\\}");

  Sharded(List!(S) shards) {
    this(shards, Hashing.MURMUR_HASH); // MD5 is really not good as we works
    // with 64-bits not 128
  }

  Sharded(List!(S) shards, Hashing algo) {
    this.algo = algo;
    initialize(shards);
  }

  Sharded(List!(S) shards, Pattern tagPattern) {
    this(shards, Hashing.MURMUR_HASH, tagPattern); // MD5 is really not good
    // as we works with
    // 64-bits not 128
  }

  Sharded(List!(S) shards, Hashing algo, Pattern tagPattern) {
    this.algo = algo;
    this.tagPattern = tagPattern;
    initialize(shards);
  }

  private void initialize(List!(S) shards) {
    nodes = new TreeMap!(Long, S)();

    for (int i = 0; i != shards.size(); ++i) {
      S shardInfo = shards.get(i);
      if (shardInfo.getName() is null) for (int n = 0; n < 160 * shardInfo.getWeight(); n++) {
        nodes.put(this.algo.hash("SHARD-" ~ i ~ "-NODE-" ~ n), shardInfo);
      }
      else for (int n = 0; n < 160 * shardInfo.getWeight(); n++) {
        nodes.put(this.algo.hash(shardInfo.getName() ~ "*" ~ n), shardInfo);
      }
      resources.put(shardInfo, shardInfo.createResource());
    }
  }

  R getShard(byte[] key) {
    return resources.get(getShardInfo(key));
  }

  R getShard(string key) {
    return resources.get(getShardInfo(key));
  }

  S getShardInfo(byte[] key) {
    SortedMap!(Long, S) tail = nodes.tailMap(algo.hash(key));
    if (tail.isEmpty()) {
      return nodes.get(nodes.firstKey());
    }
    return tail.get(tail.firstKey());
  }

  S getShardInfo(string key) {
    return getShardInfo(SafeEncoder.encode(getKeyTag(key)));
  }

  /**
   * A key tag is a special pattern inside a key that, if preset, is the only part of the key hashed
   * in order to select the server for this key.
   * @see <a href="http://redis.io/topics/partitioning">partitioning</a>
   * @param key
   * @return The tag if it exists, or the original key
   */
  string getKeyTag(string key) {
    if (tagPattern !is null) {
      Matcher m = tagPattern.matcher(key);
      if (m.find()) return m.group(1);
    }
    return key;
  }

  Collection!(S) getAllShardInfo() {
    return Collections.unmodifiableCollection(nodes.values());
  }

  Collection!(R) getAllShards() {
    return Collections.unmodifiableCollection(resources.values());
  }
}
