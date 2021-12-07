module hunt.util.pool.ObjectPool;

import hunt.redis.Future;
import hunt.redis.Promise;
import hunt.redis.FuturePromise;
import hunt.logging.ConsoleLogger;

import core.atomic;
import core.sync.mutex;
import core.time;

import std.container.dlist;
import std.conv;
import std.format;
import std.range : walkLength;

import hunt.util.pool.ObjectFactory;
import hunt.util.pool.PooledObject;
import hunt.util.pool.PooledObjectState;

/**
 * 
 */
enum CreationMode {
    Lazy,
    Eager
}

/**
 * 
 */
class PoolOptions {
    size_t size = 5;
    int maxWaitQueueSize = -1;
    string name;
    Duration waitTimeout = 15.seconds;
    int creationMode = CreationMode.Lazy;
}


enum ObjectPoolState {
    Open,
    Closing,
    Closed
}

/**
 * 
 */
class ObjectPool(T) {

    private PoolOptions _poolOptions;
    private shared ObjectPoolState _state = ObjectPoolState.Open;
    private shared bool _isClearing = false;
    private shared int _waiterNumber = 0;
    private ObjectFactory!(T) _factory;
    private PooledObject!(T)[] _pooledObjects;
    private Mutex _borrowLocker;
    private Mutex _waitersLocker;
    private DList!(FuturePromise!T) _waiters;

    static if(is(T == class) && __traits(compiles, new T())) {
        this(PoolOptions options) {
            this(new DefaultObjectFactory!(T)(), options);
        } 
    }

    this(ObjectFactory!(T) factory, PoolOptions options) {
        _factory = factory;
        _poolOptions = options;
        _pooledObjects = new PooledObject!(T)[options.size];
        _waitersLocker = new Mutex();
        _borrowLocker = new Mutex();
    }

    ObjectPoolState state() {
        return _state;
    }

    size_t size() {
        return _poolOptions.size;
    }

    /**
     * Obtains an instance from this pool.
     * <p>
     * By contract, clients <strong>must</strong> return the borrowed instance
     * using {@link #returnObject}, {@link #invalidateObject}, or a related
     * method as defined in an implementation or sub-interface.
     * </p>
     * <p>
     * The behaviour of this method when the pool has been exhausted
     * is not strictly specified (although it may be specified by
     * implementations).
     * </p>
     *
     * @return an instance from this pool.
     */
    T borrow() {
       return borrow(_poolOptions.waitTimeout, true);
    }

    T borrow(Duration timeout, bool isQuiet = true) {
        T r;
        if(timeout == Duration.zero) {
            r = doBorrow();
            if(r is null && !isQuiet) {
                throw new Exception("No idle object avaliable.");
            }
        } else {
            Future!T future = borrowAsync();
            if(timeout.isNegative()) {
                version(HUNT_POOL_DEBUG) {
                    tracef("Borrowing with promise [%s]...", (cast(FuturePromise!T)future).id());
                }   
                r = future.get();
            } else {
                version(HUNT_POOL_DEBUG) {
                    tracef("Borrowing with promise [%s] in %s", (cast(FuturePromise!T)future).id(), timeout);
                }                
                r = future.get(timeout);
            }

            version(HUNT_POOL_DEBUG_MORE) {
                tracef("Borrowed {%s} from promise [%s]", r.to!string(), (cast(FuturePromise!T)future).id());
            }
        }
        
        return r;
    }    


    /**
     * 
     */
    Future!T borrowAsync() {
        version (HUNT_POOL_DEBUG) infof("Borrowing...%s", toString());

        int number = atomicOp!("+=")(_waiterNumber, 1) - 1;
        FuturePromise!T promise = new FuturePromise!T("PoolWaiter " ~ number.to!string());
        size_t waitNumber = getNumWaiters();
        version(HUNT_POOL_DEBUG_MORE) {
            tracef("Pool: %s, new waiter [%s], current waitNumber: %d", _poolOptions.name, promise.id(), waitNumber);
        }      

        if(_poolOptions.maxWaitQueueSize == -1 || waitNumber < _poolOptions.maxWaitQueueSize) {
            safeInsertWaiter(promise);
        } else {
            string msg = format("Reach to the max WaitNumber (%d), the current: %d", 
                _poolOptions.maxWaitQueueSize, waitNumber);

            version(HUNT_DEBUG) {
                warning(msg);
            }
            promise.failed(new Exception(msg));
        }  

        handleWaiters();
        return promise;
    }

