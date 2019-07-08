module hunt.redis.ScanParams;

import hunt.redis.Protocol.Keyword.COUNT;
import hunt.redis.Protocol.Keyword.MATCH;

import hunt.redis.Protocol.Keyword;

import hunt.collection.ByteBuffer;
import hunt.collection.ArraryList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import java.util.EnumMap;
import hunt.collection.List;
import hunt.collection.Map;

import hunt.redis.util.SafeEncoder;

class ScanParams {

  private final Map!(Keyword, ByteBuffer) params = new EnumMap!(Keyword, ByteBuffer)(Keyword.class);

  final static String SCAN_POINTER_START = String.valueOf(0);
  final static byte[] SCAN_POINTER_START_BINARY = SafeEncoder.encode(SCAN_POINTER_START);

  ScanParams match(final byte[] pattern) {
    params.put(MATCH, ByteBuffer.wrap(pattern));
    return this;
  }

  /**
   * @see <a href="https://redis.io/commands/scan#the-match-option">MATCH option in Redis documentation</a>
   * 
   * @param pattern
   * @return 
   */
  ScanParams match(final String pattern) {
    params.put(MATCH, ByteBuffer.wrap(SafeEncoder.encode(pattern)));
    return this;
  }

  /**
   * @see <a href="https://redis.io/commands/scan#the-count-option">COUNT option in Redis documentation</a>
   * 
   * @param count
   * @return 
   */
  ScanParams count(final Integer count) {
    params.put(COUNT, ByteBuffer.wrap(Protocol.toByteArray(count)));
    return this;
  }

  Collection!(byte[]) getParams() {
    List!(byte[]) paramsList = new ArrayList!(byte[])(params.size());
    foreach(Map.Entry!(Keyword, ByteBuffer) param ; params.entrySet()) {
      paramsList.add(param.getKey().raw);
      paramsList.add(param.getValue().array());
    }
    return Collections.unmodifiableCollection(paramsList);
  }

  byte[] binaryMatch() {
    if (params.containsKey(MATCH)) {
      return params.get(MATCH).array();
    } else {
      return null;
    }
  }

  String match() {
    if (params.containsKey(MATCH)) {
      return new String(params.get(MATCH).array());
    } else {
      return null;
    }
  }

  Integer count() {
    if (params.containsKey(COUNT)) {
      return params.get(COUNT).getInt();
    } else {
      return null;
    }
  }
}
