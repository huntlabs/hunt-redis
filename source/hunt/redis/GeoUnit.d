module hunt.redis.GeoUnit;

import hunt.redis.util.SafeEncoder;

public enum GeoUnit {
  M, KM, MI, FT;

  final byte[] raw;

  GeoUnit() {
    raw = SafeEncoder.encode(this.name().toLowerCase());
  }
}
