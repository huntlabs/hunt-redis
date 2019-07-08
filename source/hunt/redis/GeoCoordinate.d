module hunt.redis.GeoCoordinate;

class GeoCoordinate {
  private double longitude;
  private double latitude;

  GeoCoordinate(double longitude, double latitude) {
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
  bool equals(Object o) {
    if (o == null) return false;
    if (o == this) return true;
    if (!(o instanceof GeoCoordinate)) return false;

    GeoCoordinate that = (GeoCoordinate) o;

    if (Double.compare(that.longitude, longitude) != 0) return false;
    return Double.compare(that.latitude, latitude) == 0;
  }

  override
  size_t toHash() @trusted nothrow() {
    // follows IntelliJ default hashCode implementation
    int result;
    long temp;
    temp = Double.doubleToLongBits(longitude);
    result = (int) (temp ^ (temp >>> 32));
    temp = Double.doubleToLongBits(latitude);
    result = 31 * result + (int) (temp ^ (temp >>> 32));
    return result;
  }

  override
  String toString() {
    return "(" + longitude + "," + latitude + ")";
  }
}
