module hunt.redis.Builder;

public abstract class Builder<T> {
  public abstract T build(Object data);
}
