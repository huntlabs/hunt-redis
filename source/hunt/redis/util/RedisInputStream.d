/*
 * Copyright 2009-2010 MBTE Sweden AB. Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a
 * copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable
 * law or agreed to in writing, software distributed under the License is distributed on an "AS IS"
 * BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
 * for the specific language governing permissions and limitations under the License.
 */

module hunt.redis.util.RedisInputStream;

import hunt.redis.Exceptions;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.io.Common;
import hunt.io.ByteArrayOutputStream;
import hunt.io.FilterInputStream;
import hunt.io.FilterOutputStream;
import hunt.text.StringBuilder;


import std.algorithm;

/**
 * This class assumes (to some degree) that we are reading a RESP stream. As such it assumes certain
 * conventions regarding CRLF line termination. It also assumes that if the Protocol layer requires
 * a byte that if that byte is not there it is a stream error.
 */
class RedisInputStream : FilterInputStream {

    protected byte[] buf;

    protected int count, limit;

    this(InputStream inputStream, int size) {
        super(inputStream);
        if (size <= 0) {
            throw new IllegalArgumentException("Buffer size <= 0");
        }
        buf = new byte[size];
    }

    this(InputStream inputStream) {
        this(inputStream, 8192);
    }

    byte readByte() {
        ensureFill();
        return buf[count++];
    }

    string readLine() {
        StringBuilder sb = new StringBuilder();
        while (true) {
            ensureFill();

            byte b = buf[count++];
            if (b == '\r') {
                ensureFill(); // Must be one more byte

                byte c = buf[count++];
                if (c == '\n') {
                    break;
                }
                sb.append(cast(char) b);
                sb.append(cast(char) c);
            } else {
                sb.append(cast(char) b);
            }
        }

        string reply = sb.toString();
        if (reply.length == 0) {
            throw new RedisConnectionException("It seems like server has closed the connection.");
        }

        return reply;
    }

    byte[] readLineBytes() {

        /*
         * This operation should only require one fill. In that typical case we optimize allocation and
         * copy of the byte array. In the edge case where more than one fill is required then we take a
         * slower path and expand a byte array output stream as is necessary.
         */

        ensureFill();

        int pos = count;
        byte[] buf = this.buf;
        while (true) {
            if (pos == limit) {
                return readLineBytesSlowly();
            }

            if (buf[pos++] == '\r') {
                if (pos == limit) {
                    return readLineBytesSlowly();
                }

                if (buf[pos++] == '\n') {
                    break;
                }
            }
        }

        int N = (pos - count) - 2;
        byte[] line = buf[count .. count+N].dup;
        // System.arraycopy(buf, count, line, 0, N);

        count = pos;
        return line;
    }

    /**
     * Slow path in case a line of bytes cannot be read in one #fill() operation. This is still faster
     * than creating the StrinbBuilder, string, then encoding as byte[] in Protocol, then decoding
     * back into a string.
     */
    private byte[] readLineBytesSlowly() {
        ByteArrayOutputStream bout = null;
        while (true) {
            ensureFill();

            byte b = buf[count++];
            if (b == '\r') {
                ensureFill(); // Must be one more byte

                byte c = buf[count++];
                if (c == '\n') {
                    break;
                }

                if (bout is null) {
                    bout = new ByteArrayOutputStream(16);
                }

                bout.write(b);
                bout.write(c);
            } else {
                if (bout is null) {
                    bout = new ByteArrayOutputStream(16);
                }

                bout.write(b);
            }
        }

        return bout is null ? new byte[0] : bout.toByteArray();
    }

    int readIntCrLf() {
        return cast(int) readLongCrLf();
    }

    long readLongCrLf() {
        byte[] buf = this.buf;

        ensureFill();

        bool isNeg = buf[count] == '-';
        if (isNeg) {
            ++count;
        }

        long value = 0;
        while (true) {
            ensureFill();

            int b = buf[count++];
            if (b == '\r') {
                ensureFill();

                if (buf[count++] != '\n') {
                    throw new RedisConnectionException("Unexpected character!");
                }

                break;
            } else {
                value = value * 10 + b - '0';
            }
        }

        return (isNeg ? -value : value);
    }

    override
    int read(byte[] b, int off, int len) {
        ensureFill();

        int length = min(limit - count, len);
        // System.arraycopy(buf, count, b, off, length);
        b[off .. off + length] = buf[count .. count+length];
        count += length;
        return length;
    }

    /**
     * This methods assumes there are required bytes to be read. If we cannot read anymore bytes an
     * exception is thrown to quickly ascertain that the stream was smaller than expected.
     */
    private void ensureFill() {
        if (count >= limit) {
            try {
                limit = inputStream.read(buf);
                count = 0;
                if (limit == -1) {
                    throw new RedisConnectionException("Unexpected end of stream.");
                }
                version(HUNT_REDIS_DEBUG) tracef("incoming: %s", cast(string)buf[0..limit]);
            } catch (IOException e) {
                throw new RedisConnectionException(e);
            }
        }
    }
}
