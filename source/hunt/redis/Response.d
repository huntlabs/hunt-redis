module hunt.redis.Response;

import hunt.redis.exceptions.RedisDataException;

class Response!(T) {
  protected T response = null;
  protected RedisDataException exception = null;

  private bool building = false;
  private bool built = false;
  private bool set = false;

  private Builder!(T) builder;
  private Object data;
  private Response<?> dependency = null;

  Response(Builder!(T) b) {
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

  void setDependency(Response<?> dependency) {
    this.dependency = dependency;
  }

  private void build() {
    // check build state to prevent recursion
    if (building) {
      return;
    }

    building = true;
    try {
      if (data !is null) {
        if (data instanceof RedisDataException) {
          exception = (RedisDataException) data;
        } else {
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
