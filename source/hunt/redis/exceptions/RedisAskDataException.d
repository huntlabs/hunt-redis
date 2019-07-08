module hunt.redis.exceptions;

import hunt.redis.HostAndPort;

public class RedisAskDataException extends RedisRedirectionException {
  private static final long serialVersionUID = 3878126572474819403L;

  public RedisAskDataException(Throwable cause, HostAndPort targetHost, int slot) {
    super(cause, targetHost, slot);
  }

  public RedisAskDataException(String message, Throwable cause, HostAndPort targetHost, int slot) {
    super(message, cause, targetHost, slot);
  }

  public RedisAskDataException(String message, HostAndPort targetHost, int slot) {
    super(message, targetHost, slot);
  }

}
