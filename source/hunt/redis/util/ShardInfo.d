module hunt.redis.util.ShardInfo;

abstract class ShardInfo(T) {
  private int weight;

  this() {
  }

  this(int weight) {
    this.weight = weight;
  }

  int getWeight() {
    return this.weight;
  }

  protected abstract T createResource();

  abstract string getName();
}
