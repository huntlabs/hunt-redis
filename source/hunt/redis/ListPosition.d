module hunt.redis;

import hunt.redis.util.SafeEncoder;

public enum ListPosition {
  BEFORE, AFTER;
  public final byte[] raw;

  private ListPosition() {
    raw = SafeEncoder.encode(name());
  }
}
