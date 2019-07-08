module hunt.redis.exceptions.RedisException;

class RedisException : RuntimeException {

  RedisException(string message) {
    super(message);
  }

  RedisException(Throwable e) {
    super(e);
  }

  RedisException(string message, Throwable cause) {
    super(message, cause);
  }
}
