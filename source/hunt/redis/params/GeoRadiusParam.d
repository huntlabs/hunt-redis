module hunt.redis.params.GeoRadiusParam;

import hunt.redis.Protocol;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArraryList;

class GeoRadiusParam : Params {
  private enum string WITHCOORD = "withcoord";
  private enum string WITHDIST = "withdist";

  // Do not add WITHHASH since we can't classify result of WITHHASH and WITHDIST,
  // and WITHHASH is for debugging purposes

  private enum string ASC = "asc";
  private enum string DESC = "desc";
  private enum string COUNT = "count";

  this() {
  }

  static GeoRadiusParam geoRadiusParam() {
    return new GeoRadiusParam();
  }

  GeoRadiusParam withCoord() {
    addParam(WITHCOORD);
    return this;
  }

  GeoRadiusParam withDist() {
    addParam(WITHDIST);
    return this;
  }

  GeoRadiusParam sortAscending() {
    addParam(ASC);
    return this;
  }

  GeoRadiusParam sortDescending() {
    addParam(DESC);
    return this;
  }

  GeoRadiusParam count(int count) {
    if (count > 0) {
      addParam(COUNT, count);
    }
    return this;
  }

  byte[][] getByteParams(byte[] args...) {
    ArrayList!(byte[]) byteParams = new ArrayList!(byte[])();
    foreach(byte[] arg ; args) {
      byteParams.add(arg);
    }

    if (contains(WITHCOORD)) {
      byteParams.add(SafeEncoder.encode(WITHCOORD));
    }
    if (contains(WITHDIST)) {
      byteParams.add(SafeEncoder.encode(WITHDIST));
    }

    if (contains(COUNT)) {
      byteParams.add(SafeEncoder.encode(COUNT));
      byteParams.add(Protocol.toByteArray(cast(Integer) getParam(COUNT)));
    }

    if (contains(ASC)) {
      byteParams.add(SafeEncoder.encode(ASC));
    } else if (contains(DESC)) {
      byteParams.add(SafeEncoder.encode(DESC));
    }

    return byteParams.toArray(new byte[byteParams.size()][]);
  }
}
