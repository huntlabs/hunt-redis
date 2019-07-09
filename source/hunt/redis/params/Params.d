module hunt.redis.params.Params;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;

import hunt.redis.util.SafeEncoder;

import std.array;

abstract class Params {

  private Map!(string, Object) params;

  
  T getParam(T)(string name) {
    if (params.empty()) return T.init;

    return cast(T) params.get(name);
  }

  byte[][] getByteParams() {
    if (params is null) return new byte[0][];
    ArrayList!(byte[]) byteParams = new ArrayList!(byte[])();

    // foreach(Entry!(string, Object) param ; params.entrySet()) {
    //   byteParams.add(SafeEncoder.encode(param.getKey()));

    //   Object value = param.getValue();
    //   if (value !is null) {
    //     if (value instanceof byte[]) {
    //       byteParams.add((byte[]) value);
    //     } else {
    //       byteParams.add(SafeEncoder.encode(string.valueOf(value)));
    //     }
    //   }
    // }

    // return byteParams.toArray(new byte[byteParams.size()][]);

    implementationMissing();
    return null;

  }

  protected bool contains(string name) {
    if (params is null) return false;

    return params.containsKey(name);
  }

  protected void addParam(string name, Object value) {
    if (params is null) {
      params = new HashMap!(string, Object)();
    }
    params.put(name, value);
  }

  protected void addParam(string name) {
    if (params is null) {
      params = new HashMap!(string, Object)();
    }
    params.put(name, null);
  }

}
