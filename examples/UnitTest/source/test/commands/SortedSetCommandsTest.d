module test.commands.SortedSetCommandsTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;
import hunt.Double;


// import static org.junit.Assert.assertArrayEquals;
// import static org.junit.Assert.assertEquals;
// import static org.junit.Assert.assertFalse;
// import static org.junit.Assert.assertNull;
// import static hunt.redis.ScanParams.SCAN_POINTER_START;
// import static hunt.redis.ScanParams.SCAN_POINTER_START_BINARY;
// import static hunt.redis.tests.utils.AssertUtil.assertByteArraySetEquals;

import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.ScanParams;
import hunt.redis.ScanResult;
import hunt.redis.Tuple;
import hunt.redis.ZParams;
import hunt.redis.params.ZAddParams;
import hunt.redis.params.ZIncrByParams;
import hunt.redis.util.SafeEncoder;

import test.HostAndPortUtil;
import test.commands.RedisCommandTestBase;

class SortedSetCommandsTest : RedisCommandTestBase {
  enum const(ubyte)[] bfoo = [ 0x01, 0x02, 0x03, 0x04 ];
  enum const(ubyte)[] bbar = [ 0x05, 0x06, 0x07, 0x08 ];
  enum const(ubyte)[] bcar = [ 0x09, 0x0A, 0x0B, 0x0C ];
  enum const(ubyte)[] ba = [ 0x0A ];
  enum const(ubyte)[] bb = [ 0x0B ];
  enum const(ubyte)[] bc = [ 0x0C ];
  enum const(ubyte)[] bInclusiveB = [ 0x5B, 0x0B ];
  enum const(ubyte)[] bExclusiveC = [ 0x28, 0x0C ];
  enum const(ubyte)[] bLexMinusInf = [ 0x2D ];
  enum const(ubyte)[] bLexPlusInf = [ 0x2B ];

