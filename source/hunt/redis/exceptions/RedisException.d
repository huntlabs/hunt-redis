module hunt.redis.exceptions.RedisException;

public class RedisException : RuntimeException {

  public RedisException(String message) {
    super(message);
  }

  public RedisException(Throwable e) {
    super(e);
  }

  public RedisException(String message, Throwable cause) {
    super(message, cause);
  }
}
