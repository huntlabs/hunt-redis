module hunt.redis.exceptions.RedisClusterOperationException;

public class RedisClusterOperationException extends RedisException {
  private static final long serialVersionUID = 8124535086306604887L;

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