  enum const(ubyte)[] bbar1 = [ 0x05, 0x06, 0x07, 0x08, 0x0A ];
  enum const(ubyte)[] bbar2 = [ 0x05, 0x06, 0x07, 0x08, 0x0B ];
  enum const(ubyte)[] bbar3 = [ 0x05, 0x06, 0x07, 0x08, 0x0C ];
  enum const(ubyte)[] bbarstar = [ 0x05, 0x06, 0x07, 0x08, '*' ];

//   @Test
//   void zadd() {
//     long status = redis.zadd("foo", 1d, "a");
//     assertEquals(1, status);

//     status = redis.zadd("foo", 10d, "b");
//     assertEquals(1, status);

//     status = redis.zadd("foo", 0.1d, "c");
//     assertEquals(1, status);

//     status = redis.zadd("foo", 2d, "a");
//     assertEquals(0, status);

//     // Binary
//     long bstatus = redis.zadd(bfoo, 1d, ba);
//     assertEquals(1, bstatus);

//     bstatus = redis.zadd(bfoo, 10d, bb);
//     assertEquals(1, bstatus);

//     bstatus = redis.zadd(bfoo, 0.1d, bc);
//     assertEquals(1, bstatus);

//     bstatus = redis.zadd(bfoo, 2d, ba);
//     assertEquals(0, bstatus);

//   }

//   @Test
//   void zaddWithParams() {
//     redis.del("foo");

//     // xx: never add new member
//     long status = redis.zadd("foo", 1d, "a", ZAddParams.zAddParams().xx());
//     assertEquals(0L, status);

//     redis.zadd("foo", 1d, "a");
//     // nx: never update current member
//     status = redis.zadd("foo", 2d, "a", ZAddParams.zAddParams().nx());
//     assertEquals(0L, status);
//     assertEquals(Double.valueOf(1d), redis.zscore("foo", "a"));

//     Map!(string, Double) scoreMembers = new HashMap!(string, Double)();
//     scoreMembers.put("a", 2d);
//     scoreMembers.put("b", 1d);
//     // ch: return count of members not only added, but also updated
//     status = redis.zadd("foo", scoreMembers, ZAddParams.zAddParams().ch());
//     assertEquals(2L, status);

//     // binary
//     redis.del(bfoo);

//     // xx: never add new member
//     status = redis.zadd(bfoo, 1d, ba, ZAddParams.zAddParams().xx());
//     assertEquals(0L, status);

//     redis.zadd(bfoo, 1d, ba);
//     // nx: never update current member
//     status = redis.zadd(bfoo, 2d, ba, ZAddParams.zAddParams().nx());
//     assertEquals(0L, status);
//     assertEquals(Double.valueOf(1d), redis.zscore(bfoo, ba));

//     Map!(byte[], Double) binaryScoreMembers = new HashMap!(byte[], Double)();
//     binaryScoreMembers.put(ba, 2d);
//     binaryScoreMembers.put(bb, 1d);
//     // ch: return count of members not only added, but also updated
//     status = redis.zadd(bfoo, binaryScoreMembers, ZAddParams.zAddParams().ch());
//     assertEquals(2L, status);
//   }

//   @Test
//   void zrange() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("c");
//     expected.add("a");

//     Set!(string) range = redis.zrange("foo", 0, 1);
//     assertEquals(expected, range);

//     expected.add("b");
//     range = redis.zrange("foo", 0, 100);
//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bc);
//     bexpected.add(ba);

//     Set!(byte[]) brange = redis.zrange(bfoo, 0, 1);
//     assertByteArraySetEquals(bexpected, brange);

//     bexpected.add(bb);
//     brange = redis.zrange(bfoo, 0, 100);
//     assertByteArraySetEquals(bexpected, brange);

//   }

//   @Test
//   void zrangeByLex() {
//     redis.zadd("foo", 1, "aa");
//     redis.zadd("foo", 1, "c");
//     redis.zadd("foo", 1, "bb");
//     redis.zadd("foo", 1, "d");

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("bb");
//     expected.add("c");

//     // exclusive aa ~ inclusive c
//     assertEquals(expected, redis.zrangeByLex("foo", "(aa", "[c"));

//     expected.clear();
//     expected.add("bb");
//     expected.add("c");

//     // with LIMIT
//     assertEquals(expected, redis.zrangeByLex("foo", "-", "+", 1, 2));
//   }

//   @Test
//   void zrangeByLexBinary() {
//     // binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 1, bc);
//     redis.zadd(bfoo, 1, bb);

//     Set!(byte[]) bExpected = new LinkedHashSet!(byte[])();
//     bExpected.add(bb);

//     assertByteArraySetEquals(bExpected, redis.zrangeByLex(bfoo, bInclusiveB, bExclusiveC));

//     bExpected.clear();
//     bExpected.add(ba);
//     bExpected.add(bb);

//     // with LIMIT
//     assertByteArraySetEquals(bExpected, redis.zrangeByLex(bfoo, bLexMinusInf, bLexPlusInf, 0, 2));
//   }

//   @Test
//   void zrevrangeByLex() {
//     redis.zadd("foo", 1, "aa");
//     redis.zadd("foo", 1, "c");
//     redis.zadd("foo", 1, "bb");
//     redis.zadd("foo", 1, "d");

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("c");
//     expected.add("bb");

//     // exclusive aa ~ inclusive c
//     assertEquals(expected, redis.zrevrangeByLex("foo", "[c", "(aa"));

//     expected.clear();
//     expected.add("c");
//     expected.add("bb");

//     // with LIMIT
//     assertEquals(expected, redis.zrevrangeByLex("foo", "+", "-", 1, 2));
//   }

//   @Test
//   void zrevrangeByLexBinary() {
//     // binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 1, bc);
//     redis.zadd(bfoo, 1, bb);

//     Set!(byte[]) bExpected = new LinkedHashSet!(byte[])();
//     bExpected.add(bb);

//     assertByteArraySetEquals(bExpected, redis.zrevrangeByLex(bfoo, bExclusiveC, bInclusiveB));

//     bExpected.clear();
//     bExpected.add(bb);
//     bExpected.add(ba);

//     // with LIMIT
//     assertByteArraySetEquals(bExpected, redis.zrevrangeByLex(bfoo, bLexPlusInf, bLexMinusInf, 0, 2));
//   }

//   @Test
//   void zrevrange() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("b");
//     expected.add("a");

//     Set!(string) range = redis.zrevrange("foo", 0, 1);
//     assertEquals(expected, range);

//     expected.add("c");
//     range = redis.zrevrange("foo", 0, 100);
//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bb);
//     bexpected.add(ba);

//     Set!(byte[]) brange = redis.zrevrange(bfoo, 0, 1);
//     assertByteArraySetEquals(bexpected, brange);

//     bexpected.add(bc);
//     brange = redis.zrevrange(bfoo, 0, 100);
//     assertByteArraySetEquals(bexpected, brange);

//   }

//   @Test
//   void zrem() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 2d, "b");

//     long status = redis.zrem("foo", "a");

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("b");

//     assertEquals(1, status);
//     assertEquals(expected, redis.zrange("foo", 0, 100));

//     status = redis.zrem("foo", "bar");

//     assertEquals(0, status);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 2d, bb);

//     long bstatus = redis.zrem(bfoo, ba);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bb);

//     assertEquals(1, bstatus);
//     assertByteArraySetEquals(bexpected, redis.zrange(bfoo, 0, 100));

//     bstatus = redis.zrem(bfoo, bbar);

//     assertEquals(0, bstatus);

//   }

