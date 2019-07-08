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

  private Map!(Keyword, ByteBuffer) params = new EnumMap!(Keyword, ByteBuffer)(Keyword.class);

  static string SCAN_POINTER_START = string.valueOf(0);
  static byte[] SCAN_POINTER_START_BINARY = SafeEncoder.encode(SCAN_POINTER_START);

  ScanParams match(byte[] pattern) {
    params.put(MATCH, ByteBuffer.wrap(pattern));
    return this;
  }

  /**
   * @see <a href="https://redis.io/commands/scan#the-match-option">MATCH option in Redis documentation</a>
   * 
   * @param pattern
   * @return 
   */
  ScanParams match(string pattern) {
    params.put(MATCH, ByteBuffer.wrap(SafeEncoder.encode(pattern)));
    return this;
  }

  /**
   * @see <a href="https://redis.io/commands/scan#the-count-option">COUNT option in Redis documentation</a>
   * 
   * @param count
   * @return 
   */
  ScanParams count(Integer count) {
    params.put(COUNT, ByteBuffer.wrap(Protocol.toByteArray(count)));
    return this;
  }

  Collection!(byte[]) getParams() {
    List!(byte[]) paramsList = new ArrayList!(byte[])(params.size());
    foreach(MapEntry!(Keyword, ByteBuffer) param ; params.entrySet()) {
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

  string match() {
    if (params.containsKey(MATCH)) {
      return new string(params.get(MATCH).array());
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
