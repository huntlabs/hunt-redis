module hunt.redis.exceptions.RedisConnectionException;

public class RedisConnectionException : RedisException {

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
