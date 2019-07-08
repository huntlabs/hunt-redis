module hunt.redis.exceptions.RedisClusterMaxAttemptsException;

class RedisClusterMaxAttemptsException : RedisClusterOperationException {

  RedisClusterMaxAttemptsException(string message) {
    super(message);
  }

  RedisClusterMaxAttemptsException(Throwable cause) {
    super(cause);
  }

  RedisClusterMaxAttemptsException(string message, Throwable cause) {
    super(message, cause);
  }
}
