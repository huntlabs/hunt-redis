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
 
module hunt.redis.util.RedisOutputStream;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.io.Common;
import hunt.io.FilterInputStream;
import hunt.io.FilterOutputStream;


/**
 * The class implements a buffered output stream without synchronization There are also special
 * operations like in-place string encoding. This stream fully ignore mark/reset and should not be
 * used outside Redis
 */
class RedisOutputStream : FilterOutputStream {
    protected byte[] buf;

    protected int count;

// dfmt off
    private enum int[] sizeTable = [
            9, 99, 999, 9999, 99999, 999999, 9999999, 99999999, 999999999, int.max
        ];

    private enum byte[] DigitTens = [
            '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '1', '1',
            '1', '1', '1', '1', '1', '1', '1', '2', '2', '2', '2', '2', '2',
            '2', '2', '2', '2', '3', '3', '3', '3', '3', '3', '3', '3', '3',
            '3', '4', '4', '4', '4', '4', '4', '4', '4', '4', '4', '5', '5',
            '5', '5', '5', '5', '5', '5', '5', '5', '6', '6', '6', '6', '6',
            '6', '6', '6', '6', '6', '7', '7', '7', '7', '7', '7', '7', '7',
            '7', '7', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '9',
            '9', '9', '9', '9', '9', '9', '9', '9', '9'
        ];

    private enum byte[] DigitOnes = [
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2',
            '3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5',
            '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8',
            '9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1',
            '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4',
            '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7',
            '8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
            '1', '2', '3', '4', '5', '6', '7', '8', '9'
        ];

    private enum byte[] digits = [
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
            'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
            'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
        ];
// dfmt on

    this(OutputStream outputStream) {
        this(outputStream, 8192);
    }

    this(OutputStream outputStream, int size) {
        super(outputStream);
        if (size <= 0) {
            throw new IllegalArgumentException("Buffer size <= 0");
        }
        buf = new byte[size];
    }

    private void flushBuffer() {
        if (count > 0) {
            version(HUNT_REDIS_DEBUG) {
                if(count<32) {
                tracef("outgoing: %s", cast(string)buf[0 .. count]);
                } else {
                    tracef("outgoing: %s", cast(string)buf[0 .. 32]);
                }
            }
            outputStream.write(buf, 0, count);
            count = 0;
        }
    }

    void write(byte b) {
        if (count == buf.length) {
            flushBuffer();
        }
        buf[count++] = b;
    }

    alias write = FilterOutputStream.write;
    alias write = OutputStream.write;

    override void write(byte[] b) {
        write(b, 0, cast(int) b.length);
    }

    override void write(byte[] b, int off, int len) {
        if (len >= buf.length) {
            flushBuffer();
            outputStream.write(b, off, len);
        } else {
            if (len >= buf.length - count) {
                flushBuffer();
            }

            // System.arraycopy(b, off, buf, count, len);
            buf[count .. count + len] = b[off .. off + len];
            count += len;
        }
    }

    void writeCrLf() {
        if (2 >= buf.length - count) {
            flushBuffer();
        }

        buf[count++] = '\r';
        buf[count++] = '\n';
    }

    void writeIntCrLf(int value) {
        if (value < 0) {
            write(cast(byte) '-');
            value = -value;
        }

        int size = 0;
        while (value > sizeTable[size])
            size++;

        size++;
        if (size >= buf.length - count) {
            flushBuffer();
        }

        int q, r;
        int charPos = count + size;

        while (value >= 65536) {
            q = value / 100;
            r = value - ((q << 6) + (q << 5) + (q << 2));
            value = q;
            buf[--charPos] = DigitOnes[r];
            buf[--charPos] = DigitTens[r];
        }

        for (;;) {
            q = (value * 52429) >>> (16 + 3);
            r = value - ((q << 3) + (q << 1));
            buf[--charPos] = digits[r];
            value = q;
            if (value == 0)
                break;
        }
        count += size;

        writeCrLf();
    }

    override void flush() {
        flushBuffer();
        outputStream.flush();
    }
}
