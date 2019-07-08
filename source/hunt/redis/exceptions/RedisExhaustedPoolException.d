module hunt.redis.exceptions.RedisExhaustedPoolException;

/**
 * This exception will be thrown when the Redis client isn't able to retrieve a connection from the
 * pool, since all the connections are being used (a.k.a. an "exhausted" pool).
 */
class RedisExhaustedPoolException : RedisException {

  RedisExhaustedPoolException(String message) {
    super(message);
  }

  RedisExhaustedPoolException(Throwable e) {
    super(e);
  }

  RedisExhaustedPoolException(String message, Throwable cause) {
    super(message, cause);
  }
}
