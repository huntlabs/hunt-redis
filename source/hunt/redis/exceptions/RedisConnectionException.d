module hunt.redis.exceptions.RedisConnectionException;

class RedisConnectionException : RedisException {

  RedisConnectionException(String message) {
    super(message);
  }

  RedisConnectionException(Throwable cause) {
    super(cause);
  }

  RedisConnectionException(String message, Throwable cause) {
    super(message, cause);
  }
}
