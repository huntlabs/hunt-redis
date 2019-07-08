module hunt.redis.util.ShardInfo;

abstract class ShardInfo!(T) {
  private int weight;

  ShardInfo() {
  }

  ShardInfo(int weight) {
    this.weight = weight;
  }

  int getWeight() {
    return this.weight;
  }

  protected abstract T createResource();

  abstract String getName();
}
