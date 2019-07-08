module hunt.redis.ListPosition;

import hunt.redis.util.SafeEncoder;

public enum ListPosition {
  BEFORE, AFTER;
  final byte[] raw;

  private ListPosition() {
    raw = SafeEncoder.encode(name());
  }
}
