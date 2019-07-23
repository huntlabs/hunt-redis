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
 
module hunt.redis.util.Sharded;

import hunt.redis.util.Hashing;
import hunt.redis.util.ShardInfo;

import hunt.collection;
import hunt.Long;

import std.conv;
import std.regex;

alias Pattern = Regex!char;

enum int DEFAULT_WEIGHT = 1;
  // the tag is anything between {}
enum DEFAULT_KEY_TAG_PATTERN = ctRegex!("\\{(.+?)\\}");

class Sharded(R, S) if(is(S : ShardInfo!(R))) {

  private TreeMap!(Long, S) nodes;
  private Hashing algo;
  private Map!(ShardInfo!(R), R) resources;

  /**
   * The default pattern used for extracting a key tag. The pattern must have a group (between
   * parenthesis), which delimits the tag to be hashed. A null pattern avoids applying the regular
   * expression for each lookup, improving performance a little bit is key tags aren't being used.
   */
  private Regex!char tagPattern;

  this(List!(S) shards) {
    this(shards, Hashing.MURMUR_HASH); // MD5 is really not good as we works
    // with 64-bits not 128
  }

  this(List!(S) shards, Hashing algo) {
    this.algo = algo;
    initialize(shards);
  }

  this(List!(S) shards, Pattern tagPattern) {
    this(shards, Hashing.MURMUR_HASH, tagPattern); // MD5 is really not good
    // as we works with
    // 64-bits not 128
  }

  this(List!(S) shards, Hashing algo, Pattern tagPattern) {
    this.algo = algo;
    this.tagPattern = tagPattern;
    initialize(shards);
  }

  private void initialize(List!(S) shards) {
    resources = new LinkedHashMap!(ShardInfo!(R), R)();
    nodes = new TreeMap!(Long, S)();

    for (int i = 0; i != shards.size(); ++i) {
      S shardInfo = shards.get(i);
      if (shardInfo.getName() is null) for (int n = 0; n < 160 * shardInfo.getWeight(); n++) {
        long v = this.algo.hash("SHARD-" ~ i.to!string() ~ "-NODE-" ~ n.to!string());
        nodes.put(new Long(v), shardInfo);
      } else {
         for (int n = 0; n < 160 * shardInfo.getWeight(); n++) {
           long v = this.algo.hash(shardInfo.getName() ~ "*" ~ n.to!string());
          nodes.put(new Long(v), shardInfo);
        }
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
