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
 
module hunt.redis.RedisClusterCommand;

import hunt.redis.Redis;
import hunt.redis.RedisClusterConnectionHandler;
import hunt.redis.Exceptions;
import hunt.redis.util.RedisClusterCRC16;

abstract class RedisClusterCommand(T) {

    private RedisClusterConnectionHandler connectionHandler;
    private int maxAttempts;

    this(RedisClusterConnectionHandler connectionHandler, int maxAttempts) {
        this.connectionHandler = connectionHandler;
        this.maxAttempts = maxAttempts;
    }

    abstract T execute(Redis connection);

    T run(string key) {
        return runWithRetries(RedisClusterCRC16.getSlot(key), this.maxAttempts, false, null);
    }

    T run(string[] keys...) { // int keyCount, 
        if (keys is null || keys.length == 0) {
            throw new RedisClusterOperationException("No way to dispatch this command to Redis Cluster.");
        }
        int keyCount = cast(int)keys.length;

        // For multiple keys, only execute if they all share the same connection slot.
        int slot = RedisClusterCRC16.getSlot(keys[0]);
        if (keys.length > 1) {
            for (int i = 1; i < keyCount; i++) {
                int nextSlot = RedisClusterCRC16.getSlot(keys[i]);
                if (slot != nextSlot) {
                    throw new RedisClusterOperationException("No way to dispatch this command to Redis "
                            ~ "Cluster because keys have different slots.");
                }
            }
        }

        return runWithRetries(slot, this.maxAttempts, false, null);
    }

    T runBinary(const(ubyte)[] key) {
        return runWithRetries(RedisClusterCRC16.getSlot(key), this.maxAttempts, false, null);
    }

    T runBinary(const(ubyte)[][] keys...) { // int keyCount, 
        if (keys is null || keys.length == 0) {
            throw new RedisClusterOperationException("No way to dispatch this command to Redis Cluster.");
        }

        int keyCount = cast(int)keys.length;

        // For multiple keys, only execute if they all share the same connection slot.
        int slot = RedisClusterCRC16.getSlot(keys[0]);
        if (keys.length > 1) {
            for (int i = 1; i < keyCount; i++) {
                int nextSlot = RedisClusterCRC16.getSlot(keys[i]);
                if (slot != nextSlot) {
                    throw new RedisClusterOperationException("No way to dispatch this command to Redis "
                            ~ "Cluster because keys have different slots.");
                }
            }
        }

        return runWithRetries(slot, this.maxAttempts, false, null);
    }

    T runWithAnyNode() {
        Redis connection = null;
        try {
            connection = connectionHandler.getConnection();
            return execute(connection);
        } catch (RedisConnectionException e) {
            throw e;
        } finally {
            releaseConnection(connection);
        }
    }

    private T runWithRetries(int slot, int attempts, bool tryRandomNode, RedisRedirectionException redirect) {
        if (attempts <= 0) {
            throw new RedisClusterMaxAttemptsException("No more cluster attempts left.");
        }

        Redis connection = null;
        try {

            if (redirect !is null) {
                connection = this.connectionHandler.getConnectionFromNode(redirect.getTargetNode());
                RedisAskDataException ex = cast(RedisAskDataException)redirect;
                if (ex !is null) {
                    // TODO: Pipeline asking with the original command to make it[] faster....
                    connection.asking();
                }
            } else {
                if (tryRandomNode) {
                    connection = connectionHandler.getConnection();
                } else {
                    connection = connectionHandler.getConnectionFromSlot(slot);
                }
            }

            return execute(connection);

        } catch (RedisNoReachableClusterNodeException jnrcne) {
            throw jnrcne;
        } catch (RedisConnectionException jce) {
            // release current connection before recursion
            releaseConnection(connection);
            connection = null;

            if (attempts <= 1) {
                //We need this because if node is not reachable anymore - we need to finally initiate slots
                //renewing, or we can stuck with cluster state without one node in opposite case.
                //But now if maxAttempts = [1 or 2] we will do it too often.
                //TODO make tracking of successful/unsuccessful operations for node - do renewing only
                //if there were no successful responses from this node last few seconds
                this.connectionHandler.renewSlotCache();
            }

            return runWithRetries(slot, attempts - 1, tryRandomNode, redirect);
        } catch (RedisRedirectionException jre) {
            // if MOVED redirection occurred,
            RedisMovedDataException ex = cast(RedisMovedDataException)jre;
            if (jre !is null) {
                // it rebuilds cluster's slot cache recommended by Redis cluster specification
                this.connectionHandler.renewSlotCache(connection);
            }

            // release current connection before recursion
            releaseConnection(connection);
            connection = null;

            return runWithRetries(slot, attempts - 1, false, jre);
        } finally {
            releaseConnection(connection);
        }
    }

    private void releaseConnection(Redis connection) {
        if (connection !is null) {
            connection.close();
        }
    }

}
