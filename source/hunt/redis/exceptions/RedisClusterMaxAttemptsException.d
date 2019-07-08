module hunt.redis.exceptions.RedisClusterMaxAttemptsException;

public class RedisClusterMaxAttemptsException : RedisClusterOperationException {

  public RedisClusterMaxAttemptsException(String message) {
    super(message);
  }

  public RedisClusterMaxAttemptsException(Throwable cause) {
    super(cause);
  }

  public RedisClusterMaxAttemptsException(String message, Throwable cause) {
    super(message, cause);
  }
}
