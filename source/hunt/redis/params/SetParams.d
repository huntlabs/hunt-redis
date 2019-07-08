module hunt.redis.params.SetParams;

import hunt.collection.ArraryList;

import hunt.redis.util.SafeEncoder;

public class SetParams : Params {

  private enum string XX = "xx";
  private enum string NX = "nx";
  private enum string PX = "px";
  private enum string EX = "ex";

  public SetParams() {
  }

  public static SetParams setParams() {
    return new SetParams();
  }

  /**
   * Set the specified expire time, in seconds.
   * @param secondsToExpire
   * @return SetParams
   */
  public SetParams ex(int secondsToExpire) {
    addParam(EX, secondsToExpire);
    return this;
  }

  /**
   * Set the specified expire time, in milliseconds.
   * @param millisecondsToExpire
   * @return SetParams
   */
  public SetParams px(long millisecondsToExpire) {
    addParam(PX, millisecondsToExpire);
    return this;
  }

  /**
   * Only set the key if it does not already exist.
   * @return SetParams
   */
  public SetParams nx() {
    addParam(NX);
    return this;
  }

  /**
   * Only set the key if it already exist.
   * @return SetParams
   */
  public SetParams xx() {
    addParam(XX);
    return this;
  }

  public byte[][] getByteParams(byte[]... args) {
    ArrayList!(byte[]) byteParams = new ArrayList!(byte[])();
    for (byte[] arg : args) {
      byteParams.add(arg);
    }

    if (contains(NX)) {
      byteParams.add(SafeEncoder.encode(NX));
    }
    if (contains(XX)) {
      byteParams.add(SafeEncoder.encode(XX));
    }

    if (contains(EX)) {
      byteParams.add(SafeEncoder.encode(EX));
      byteParams.add(SafeEncoder.encode(String.valueOf(getParam(EX))));
    }
    if (contains(PX)) {
      byteParams.add(SafeEncoder.encode(PX));
      byteParams.add(SafeEncoder.encode(String.valueOf(getParam(PX))));
    }

    return byteParams.toArray(new byte[byteParams.size()][]);
  }

}
