module test.utils.RedisClusterTestUtil;

import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.Exceptions;

import core.thread;
import core.time;

import hunt.Exceptions;
import hunt.util.DateTime;

import std.algorithm;
import std.string;

class RedisClusterTestUtil {

    static void waitForClusterReady(Redis[] nodes...) {
        bool clusterOk = false;
        while (!clusterOk) {
            bool isOk = true;
            foreach (Redis node ; nodes) {
                if (!node.clusterInfo().split("\n")[0].canFind("ok")) {
                    isOk = false;
                    break;
                }
            }

            if (isOk) {
                clusterOk = true;
            }

            Thread.sleep(50.msecs);
        }
    }

    static string getNodeId(string infoOutput) {
        foreach (string infoLine ; infoOutput.split("\n")) {
            if (infoLine.canFind("myself")) {
                return infoLine.split(" ")[0];
            }
        }
        return "";
    }

    static string getNodeId(string infoOutput, HostAndPort node) {

        foreach (string infoLine ; infoOutput.split("\n")) {
            if (infoLine.canFind(node.toString())) {
                return infoLine.split(" ")[0];
            }
        }
        return "";
    }

    static void assertNodeIsKnown(Redis node, string targetNodeId, int timeoutMs) {
        assertNodeRecognizedStatus(node, targetNodeId, true, timeoutMs);
    }

    static void assertNodeIsUnknown(Redis node, string targetNodeId, int timeoutMs) {
        assertNodeRecognizedStatus(node, targetNodeId, false, timeoutMs);
    }

    private static void assertNodeRecognizedStatus(Redis node, string targetNodeId,
            bool shouldRecognized, int timeoutMs) {
        int sleepInterval = 100;
        for (int sleepTime = 0; sleepTime <= timeoutMs; sleepTime += sleepInterval) {
            bool known = isKnownNode(node, targetNodeId);
            if (shouldRecognized == known) return;

            try {
                Thread.sleep(sleepInterval.msecs);
            } catch (InterruptedException e) {
            }
        }

        throw new RedisException("Node recognize check error");
    }

    private static bool isKnownNode(Redis node, string nodeId) {
        string infoOutput = node.clusterNodes();
        foreach (string infoLine ; infoOutput.split("\n")) {
            if (infoLine.canFind(nodeId)) {
                return true;
            }
        }
        return false;
    }

}
