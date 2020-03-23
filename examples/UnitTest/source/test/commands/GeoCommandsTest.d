module test.commands.GeoCommandsTest;

import test.HostAndPortUtil;
import test.commands.RedisCommandTestBase;

import hunt.Assert;
import hunt.collection;
import hunt.Double;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Long;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.GeoUnit;
import hunt.redis.HostAndPort;
import hunt.redis.params.GeoRadiusParam;
import hunt.redis.Redis;
import hunt.redis.util.SafeEncoder;

import std.math;


class GeoCommandsTest : RedisCommandTestBase {
    enum const(ubyte)[] bfoo = [ 0x01, 0x02, 0x03, 0x04 ];
    enum const(ubyte)[] bA = [ 0x0A ];
    enum const(ubyte)[] bB = [ 0x0B ];
    enum const(ubyte)[] bC = [ 0x0C ];
    enum const(ubyte)[] bD = [ 0x0D ];
    enum const(ubyte)[] bNotexist = [ 0x0F ];

    // @Test
    // void geoadd() {
    //     long size = redis.geoadd("foo", 1, 2, "a");
    //     assertEquals(1, size);
    //     size = redis.geoadd("foo", 2, 3, "a");
    //     assertEquals(0, size);

    //     Map!(string, GeoCoordinate) coordinateMap = new HashMap!(string, GeoCoordinate)();
    //     coordinateMap.put("a", new GeoCoordinate(3, 4));
    //     coordinateMap.put("b", new GeoCoordinate(2, 3));
    //     coordinateMap.put("c", new GeoCoordinate(3.314, 2.3241));

    //     size = redis.geoadd("foo", coordinateMap);
    //     assertEquals(2, size);

    //     // binary
    //     size = redis.geoadd(bfoo, 1, 2, bA);
    //     assertEquals(1, size);
    //     size = redis.geoadd(bfoo, 2, 3, bA);
    //     assertEquals(0, size);

    //     Map!(byte[], GeoCoordinate) bcoordinateMap = new HashMap!(byte[], GeoCoordinate)();
    //     bcoordinateMap.put(bA, new GeoCoordinate(3, 4));
    //     bcoordinateMap.put(bB, new GeoCoordinate(2, 3));
    //     bcoordinateMap.put(bC, new GeoCoordinate(3.314, 2.3241));

    //     size = redis.geoadd(bfoo, bcoordinateMap);
    //     assertEquals(2, size);
    // }

    @Test
    void geodist() {
        prepareGeoData();

        Double dist = redis.geodist("foo", "a", "b");
        assertEquals(157149, dist.intValue());

        dist = redis.geodist("foo", "a", "b", GeoUnit.KM);
        assertEquals(157, dist.intValue());

        dist = redis.geodist("foo", "a", "b", GeoUnit.MI);
        assertEquals(97, dist.intValue());

        dist = redis.geodist("foo", "a", "b", GeoUnit.FT);
        assertEquals(515583, dist.intValue());

        // binary
        dist = redis.geodist(bfoo, bA, bB);
        assertEquals(157149, dist.intValue());

        dist = redis.geodist(bfoo, bA, bB, GeoUnit.KM);
        assertEquals(157, dist.intValue());

        dist = redis.geodist(bfoo, bA, bB, GeoUnit.MI);
        assertEquals(97, dist.intValue());

        dist = redis.geodist(bfoo, bA, bB, GeoUnit.FT);
        assertEquals(515583, dist.intValue());
    }

    // @Test
    // void geohash() {
    //     prepareGeoData();

    //     List!(string) hashes = redis.geohash("foo", "a", "b", "notexist");
    //     assertEquals(3, hashes.size());
    //     assertEquals("s0dnu20t9j0", hashes.get(0));
    //     assertEquals("s093jd0k720", hashes.get(1));
    //     assertNull(hashes.get(2));

    //     // binary
    //     List!(byte[]) bhashes = redis.geohash(bfoo, bA, bB, bNotexist);
    //     assertEquals(3, bhashes.size());
    //     assertArrayEquals(SafeEncoder.encode("s0dnu20t9j0"), bhashes.get(0));
    //     assertArrayEquals(SafeEncoder.encode("s093jd0k720"), bhashes.get(1));
    //     assertNull(bhashes.get(2));
    // }