  @Test
  void zincrby() {
    redis.zadd("foo", 1, "a");
    redis.zadd("foo", 2, "b");

    double score = redis.zincrby("foo", 2, "a");

    // Set!(string) expected = new LinkedHashSet!(string)();
    // expected.add("a");
    // expected.add("b");
    string[] expected = ["a", "b"];

    assertEquals(cast(double)3, score, cast(double)0);

    auto zrange = redis.zrange("foo", 0, 100);
    foreach(string s; zrange) {
        trace(s);
    }

    // assertEquals(expected, redis.zrange("foo", 0, 100));

    // Binary
    redis.zadd(bfoo, 1.0, ba);
    redis.zadd(bfoo, 2.0, bb);

    double bscore = redis.zincrby(bfoo, 2.0, ba);

    // Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
    // bexpected.add(bb);
    // bexpected.add(ba);

    assertEquals(3.0, bscore, 0.0);
    const(ubyte)[][] bv = redis.zrange(bfoo, cast(long)0, cast(long)100);
    foreach(v; bv) {
        tracef("%(0x%02X, %)", v);
    }
    // assertByteArraySetEquals(bexpected, redis.zrange(bfoo, 0, 100));

  }

//   @Test
//   void zincrbyWithParams() {
//     redis.del("foo");

//     // xx: never add new member
//     Double score = redis.zincrby("foo", 2d, "a", ZIncrByParams.zIncrByParams().xx());
//     assertNull(score);

//     redis.zadd("foo", 2d, "a");

//     // nx: never update current member
//     score = redis.zincrby("foo", 1d, "a", ZIncrByParams.zIncrByParams().nx());
//     assertNull(score);
//     assertEquals(Double.valueOf(2d), redis.zscore("foo", "a"));

//     // Binary

//     redis.del(bfoo);

//     // xx: never add new member
//     score = redis.zincrby(bfoo, 2d, ba, ZIncrByParams.zIncrByParams().xx());
//     assertNull(score);

//     redis.zadd(bfoo, 2d, ba);

//     // nx: never update current member
//     score = redis.zincrby(bfoo, 1d, ba, ZIncrByParams.zIncrByParams().nx());
//     assertNull(score);
//     assertEquals(Double.valueOf(2d), redis.zscore(bfoo, ba));
//   }

//   @Test
//   void zrank() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 2d, "b");

//     long rank = redis.zrank("foo", "a");
//     assertEquals(0, rank);

//     rank = redis.zrank("foo", "b");
//     assertEquals(1, rank);

//     assertNull(redis.zrank("car", "b"));

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 2d, bb);

//     long brank = redis.zrank(bfoo, ba);
//     assertEquals(0, brank);

//     brank = redis.zrank(bfoo, bb);
//     assertEquals(1, brank);

//     assertNull(redis.zrank(bcar, bb));

//   }

//   @Test
//   void zrevrank() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 2d, "b");

