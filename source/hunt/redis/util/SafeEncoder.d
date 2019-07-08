module hunt.redis.util.SafeEncoder;

import java.io.UnsupportedEncodingException;

import hunt.redis.Protocol;
import hunt.redis.exceptions.RedisDataException;
import hunt.redis.exceptions.RedisException;

/**
 * The only reason to have this is to be able to compatible with java 1.5 :(
 */
final class SafeEncoder {
  private SafeEncoder(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static byte[][] encodeMany(final String strs...) {
    byte[][] many = new byte[strs.length][];
    for (int i = 0; i < strs.length; i++) {
      many[i] = encode(strs[i]);
    }
    return many;
  }

  static byte[] encode(final String str) {
    try {
      if (str == null) {
        throw new RedisDataException("value sent to redis cannot be null");
      }
      return str.getBytes(Protocol.CHARSET);
    } catch (UnsupportedEncodingException e) {
      throw new RedisException(e);
    }
  }

  static String encode(final byte[] data) {
    try {
      return new String(data, Protocol.CHARSET);
    } catch (UnsupportedEncodingException e) {
      throw new RedisException(e);
    }
  }
}
