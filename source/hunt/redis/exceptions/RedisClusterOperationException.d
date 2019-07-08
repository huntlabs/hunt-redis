module hunt.redis.exceptions.RedisClusterOperationException;

class RedisClusterOperationException : RedisException {

  RedisClusterOperationException(String message) {
    super(message);
  }

  RedisClusterOperationException(Throwable cause) {
    super(cause);
  }

  RedisClusterOperationException(String message, Throwable cause) {
    super(message, cause);
  }
}