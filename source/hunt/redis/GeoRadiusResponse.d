/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
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

    string getMemberByString() {
        return cast(string)SafeEncoder.encode(member);
    }

    double getDistance() {
        return distance;
    }

    GeoCoordinate getCoordinate() {
        return coordinate;
    }
}
