module hunt.redis.exceptions.RedisNoReachableClusterNodeException;

public class RedisNoReachableClusterNodeException extends RedisConnectionException {
    private static final long serialVersionUID = 3878122572474110407L;

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
