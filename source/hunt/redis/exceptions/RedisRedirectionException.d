module hunt.redis.exceptions.RedisRedirectionException;

import hunt.redis.HostAndPort;

public class RedisRedirectionException : RedisDataException {

  private HostAndPort targetNode;
  private int slot;

  public RedisRedirectionException(String message, HostAndPort targetNode, int slot) {
    super(message);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  public RedisRedirectionException(Throwable cause, HostAndPort targetNode, int slot) {
    super(cause);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  public RedisRedirectionException(String message, Throwable cause, HostAndPort targetNode, int slot) {
    super(message, cause);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  public HostAndPort getTargetNode() {
    return targetNode;
  }

  public int getSlot() {
    return slot;
  }
}
