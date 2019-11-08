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
 
module hunt.redis.RedisPoolAbstract;

import hunt.redis.Redis;

import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.GenericObjectPoolConfig;

import hunt.redis.util.Pool;

class RedisPoolAbstract : Pool!(Redis) {

    this() {
        super();
    }

    this(GenericObjectPoolConfig poolConfig, PooledObjectFactory!(Redis) factory) {
        super(poolConfig, factory);
    }

    override void returnBrokenResource(Redis resource) {
        super.returnBrokenResource(resource);
    }

    override void returnResource(Redis resource) {
        super.returnResource(resource);
    }
}