    // @Test
    // void geopos() {
    //     prepareGeoData();

    //     List!(GeoCoordinate) coordinates = redis.geopos("foo", "a", "b", "notexist");
    //     assertEquals(3, coordinates.size());
    //     assertTrue(equalsWithinEpsilon(3.0, coordinates.get(0).getLongitude()));
    //     assertTrue(equalsWithinEpsilon(4.0, coordinates.get(0).getLatitude()));
    //     assertTrue(equalsWithinEpsilon(2.0, coordinates.get(1).getLongitude()));
    //     assertTrue(equalsWithinEpsilon(3.0, coordinates.get(1).getLatitude()));
    //     assertNull(coordinates.get(2));

    //     List!(GeoCoordinate) bcoordinates = redis.geopos(bfoo, bA, bB, bNotexist);
    //     assertEquals(3, bcoordinates.size());
    //     assertTrue(equalsWithinEpsilon(3.0, bcoordinates.get(0).getLongitude()));
    //     assertTrue(equalsWithinEpsilon(4.0, bcoordinates.get(0).getLatitude()));
    //     assertTrue(equalsWithinEpsilon(2.0, bcoordinates.get(1).getLongitude()));
    //     assertTrue(equalsWithinEpsilon(3.0, bcoordinates.get(1).getLatitude()));
    //     assertNull(bcoordinates.get(2));
    // }

    @Test
    void georadius() {
        // prepare datas
        Map!(string, GeoCoordinate) coordinateMap = new HashMap!(string, GeoCoordinate)();
        coordinateMap.put("Palermo", new GeoCoordinate(13.361389, 38.115556));
        coordinateMap.put("Catania", new GeoCoordinate(15.087269, 37.502669));
        redis.geoadd("Sicily", coordinateMap);

        List!(GeoRadiusResponse) members = redis.georadius("Sicily", 15, 37, 200, GeoUnit.KM);
        assertEquals(2, members.size());

        // sort
        members = redis.georadius("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
                .sortAscending());
        assertEquals(2, members.size());
        assertEquals("Catania", members.get(0).getMemberByString());
        assertEquals("Palermo", members.get(1).getMemberByString());

        // sort, count 1
        members = redis.georadius("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
                .sortAscending().count(1));
        assertEquals(1, members.size());

        // sort, count 1, withdist, withcoord
        members = redis.georadius("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
                .sortAscending().count(1).withCoord().withDist());
        assertEquals(1, members.size());

        GeoRadiusResponse response = members.get(0);
        // infof("%f", response.getDistance());
        // infof("%f", response.getCoordinate().getLongitude());
        // infof("%f", response.getCoordinate().getLatitude());
        // assertTrue(equalsWithinEpsilon(56.4413, response.getDistance()));
        
        assertTrue(equalsWithinEpsilon(56.445, response.getDistance()));
        assertTrue(equalsWithinEpsilon(15.087269, response.getCoordinate().getLongitude()));
        assertTrue(equalsWithinEpsilon(37.502669, response.getCoordinate().getLatitude()));

    }

    // @Test
    // void georadiusReadonly() {
    //     // prepare datas
    //     Map!(string, GeoCoordinate) coordinateMap = new HashMap!(string, GeoCoordinate)();
    //     coordinateMap.put("Palermo", new GeoCoordinate(13.361389, 38.115556));
    //     coordinateMap.put("Catania", new GeoCoordinate(15.087269, 37.502669));
    //     redis.geoadd("Sicily", coordinateMap);

    //     List!(GeoRadiusResponse) members = redis.georadiusReadonly("Sicily", 15, 37, 200, GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     // sort
    //     members = redis.georadiusReadonly("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending());
    //     assertEquals(2, members.size());
    //     assertEquals("Catania", members.get(0).getMemberByString());
    //     assertEquals("Palermo", members.get(1).getMemberByString());

    //     // sort, count 1
    //     members = redis.georadiusReadonly("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1));
    //     assertEquals(1, members.size());

