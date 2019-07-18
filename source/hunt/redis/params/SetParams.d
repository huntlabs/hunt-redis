module hunt.redis.params.SetParams;

import hunt.redis.params.Params;

import hunt.collection.ArrayList;
import hunt.collection.BufferUtils;

import hunt.redis.util.SafeEncoder;

import std.conv;

class SetParams : Params {

    private enum string XX = "xx";
    private enum string NX = "nx";
    private enum string PX = "px";
    private enum string EX = "ex";

    this() {
    }

    static SetParams setParams() {
        return new SetParams();
    }

    /**
     * Set the specified expire time, in seconds.
     * @param secondsToExpire
     * @return SetParams
     */
    SetParams ex(int secondsToExpire) {
        addParam(EX, secondsToExpire);
        return this;
    }

    /**
     * Set the specified expire time, in milliseconds.
     * @param millisecondsToExpire
     * @return SetParams
     */
    SetParams px(long millisecondsToExpire) {
        addParam(PX, millisecondsToExpire);
        return this;
    }

    /**
     * Only set the key if it does not already exist.
     * @return SetParams
     */
    SetParams nx() {
        addParam(NX);
        return this;
    }

    /**
     * Only set the key if it already exist.
     * @return SetParams
     */
    SetParams xx() {
        addParam(XX);
        return this;
    }

    string[] getByteParams(string[] args...) {
        ArrayList!(string) byteParams = new ArrayList!(string)();
        foreach(string arg ; args) {
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
            byteParams.add(SafeEncoder.encode(getParam!string(EX)));
        }
        if (contains(PX)) {
            byteParams.add(SafeEncoder.encode(PX));
            byteParams.add(SafeEncoder.encode(getParam!string(PX)));
        }

        return byteParams.toArray();
    }

}
