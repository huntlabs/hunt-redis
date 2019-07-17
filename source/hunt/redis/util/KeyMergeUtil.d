module hunt.redis.util.KeyMergeUtil;

import hunt.Exceptions;

class KeyMergeUtil {
  private this(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static string[] merge(string destKey, string[] keys) {
    string[] mergedKeys = new string[keys.length + 1];
    mergedKeys[0] = destKey;
    // System.arraycopy(keys, 0, mergedKeys, 1, keys.length);
    size_t len = keys.length;
    mergedKeys[1 .. 1+len] = keys[0 .. $];
    return mergedKeys;
  }

  static byte[][] merge(byte[] destKey, byte[][] keys) {
    byte[][] mergedKeys = new byte[][keys.length + 1];
    mergedKeys[0] = destKey;
    // System.arraycopy(keys, 0, mergedKeys, 1, keys.length);
    size_t len = keys.length;
    mergedKeys[1 .. 1+len] = keys[0 .. $];
    return mergedKeys;
  }
}