module test.commands.StreamsCommandsTest;

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
import hunt.redis.StreamEntry;
import hunt.redis.StreamEntryID;
import hunt.redis.Redis;
import hunt.redis.util.SafeEncoder;


public class StreamsCommandsTest : RedisCommandTestBase {

  // @Test
  // void xadd() {
    
  //   try {
  //     Map!(String,String) map1 = new HashMap!(String, String)();
  //     redis.xadd("stream1", null, map1);
  //     fail();
  //   } catch (RedisDataException expected) {
  //     assertEquals("ERR wrong number of arguments for 'xadd' command", expected.getMessage());
  //   }
    
  //   Map!(String,String) map1 = new HashMap!(String, String)();
  //   map1.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xadd-stream1", null, map1);
  //   assertNotNull(id1);	

  //   Map!(String,String) map2 = new HashMap!(String, String)();
  //   map2.put("f1", "v1");
  //   map2.put("f2", "v2");
  //   StreamEntryID id2 = redis.xadd("xadd-stream1", null, map2);
  //   assertTrue(id2.compareTo(id1) > 0);

  //   Map!(String,String) map3 = new HashMap!(String, String)();
  //   map3.put("f2", "v2");
  //   map3.put("f3", "v3");
  //   StreamEntryID id3 = redis.xadd("xadd-stream2", null, map3);

  //   Map!(String,String) map4 = new HashMap!(String, String)();
  //   map4.put("f2", "v2");
  //   map4.put("f3", "v3");
  //   StreamEntryID idIn = new StreamEntryID(id3.getTime()+1, 1L);
  //   StreamEntryID id4 = redis.xadd("xadd-stream2", idIn, map4);
  //   assertEquals(idIn, id4);
  //   assertTrue(id4.compareTo(id3) > 0);
    
  //   Map!(String,String) map5 = new HashMap!(String, String)();
  //   map3.put("f4", "v4");
  //   map3.put("f5", "v5");
  //   StreamEntryID id5 = redis.xadd("xadd-stream2", null, map3);
  //   assertTrue(id5.compareTo(id4) > 0);    
    
  //   Map!(String,String) map6 = new HashMap!(String, String)();
  //   map3.put("f4", "v4");
  //   map3.put("f5", "v5");
  //   StreamEntryID id6 = redis.xadd("xadd-stream2", null, map3, 3, false);
  //   assertTrue(id6.compareTo(id5) > 0);
  //   assertEquals(3L, redis.xlen("xadd-stream2").longValue());
  // }
  
  // @Test
  // void xdel() {
  //   Map!(String,String) map1 = new HashMap!(String, String)();
  //   map1.put("f1", "v1");
    
  //   StreamEntryID id1 = redis.xadd("xdel-stream", null, map1);
  //   assertNotNull(id1); 
    
  //   StreamEntryID id2 = redis.xadd("xdel-stream", null, map1);
  //   assertNotNull(id2);
  //   assertEquals(2L, redis.xlen("xdel-stream").longValue());


  //   assertEquals(1L, redis.xdel("xdel-stream", id1));
  //   assertEquals(1L, redis.xlen("xdel-stream").longValue());
  // }

  // @Test
  // void xlen() {
  //   assertEquals(0L, redis.xlen("xlen-stream").longValue());
    
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   redis.xadd("xlen-stream", null, map);
  //   assertEquals(1L, redis.xlen("xlen-stream").longValue());
    
  //   redis.xadd("xlen-stream", null, map);
  //   assertEquals(2L, redis.xlen("xlen-stream").longValue());
  // }

  // @Test
  // void xrange() {
  //   List!(StreamEntry) range = redis.xrange("xrange-stream", (StreamEntryID)null, (StreamEntryID)null, Integer.MAX_VALUE); 
  //   assertEquals(0, range.size());
        
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xrange-stream", null, map);
  //   StreamEntryID id2 = redis.xadd("xrange-stream", null, map);
  //   List!(StreamEntry) range2 = redis.xrange("xrange-stream", (StreamEntryID)null, (StreamEntryID)null, 3); 
  //   assertEquals(2, range2.size());
    
