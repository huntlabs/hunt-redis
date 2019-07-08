module hunt.redis.exceptions.RedisDataException;

class RedisDataException : RedisException {

  RedisDataException(String message) {
    super(message);
  }

  RedisDataException(Throwable cause) {
    super(cause);
  }

  RedisDataException(String message, Throwable cause) {
    super(message, cause);
  }
}
