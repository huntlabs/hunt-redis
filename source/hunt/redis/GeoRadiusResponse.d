module hunt.redis.GeoRadiusResponse;

import hunt.redis.GeoCoordinate;

import hunt.redis.util.SafeEncoder;

class GeoRadiusResponse {
    private string member;
    private double distance;
    private GeoCoordinate coordinate;

    this(string member) {
        this.member = member;
    }

    void setDistance(double distance) {
        this.distance = distance;
    }

    void setCoordinate(GeoCoordinate coordinate) {
        this.coordinate = coordinate;
    }

    string getMember() {
        return member;
    }

    // string getMemberByString() {
    //     return SafeEncoder.encode(member);
    // }

    double getDistance() {
        return distance;
    }

    GeoCoordinate getCoordinate() {
        return coordinate;
    }
}
