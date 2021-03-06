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
 
module hunt.redis.params.ZAddParams;

import hunt.redis.params.Params;

import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;

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

    const(ubyte)[][] getByteParams(const(ubyte)[] key, const(ubyte)[][] args...) {
        ArrayList!(const(ubyte)[]) byteParams = new ArrayList!(const(ubyte)[])();
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

        foreach (const(ubyte)[] arg; args) {
            byteParams.add(arg);
        }

        return byteParams.toArray();
    }

}
