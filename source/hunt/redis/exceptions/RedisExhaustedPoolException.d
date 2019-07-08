module hunt.redis.exceptions;

/**
 * This exception will be thrown when the Redis client isn't able to retrieve a connection from the
 * pool, since all the connections are being used (a.k.a. an "exhausted" pool).
 */
public class RedisExhaustedPoolException extends RedisException {

  public RedisExhaustedPoolException(String message) {
    super(message);
  }

  public RedisExhaustedPoolException(Throwable e) {
    super(e);
  }

  public RedisExhaustedPoolException(String message, Throwable cause) {
    super(message, cause);
  }
}
