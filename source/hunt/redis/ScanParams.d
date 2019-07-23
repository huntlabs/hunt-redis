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
 
module hunt.redis.ScanParams;

import hunt.redis.Protocol;
import hunt.redis.util.SafeEncoder;

import hunt.collection;
import hunt.Integer;

import std.conv;

class ScanParams {

    private Map!(Protocol.Keyword, ByteBuffer) params;

    enum string SCAN_POINTER_START = "0";
    enum const(ubyte)[] SCAN_POINTER_START_BINARY = SafeEncoder.encode(SCAN_POINTER_START);

    this() {
        params = new HashMap!(Protocol.Keyword, ByteBuffer); // new EnumMap!(Keyword, ByteBuffer)(Keyword.class);
    }

    ScanParams match(const(ubyte)[] pattern) {
        params.put(Protocol.Keyword.MATCH, BufferUtils.toBuffer(cast(byte[])pattern));
        return this;
    }

    /**
   * @see <a href="https://redis.io/commands/scan#the-match-option">MATCH option in Redis documentation</a>
   * 
   * @param pattern
   * @return 
   */
    ScanParams match(string pattern) {
        params.put(Protocol.Keyword.MATCH, BufferUtils.toBuffer(cast(byte[])SafeEncoder.encode(pattern)));
        return this;
    }

    /**
   * @see <a href="https://redis.io/commands/scan#the-count-option">COUNT option in Redis documentation</a>
   * 
   * @param count
   * @return 
   */
    ScanParams count(int count) {
        params.put(Protocol.Keyword.COUNT, BufferUtils.toBuffer(cast(byte[])Protocol.toByteArray(count)));
        return this;
    }

    Collection!(const(ubyte)[]) getParams() {
        List!(const(ubyte)[]) paramsList = new ArrayList!(const(ubyte)[])(params.size());
        foreach (Protocol.Keyword key, ByteBuffer value; params) {
            paramsList.add(cast(const(ubyte)[])key.to!string());
            paramsList.add(cast(const(ubyte)[])value.array());
        }
        // return Collections.unmodifiableCollection(paramsList);
        return paramsList;
    }

    const(ubyte)[] binaryMatch() {
        if (params.containsKey(Protocol.Keyword.MATCH)) {
            return cast(const(ubyte)[])(params.get(Protocol.Keyword.MATCH).array());
        } else {
            return null;
        }
    }

    string match() {
        if (params.containsKey(Protocol.Keyword.MATCH)) {
            return cast(string)(params.get(Protocol.Keyword.MATCH).array());
        } else {
            return null;
        }
    }

    Integer count() {
        if (params.containsKey(Protocol.Keyword.COUNT)) {
            return new Integer(params.get(Protocol.Keyword.COUNT).getInt());
        } else {
            return null;
        }
    }
}