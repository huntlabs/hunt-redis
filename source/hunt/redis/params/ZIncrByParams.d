module hunt.redis.params.ZIncrByParams;

import hunt.redis.params.Params;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;

/**
 * Parameters for ZINCRBY commands <br/>
 * <br/>
 * In fact, Redis doesn't have parameters for ZINCRBY. Instead Redis has INCR parameter for ZADD.<br/>
 * When users call ZADD with INCR option, its restriction (only one member) and return type is same
 * to ZINCRBY. <br/>
 * Document page for ZADD also describes INCR option to act like ZINCRBY. <br/>
 * http://redis.io/commands/zadd <br/>
 * <br/>
 * So we decided to wrap "ZADD with INCR option" to ZINCRBY. <br/>
 * https://github.com/xetorthio/jedis/issues/1067 <br/>
 * <br/>
 * Works with Redis 3.0.2 and onwards.
 */
class ZIncrByParams : Params {

  private enum string XX = "xx";
  private enum string NX = "nx";
  private enum string INCR = "incr";

  this() {
  }

  static ZIncrByParams zIncrByParams() {
    return new ZIncrByParams();
  }

  /**
   * Only set the key if it does not already exist.
   * @return ZIncrByParams
   */
  ZIncrByParams nx() {
    addParam(NX);
    return this;
  }

  /**
   * Only set the key if it already exist.
   * @return ZIncrByParams
   */
  ZIncrByParams xx() {
    addParam(XX);
    return this;
  }

  byte[][] getByteParams(byte[] key, byte[] args...) {
    ArrayList!(byte[]) byteParams = new ArrayList!(byte[])();
    byteParams.add(key);

    if (contains(NX)) {
      byteParams.add(SafeEncoder.encode(NX));
    }
    if (contains(XX)) {
      byteParams.add(SafeEncoder.encode(XX));
    }

    byteParams.add(SafeEncoder.encode(INCR));

    foreach(byte[] arg ; args) {
      byteParams.add(arg);
    }

    return byteParams.toArray(new byte[byteParams.size()][]);
  }

}
