module hunt.redis.util.RedisClusterHashTagUtil;

/**
 * Holds various methods/utilities to manipualte and parse redis hash-tags. See <a
 * href="http://redis.io/topics/cluster-spec">Cluster-Spec : Keys hash tags</a>
 */
final class RedisClusterHashTagUtil {

  private RedisClusterHashTagUtil() {
    throw new InstantiationError("Must not instantiate this class");
  }

  static String getHashTag(String key) {
    return extractHashTag(key, true);
  }

  static bool isClusterCompliantMatchPattern(byte[] matchPattern) {
    return isClusterCompliantMatchPattern(SafeEncoder.encode(matchPattern));
  }

  static bool isClusterCompliantMatchPattern(String matchPattern) {
    String tag = extractHashTag(matchPattern, false);
    return tag != null && !tag.isEmpty();
  }

  private static String extractHashTag(String key, bool returnKeyOnAbsence) {
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
