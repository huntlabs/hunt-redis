module hunt.util.pool.PooledObject;

import core.atomic;
import std.datetime;

import hunt.logging.ConsoleLogger;

import hunt.util.pool.PooledObjectState;

/**
 * Defines the wrapper that is used to track the additional information, such as
 * state, for the pooled objects.
 * <p>
 * Implementations of this class are required to be thread-safe.
 *
 * @param <T> the type of object in the pool
 *
 */
class PooledObject(T) {
    private size_t _id;
    private T _obj;
    private shared PooledObjectState _state;
    private SysTime _createTime;
    private SysTime _lastBorrowTime;
    private SysTime _lastUseTime;
    private SysTime _lastReturnTime;
    private shared long _borrowedCount = 0;
    private static shared size_t _counter;

    this() {
        _state = PooledObjectState.UNUSABLE;
        _createTime = Clock.currTime;
        _id = atomicOp!("+=")(_counter, 1);
    }

    this(T obj) {
        assert(obj !is null);

        _obj = obj;
        _state = PooledObjectState.IDLE;
        _createTime = Clock.currTime;
        _id = atomicOp!("+=")(_counter, 1);
    }

    // package void bind(T obj) {
    //     _obj = obj;
    //     _state = PooledObjectState.IDLE;
    // }

    size_t id() {
        return _id;
    }

    /**
     * Obtains the underlying object that is wrapped by this instance of
     * {@link PooledObject}.
     *
     * @return The wrapped object
     */
    T getObject() {
        return _obj;
    }  

    SysTime createTime() {
        return _createTime;
    }    

    SysTime lastBorrowTime() {
        return _lastBorrowTime;
    }

    SysTime lastReturnTime() {
        return _lastReturnTime;
    }

    /**
     * Get the number of times this object has been borrowed.
     * @return The number of times this object has been borrowed.
     */
    long borrowedCount() {
        return _borrowedCount;
    }

    /**
     * Returns the state of this object.
     * @return state
     */
    PooledObjectState state() {
        return _state;
    }

    /**
     * Allocates the object.
     *
     * @return {@code true} if the original state was {@link PooledObjectState#IDLE IDLE}
     */
    bool allocate() {
        version(HUNT_POOL_DEBUG) tracef(toString());

        if(cas(&_state, PooledObjectState.IDLE, PooledObjectState.ALLOCATED)) {
            _lastBorrowTime = Clock.currTime;
            _lastUseTime = _lastBorrowTime;
            atomicOp!("+=")(_borrowedCount, 1);
            return true;
        } else {
            version(HUNT_DEBUG) warningf("allocate collision: %s", toString());
        }
        
        return false;        
    }


    /**
     * Allocates the object.
     *
     * @return {@code true} if the original state was {@link PooledObjectState#IDLE IDLE}
     */
    bool allocate(T obj) {
        // version(HUNT_POOL_DEBUG) tracef(toString());

        if(cas(&_state, PooledObjectState.UNUSABLE, PooledObjectState.ALLOCATED)) {
            _obj = obj;
            _lastBorrowTime = Clock.currTime;
            _lastUseTime = _lastBorrowTime;
            atomicOp!("+=")(_borrowedCount, 1);
            return true;
        } else {
            version(HUNT_DEBUG) warningf("allocate collision: %s", toString());
        }
        
        return false;        
    }    

    /**
     * Sets the state to {@link PooledObjectState#INVALID INVALID}
     */
    void invalidate() {
        _state = PooledObjectState.INVALID;
    }

    /**
     * Marks the pooled object as abandoned.
     */
    void abandoned() {
        _state = PooledObjectState.ABANDONED;
    }

    /**
     * Marks the object as returning to the pool.
     */
    bool returning() { 
        version(HUNT_POOL_DEBUG_MORE) tracef(toString());
        if(cas(&_state, PooledObjectState.ALLOCATED, PooledObjectState.IDLE)) {
            _lastReturnTime = Clock.currTime;
            return true;
        }

        return false;        
    }

    bool isIdle() {
        return _state == PooledObjectState.IDLE;
    }

    bool isInUse() {
        return _state == PooledObjectState.ALLOCATED;
    }

    bool isInvalid() {
        return _state == PooledObjectState.INVALID;
    }

    bool isUnusable() {
        return _state == PooledObjectState.UNUSABLE;
    }

    override string toString() {
        import std.format;
        string str = format("id: %d, state: %s, binded: {%s}", 
             id(), _state, _obj is null ? "null" : (cast(Object)_obj).toString());
        return str;
    }
    
}
