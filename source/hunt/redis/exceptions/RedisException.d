module hunt.redis.exceptions.RedisException;

class RedisException : RuntimeException {

  RedisException(String message) {
    super(message);
  }

  RedisException(Throwable e) {
    super(e);
  }

  RedisException(String message, Throwable cause) {
    super(message, cause);
  }
}
