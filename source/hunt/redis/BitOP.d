module hunt.redis.BitOP;

public enum BitOP {
  AND, OR, XOR, NOT;

  final byte[] raw;

  private BitOP() {
    this.raw = hunt.redis.util.SafeEncoder.encode(name());
  }
}
