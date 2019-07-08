module hunt.redis.exceptions;

public class RedisNoScriptException extends RedisDataException  {
  private static final long serialVersionUID = 4674378093072060731L;

  public RedisNoScriptException(final String message) { super(message); }

  public RedisNoScriptException(final Throwable cause) { super(cause); }

  public RedisNoScriptException(final String message, final Throwable cause) { super(message, cause); }
}
