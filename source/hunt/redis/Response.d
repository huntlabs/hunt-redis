module hunt.redis.Response;

import hunt.redis.exceptions.RedisDataException;

abstract class AbstractResponse {
  protected bool building = false;
  protected bool built = false;
  protected bool set = false;

  protected RedisDataException exception = null;
  protected Object data;

  protected void build();
}

class Response(T) : AbstractResponse {
  protected T response = null;

  private Builder!(T) builder;
  private AbstractResponse dependency = null;

  this(Builder!(T) b) {
    this.builder = b;
  }

  void set(Object data) {
    this.data = data;
    set = true;
  }

  T get() {
    // if response has dependency response and dependency is not built,
    // build it first and no more!!
    if (dependency !is null && dependency.set && !dependency.built) {
      dependency.build();
    }
    if (!set) {
      throw new RedisDataException(
          "Please close pipeline or multi block before calling this method.");
    }
    if (!built) {
      build();
    }
    if (exception !is null) {
      throw exception;
    }
    return response;
  }

  void setDependency(AbstractResponse dependency) {
    this.dependency = dependency;
  }

  protected void build() {
    // check build state to prevent recursion
    if (building) {
      return;
    }

    building = true;
    try {
      if (data !is null) {
        exception = cast(RedisDataException) data;
        if (exception is null) {
          response = builder.build(data);
        }
      }

      data = null;
    } finally {
      building = false;
      built = true;
    }
  }

  override
  string toString() {
    return "Response " ~ builder.toString();
  }

}
