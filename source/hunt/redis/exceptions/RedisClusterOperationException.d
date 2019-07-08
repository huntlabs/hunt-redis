module hunt.redis.exceptions.RedisClusterOperationException;

class RedisClusterOperationException : RedisException {

  RedisClusterOperationException(string message) {
    super(message);
  }

  RedisClusterOperationException(Throwable cause) {
    super(cause);
  }

  RedisClusterOperationException(string message, Throwable cause) {
    super(message, cause);
  }
}