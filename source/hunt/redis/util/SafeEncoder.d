module hunt.redis.util.SafeEncoder;

import hunt.redis.Exceptions;
import hunt.redis.Protocol;

import hunt.Exceptions;
import hunt.text.StringUtils;

import std.array;
import std.conv;

/**
 * The only reason to have this is to be able to compatible with java 1.5 :(
 */
class SafeEncoder {

    private this(){
        throw new InstantiationError( "Must not instantiate this class" );
    }

    static const(ubyte)[][] encodeMany(string[] strs...) {
        const(ubyte)[][] many = new const(ubyte)[][strs.length];
        for (size_t i = 0; i < strs.length; i++) {
            many[i] = encode(strs[i]);
        }
        return many;
    }
    // static string[] encodeMany(string[] strs...) {
    //     return strs;
    //     // byte[][] many = new byte[][strs.length];
    //     // for (size_t i = 0; i < strs.length; i++) {
    //     //     many[i] = encode(strs[i]);
    //     // }
    //     // return many;
    // }

    // static const(ubyte)[] encode(string str) {
    //     return cast(const(ubyte)[])str;
    // }

    static const(ubyte)[] encode(string str) {
        try {
            if (str.empty) {
                throw new RedisDataException("value sent to redis cannot be null");
            }
            return cast(const(ubyte)[])(StringUtils.getBytes(str, Protocol.CHARSET));
        } catch (UnsupportedEncodingException e) {
            throw new RedisException(e);
        }
    }

    static string encode(const(ubyte)[] data) {
        try {
            return cast(string)data.idup;
        } catch (UnsupportedEncodingException e) {
            throw new RedisException(e);
        }
    }
}
