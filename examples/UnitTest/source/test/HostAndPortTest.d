module test.HostAndPortTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.redis.HostAndPort;

import std.conv;


class HostAndPortTest {
    @Test
    void checkExtractParts() {
        string host = "2a11:1b1:0:111:e111:1f11:1111:1f1e:1999";
        string port = "6379";

        assertArrayEquals([host, port], HostAndPort.extractParts(host ~ ":" ~ port));

        host = "";
        port = "";
        assertArrayEquals([host, port], HostAndPort.extractParts(host ~ ":" ~ port));

        host = "localhost";
        port = "";
        assertArrayEquals([host, port], HostAndPort.extractParts(host ~ ":" ~ port));

        host = "";
        port = "6379";
        assertArrayEquals([host, port], HostAndPort.extractParts(host ~ ":" ~ port));

        host = "11:22:33:44:55";
        port = "";
        assertArrayEquals([host, port], HostAndPort.extractParts(host ~ ":" ~ port));
    }

    @Test
    void checkParseString() {
        string host = "2a11:1b1:0:111:e111:1f11:1111:1f1e:1999";
        int port = 6379;
        HostAndPort hp = HostAndPort.parseString(host ~ ":" ~ to!string(port));
        assertEquals(host, hp.getHost());
        assertEquals(port, hp.getPort());
    }

    @Test
    void checkParseStringWithoutPort() {
        try {
            string host = "localhost";
            HostAndPort.parseString(host ~ ":");
        } catch(IllegalArgumentException e) {

        }
    }

    @Test
    void checkConvertHost() {
        string host = "2a11:1b1:0:111:e111:1f11:1111:1f1e";
        assertEquals(host, HostAndPort.convertHost(host));
    }
}