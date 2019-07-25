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

module hunt.redis.util.RedisClusterHashTagUtil;

import hunt.redis.util.SafeEncoder;

import hunt.Exceptions;

import std.array;
import std.range;
import std.string;

/**
 * Holds various methods/utilities to manipualte and parse redis hash-tags. See <a
 * href="http://redis.io/topics/cluster-spec">Cluster-Spec : Keys hash tags</a>
 */
class RedisClusterHashTagUtil {

    private this() {
        throw new InstantiationError("Must not instantiate this class");
    }

    static string getHashTag(string key) {
        return extractHashTag(key, true);
    }

    static bool isClusterCompliantMatchPattern(const(ubyte)[] matchPattern) {
        return isClusterCompliantMatchPattern(SafeEncoder.encode(matchPattern));
    }

    static bool isClusterCompliantMatchPattern(string matchPattern) {
        string tag = extractHashTag(matchPattern, false);
        return !tag.empty();
    }

    private static string extractHashTag(string key, bool returnKeyOnAbsence) {
        ptrdiff_t s = key.indexOf("{");
        if (s > -1) {
            ptrdiff_t e = key.indexOf("}", s + 1);
            if (e > -1 && e != s + 1) {
                return key[s + 1 .. e];
            }
        }
        return returnKeyOnAbsence ? key : null;
    }
}
