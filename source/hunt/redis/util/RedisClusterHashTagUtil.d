module hunt.redis.util.RedisClusterHashTagUtil;

/**
 * Holds various methods/utilities to manipualte and parse redis hash-tags. See <a
 * href="http://redis.io/topics/cluster-spec">Cluster-Spec : Keys hash tags</a>
 */
class RedisClusterHashTagUtil {

  private RedisClusterHashTagUtil() {
    throw new InstantiationError("Must not instantiate this class");
  }

  static string getHashTag(string key) {
    return extractHashTag(key, true);
  }

  static bool isClusterCompliantMatchPattern(byte[] matchPattern) {
    return isClusterCompliantMatchPattern(SafeEncoder.encode(matchPattern));
  }

  static bool isClusterCompliantMatchPattern(string matchPattern) {
    string tag = extractHashTag(matchPattern, false);
    return tag !is null && !tag.isEmpty();
  }

  private static string extractHashTag(string key, bool returnKeyOnAbsence) {
    int s = key.indexOf("{");
    if (s > -1) {
      int e = key.indexOf("}", s + 1);
      if (e > -1 && e != s + 1) {
        return key.substring(s + 1, e);
      }
    }
    return returnKeyOnAbsence ? key : null;
  }
}
