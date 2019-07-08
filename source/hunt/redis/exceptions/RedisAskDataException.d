module hunt.redis.exceptions.RedisAskDataException;

import hunt.redis.HostAndPort;

class RedisAskDataException : RedisRedirectionException {

  RedisAskDataException(Throwable cause, HostAndPort targetHost, int slot) {
    super(cause, targetHost, slot);
  }

  RedisAskDataException(String message, Throwable cause, HostAndPort targetHost, int slot) {
    super(message, cause, targetHost, slot);
  }

  RedisAskDataException(String message, HostAndPort targetHost, int slot) {
    super(message, targetHost, slot);
  }

}