//     long rank = redis.zrevrank("foo", "a");
//     assertEquals(1, rank);

//     rank = redis.zrevrank("foo", "b");
//     assertEquals(0, rank);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 2d, bb);

//     long brank = redis.zrevrank(bfoo, ba);
//     assertEquals(1, brank);

//     brank = redis.zrevrank(bfoo, bb);
//     assertEquals(0, brank);

//   }

//   @Test
//   void zrangeWithScores() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("c", 0.1d));
//     expected.add(new Tuple("a", 2d));

//     Set!(Tuple) range = redis.zrangeWithScores("foo", 0, 1);
//     assertEquals(expected, range);

//     expected.add(new Tuple("b", 10d));
//     range = redis.zrangeWithScores("foo", 0, 100);
//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bc, 0.1d));
//     bexpected.add(new Tuple(ba, 2d));

//     Set!(Tuple) brange = redis.zrangeWithScores(bfoo, 0, 1);
//     assertEquals(bexpected, brange);

//     bexpected.add(new Tuple(bb, 10d));
//     brange = redis.zrangeWithScores(bfoo, 0, 100);
//     assertEquals(bexpected, brange);

//   }

//   @Test
//   void zrevrangeWithScores() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("b", 10d));
//     expected.add(new Tuple("a", 2d));

//     Set!(Tuple) range = redis.zrevrangeWithScores("foo", 0, 1);
//     assertEquals(expected, range);

//     expected.add(new Tuple("c", 0.1d));
//     range = redis.zrevrangeWithScores("foo", 0, 100);
//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bb, 10d));
//     bexpected.add(new Tuple(ba, 2d));

//     Set!(Tuple) brange = redis.zrevrangeWithScores(bfoo, 0, 1);
//     assertEquals(bexpected, brange);

//     bexpected.add(new Tuple(bc, 0.1d));
//     brange = redis.zrevrangeWithScores(bfoo, 0, 100);
//     assertEquals(bexpected, brange);

//   }

//   @Test
//   void zcard() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     long size = redis.zcard("foo");
//     assertEquals(3, size);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     long bsize = redis.zcard(bfoo);
//     assertEquals(3, bsize);

//   }

//   @Test
//   void zscore() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Double score = redis.zscore("foo", "b");
//     assertEquals((Double) 10d, score);

//     score = redis.zscore("foo", "c");
//     assertEquals((Double) 0.1d, score);

//     score = redis.zscore("foo", "s");
//     assertNull(score);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Double bscore = redis.zscore(bfoo, bb);
//     assertEquals((Double) 10d, bscore);

//     bscore = redis.zscore(bfoo, bc);
//     assertEquals((Double) 0.1d, bscore);

//     bscore = redis.zscore(bfoo, SafeEncoder.encode("s"));
//     assertNull(bscore);

//   }

//   @Test
//   void zcount() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     long result = redis.zcount("foo", 0.01d, 2.1d);

//     assertEquals(2, result);

//     result = redis.zcount("foo", "(0.01", "+inf");

//     assertEquals(3, result);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     long bresult = redis.zcount(bfoo, 0.01d, 2.1d);

//     assertEquals(2, bresult);

//     bresult = redis.zcount(bfoo, SafeEncoder.encode("(0.01"), SafeEncoder.encode("+inf"));

//     assertEquals(3, bresult);
//   }

//   @Test
//   void zlexcount() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 1, "b");
//     redis.zadd("foo", 1, "c");
//     redis.zadd("foo", 1, "aa");

//     long result = redis.zlexcount("foo", "[aa", "(c");
//     assertEquals(2, result);

//     result = redis.zlexcount("foo", "-", "+");
//     assertEquals(4, result);

//     result = redis.zlexcount("foo", "-", "(c");
//     assertEquals(3, result);

//     result = redis.zlexcount("foo", "[aa", "+");
//     assertEquals(3, result);
//   }

//   @Test
//   void zlexcountBinary() {
//     // Binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 1, bc);
//     redis.zadd(bfoo, 1, bb);

//     long result = redis.zlexcount(bfoo, bInclusiveB, bExclusiveC);
//     assertEquals(1, result);