  //   List!(StreamEntry) range3 = redis.xrange("xrange-stream", id1, null, 2); 
  //   assertEquals(2, range3.size());
    
  //   List!(StreamEntry) range4 = redis.xrange("xrange-stream", id1, id2, 2); 
  //   assertEquals(2, range4.size());

  //   List!(StreamEntry) range5 = redis.xrange("xrange-stream", id1, id2, 1); 
  //   assertEquals(1, range5.size());
    
  //   List!(StreamEntry) range6 = redis.xrange("xrange-stream", id2, null, 4); 
  //   assertEquals(1, range6.size());
    
  //   StreamEntryID id3 = redis.xadd("xrange-stream", null, map);
  //   List!(StreamEntry) range7 = redis.xrange("xrange-stream", id2, id2, 4); 
  //   assertEquals(1, range7.size());
  // }
  
  // @Test
  // void xread() {
    
  //   MapEntry!(String, StreamEntryID) streamQeury1 = new SimpleImmutableEntry!(String, StreamEntryID)("xread-stream1", new StreamEntryID());

  //   // Empty Stream
  //   List!(MapEntry!(String, List!(StreamEntry))) range = redis.xread(1, 1L, streamQeury1); 
  //   assertEquals(0, range.size());
    
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xread-stream1", null, map);
  //   StreamEntryID id2 = redis.xadd("xread-stream2", null, map);
    
  //   // Read only a single Stream
  //   List!(MapEntry!(String, List!(StreamEntry))) streams1 = redis.xread(1, 1L, streamQeury1); 
  //   assertEquals(1, streams1.size());

  //   // Read from two Streams
  //   MapEntry!(String, StreamEntryID) streamQuery2 = new SimpleImmutableEntry!(String, StreamEntryID)("xread-stream1", new StreamEntryID());
  //   MapEntry!(String, StreamEntryID) streamQuery3 = new SimpleImmutableEntry!(String, StreamEntryID)("xread-stream2", new StreamEntryID());
  //   List!(MapEntry!(String, List!(StreamEntry))) streams2 = redis.xread(2, 1L, streamQuery2, streamQuery3); 
  //   assertEquals(2, streams2.size());

  // }
  
  // @Test
  // void xtrim() {
  //   Map!(String,String) map1 = new HashMap!(String, String)();
  //   map1.put("f1", "v1");
    
  //   redis.xadd("xtrim-stream", null, map1);
  //   redis.xadd("xtrim-stream", null, map1);
  //   redis.xadd("xtrim-stream", null, map1);
  //   redis.xadd("xtrim-stream", null, map1);
  //   redis.xadd("xtrim-stream", null, map1);
  //   assertEquals(5L, redis.xlen("xtrim-stream").longValue());

  //   redis.xtrim("xtrim-stream", 3, false);
  //   assertEquals(3L, redis.xlen("xtrim-stream").longValue());
  // }
  
  // @Test
  // void xrevrange() {
  //   List!(StreamEntry) range = redis.xrevrange("xrevrange-stream", (StreamEntryID)null, (StreamEntryID)null, Integer.MAX_VALUE); 
  //   assertEquals(0, range.size());
        
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xrevrange-stream", null, map);
  //   StreamEntryID id2 = redis.xadd("xrevrange-stream", null, map);
  //   List!(StreamEntry) range2 = redis.xrange("xrevrange-stream", (StreamEntryID)null, (StreamEntryID)null, 3); 
  //   assertEquals(2, range2.size());
    
  //   List!(StreamEntry) range3 = redis.xrevrange("xrevrange-stream", null, id1, 2); 
  //   assertEquals(2, range3.size());
    
  //   List!(StreamEntry) range4 = redis.xrevrange("xrevrange-stream", id2, id1, 2); 
  //   assertEquals(2, range4.size());

  //   List!(StreamEntry) range5 = redis.xrevrange("xrevrange-stream", id2, id1, 1); 
  //   assertEquals(1, range5.size());
    
  //   List!(StreamEntry) range6 = redis.xrevrange("xrevrange-stream", null, id2, 4); 
  //   assertEquals(1, range6.size());
    
