module hunt.util.pool.PooledObjectState;



/**
 * Provides the possible states that a {@link PooledObject} may be in.
 *
 */
enum PooledObjectState {
    /**
     * Not ready (Creating)
     */
    UNUSABLE,

    /**
     * In the queue, not in use.
     */
    IDLE,

    /**
     * In use.
     */
    ALLOCATED,

    /**
     * Failed maintenance (e.g. eviction test or validation) and will be / has
     * been destroyed
     */
    INVALID,

    /**
     * Deemed abandoned, to be invalidated.
     */
    ABANDONED,

    // /**
    //  * Returning to the pool.
    //  */
    // RETURNING
}