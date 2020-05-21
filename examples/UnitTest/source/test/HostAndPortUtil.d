module test.HostAndPortUtil;

import hunt.collection;
import hunt.Exceptions;

import hunt.redis.HostAndPort;
import hunt.redis.Protocol;

import std.array;
import std.conv;

final class HostAndPortUtil {
    private __gshared List!(HostAndPort) redisHostAndPortList;
    private __gshared List!(HostAndPort) sentinelHostAndPortList;
    private __gshared List!(HostAndPort) clusterHostAndPortList;

    private this() {
        throw new InstantiationError("Must not instantiate this class");
    }

    shared static this() {
        redisHostAndPortList = new ArrayList!(HostAndPort)();
        sentinelHostAndPortList = new ArrayList!(HostAndPort)();
        clusterHostAndPortList = new ArrayList!(HostAndPort)();

        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 1));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 2));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 3));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 4));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 5));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 6));
        redisHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_PORT + 7));

        sentinelHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_SENTINEL_PORT));
        sentinelHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_SENTINEL_PORT + 1));
        sentinelHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_SENTINEL_PORT + 2));
        sentinelHostAndPortList.add(new HostAndPort("localhost", Protocol.DEFAULT_SENTINEL_PORT + 3));

        clusterHostAndPortList.add(new HostAndPort("localhost", 7379));
        clusterHostAndPortList.add(new HostAndPort("localhost", 7380));
        clusterHostAndPortList.add(new HostAndPort("localhost", 7381));
        clusterHostAndPortList.add(new HostAndPort("localhost", 7382));
        clusterHostAndPortList.add(new HostAndPort("localhost", 7383));
        clusterHostAndPortList.add(new HostAndPort("localhost", 7384));

        // string envRedisHosts = System.getProperty("redis-hosts");
        // string envSentinelHosts = System.getProperty("sentinel-hosts");
        // string envClusterHosts; // = System.getProperty("cluster-hosts");

        string envRedisHosts = "10.1.222.110:6379, 10.1.11.115:6379";
        string envSentinelHosts = "";
        // string envClusterHosts = "127.0.0.1:6380,127.0.0.1:6381,127.0.0.1:6382,127.0.0.1:7380,127.0.0.1:7381,127.0.0.1:7382";
        string envClusterHosts = "10.1.222.110:6380,10.1.222.110:6381,10.1.222.110:6382,10.1.222.110:7380,10.1.222.110:7381,10.1.222.110:7382";

        redisHostAndPortList = parseHosts(envRedisHosts, redisHostAndPortList);
        sentinelHostAndPortList = parseHosts(envSentinelHosts, sentinelHostAndPortList);
        clusterHostAndPortList = parseHosts(envClusterHosts, clusterHostAndPortList);
    }

    static List!(HostAndPort) parseHosts(string envHosts, List!(HostAndPort) existingHostsAndPorts) {
        if (!envHosts.empty()) {
            string[] hostDefs = envHosts.split(",");
            if (2 <= hostDefs.length) {
                List!(HostAndPort) envHostsAndPorts = new ArrayList!(HostAndPort)(cast(int)hostDefs.length);
                foreach (string hostDef ; hostDefs) {
                    string[] hostAndPortParts = HostAndPort.extractParts(hostDef);

                    if (2 == hostAndPortParts.length) {
                        string host = hostAndPortParts[0];
                        int port = Protocol.DEFAULT_PORT;
                        try {
                            port = to!int(hostAndPortParts[1]);
                        } catch (NumberFormatException nfe) {
                        }
                        envHostsAndPorts.add(new HostAndPort(host, port));
                    }
                }

                return envHostsAndPorts;
            }
        }

        return existingHostsAndPorts;
    }

    static List!(HostAndPort) getRedisServers() {
        return redisHostAndPortList;
    }

    static List!(HostAndPort) getSentinelServers() {
        return sentinelHostAndPortList;
    }

    static List!(HostAndPort) getClusterServers() {
        return clusterHostAndPortList;
    }
}