//     result = redis.zlexcount(bfoo, bLexMinusInf, bLexPlusInf);
//     assertEquals(3, result);
//   }

//   @Test
//   void zrangebyscore() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(string) range = redis.zrangeByScore("foo", 0d, 2d);

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("c");
//     expected.add("a");

//     assertEquals(expected, range);

//     range = redis.zrangeByScore("foo", 0d, 2d, 0, 1);

//     expected = new LinkedHashSet!(string)();
//     expected.add("c");

//     assertEquals(expected, range);

//     range = redis.zrangeByScore("foo", 0d, 2d, 1, 1);
//     Set!(string) range2 = redis.zrangeByScore("foo", "-inf", "(2");
//     assertEquals(expected, range2);

//     expected = new LinkedHashSet!(string)();
//     expected.add("a");

//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(byte[]) brange = redis.zrangeByScore(bfoo, 0d, 2d);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bc);
//     bexpected.add(ba);

//     assertByteArraySetEquals(bexpected, brange);

//     brange = redis.zrangeByScore(bfoo, 0d, 2d, 0, 1);

//     bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bc);

//     assertByteArraySetEquals(bexpected, brange);

//     brange = redis.zrangeByScore(bfoo, 0d, 2d, 1, 1);
//     Set!(byte[]) brange2 = redis.zrangeByScore(bfoo, SafeEncoder.encode("-inf"),
//       SafeEncoder.encode("(2"));
//     assertByteArraySetEquals(bexpected, brange2);

//     bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(ba);

//     assertByteArraySetEquals(bexpected, brange);

//   }

//   @Test
//   void zrevrangebyscore() {
//     redis.zadd("foo", 1.0d, "a");
//     redis.zadd("foo", 2.0d, "b");
//     redis.zadd("foo", 3.0d, "c");
//     redis.zadd("foo", 4.0d, "d");
//     redis.zadd("foo", 5.0d, "e");

//     Set!(string) range = redis.zrevrangeByScore("foo", 3d, Double.NEGATIVE_INFINITY, 0, 1);
//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("c");

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScore("foo", 3.5d, Double.NEGATIVE_INFINITY, 0, 2);
//     expected = new LinkedHashSet!(string)();
//     expected.add("c");
//     expected.add("b");

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScore("foo", 3.5d, Double.NEGATIVE_INFINITY, 1, 1);
//     expected = new LinkedHashSet!(string)();
//     expected.add("b");

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScore("foo", 4d, 2d);
//     expected = new LinkedHashSet!(string)();
//     expected.add("d");
//     expected.add("c");
//     expected.add("b");

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScore("foo", "+inf", "(4");
//     expected = new LinkedHashSet!(string)();
//     expected.add("e");

//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(byte[]) brange = redis.zrevrangeByScore(bfoo, 2d, 0d);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bc);
//     bexpected.add(ba);

//     assertByteArraySetEquals(bexpected, brange);

//     brange = redis.zrevrangeByScore(bfoo, 2d, 0d, 0, 1);

//     bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(ba);

//     assertByteArraySetEquals(bexpected, brange);

//     Set!(byte[]) brange2 = redis.zrevrangeByScore(bfoo, SafeEncoder.encode("+inf"),
//       SafeEncoder.encode("(2"));

//     bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bb);

//     assertByteArraySetEquals(bexpected, brange2);

//     brange = redis.zrevrangeByScore(bfoo, 2d, 0d, 1, 1);
//     bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bc);

//     assertByteArraySetEquals(bexpected, brange);
//   }

//   @Test
//   void zrangebyscoreWithScores() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     Set!(Tuple) range = redis.zrangeByScoreWithScores("foo", 0d, 2d);

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("c", 0.1d));
//     expected.add(new Tuple("a", 2d));

//     assertEquals(expected, range);

//     range = redis.zrangeByScoreWithScores("foo", 0d, 2d, 0, 1);

//     expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("c", 0.1d));

//     assertEquals(expected, range);

//     range = redis.zrangeByScoreWithScores("foo", 0d, 2d, 1, 1);

//     expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("a", 2d));

//     assertEquals(expected, range);

//     // Binary

