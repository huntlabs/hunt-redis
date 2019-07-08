module hunt.redis.exceptions.RedisBusyException;

public class RedisBusyException : RedisDataException {


    public RedisBusyException(final String message) {
        super(message);
    }

    public RedisBusyException(final Throwable cause) {
        super(cause);
    }

    public RedisBusyException(final String message, final Throwable cause) {
        super(message, cause);
    }

}
