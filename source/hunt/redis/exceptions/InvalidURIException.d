module hunt.redis.exceptions.InvalidURIException;

public class InvalidURIException : RedisException {


  public InvalidURIException(String message) {
    super(message);
  }

  public InvalidURIException(Throwable cause) {
    super(cause);
  }

  public InvalidURIException(String message, Throwable cause) {
    super(message, cause);
  }

}
