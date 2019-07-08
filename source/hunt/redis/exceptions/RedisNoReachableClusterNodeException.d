module hunt.redis.exceptions.RedisNoReachableClusterNodeException;

public class RedisNoReachableClusterNodeException : RedisConnectionException {

    public RedisNoReachableClusterNodeException(String message) {
        super(message);
    }

    public RedisNoReachableClusterNodeException(Throwable cause) {
        super(cause);
    }

    public RedisNoReachableClusterNodeException(String message, Throwable cause) {
        super(message, cause);
    }
}
