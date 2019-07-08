module hunt.redis.exceptions.RedisClusterException;

class RedisClusterException : RedisDataException {

  RedisClusterException(Throwable cause) {
    super(cause);
  }

  RedisClusterException(string message, Throwable cause) {
    super(message, cause);
  }

  RedisClusterException(string message) {
    super(message);
  }
}
