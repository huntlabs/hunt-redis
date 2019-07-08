module hunt.redis.exceptions.RedisConnectionException;

public class RedisConnectionException extends RedisException {
  private static final long serialVersionUID = 3878126572474819403L;

  public RedisConnectionException(String message) {
    super(message);
  }

  public RedisConnectionException(Throwable cause) {
    super(cause);
  }

  public RedisConnectionException(String message, Throwable cause) {
    super(message, cause);
  }
}
