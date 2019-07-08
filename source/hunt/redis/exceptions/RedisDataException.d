module hunt.redis.exceptions.RedisDataException;

public class RedisDataException extends RedisException {
  private static final long serialVersionUID = 3878126572474819403L;

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