//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(Tuple) brange = redis.zrangeByScoreWithScores(bfoo, 0d, 2d);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bc, 0.1d));
//     bexpected.add(new Tuple(ba, 2d));

//     assertEquals(bexpected, brange);

//     brange = redis.zrangeByScoreWithScores(bfoo, 0d, 2d, 0, 1);

//     bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bc, 0.1d));

//     assertEquals(bexpected, brange);

//     brange = redis.zrangeByScoreWithScores(bfoo, 0d, 2d, 1, 1);

//     bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(ba, 2d));

//     assertEquals(bexpected, brange);

//   }

//   @Test
//   void zrevrangebyscoreWithScores() {
//     redis.zadd("foo", 1.0d, "a");
//     redis.zadd("foo", 2.0d, "b");
//     redis.zadd("foo", 3.0d, "c");
//     redis.zadd("foo", 4.0d, "d");
//     redis.zadd("foo", 5.0d, "e");

//     Set!(Tuple) range = redis.zrevrangeByScoreWithScores("foo", 3d, Double.NEGATIVE_INFINITY, 0, 1);
//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("c", 3.0d));

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScoreWithScores("foo", 3.5d, Double.NEGATIVE_INFINITY, 0, 2);
//     expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("c", 3.0d));
//     expected.add(new Tuple("b", 2.0d));

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScoreWithScores("foo", 3.5d, Double.NEGATIVE_INFINITY, 1, 1);
//     expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("b", 2.0d));

//     assertEquals(expected, range);

//     range = redis.zrevrangeByScoreWithScores("foo", 4d, 2d);
//     expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("d", 4.0d));
//     expected.add(new Tuple("c", 3.0d));
//     expected.add(new Tuple("b", 2.0d));

//     assertEquals(expected, range);

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     Set!(Tuple) brange = redis.zrevrangeByScoreWithScores(bfoo, 2d, 0d);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bc, 0.1d));
//     bexpected.add(new Tuple(ba, 2d));

//     assertEquals(bexpected, brange);

//     brange = redis.zrevrangeByScoreWithScores(bfoo, 2d, 0d, 0, 1);

//     bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(ba, 2d));

//     assertEquals(bexpected, brange);

//     brange = redis.zrevrangeByScoreWithScores(bfoo, 2d, 0d, 1, 1);

//     bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bc, 0.1d));

//     assertEquals(bexpected, brange);
//   }

//   @Test
//   void zremrangeByRank() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     long result = redis.zremrangeByRank("foo", 0, 0);

//     assertEquals(1, result);

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("a");
//     expected.add("b");

//     assertEquals(expected, redis.zrange("foo", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     long bresult = redis.zremrangeByRank(bfoo, 0, 0);

//     assertEquals(1, bresult);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(ba);
//     bexpected.add(bb);

//     assertByteArraySetEquals(bexpected, redis.zrange(bfoo, 0, 100));

//   }

//   @Test
//   void zremrangeByScore() {
//     redis.zadd("foo", 1d, "a");
//     redis.zadd("foo", 10d, "b");
//     redis.zadd("foo", 0.1d, "c");
//     redis.zadd("foo", 2d, "a");

//     long result = redis.zremrangeByScore("foo", 0, 2);

//     assertEquals(2, result);

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("b");

//     assertEquals(expected, redis.zrange("foo", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1d, ba);
//     redis.zadd(bfoo, 10d, bb);
//     redis.zadd(bfoo, 0.1d, bc);
//     redis.zadd(bfoo, 2d, ba);

//     long bresult = redis.zremrangeByScore(bfoo, 0, 2);

//     assertEquals(2, bresult);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(bb);

//     assertByteArraySetEquals(bexpected, redis.zrange(bfoo, 0, 100));
//   }

//   @Test
//   void zremrangeByLex() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 1, "b");
//     redis.zadd("foo", 1, "c");
//     redis.zadd("foo", 1, "aa");

//     long result = redis.zremrangeByLex("foo", "[aa", "(c");

//     assertEquals(2, result);

//     Set!(string) expected = new LinkedHashSet!(string)();
//     expected.add("a");
//     expected.add("c");

