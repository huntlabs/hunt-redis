module hunt.redis.exceptions.RedisBusyException;

class RedisBusyException : RedisDataException {


    RedisBusyException(final String message) {
        super(message);
    }

    RedisBusyException(final Throwable cause) {
        super(cause);
    }

    RedisBusyException(final String message, final Throwable cause) {
        super(message, cause);
    }

}
