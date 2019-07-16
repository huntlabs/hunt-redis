module hunt.redis.GeoCoordinate;

import hunt.Double;
import hunt.util.Comparator;

import std.conv;

class GeoCoordinate {
  private double longitude;
  private double latitude;

  this(double longitude, double latitude) {
    this.longitude = longitude;
    this.latitude = latitude;
  }

  double getLongitude() {
    return longitude;
  }

  double getLatitude() {
    return latitude;
  }

  override
  bool opEquals(Object o) {
    if (o is null) return false;
    if (o is this) return true;

    GeoCoordinate that = cast(GeoCoordinate) o;
    if(that is null)
      return false;

    if (compare(that.longitude, longitude) != 0) return false;
    return compare(that.latitude, latitude) == 0;
  }

  override
  size_t toHash() @trusted nothrow {
    // follows IntelliJ default hashCode implementation
    int result;
    long temp;
    temp = cast(long)longitude; // Double.doubleToLongBits(longitude);
    result = cast(int) (temp ^ (temp >>> 32));
    temp = cast(long)latitude; // Double.doubleToLongBits(latitude);
    result = 31 * result + cast(int) (temp ^ (temp >>> 32));
    return result;
  }

  override
  string toString() {
    return "(" ~ longitude.to!string() ~ "," ~ latitude.to!string() ~ ")";
  }
}