    private void safeInsertWaiter(FuturePromise!T promise) {
        _waitersLocker.lock();
        scope(exit) {
            _waitersLocker.unlock();
        }

        _waiters.stableInsert(promise);
    }

    private FuturePromise!T safeGetFrontWaiter() {
        _waitersLocker.lock();
        scope(exit) {
            _waitersLocker.unlock();
        }

        // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-10-10T21:13:56+08:00
        // More test
        if(_waiters.empty) return null;

        FuturePromise!T waiter = _waiters.front();

        // Clear up all the finished waiter until a awaiting waiter found
        while(waiter.isDone()) {
            version(HUNT_POOL_DEBUG_MORE) 
                tracef("Waiter %s is done, so removed.", waiter.id());
            _waiters.removeFront();
            
            if(_waiters.empty()) {
                version(HUNT_POOL_DEBUG) trace("No awaiting waiter found.");
                return null;
            }

            waiter = _waiters.front();
        } 
        _waiters.removeFront(); 

        return waiter;       
    }

    private void safeRemoveFrontWaiter() {

        _waitersLocker.lock();
        scope(exit) {
            _waitersLocker.unlock();
        } 

        _waiters.removeFront();       
    }


    /**
     * 
     */
    private T doBorrow() {
    // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-10-10T16:16:24+08:00        
    // nothrow

        _borrowLocker.lock();
        bool isUnlocked = false;

        scope(exit) {
            version(HUNT_POOL_DEBUG_MORE) warningf("isUnlocked: %s...", isUnlocked);

            if(!isUnlocked) {
                _borrowLocker.unlock();
            }
        }

        PooledObject!(T) pooledObj;
        T underlyingObj = null;
        bool r = false;
        size_t index = 0;

        for(; index<_pooledObjects.length; index++) {
            pooledObj = _pooledObjects[index];

            version(HUNT_POOL_DEBUG_MORE) {
                tracef("Pool: %s, slot[%d] => %s", _poolOptions.name, index, pooledObj.to!string());
            }

            if(pooledObj is null) {
                PooledObject!(T) obj = new PooledObject!(T)();
                _pooledObjects[index] = obj;
                pooledObj = obj;
                isUnlocked = true;
                _borrowLocker.unlock();

                version(HUNT_POOL_DEBUG_MORE) {
                    tracef("Pool: %s, binding slot[%d] => %s", _poolOptions.name, index, obj.toString());
                }

                try {
                    underlyingObj = _factory.makeObject();

                    // tracef("Pool: %s, binded slot[%d] locking...", _poolOptions.name, index);
                    // _borrowLocker.lock();
                    // tracef("Pool: %s, binded slot[%d] locked... underlyingObj is null: %s", _poolOptions.name, index, underlyingObj is null);
                    
                    // obj.bind(underlyingObj);
                    r = pooledObj.allocate(underlyingObj);
                    // isUnlocked = true;
                    // _borrowLocker.unlock();
                } catch(Throwable t) {
                    warning(t.msg);
                    version(HUNT_DEBUG) warning(t);
                    pooledObj = null;
                    _pooledObjects[index] = null;
                }
                
                version(HUNT_POOL_DEBUG) {
                    tracef("Pool: %s, binded slot[%d] => %s", _poolOptions.name, index,  obj.toString());
                }

                break;
            } else if(pooledObj.isIdle()) {
                underlyingObj = pooledObj.getObject();
                bool isValid = _factory.isValid(underlyingObj);
                if(isValid) {
                    r = pooledObj.allocate();
                    // isUnlocked = true;
                    // _borrowLocker.unlock();
                    break;
                } else {
                    pooledObj.invalidate();
                    version(HUNT_POOL_DEBUG) {
                        warningf("Pool: %s. An invalid object (id=%d) detected at slot %d.", 
                            _poolOptions.name, pooledObj.id, index);
                    }
                }
            } else if(pooledObj.isInvalid()) {
                underlyingObj = pooledObj.getObject();
                version(HUNT_POOL_DEBUG) {
                    warningf("Pool: %s. An invalid object (id=%d) detected at slot %d.", 
                        _poolOptions.name, pooledObj.id, index);
                }
                _pooledObjects[index] = null;
                // isUnlocked = true;
                // _borrowLocker.unlock();
                _factory.destroyObject(underlyingObj);
                break;
            }

            pooledObj = null;
        }
        
        if(pooledObj is null) {
            version(HUNT_DEBUG) {
                warningf("Failed to borrow from {%s}",  toString());
            }
            return null;
        }
        
        if(r) {
            version(HUNT_POOL_DEBUG) {
                infof("Pool: %s, allocate: %s, borrowed: {%s}", _poolOptions.name, r, pooledObj.toString()); 
            }
            return underlyingObj;
        } else {
            warningf("Pool: %s, borrowing collision: slot[%d]", _poolOptions.name, index, pooledObj.toString());
            return null;
        }
    }

