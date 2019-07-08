module hunt.redis.exceptions.InvalidURIException;

class InvalidURIException : RedisException {


  InvalidURIException(String message) {
    super(message);
  }

  InvalidURIException(Throwable cause) {
    super(cause);
  }

  InvalidURIException(String message, Throwable cause) {
    super(message, cause);
  }

}
