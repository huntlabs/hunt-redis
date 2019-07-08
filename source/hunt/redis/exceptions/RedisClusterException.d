module hunt.redis.exceptions.RedisClusterException;

class RedisClusterException : RedisDataException {

  RedisClusterException(Throwable cause) {
    super(cause);
  }

  RedisClusterException(String message, Throwable cause) {
    super(message, cause);
  }

  RedisClusterException(String message) {
    super(message);
  }
}
