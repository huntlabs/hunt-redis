module hunt.redis.exceptions.RedisNoScriptException;

class RedisNoScriptException : RedisDataException  {

  RedisNoScriptException(string message) { super(message); }

  RedisNoScriptException(Throwable cause) { super(cause); }

  RedisNoScriptException(string message, Throwable cause) { super(message, cause); }
}
