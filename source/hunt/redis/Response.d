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
 
module hunt.redis.Response;

import hunt.redis.Builder;
import hunt.redis.Exceptions;

abstract class AbstractResponse {
    protected AbstractResponse dependency = null;
    protected bool building = false;
    protected bool built = false;
    protected bool _set = false;

    protected RedisDataException exception = null;
    protected Object data;

    protected void build();
    
    void set(Object data) {
        this.data = data;
        _set = true;
    }

    void setDependency(AbstractResponse dependency) {
        this.dependency = dependency;
    }

}

alias Response = RedisResponse;

class RedisResponse(T) : AbstractResponse {
    protected T response = null;

    private Builder!(T) builder;

    this(Builder!(T) b) {
        this.builder = b;
    }

    T get() {
        // if response has dependency response and dependency is not built,
        // build it first and no more!!
        if (dependency !is null && dependency._set && !dependency.built) {
            dependency.build();
        }
        if (!_set) {
            throw new RedisDataException(
                    "Please close pipeline or multi block before calling this method.");
        }
        if (!built) {
            build();
        }
        if (exception !is null) {
            throw exception;
        }
        return response;
    }

    override protected void build() {
        // check build state to prevent recursion
        if (building) {
            return;
        }

        building = true;
        try {
            if (data !is null) {
                exception = cast(RedisDataException) data;
                if (exception is null) {
                    response = builder.build(data);
                }
            }

            data = null;
        } finally {
            building = false;
            built = true;
        }
    }

    override
    string toString() {
        return "Response " ~ builder.toString();
    }

}