//     assertEquals(expected, redis.zrangeByLex("foo", "-", "+"));
//   }

//   @Test
//   void zremrangeByLexBinary() {
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 1, bc);
//     redis.zadd(bfoo, 1, bb);

//     long bresult = redis.zremrangeByLex(bfoo, bInclusiveB, bExclusiveC);

//     assertEquals(1, bresult);

//     Set!(byte[]) bexpected = new LinkedHashSet!(byte[])();
//     bexpected.add(ba);
//     bexpected.add(bc);

//     assertByteArraySetEquals(bexpected, redis.zrangeByLex(bfoo, bLexMinusInf, bLexPlusInf));
//   }

//   @Test
//   void zunionstore() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 2, "b");
//     redis.zadd("bar", 2, "a");
//     redis.zadd("bar", 2, "b");

//     long result = redis.zunionstore("dst", "foo", "bar");

//     assertEquals(2, result);

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("b", new Double(4)));
//     expected.add(new Tuple("a", new Double(3)));

//     assertEquals(expected, redis.zrangeWithScores("dst", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 2, bb);
//     redis.zadd(bbar, 2, ba);
//     redis.zadd(bbar, 2, bb);

//     long bresult = redis.zunionstore(SafeEncoder.encode("dst"), bfoo, bbar);

//     assertEquals(2, bresult);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bb, new Double(4)));
//     bexpected.add(new Tuple(ba, new Double(3)));

//     assertEquals(bexpected, redis.zrangeWithScores(SafeEncoder.encode("dst"), 0, 100));
//   }

//   @Test
//   void zunionstoreParams() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 2, "b");
//     redis.zadd("bar", 2, "a");
//     redis.zadd("bar", 2, "b");

//     ZParams params = new ZParams();
//     params.weights(2, 2.5);
//     params.aggregate(ZParams.Aggregate.SUM);
//     long result = redis.zunionstore("dst", params, "foo", "bar");

//     assertEquals(2, result);

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("b", new Double(9)));
//     expected.add(new Tuple("a", new Double(7)));

//     assertEquals(expected, redis.zrangeWithScores("dst", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 2, bb);
//     redis.zadd(bbar, 2, ba);
//     redis.zadd(bbar, 2, bb);

//     ZParams bparams = new ZParams();
//     bparams.weights(2, 2.5);
//     bparams.aggregate(ZParams.Aggregate.SUM);
//     long bresult = redis.zunionstore(SafeEncoder.encode("dst"), bparams, bfoo, bbar);

//     assertEquals(2, bresult);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(bb, new Double(9)));
//     bexpected.add(new Tuple(ba, new Double(7)));

//     assertEquals(bexpected, redis.zrangeWithScores(SafeEncoder.encode("dst"), 0, 100));
//   }

//   @Test
//   void zinterstore() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 2, "b");
//     redis.zadd("bar", 2, "a");

//     long result = redis.zinterstore("dst", "foo", "bar");

//     assertEquals(1, result);

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("a", new Double(3)));

//     assertEquals(expected, redis.zrangeWithScores("dst", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 2, bb);
//     redis.zadd(bbar, 2, ba);

//     long bresult = redis.zinterstore(SafeEncoder.encode("dst"), bfoo, bbar);

//     assertEquals(1, bresult);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(ba, new Double(3)));

//     assertEquals(bexpected, redis.zrangeWithScores(SafeEncoder.encode("dst"), 0, 100));
//   }

//   @Test
//   void zintertoreParams() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 2, "b");
//     redis.zadd("bar", 2, "a");

//     ZParams params = new ZParams();
//     params.weights(2, 2.5);
//     params.aggregate(ZParams.Aggregate.SUM);
//     long result = redis.zinterstore("dst", params, "foo", "bar");

//     assertEquals(1, result);

//     Set!(Tuple) expected = new LinkedHashSet!(Tuple)();
//     expected.add(new Tuple("a", new Double(7)));

//     assertEquals(expected, redis.zrangeWithScores("dst", 0, 100));

//     // Binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 2, bb);
//     redis.zadd(bbar, 2, ba);

