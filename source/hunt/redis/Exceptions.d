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
 
module hunt.redis.Exceptions;

import hunt.Exceptions;

import hunt.redis.HostAndPort;

class RedisException : RuntimeException {
    mixin BasicExceptionCtors;
}

class InvalidURIException : RedisException {
    mixin BasicExceptionCtors;
}

class RedisConnectionException : RedisException {
    mixin BasicExceptionCtors;
}

class RedisExhaustedPoolException : RedisException {
    mixin BasicExceptionCtors;
}

class RedisNoReachableClusterNodeException : RedisConnectionException {
    mixin BasicExceptionCtors;
}

class RedisClusterOperationException : RedisException {
    mixin BasicExceptionCtors;
}

class RedisDataException : RedisException {
    mixin BasicExceptionCtors;
}

class RedisBusyException : RedisDataException {
    mixin BasicExceptionCtors;
}

class RedisClusterException : RedisDataException {
    mixin BasicExceptionCtors;
}

class RedisNoScriptException : RedisDataException {
    mixin BasicExceptionCtors;
}


class RedisClusterMaxAttemptsException : RedisClusterOperationException {
    mixin BasicExceptionCtors;
}

class RedisRedirectionException : RedisDataException {

    private HostAndPort targetNode;
    private int slot;

    this(string message, HostAndPort targetNode, int slot) {
        super(message);
        this.targetNode = targetNode;
        this.slot = slot;
    }

    this(Throwable cause, HostAndPort targetNode, int slot) {
        super(cause);
        this.targetNode = targetNode;
        this.slot = slot;
    }

    this(string message, Throwable cause, HostAndPort targetNode, int slot) {
        super(message, cause);
        this.targetNode = targetNode;
        this.slot = slot;
    }

    HostAndPort getTargetNode() {
        return targetNode;
    }

    int getSlot() {
        return slot;
    }
}

class RedisMovedDataException : RedisRedirectionException {
    this(string message, HostAndPort targetNode, int slot) {
        super(message, targetNode, slot);
    }

    this(Throwable cause, HostAndPort targetNode, int slot) {
        super(cause, targetNode, slot);
    }

    this(string message, Throwable cause, HostAndPort targetNode, int slot) {
        super(message, cause, targetNode, slot);
    }
}

class RedisAskDataException : RedisRedirectionException {
    this(Throwable cause, HostAndPort targetHost, int slot) {
        super(cause, targetHost, slot);
    }

    this(string message, Throwable cause, HostAndPort targetHost, int slot) {
        super(message, cause, targetHost, slot);
    }

    this(string message, HostAndPort targetHost, int slot) {
        super(message, targetHost, slot);
    }
}