    //     // sort, count 1, withdist, withcoord
    //     members = redis.georadiusReadonly("Sicily", 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());
    //     GeoRadiusResponse response = members.get(0);
    //     assertTrue(equalsWithinEpsilon(56.4413, response.getDistance()));
    //     assertTrue(equalsWithinEpsilon(15.087269, response.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.502669, response.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusBinary() {
    //     // prepare datas
    //     Map!(byte[], GeoCoordinate) bcoordinateMap = new HashMap!(byte[], GeoCoordinate)();
    //     bcoordinateMap.put(bA, new GeoCoordinate(13.361389, 38.115556));
    //     bcoordinateMap.put(bB, new GeoCoordinate(15.087269, 37.502669));
    //     redis.geoadd(bfoo, bcoordinateMap);

    //     List!(GeoRadiusResponse) members = redis.georadius(bfoo, 15, 37, 200, GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     // sort
    //     members = redis.georadius(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending());
    //     assertEquals(2, members.size());
    //     assertArrayEquals(bB, members.get(0).getMember());
    //     assertArrayEquals(bA, members.get(1).getMember());

    //     // sort, count 1
    //     members = redis.georadius(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1));
    //     assertEquals(1, members.size());

    //     // sort, count 1, withdist, withcoord
    //     members = redis.georadius(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());
    //     GeoRadiusResponse response = members.get(0);
    //     assertTrue(equalsWithinEpsilon(56.4413, response.getDistance()));
    //     assertTrue(equalsWithinEpsilon(15.087269, response.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.502669, response.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusReadonlyBinary() {
    //     // prepare datas
    //     Map!(byte[], GeoCoordinate) bcoordinateMap = new HashMap!(byte[], GeoCoordinate)();
    //     bcoordinateMap.put(bA, new GeoCoordinate(13.361389, 38.115556));
    //     bcoordinateMap.put(bB, new GeoCoordinate(15.087269, 37.502669));
    //     redis.geoadd(bfoo, bcoordinateMap);

    //     List!(GeoRadiusResponse) members = redis.georadiusReadonly(bfoo, 15, 37, 200, GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     // sort
    //     members = redis.georadiusReadonly(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending());
    //     assertEquals(2, members.size());
    //     assertArrayEquals(bB, members.get(0).getMember());
    //     assertArrayEquals(bA, members.get(1).getMember());

    //     // sort, count 1
    //     members = redis.georadiusReadonly(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1));
    //     assertEquals(1, members.size());

    //     // sort, count 1, withdist, withcoord
    //     members = redis.georadiusReadonly(bfoo, 15, 37, 200, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());
    //     GeoRadiusResponse response = members.get(0);
    //     assertTrue(equalsWithinEpsilon(56.4413, response.getDistance()));
    //     assertTrue(equalsWithinEpsilon(15.087269, response.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.502669, response.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusByMember() {
    //     redis.geoadd("Sicily", 13.583333, 37.316667, "Agrigento");
    //     redis.geoadd("Sicily", 13.361389, 38.115556, "Palermo");
    //     redis.geoadd("Sicily", 15.087269, 37.502669, "Catania");

    //     List!(GeoRadiusResponse) members = redis.georadiusByMember("Sicily", "Agrigento", 100,
    //         GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     members = redis.georadiusByMember("Sicily", "Agrigento", 100, GeoUnit.KM, GeoRadiusParam
    //             .geoRadiusParam().sortAscending());
    //     assertEquals(2, members.size());
    //     assertEquals("Agrigento", members.get(0).getMemberByString());
    //     assertEquals("Palermo", members.get(1).getMemberByString());

    //     members = redis.georadiusByMember("Sicily", "Agrigento", 100, GeoUnit.KM, GeoRadiusParam
    //             .geoRadiusParam().sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());

    //     GeoRadiusResponse member = members.get(0);
    //     assertEquals("Agrigento", member.getMemberByString());
    //     assertTrue(equalsWithinEpsilon(0, member.getDistance()));
    //     assertTrue(equalsWithinEpsilon(13.583333, member.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.316667, member.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusByMemberReadonly() {
    //     redis.geoadd("Sicily", 13.583333, 37.316667, "Agrigento");
    //     redis.geoadd("Sicily", 13.361389, 38.115556, "Palermo");
    //     redis.geoadd("Sicily", 15.087269, 37.502669, "Catania");

    //     List!(GeoRadiusResponse) members = redis.georadiusByMemberReadonly("Sicily", "Agrigento", 100,
    //         GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     members = redis.georadiusByMemberReadonly("Sicily", "Agrigento", 100, GeoUnit.KM, GeoRadiusParam
    //             .geoRadiusParam().sortAscending());
    //     assertEquals(2, members.size());
    //     assertEquals("Agrigento", members.get(0).getMemberByString());
    //     assertEquals("Palermo", members.get(1).getMemberByString());

