module hunt.redis.exceptions.RedisNoReachableClusterNodeException;

class RedisNoReachableClusterNodeException : RedisConnectionException {

    RedisNoReachableClusterNodeException(string message) {
        super(message);
    }

    RedisNoReachableClusterNodeException(Throwable cause) {
        super(cause);
    }

    RedisNoReachableClusterNodeException(string message, Throwable cause) {
        super(message, cause);
    }
}
