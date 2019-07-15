module hunt.redis.GeoRadiusResponse;

import hunt.redis.GeoCoordinate;

import hunt.redis.util.SafeEncoder;

class GeoRadiusResponse {
  private byte[] member;
  private double distance;
  private GeoCoordinate coordinate;

  this(byte[] member) {
    this.member = member;
  }

  void setDistance(double distance) {
    this.distance = distance;
  }

  void setCoordinate(GeoCoordinate coordinate) {
    this.coordinate = coordinate;
  }

  byte[] getMember() {
    return member;
  }

  string getMemberByString() {
    return SafeEncoder.encode(member);
  }

  double getDistance() {
    return distance;
  }

  GeoCoordinate getCoordinate() {
    return coordinate;
  }
}
