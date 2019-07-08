module hunt.redis.exceptions.RedisClusterOperationException;

public class RedisClusterOperationException : RedisException {

  public RedisClusterOperationException(String message) {
    super(message);
  }

  public RedisClusterOperationException(Throwable cause) {
    super(cause);
  }

  public RedisClusterOperationException(String message, Throwable cause) {
    super(message, cause);
  }
}