module hunt.redis.exceptions;

public class RedisClusterMaxAttemptsException extends RedisClusterOperationException {
  private static final long serialVersionUID = 167600616259092761L;

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
