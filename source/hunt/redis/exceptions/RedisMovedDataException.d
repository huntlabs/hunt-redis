module hunt.redis.exceptions.RedisMovedDataException;

import hunt.redis.HostAndPort;

public class RedisMovedDataException : RedisRedirectionException {

  public RedisMovedDataException(String message, HostAndPort targetNode, int slot) {
    super(message, targetNode, slot);
  }

  public RedisMovedDataException(Throwable cause, HostAndPort targetNode, int slot) {
    super(cause, targetNode, slot);
  }

  public RedisMovedDataException(String message, Throwable cause, HostAndPort targetNode, int slot) {
    super(message, cause, targetNode, slot);
  }
}
