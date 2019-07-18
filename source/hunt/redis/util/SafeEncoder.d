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

    // static byte[][] encodeMany(string[] strs...) {
    //     byte[][] many = new byte[][strs.length];
    //     for (size_t i = 0; i < strs.length; i++) {
    //         many[i] = encode(strs[i]);
    //     }
    //     return many;
    // }
    static string[] encodeMany(string[] strs...) {
        return strs;
        // byte[][] many = new byte[][strs.length];
        // for (size_t i = 0; i < strs.length; i++) {
        //     many[i] = encode(strs[i]);
        // }
        // return many;
    }

    static string encode(string str) {
        return str;
    }

    // static byte[] encode(string str) {
    //     try {
    //         if (str.empty) {
    //             throw new RedisDataException("value sent to redis cannot be null");
    //         }
    //         return StringUtils.getBytes(str, Protocol.CHARSET);
    //     } catch (UnsupportedEncodingException e) {
    //         throw new RedisException(e);
    //     }
    // }

    // static string encode(byte[] data) {
    //     try {
    //         return cast(string)data.idup;
    //     } catch (UnsupportedEncodingException e) {
    //         throw new RedisException(e);
    //     }
    // }
}
