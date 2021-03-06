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
 
module hunt.redis.params.GeoRadiusParam;

import hunt.redis.params.Params;

import hunt.redis.Protocol;
import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;
import hunt.Integer;

class GeoRadiusParam : Params {
    private enum string WITHCOORD = "withcoord";
    private enum string WITHDIST = "withdist";

    // Do not add WITHHASH since we can't classify result of WITHHASH and WITHDIST,
    // and WITHHASH is for debugging purposes

    private enum string ASC = "asc";
    private enum string DESC = "desc";
    private enum string COUNT = "count";

    alias addParam = Params.addParam;
    alias getByteParams = Params.getByteParams;

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

    const(ubyte)[][] getByteParams(const(ubyte)[][] args...) {
        ArrayList!(const(ubyte)[]) byteParams = new ArrayList!(const(ubyte)[])();
        foreach (const(ubyte)[] arg; args) {
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
            byteParams.add(Protocol.toByteArray(getParam!int(COUNT)));
        }

        if (contains(ASC)) {
            byteParams.add(SafeEncoder.encode(ASC));
        } else if (contains(DESC)) {
            byteParams.add(SafeEncoder.encode(DESC));
        }

        return byteParams.toArray();
    }
}