  //   StreamEntryID id3 = redis.xadd("xrevrange-stream", null, map);
  //   List!(StreamEntry) range7 = redis.xrevrange("xrevrange-stream", id2, id2, 4); 
  //   assertEquals(1, range7.size());

  // }
  
  // @Test
  // void xgroup() {
    
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xgroup-stream", null, map);
    
  //   String status = redis.xgroupCreate("xgroup-stream", "consumer-group-name", null, false);
  //   assertTrue(Keyword.OK.name().equalsIgnoreCase(status));


  //   status = redis.xgroupSetID("xgroup-stream", "consumer-group-name", id1);
  //   assertTrue(Keyword.OK.name().equalsIgnoreCase(status));

  //   status = redis.xgroupCreate("xgroup-stream", "consumer-group-name1", StreamEntryID.LAST_ENTRY, false);
  //   assertTrue(Keyword.OK.name().equalsIgnoreCase(status));
    
  //   redis.xgroupDestroy("xgroup-stream", "consumer-group-name");

  //   //TODO test xgroupDelConsumer
  // }
  
  @Test
  void xreadGroup() {
    
    // Simple xreadGroup with NOACK
    Map!(string,string) map = new HashMap!(string,string)();
    map.put("f1", "v1");
    StreamEntryID id1 = redis.xadd("xreadGroup-stream1", null, map);
    string status1 = redis.xgroupCreate("xreadGroup-stream1", "xreadGroup-group", null, false);
    MapEntry!(string, StreamEntryID) streamQeury1 = new SimpleImmutableEntry!(string, StreamEntryID)("xreadGroup-stream1", StreamEntryID.UNRECEIVED_ENTRY);
    List!(MapEntry!(string, List!(StreamEntry))) range = redis.xreadGroup("xreadGroup-group", "xreadGroup-consumer", 1, 0, true, streamQeury1); 
    assertEquals(1, range.size());
    assertEquals(1, range.get(0).getValue().size());

    
    StreamEntryID id2 = redis.xadd("xreadGroup-stream1", null, map);
    StreamEntryID id3 = redis.xadd("xreadGroup-stream2", null, map);
    string status2 = redis.xgroupCreate("xreadGroup-stream2", "xreadGroup-group", null, false);
   
    // Read only a single Stream
    MapEntry!(string, StreamEntryID) streamQeury11 = new SimpleImmutableEntry!(string, StreamEntryID)("xreadGroup-stream1", StreamEntryID.UNRECEIVED_ENTRY);
    List!(MapEntry!(string, List!(StreamEntry))) streams1 = redis.xreadGroup("xreadGroup-group", "xreadGroup-consumer", 1, 1L, true, streamQeury11); 
    assertEquals(1, streams1.size());
    assertEquals(1, streams1.get(0).getValue().size());

    // Read from two Streams
    MapEntry!(string, StreamEntryID) streamQuery2 = new SimpleImmutableEntry!(string, StreamEntryID)("xreadGroup-stream1", new StreamEntryID());
    MapEntry!(string, StreamEntryID) streamQuery3 = new SimpleImmutableEntry!(string, StreamEntryID)("xreadGroup-stream2", new StreamEntryID());
    List!(MapEntry!(string, List!(StreamEntry))) streams2 = redis.xreadGroup("xreadGroup-group", "xreadGroup-consumer", 1, 1L, true, streamQuery2, streamQuery3); 
    assertEquals(2, streams2.size());

    // Read only fresh messages
    StreamEntryID id4 = redis.xadd("xreadGroup-stream1", null, map);
    MapEntry!(string, StreamEntryID) streamQeuryFresh = new SimpleImmutableEntry!(string, StreamEntryID)("xreadGroup-stream1", StreamEntryID.UNRECEIVED_ENTRY);
    List!(MapEntry!(string, List!(StreamEntry))) streams3 = redis.xreadGroup("xreadGroup-group", "xreadGroup-consumer", 4, 100L, true, streamQeuryFresh); 
    assertEquals(1, streams3.size());

    warning(id4.toString());
    StreamEntryID tempId = streams3.get(0).getValue().get(0).getID();
    warning(tempId.toString());

    assertEquals(id4, tempId);
  }

  
  