    /**
     * Returns an instance to the pool. By contract, <code>obj</code>
     * <strong>must</strong> have been obtained using {@link #borrowObject()} or
     * a related method as defined in an implementation or sub-interface.
     *
     * @param obj a {@link #borrowObject borrowed} instance to be returned.
     */
    void returnObject(T obj) {
        if(obj !is null) {
            doReturning(obj);
        }

        handleWaiters();
    } 

    private bool doReturning(T obj) {
        // _pooledObjectsLocker.lock();
        // scope(exit) {
        //     _pooledObjectsLocker.unlock();
        // }

        bool result = false;

        PooledObject!(T) pooledObj;
        for(size_t index; index<_pooledObjects.length; index++) {
            pooledObj = _pooledObjects[index];
            if(pooledObj is null) {
                continue;
            }
            
            T underlyingObj = pooledObj.getObject();
            if(underlyingObj is obj) {
                version(HUNT_POOL_DEBUG_MORE) {
                    tracef("Pool: %s, slot: %d, returning: {%s}", _poolOptions.name, index, pooledObj.toString()); 
                }
                    
                result = pooledObj.returning();
                
                if(result) {
                    version(HUNT_POOL_DEBUG) {
                        tracef("Pool: %s; slot: %d, Returned: {%s}", 
                            _poolOptions.name, index, pooledObj.toString());
                    }
                } else {
                    errorf("Pool: %s, slot: %d, Return failed: {%s}", _poolOptions.name, index, pooledObj.toString());
                }
                break;
            }
        }

        version(HUNT_DEBUG) {
            info(toString());
        }
        // info(toString());
        return result;
    }

    private void handleWaiters() {
        if(_state == ObjectPoolState.Closing || _state == ObjectPoolState.Closed) {
            return;
        }

        if(_state != ObjectPoolState.Open) {
            warningf("Failed to query the waiters. The state is %s.", _state);
            return;
        }

        while(true) {
            
            if(_waiters.empty()) {
                version(HUNT_POOL_DEBUG) warningf("Pool: %s => No waiter avaliable.", _poolOptions.name);
                break;
            }

            // 
            T r = doBorrow();
            if(r is null) {
                version(HUNT_POOL_DEBUG) warningf("Pool: %s => No idle object avaliable", _poolOptions.name);
                break;
            } 

            FuturePromise!T waiter = safeGetFrontWaiter();
            if(waiter is null) {
                doReturning(r);
                break;
            }

            version(HUNT_POOL_DEBUG) {
                tracef("Borrowing for waiter [%s], isDone: %s", waiter.id(), waiter.isDone());
            }

            //
            try {
                if(waiter.succeeded(r)) {
                    version(HUNT_POOL_DEBUG) {
                        tracef("Borrowed for waiter [%s], result: %s", waiter.id(), (cast(Object)r).toString());
                    }                    
                } else {
                    warningf("Failed to set the result for promise [%s] with %s", 
                        waiter.id(), (cast(Object)r).toString());

                    doReturning(r);
                }
            } catch(Throwable ex) {
                warning(ex);
                doReturning(r);
            }
        }
    }

    /**
     * Returns the number of instances currently idle in this pool. This may be
     * considered an approximation of the number of objects that can be
     * {@link #borrowObject borrowed} without creating any new instances.
     * Returns a negative value if this information is not available.
     * @return the number of instances currently idle in this pool.
     */
    size_t getNumIdle() {
        size_t count = 0;

        foreach(PooledObject!(T) obj; _pooledObjects) {
            if(obj !is null && obj.isIdle()) {
                count++;
            } 
        }

        return count;
    }

