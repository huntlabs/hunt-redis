module hunt.redis.exceptions.RedisBusyException;

class RedisBusyException : RedisDataException {


    RedisBusyException(string message) {
        super(message);
    }

    RedisBusyException(Throwable cause) {
        super(cause);
    }

    RedisBusyException(string message, Throwable cause) {
        super(message, cause);
    }

}
