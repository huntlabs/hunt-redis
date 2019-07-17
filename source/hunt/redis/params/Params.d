module hunt.redis.params.Params;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;

import hunt.redis.util.SafeEncoder;

import hunt.String;
import hunt.Byte;
import hunt.Integer;

import std.array;
import std.variant;

abstract class Params {

    private Map!(string, Variant) params;

    this() {
        params = new HashMap!(string, Variant)();
    }

    T getParam(T)(string name) {
        if (params.empty())
            return T.init;

        return cast(T) params.get(name);
    }

    byte[][] getByteParams() {
        if (params is null)
            return new byte[][0];
        ArrayList!(byte[]) byteParams = new ArrayList!(byte[])();

        // foreach(Entry!(string, Object) param ; params.entrySet()) {
        //   byteParams.add(SafeEncoder.encode(param.getKey()));

        //   Object value = param.getValue();
        //   if (value !is null) {
        //     if (value instanceof byte[]) {
        //       byteParams.add((byte[]) value);
        //     } else {
        //       byteParams.add(SafeEncoder.encode(to!string(value)));
        //     }
        //   }
        // }

        // return byteParams.toArray(new byte[byteParams.size()][]);

        implementationMissing();
        return null;

    }

    protected bool contains(string name) {
        if (params is null)
            return false;

        return params.containsKey(name);
    }

    protected void addParam(string name, string value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, int value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, byte[] value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, Object value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, ref Variant value) {
        params.put(name, value);
    }

    protected void addParam(string name) {
        params.put(name, Variant(null));
    }

}
