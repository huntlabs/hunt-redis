/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
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
import std.conv;
import std.variant;

abstract class Params {

    private Map!(string, Variant) params;

    this() {
        params = new HashMap!(string, Variant)();
    }

    T getParam(T)(string name) {
        if (params is null || params.isEmpty())
            return T.init;
        Variant v = params.get(name);
        return v.get!T();
    }

    const(ubyte)[][] getByteParams() {
        if (params is null)
            return null;
        ArrayList!(const(ubyte)[]) byteParams = new ArrayList!(const(ubyte)[])();

        foreach(string key, Variant value; params) {
          byteParams.add(SafeEncoder.encode(key));

          if (value.hasValue()) {
              
            //   byteParams.add(value.toString());
            if (value.type == typeid(byte[]) || value.type == typeid(const(ubyte)[])) {
              byteParams.add(value.get!(const(ubyte)[])());
            } else {
              byteParams.add(SafeEncoder.encode(to!string(value)));
            }
          }
        }

        return byteParams.toArray();

        // return byteParams.toArray(new byte[byteParams.size()][]);
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

    protected void addParam(string name, long value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, byte[] value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, Object value) {
        params.put(name, Variant(value));
    }

    protected void addParam(string name, Variant value) {
        params.put(name, value);
    }

    protected void addParam(string name) {
        params.put(name, Variant(null));
    }

}
