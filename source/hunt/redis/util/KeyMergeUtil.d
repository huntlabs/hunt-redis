module hunt.redis.util.KeyMergeUtil;

class KeyMergeUtil {
  private KeyMergeUtil(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static string[] merge(string destKey, string[] keys) {
    string[] mergedKeys = new string[keys.length + 1];
    mergedKeys[0] = destKey;
    System.arraycopy(keys, 0, mergedKeys, 1, keys.length);
    return mergedKeys;
  }

  static byte[][] merge(byte[] destKey, byte[][] keys) {
    byte[][] mergedKeys = new byte[keys.length + 1][];
    mergedKeys[0] = destKey;
    System.arraycopy(keys, 0, mergedKeys, 1, keys.length);
    return mergedKeys;
  }
}