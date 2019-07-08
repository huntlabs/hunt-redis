module hunt.redis.params.ZAddParams;

import hunt.redis.util.SafeEncoder;

import hunt.collection.ArraryList;

class ZAddParams : Params {

  private enum string XX = "xx";
  private enum string NX = "nx";
  private enum string CH = "ch";

  this() {
  }

  static ZAddParams zAddParams() {
    return new ZAddParams();
  }

  /**
   * Only set the key if it does not already exist.
   * @return ZAddParams
   */
  ZAddParams nx() {
    addParam(NX);
    return this;
  }

  /**
   * Only set the key if it already exist.
   * @return ZAddParams
   */
  ZAddParams xx() {
    addParam(XX);
    return this;
  }

  /**
   * Modify the return value from the number of new elements added to the total number of elements
   * changed
   * @return ZAddParams
   */
  ZAddParams ch() {
    addParam(CH);
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
    if (contains(CH)) {
      byteParams.add(SafeEncoder.encode(CH));
    }

    foreach(byte[] arg ; args) {
      byteParams.add(arg);
    }

    return byteParams.toArray(new byte[byteParams.size()][]);
  }

}