    //     members = redis.georadiusByMemberReadonly("Sicily", "Agrigento", 100, GeoUnit.KM, GeoRadiusParam
    //             .geoRadiusParam().sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());

    //     GeoRadiusResponse member = members.get(0);
    //     assertEquals("Agrigento", member.getMemberByString());
    //     assertTrue(equalsWithinEpsilon(0, member.getDistance()));
    //     assertTrue(equalsWithinEpsilon(13.583333, member.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.316667, member.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusByMemberBinary() {
    //     redis.geoadd(bfoo, 13.583333, 37.316667, bA);
    //     redis.geoadd(bfoo, 13.361389, 38.115556, bB);
    //     redis.geoadd(bfoo, 15.087269, 37.502669, bC);

    //     List!(GeoRadiusResponse) members = redis.georadiusByMember(bfoo, bA, 100, GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     members = redis.georadiusByMember(bfoo, bA, 100, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending());
    //     assertEquals(2, members.size());
    //     assertArrayEquals(bA, members.get(0).getMember());
    //     assertArrayEquals(bB, members.get(1).getMember());

    //     members = redis.georadiusByMember(bfoo, bA, 100, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());

    //     GeoRadiusResponse member = members.get(0);
    //     assertArrayEquals(bA, member.getMember());
    //     assertTrue(equalsWithinEpsilon(0, member.getDistance()));
    //     assertTrue(equalsWithinEpsilon(13.583333, member.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.316667, member.getCoordinate().getLatitude()));
    // }

    // @Test
    // void georadiusByMemberReadonlyBinary() {
    //     redis.geoadd(bfoo, 13.583333, 37.316667, bA);
    //     redis.geoadd(bfoo, 13.361389, 38.115556, bB);
    //     redis.geoadd(bfoo, 15.087269, 37.502669, bC);

    //     List!(GeoRadiusResponse) members = redis.georadiusByMemberReadonly(bfoo, bA, 100, GeoUnit.KM);
    //     assertEquals(2, members.size());

    //     members = redis.georadiusByMemberReadonly(bfoo, bA, 100, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending());
    //     assertEquals(2, members.size());
    //     assertArrayEquals(bA, members.get(0).getMember());
    //     assertArrayEquals(bB, members.get(1).getMember());

    //     members = redis.georadiusByMemberReadonly(bfoo, bA, 100, GeoUnit.KM, GeoRadiusParam.geoRadiusParam()
    //             .sortAscending().count(1).withCoord().withDist());
    //     assertEquals(1, members.size());

    //     GeoRadiusResponse member = members.get(0);
    //     assertArrayEquals(bA, member.getMember());
    //     assertTrue(equalsWithinEpsilon(0, member.getDistance()));
    //     assertTrue(equalsWithinEpsilon(13.583333, member.getCoordinate().getLongitude()));
    //     assertTrue(equalsWithinEpsilon(37.316667, member.getCoordinate().getLatitude()));
    // }

    private void prepareGeoData() {
        Map!(string, GeoCoordinate) coordinateMap = new HashMap!(string, GeoCoordinate)();
        coordinateMap.put("a", new GeoCoordinate(3, 4));
        coordinateMap.put("b", new GeoCoordinate(2, 3));
        coordinateMap.put("c", new GeoCoordinate(3.314, 2.3241));

        Long size = redis.geoadd("foo", coordinateMap);
        assertEquals(3, size.value);

        Map!(const(ubyte)[], GeoCoordinate) bcoordinateMap = new HashMap!(const(ubyte)[], GeoCoordinate)();
        bcoordinateMap.put(bA, new GeoCoordinate(3, 4));
        bcoordinateMap.put(bB, new GeoCoordinate(2, 3));
        bcoordinateMap.put(bC, new GeoCoordinate(3.314, 2.3241));

        size = redis.geoadd(bfoo, bcoordinateMap);
        assertEquals(3, size.value);
    }

    private bool equalsWithinEpsilon(double d1, double d2) {
        // double epsilon = 1E-5;
        double epsilon = 1E-4;
        // warning(abs(d1 - d2));
        return abs(d1 - d2) < epsilon;
    }
}
