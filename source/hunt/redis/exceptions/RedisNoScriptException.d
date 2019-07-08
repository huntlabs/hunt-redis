module hunt.redis.exceptions.RedisNoScriptException;

public class RedisNoScriptException : RedisDataException  {

  public RedisNoScriptException(final String message) { super(message); }

  public RedisNoScriptException(final Throwable cause) { super(cause); }

  public RedisNoScriptException(final String message, final Throwable cause) { super(message, cause); }
}
