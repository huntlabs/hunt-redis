module hunt.redis.Builder;

abstract class Builder!(T) {
  abstract T build(Object data);
}
