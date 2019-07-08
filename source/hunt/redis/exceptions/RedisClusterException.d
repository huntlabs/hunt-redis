module hunt.redis.exceptions.RedisClusterException;

public class RedisClusterException : RedisDataException {

  public RedisClusterException(Throwable cause) {
    super(cause);
  }

  public RedisClusterException(String message, Throwable cause) {
    super(message, cause);
  }

  public RedisClusterException(String message) {
    super(message);
  }
}
