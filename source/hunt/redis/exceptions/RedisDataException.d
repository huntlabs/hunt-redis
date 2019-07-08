module hunt.redis.exceptions.RedisDataException;

public class RedisDataException : RedisException {

  public RedisDataException(String message) {
    super(message);
  }

  public RedisDataException(Throwable cause) {
    super(cause);
  }

  public RedisDataException(String message, Throwable cause) {
    super(message, cause);
  }
}