    size_t getNumFree() {

        size_t count = 0;

        foreach(PooledObject!(T) obj; _pooledObjects) {
            if(obj is null || obj.isUnusable() || obj.isInvalid()) {
                count++;
            } 
        }

        return count;        
    }

    /**
     * Returns the number of instances currently borrowed from this pool. Returns
     * a negative value if this information is not available.
     * @return the number of instances currently borrowed from this pool.
     */
    size_t getNumActive() {
        size_t count = 0;

        foreach(PooledObject!(T) obj; _pooledObjects) {
            if(obj !is null && obj.isInUse()) {
                count++;
            } 
        }

        return count;        
    }

    /**
     * Returns an estimate of the number of threads currently blocked waiting for
     * an object from the pool. This is intended for monitoring only, not for
     * synchronization control.
     *
     * @return The estimate of the number of threads currently blocked waiting
     *         for an object from the pool
     */
    size_t getNumWaiters() {
        _waitersLocker.lock();
        scope(exit) {
            _waitersLocker.unlock();
        } 
        return walkLength(_waiters[]);
    }

    /**
     * Clears any objects sitting idle in the pool, releasing any associated
     * resources (optional operation). Idle objects cleared must be
     * {@link PooledObjectFactory#destroyObject(PooledObject)}.
     *
     * @throws Exception if the pool cannot be cleared
     */
    void clear() {
        version(HUNT_POOL_DEBUG) {
            infof("Pool [%s] is clearing...", _poolOptions.name);
        }

        bool r = cas(&_isClearing, false, true);
        if(!r) {
            return;
        }

        _borrowLocker.lock();
        scope(exit) {
            _isClearing = false;
            version(HUNT_POOL_DEBUG) infof("Pool [%s] is cleared...", _poolOptions.name);
            _borrowLocker.unlock();        
        }

        for(size_t index; index<_pooledObjects.length; index++) {
            PooledObject!(T) obj = _pooledObjects[index];

            if(obj !is null) {
                version(HUNT_POOL_DEBUG) {
                    tracef("clearing object: id=%d, slot=%d", obj.id, index);
                }

                _pooledObjects[index] = null;
                obj.abandoned();

                // TODO: It's better to run it asynchronously
                _factory.destroyObject(obj.getObject());
            }
        }
    }

    /**
     * Closes this pool, and free any resources associated with it.
     * <p>
     * Calling {@link #borrowObject} after invoking this
     * method on a pool will cause them to throw an {@link IllegalStateException}.
     * </p>
     * <p>
     * Implementations should silently fail if not all resources can be freed.
     * </p>
     */
    void close() {
        version(HUNT_DEBUG) {
            // infof("Closing pool %s (state=%s)...", _poolOptions.name, _state);
            tracef(toString());
        }

        bool r = cas(&_state, ObjectPoolState.Open, ObjectPoolState.Closing);
        if(!r) {
            return;
        }

        scope(exit) {
            _state = ObjectPoolState.Closed;
            version(HUNT_POOL_DEBUG) {
                infof("Pool %s closed...", _poolOptions.name);
            }
        }

        for(size_t index; index<_pooledObjects.length; index++) {
            PooledObject!(T) obj = _pooledObjects[index];

            if(obj !is null) {
                version(HUNT_POOL_DEBUG) {
                    tracef("Pool: %s, destroying object: id=%d, slot=%d, state: %s", 
                        _poolOptions.name,  obj.id, index, obj.state());

                    if(obj.state() == PooledObjectState.ALLOCATED) {
                        warningf("binded obj: %s", (cast(Object)obj.getObject()).toString());
                    }
                }

                _pooledObjects[index] = null;
                obj.abandoned();

                // TODO: It's better to run it asynchronously
                _factory.destroyObject(obj.getObject());
            }
        }

    }

    override string toString() {
        string str = format("Name: %s, Total: %d, Active: %d, Idle: %d, Free: %d, Waiters: %d", 
                _poolOptions.name, size(), getNumActive(), getNumIdle(), getNumFree(), getNumWaiters());
        return str;
    }
}