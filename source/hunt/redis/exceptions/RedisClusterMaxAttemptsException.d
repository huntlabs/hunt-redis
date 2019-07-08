module hunt.redis.exceptions.RedisClusterMaxAttemptsException;

class RedisClusterMaxAttemptsException : RedisClusterOperationException {

  RedisClusterMaxAttemptsException(String message) {
    super(message);
  }

  RedisClusterMaxAttemptsException(Throwable cause) {
    super(cause);
  }

  RedisClusterMaxAttemptsException(String message, Throwable cause) {
    super(message, cause);
  }
}
