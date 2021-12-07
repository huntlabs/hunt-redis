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
 
module hunt.redis.util.MurmurHash;

import hunt.redis.util.SafeEncoder;
import hunt.redis.util.Hashing;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;

/**
 * This is a very fast, non-cryptographic hash suitable for general hash-based lookup. See
 * http://murmurhash.googlepages.com/ for more details. <br>
 * <p>
 * The C version of MurmurHash 2.0 found at that site was ported to Java by Andrzej Bialecki (ab at
 * getopt org).
 * </p>
 */
class MurmurHash : Hashing {
    /**
   * Hashes bytes in an array.
   * @param data The bytes to hash.
   * @param seed The seed for the hash.
   * @return The 32 bit hash of the bytes in question.
   */
    static int hash(const(ubyte)[] data, int seed) {
        return hash(BufferUtils.toBuffer(cast(byte[])data), seed);
    }

    /**
   * Hashes bytes in part of an array.
   * @param data The data to hash.
   * @param offset Where to start munging.
   * @param length How many bytes to process.
   * @param seed The seed to start with.
   * @return The 32-bit hash of the data in question.
   */
    static int hash(const(ubyte)[] data, int offset, int length, int seed) {
        return hash(BufferUtils.toBuffer(cast(byte[])data, offset, length), seed);
    }

    /**
   * Hashes the bytes in a buffer from the current position to the limit.
   * @param buf The bytes to hash.
   * @param seed The seed for the hash.
   * @return The 32 bit murmur hash of the bytes in the buffer.
   */
    static int hash(ByteBuffer buf, int seed) {
        // save byte order for later restoration
        ByteOrder byteOrder = buf.order();
        buf.order(ByteOrder.LittleEndian);

        int m = 0x5bd1e995;
        int r = 24;

        int h = seed ^ buf.remaining();

        int k;
        while (buf.remaining() >= 4) {
            k = buf.getInt();

            k *= m;
            k ^= k >>> r;
            k *= m;

            h *= m;
            h ^= k;
        }

        if (buf.remaining() > 0) {
            ByteBuffer finish = BufferUtils.allocate(4).order(ByteOrder.LittleEndian);
            // for big-endian version, use this first:
            // finish.position(4-buf.remaining());
            finish.put(buf).rewind();
            h ^= finish.getInt();
            h *= m;
        }

        h ^= h >>> 13;
        h *= m;
        h ^= h >>> 15;

        buf.order(byteOrder);
        return h;
    }

    static long hash64A(const(ubyte)[] data, int seed) {
        return hash64A(BufferUtils.toBuffer(cast(byte[])data), seed);
    }

    static long hash64A(const(ubyte)[] data, int offset, int length, int seed) {
        return hash64A(BufferUtils.toBuffer(cast(byte[])data, offset, length), seed);
    }

    static long hash64A(ByteBuffer buf, int seed) {
        ByteOrder byteOrder = buf.order();
        buf.order(ByteOrder.LittleEndian);

        long m = 0xc6a4a7935bd1e995L;
        int r = 47;

        long h = seed ^ (buf.remaining() * m);

        long k;
        while (buf.remaining() >= 8) {
            k = buf.getLong();

            k *= m;
            k ^= k >>> r;
            k *= m;

            h ^= k;
            h *= m;
        }

        if (buf.remaining() > 0) {
            ByteBuffer finish = BufferUtils.allocate(8).order(ByteOrder.LittleEndian);
            // for big-endian version, do this first:
            // finish.position(8-buf.remaining());
            finish.put(buf).rewind();
            h ^= finish.getLong();
            h *= m;
        }

        h ^= h >>> r;
        h *= m;
        h ^= h >>> r;

        buf.order(byteOrder);
        return h;
    }

    override long hash(const(ubyte)[] key) {
        return hash64A(key, 0x1234ABCD);
    }

    override long hash(string key) {
        return hash(SafeEncoder.encode(key));
    }
}
