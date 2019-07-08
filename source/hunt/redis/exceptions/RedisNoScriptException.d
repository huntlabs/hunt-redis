module hunt.redis.exceptions.RedisNoScriptException;

class RedisNoScriptException : RedisDataException  {

  RedisNoScriptException(final String message) { super(message); }

  RedisNoScriptException(final Throwable cause) { super(cause); }

  RedisNoScriptException(final String message, final Throwable cause) { super(message, cause); }
}
