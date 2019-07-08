module hunt.redis.exceptions;

public class RedisBusyException extends RedisDataException {

    private static final long serialVersionUID = 3992655220229243478L;

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
