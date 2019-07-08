module hunt.redis.exceptions.RedisNoReachableClusterNodeException;

class RedisNoReachableClusterNodeException : RedisConnectionException {

    RedisNoReachableClusterNodeException(String message) {
        super(message);
    }

    RedisNoReachableClusterNodeException(Throwable cause) {
        super(cause);
    }

    RedisNoReachableClusterNodeException(String message, Throwable cause) {
        super(message, cause);
    }
}
