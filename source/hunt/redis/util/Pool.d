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
 
module hunt.redis.util.Pool;

import hunt.redis.Exceptions;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;

import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.GenericObjectPool;
import hunt.pool.impl.GenericObjectPoolConfig;



abstract class Pool(T) : Closeable {
    protected GenericObjectPool!(T) internalPool;

    /**
     * Using this constructor means you have to set and initialize the internalPool yourself.
     */
    this() {
    }

    this(GenericObjectPoolConfig poolConfig, PooledObjectFactory!(T) factory) {
        initPool(poolConfig, factory);
    }

    override
    void close() {
        destroy();
    }

    bool isClosed() {
        return this.internalPool.isClosed();
    }

    void initPool(GenericObjectPoolConfig poolConfig, PooledObjectFactory!(T) factory) {

        if (this.internalPool !is null) {
            try {
                closeInternalPool();
            } catch (Exception e) {
                debug warning(e.msg);
                version(HUNT_REDIS_DEBUG) warning(e);
            }
        }

        this.internalPool = new GenericObjectPool!(T)(factory, poolConfig);
    }

    T getResource() {
        try {
            return internalPool.borrowObject();
        } catch (NoSuchElementException nse) {
            debug warning(nse.msg);
            version(HUNT_REDIS_DEBUG) warning(nse);
            if (nse.next is null) { // The exception was caused by an exhausted pool
                throw new RedisExhaustedPoolException(
                        "Could not get a resource since the pool is exhausted", nse);
            }
            // Otherwise, the exception was caused by the implemented activateObject() or ValidateObject()
            throw new RedisException("Could not get a resource from the pool", nse);
        } catch (Exception e) {
            debug warning(e.msg);
            version(HUNT_REDIS_DEBUG) warning(e);
            throw new RedisConnectionException("Could not get a resource from the pool", e);
        }
    }

    protected void returnResourceObject(T resource) {
        if (resource is null) {
            return;
        }
        
        try {
            internalPool.returnObject(resource);
        } catch (Exception e) {
            debug warning(e.msg);
            version(HUNT_REDIS_DEBUG) warning(e);
            throw new RedisException("Could not return the resource to the pool", e);
        }
    }

    protected void returnBrokenResource(T resource) {
        if (resource !is null) {
            returnBrokenResourceObject(resource);
        }
    }

    protected void returnResource(T resource) {
        if (resource !is null) {
            returnResourceObject(resource);
        }
    }

    void destroy() {
        closeInternalPool();
    }

    protected void returnBrokenResourceObject(T resource) {
        try {
            internalPool.invalidateObject(resource);
        } catch (Exception e) {
            debug warning(e.msg);
            version(HUNT_REDIS_DEBUG) warning(e);
            throw new RedisException("Could not return the broken resource to the pool", e);
        }
    }

    protected void closeInternalPool() {
        try {
            internalPool.close();
        } catch (Exception e) {
            debug warning(e.msg);
            version(HUNT_REDIS_DEBUG) warning(e);
            throw new RedisException("Could not destroy the pool", e);
        }
    }
    
    /**
     * Returns the number of instances currently borrowed from this pool.
     *
     * @return The number of instances currently borrowed from this pool, -1 if
     * the pool is inactive.
     */
    int getNumActive() {
        if (poolInactive()) {
            return -1;
        }

        return this.internalPool.getNumActive();
    }
    
    /**
     * Returns the number of instances currently idle in this pool.
     *
     * @return The number of instances currently idle in this pool, -1 if the
     * pool is inactive.
     */
    int getNumIdle() {
        if (poolInactive()) {
            return -1;
        }

        return this.internalPool.getNumIdle();
    }
    
    /**
     * Returns an estimate of the number of threads currently blocked waiting for
     * a resource from this pool.
     *
     * @return The number of threads waiting, -1 if the pool is inactive.
     */
    int getNumWaiters() {
        if (poolInactive()) {
            return -1;
        }

        return this.internalPool.getNumWaiters();
    }
    
    /**
     * Returns the mean waiting time spent by threads to obtain a resource from
     * this pool.
     *
     * @return The mean waiting time, in milliseconds, -1 if the pool is
     * inactive.
     */
    long getMeanBorrowWaitTimeMillis() {
        if (poolInactive()) {
            return -1;
        }

        return this.internalPool.getMeanBorrowWaitTimeMillis();
    }
    
    /**
     * Returns the maximum waiting time spent by threads to obtain a resource
     * from this pool.
     *
     * @return The maximum waiting time, in milliseconds, -1 if the pool is
     * inactive.
     */
    long getMaxBorrowWaitTimeMillis() {
        if (poolInactive()) {
            return -1;
        }

        return this.internalPool.getMaxBorrowWaitTimeMillis();
    }

    private bool poolInactive() {
        return this.internalPool is null || this.internalPool.isClosed();
    }

    void addObjects(int count) {
        try {
            for (int i = 0; i < count; i++) {
                this.internalPool.addObject();
            }
        } catch (Exception e) {
            debug warning(e.msg);
            version(HUNT_REDIS_DEBUG) warning(e);
            throw new RedisException("Error trying to add idle objects", e);
        }
    }
}
