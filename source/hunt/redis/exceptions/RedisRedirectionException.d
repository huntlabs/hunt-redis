module hunt.redis.exceptions.RedisRedirectionException;

import hunt.redis.HostAndPort;

class RedisRedirectionException : RedisDataException {

  private HostAndPort targetNode;
  private int slot;

  RedisRedirectionException(String message, HostAndPort targetNode, int slot) {
    super(message);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  RedisRedirectionException(Throwable cause, HostAndPort targetNode, int slot) {
    super(cause);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  RedisRedirectionException(String message, Throwable cause, HostAndPort targetNode, int slot) {
    super(message, cause);
    this.targetNode = targetNode;
    this.slot = slot;
  }

  HostAndPort getTargetNode() {
    return targetNode;
  }

  int getSlot() {
    return slot;
  }
}
