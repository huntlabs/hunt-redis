module hunt.redis;

public enum BitOP {
  AND, OR, XOR, NOT;

  public final byte[] raw;

  private BitOP() {
    this.raw = hunt.redis.util.SafeEncoder.encode(name());
  }
}