  // @Test
  // void xack() {
       
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xack-stream", null, map);
    
  //   String status = redis.xgroupCreate("xack-stream", "xack-group", null, false);
    
  //   MapEntry!(String, StreamEntryID) streamQeury1 = new SimpleImmutableEntry!(String, StreamEntryID)("xack-stream", StreamEntryID.UNRECEIVED_ENTRY);

  //   // Empty Stream
  //   List!(MapEntry!(String, List!(StreamEntry))) range = redis.xreadGroup("xack-group", "xack-consumer", 1, 1L, false, streamQeury1); 
  //   assertEquals(1, range.size());

  //   assertEquals(1L, redis.xack("xack-stream", "xack-group", range.get(0).getValue().get(0).getID()));
  // }
  
  // @Test
  // void xpendeing() {       
  //   Map!(String,String) map = new HashMap!(String, String)();
  //   map.put("f1", "v1");
  //   StreamEntryID id1 = redis.xadd("xpendeing-stream", null, map);
    
  //   String status = redis.xgroupCreate("xpendeing-stream", "xpendeing-group", null, false);
    
  //   MapEntry!(String, StreamEntryID) streamQeury1 = new SimpleImmutableEntry!(String, StreamEntryID)("xpendeing-stream", StreamEntryID.UNRECEIVED_ENTRY);

  //   // Empty Stream
  //   List!(MapEntry!(String, List!(StreamEntry))) range = redis.xreadGroup("xpendeing-group", "xpendeing-consumer", 1, 1L, false, streamQeury1); 
  //   assertEquals(1, range.size());
  //   assertEquals(1, range.get(0).getValue().size());
    
  //   List!(StreamPendingEntry) pendingRange = redis.xpending("xpendeing-stream", "xpendeing-group", null, null, 3, "xpendeing-consumer");
  //   assertEquals(1, pendingRange.size());
    
  //   try {
  //     Thread.sleep(1000);
  //   } catch (InterruptedException e) {
  //     e.printStackTrace();
  //   }
    
  //   redis.xclaim("xpendeing-stream", "xpendeing-group", "xpendeing-consumer2", 500, 0, 0, false, pendingRange.get(0).getID());
  // }

  // @Test
  // void pipeline() {
  //   Map!(String,String) map = new HashMap<>();
  //   map.put("a", "b");
  //   Pipeline p = redis.pipelined();
  //   Response!(StreamEntryID) id1 = p.xadd("stream1", StreamEntryID.NEW_ENTRY, map);
  //   Response!(StreamEntryID) id2 = p.xadd("stream1", StreamEntryID.NEW_ENTRY, map);
  //   Response!(List!(StreamEntry)) results = p.xrange("stream1", null, null, 2);
  //   p.sync();

  //   List!(StreamEntry) entries = results.get();
  //   assertEquals(2, entries.size());
  //   assertEquals(id1.get(), entries.get(0).getID());
  //   assertEquals(map, entries.get(0).getFields());
  //   assertEquals(id2.get(), entries.get(1).getID());
  //   assertEquals(map, entries.get(1).getFields());
  // }

  // @Test
  // void transaction() {
  //   Map!(String,String) map = new HashMap<>();
  //   map.put("a", "b");
  //   Transaction t = redis.multi();
  //   Response!(StreamEntryID) id1 = t.xadd("stream1", StreamEntryID.NEW_ENTRY, map);
  //   Response!(StreamEntryID) id2 = t.xadd("stream1", StreamEntryID.NEW_ENTRY, map);
  //   Response!(List!(StreamEntry)) results = t.xrange("stream1", null, null, 2);
  //   t.exec();

  //   List!(StreamEntry) entries = results.get();
  //   assertEquals(2, entries.size());
  //   assertEquals(id1.get(), entries.get(0).getID());
  //   assertEquals(map, entries.get(0).getFields());
  //   assertEquals(id2.get(), entries.get(1).getID());
  //   assertEquals(map, entries.get(1).getFields());
  // }
}
