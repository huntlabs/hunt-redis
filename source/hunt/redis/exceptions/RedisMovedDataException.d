module hunt.redis.exceptions.RedisMovedDataException;

import hunt.redis.HostAndPort;

class RedisMovedDataException : RedisRedirectionException {

  RedisMovedDataException(string message, HostAndPort targetNode, int slot) {
    super(message, targetNode, slot);
  }

  RedisMovedDataException(Throwable cause, HostAndPort targetNode, int slot) {
    super(cause, targetNode, slot);
  }

  RedisMovedDataException(string message, Throwable cause, HostAndPort targetNode, int slot) {
    super(message, cause, targetNode, slot);
  }
}
