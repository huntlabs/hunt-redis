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
 
module hunt.redis.util.Hashing;

import hunt.Exceptions;
import hunt.redis.util.MurmurHash;

import std.concurrency : initOnce;
import std.digest.md;

import object;

interface Hashing {
  static Hashing MURMUR_HASH() {
    __gshared Hashing inst;
    return initOnce!inst(new MurmurHash());
  }

  static Hashing MD5() {
    __gshared Hashing inst;
    return initOnce!inst(new class Hashing {
        override long hash(string key) {
            return cast(long)hashOf(key);
        }

        override
        long hash(const(ubyte)[] key) {
            ubyte[] bKey = md5Of(key).dup;
            long res = (cast(long) (bKey[3] & 0xFF) << 24) | (cast(long) (bKey[2] & 0xFF) << 16)
                | (cast(long) (bKey[1] & 0xFF) << 8) | cast(long) (bKey[0] & 0xFF);
            return res;
        }
    });
  } 
  

  long hash(string key);

  long hash(const(ubyte)[] key);
}