//     ZParams bparams = new ZParams();
//     bparams.weights(2, 2.5);
//     bparams.aggregate(ZParams.Aggregate.SUM);
//     long bresult = redis.zinterstore(SafeEncoder.encode("dst"), bparams, bfoo, bbar);

//     assertEquals(1, bresult);

//     Set!(Tuple) bexpected = new LinkedHashSet!(Tuple)();
//     bexpected.add(new Tuple(ba, new Double(7)));

//     assertEquals(bexpected, redis.zrangeWithScores(SafeEncoder.encode("dst"), 0, 100));
//   }

//   @Test
//   void zscan() {
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 2, "b");

//     ScanResult!(Tuple) result = redis.zscan("foo", SCAN_POINTER_START);

//     assertEquals(SCAN_POINTER_START, result.getCursor());
//     assertFalse(result.getResult().isEmpty());

//     // binary
//     redis.zadd(bfoo, 1, ba);
//     redis.zadd(bfoo, 1, bb);

//     ScanResult!(Tuple) bResult = redis.zscan(bfoo, SCAN_POINTER_START_BINARY);

//     assertArrayEquals(SCAN_POINTER_START_BINARY, bResult.getCursorAsBytes());
//     assertFalse(bResult.getResult().isEmpty());
//   }

//   @Test
//   void zscanMatch() {
//     ScanParams params = new ScanParams();
//     params.match("a*");

//     redis.zadd("foo", 2, "b");
//     redis.zadd("foo", 1, "a");
//     redis.zadd("foo", 11, "aa");
//     ScanResult!(Tuple) result = redis.zscan("foo", SCAN_POINTER_START, params);

//     assertEquals(SCAN_POINTER_START, result.getCursor());
//     assertFalse(result.getResult().isEmpty());

//     // binary
//     params = new ScanParams();
//     params.match(bbarstar);

//     redis.zadd(bfoo, 2, bbar1);
//     redis.zadd(bfoo, 1, bbar2);
//     redis.zadd(bfoo, 11, bbar3);
//     ScanResult!(Tuple) bResult = redis.zscan(bfoo, SCAN_POINTER_START_BINARY, params);

//     assertArrayEquals(SCAN_POINTER_START_BINARY, bResult.getCursorAsBytes());
//     assertFalse(bResult.getResult().isEmpty());

//   }

//   @Test
//   void zscanCount() {
//     ScanParams params = new ScanParams();
//     params.count(2);

//     redis.zadd("foo", 1, "a1");
//     redis.zadd("foo", 2, "a2");
//     redis.zadd("foo", 3, "a3");
//     redis.zadd("foo", 4, "a4");
//     redis.zadd("foo", 5, "a5");

//     ScanResult!(Tuple) result = redis.zscan("foo", SCAN_POINTER_START, params);

//     assertFalse(result.getResult().isEmpty());

//     // binary
//     params = new ScanParams();
//     params.count(2);

//     redis.zadd(bfoo, 2, bbar1);
//     redis.zadd(bfoo, 1, bbar2);
//     redis.zadd(bfoo, 11, bbar3);

//     ScanResult!(Tuple) bResult = redis.zscan(bfoo, SCAN_POINTER_START_BINARY, params);

//     assertFalse(bResult.getResult().isEmpty());
//   }

//   @Test
//   void infinity() {
//     redis.zadd("key", Double.POSITIVE_INFINITY, "pos");
//     assertEquals(Double.POSITIVE_INFINITY, redis.zscore("key", "pos"), 0d);
//     redis.zadd("key", Double.NEGATIVE_INFINITY, "neg");
//     assertEquals(Double.NEGATIVE_INFINITY, redis.zscore("key", "neg"), 0d);
//     redis.zadd("key", 0d, "zero");

//     Set!(Tuple) set = redis.zrangeWithScores("key", 0, -1);
//     Iterator!(Tuple) itr = set.iterator();
//     assertEquals(Double.NEGATIVE_INFINITY, itr.next().getScore(), 0d);
//     assertEquals(0d, itr.next().getScore(), 0d);
//     assertEquals(Double.POSITIVE_INFINITY, itr.next().getScore(), 0d);
//   }
}
