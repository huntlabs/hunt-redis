module test.RedisClusterTest;

import test.HostAndPortUtil;
import test.utils.RedisClusterTestUtil;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

// import java.util.concurrent.ArrayBlockingQueue;
// import java.util.concurrent.Callable;
// import java.util.concurrent.ExecutionException;
// import java.util.concurrent.Future;
// import java.util.concurrent.ThreadPoolExecutor;
// import java.util.concurrent.TimeUnit;


import hunt.redis.HostAndPort;
import hunt.redis.Redis;
import hunt.redis.RedisCluster;
import hunt.redis.ClusterReset;
import hunt.redis.Exceptions;
import hunt.redis.RedisClusterInfoCache;
import hunt.redis.RedisPool;
import hunt.redis.RedisPoolConfig;
// import hunt.redis.exceptions.*;
// import hunt.redis.tests.utils.ClientKillerUtil;
// import hunt.redis.tests.utils.RedisClusterTestUtil;
import hunt.redis.util.RedisClusterCRC16;


class RedisClusterTest {
    private static Redis node1;
    private static Redis node2;
    private static Redis node3;
    private static Redis node4;
    private static Redis nodeSlave2;
    private enum string RedisServerHost = "10.1.222.120"; // "127.0.0.1";
    private enum RedisServerPort = 6380; // 6379;
    private string RedisPassword = "foobared";

    private enum int DEFAULT_TIMEOUT = 2000;
    private enum int DEFAULT_REDIRECTIONS = 5;
    private RedisPoolConfig DEFAULT_CONFIG;

    private HostAndPort nodeInfo1;
    private HostAndPort nodeInfo2;
    private HostAndPort nodeInfo3;
    private HostAndPort nodeInfo4;
    private HostAndPort nodeInfoSlave2;

    this() {
        DEFAULT_CONFIG = new RedisPoolConfig();

        nodeInfo1 = HostAndPortUtil.getClusterServers().get(0);
        nodeInfo2 = HostAndPortUtil.getClusterServers().get(1);
        nodeInfo3 = HostAndPortUtil.getClusterServers().get(2);
        nodeInfo4 = HostAndPortUtil.getClusterServers().get(3);
        nodeInfoSlave2 = HostAndPortUtil.getClusterServers().get(4);        
    }

    @Before
    void setUp() {
        // node1 = new Redis(nodeInfo1);
        // node1.auth(RedisPassword);
        // node1.flushAll();

        // node2 = new Redis(nodeInfo2);
        // node2.auth(RedisPassword);
        // node2.flushAll();

        // node3 = new Redis(nodeInfo3);
        // node3.auth(RedisPassword);
        // node3.flushAll();

        // node4 = new Redis(nodeInfo4);
        // node4.auth(RedisPassword);
        // node4.flushAll();

        // nodeSlave2 = new Redis(nodeInfoSlave2);
        // nodeSlave2.auth(RedisPassword);
        // nodeSlave2.flushAll();


        // // ---- configure cluster
        // node1.clusterReset(ClusterReset.SOFT);
        // node2.clusterReset(ClusterReset.SOFT);
        // node3.clusterReset(ClusterReset.SOFT);
        // node4.clusterReset(ClusterReset.SOFT);  

        // // add nodes to cluster
        // node1.clusterMeet(RedisServerHost, nodeInfo2.getPort());
        // node1.clusterMeet(RedisServerHost, nodeInfo3.getPort());

        // // split available slots across the three nodes
        // int slotsPerNode = RedisCluster.HASHSLOTS / 3;
        // int[] node1Slots = new int[slotsPerNode];
        // int[] node2Slots = new int[slotsPerNode + 1];
        // int[] node3Slots = new int[slotsPerNode];
        // for (int i = 0, slot1 = 0, slot2 = 0, slot3 = 0; i < RedisCluster.HASHSLOTS; i++) {
        //     if (i < slotsPerNode) {
        //         node1Slots[slot1++] = i;
        //     } else if (i > slotsPerNode * 2) {
        //         node3Slots[slot3++] = i;
        //     } else {
        //         node2Slots[slot2++] = i;
        //     }
        // }

        // node1.clusterAddSlots(node1Slots);
        // node2.clusterAddSlots(node2Slots);
        // node3.clusterAddSlots(node3Slots);

        // RedisClusterTestUtil.waitForClusterReady(node1, node2, node3);
    }

    @AfterClass
    static void cleanUp() {
        // node1.flushDB();
        // node2.flushDB();
        // node3.flushDB();
        // node4.flushDB();

        // node1.clusterReset(ClusterReset.SOFT);
        // node2.clusterReset(ClusterReset.SOFT);
        // node3.clusterReset(ClusterReset.SOFT);
        // node4.clusterReset(ClusterReset.SOFT);
    }

    @After
    void tearDown() {
        cleanUp();
    }

    // @TestWith!(RedisMovedDataException)
    // void testThrowMovedException() {
    //     warning("running here");
    //     node1.set("foo", "bar");
    //     info("running here");
    // }

    // @Test
    // void testMovedExceptionParameters() {
    //     try {
    //         node1.set("foo", "bar");
    //     } catch (RedisMovedDataException jme) {
    //         infof("slot: %d", jme.getSlot());
    //         assertEquals(12182, jme.getSlot());
    //         warning(jme.getTargetNode().toString());
    //         // assertEquals(new HostAndPort(RedisServerHost, 7381), jme.getTargetNode());
    //         return;
    //     }
    //     fail();
    // }

    // @TestWith!(RedisAskDataException)
    // void testThrowAskException() {
    //     int keySlot = RedisClusterCRC16.getSlot("test");
    //     string node3Id = RedisClusterTestUtil.getNodeId(node3.clusterNodes());
    //     node2.clusterSetSlotMigrating(keySlot, node3Id);
    //     node2.get("test");
    // }

    // @Test
    // void testDiscoverNodesAutomatically() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     // jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     int size = jc.getClusterNodes().size();
    //     warningf("Cluster size: %d", size);
    //     assertEquals(3, size);

    //     RedisCluster jc2 = new RedisCluster(new HostAndPort(RedisServerHost, RedisServerPort), DEFAULT_TIMEOUT,
    //             DEFAULT_TIMEOUT, DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     warningf("Cluster size: %d",jc2.getClusterNodes().size());
    //     assertEquals(3, jc2.getClusterNodes().size());
    // }

    @Test
    void testSetClientName() {
        Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
        jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
        string clientName = "myAppName";
        RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
                DEFAULT_REDIRECTIONS, RedisPassword, clientName, DEFAULT_CONFIG);

        Map!(string, RedisPool) clusterNodes = jc.getClusterNodes();
        RedisPool[] values = clusterNodes.values();
        tracef("pool size: %d", values.length);
        foreach (RedisPool jedisPool ; values) {
            Redis jedis = jedisPool.getResource();
            try {
                warningf("%s, %s", jedis.toString(), jedis.clientGetname());
                assertEquals(clientName, jedis.clientGetname());
            } catch(Throwable t) {
                warning(t);
            } finally {
                jedis.close();
            }
        }
    }

    // @Test
    // void testCalculateConnectionPerSlot() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     jc.set("foo", "bar");
    //     jc.set("test", "test");
    //     assertEquals("bar", node3.get("foo"));
    //     assertEquals("test", node2.get("test"));

    //     RedisCluster jc2 = new RedisCluster(new HostAndPort(RedisServerHost, RedisServerPort), DEFAULT_TIMEOUT,
    //             DEFAULT_TIMEOUT, DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     jc2.set("foo", "bar");
    //     jc2.set("test", "test");
    //     assertEquals("bar", node3.get("foo"));
    //     assertEquals("test", node2.get("test"));
    // }

    // @Test
    // void testReadonly() throws Exception {
    //     node1.clusterMeet(RedisServerHost, nodeInfoSlave2.getPort());
    //     RedisClusterTestUtil.waitForClusterReady(node1, node2, node3, nodeSlave2);

    //     for (string nodeInfo : node2.clusterNodes().split("\n")) {
    //         if (nodeInfo.contains("myself")) {
    //             nodeSlave2.clusterReplicate(nodeInfo.split(" ")[0]);
    //             break;
    //         }
    //     }
    //     try {
    //         nodeSlave2.get("test");
    //         fail();
    //     } catch (RedisMovedDataException e) {
    //     }
    //     nodeSlave2.readonly();
    //     nodeSlave2.get("test");

    //     nodeSlave2.clusterReset(ClusterReset.SOFT);
    //     nodeSlave2.flushDB();
    // }

    // /**
    //  * slot->nodes 15363 node3 e
    //  */
    // @Test
    // void testMigrate() {
    //     log.info("test migrate slot");
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(nodeInfo1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     string node3Id = RedisClusterTestUtil.getNodeId(node3.clusterNodes());
    //     string node2Id = RedisClusterTestUtil.getNodeId(node2.clusterNodes());
    //     node3.clusterSetSlotMigrating(15363, node2Id);
    //     node2.clusterSetSlotImporting(15363, node3Id);
    //     try {
    //         node2.set("e", "e");
    //     } catch (RedisMovedDataException jme) {
    //         assertEquals(15363, jme.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo3.getPort()), jme.getTargetNode());
    //     }

    //     try {
    //         node3.set("e", "e");
    //     } catch (RedisAskDataException jae) {
    //         assertEquals(15363, jae.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo2.getPort()), jae.getTargetNode());
    //     }

    //     jc.set("e", "e");

    //     try {
    //         node2.get("e");
    //     } catch (RedisMovedDataException jme) {
    //         assertEquals(15363, jme.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo3.getPort()), jme.getTargetNode());
    //     }
    //     try {
    //         node3.get("e");
    //     } catch (RedisAskDataException jae) {
    //         assertEquals(15363, jae.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo2.getPort()), jae.getTargetNode());
    //     }

    //     assertEquals("e", jc.get("e"));

    //     node2.clusterSetSlotNode(15363, node2Id);
    //     node3.clusterSetSlotNode(15363, node2Id);
    //     // assertEquals("e", jc.get("e"));
    //     assertEquals("e", node2.get("e"));

    //     // assertEquals("e", node3.get("e"));

    // }

    // @Test
    // void testMigrateToNewNode() {
    //     log.info("test migrate slot to new node");
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(nodeInfo1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     node4.clusterMeet(RedisServerHost, nodeInfo1.getPort());

    //     string node3Id = RedisClusterTestUtil.getNodeId(node3.clusterNodes());
    //     string node4Id = RedisClusterTestUtil.getNodeId(node4.clusterNodes());
    //     RedisClusterTestUtil.waitForClusterReady(node4);
    //     node3.clusterSetSlotMigrating(15363, node4Id);
    //     node4.clusterSetSlotImporting(15363, node3Id);
    //     try {
    //         node4.set("e", "e");
    //     } catch (RedisMovedDataException jme) {
    //         assertEquals(15363, jme.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo3.getPort()), jme.getTargetNode());
    //     }

    //     try {
    //         node3.set("e", "e");
    //     } catch (RedisAskDataException jae) {
    //         assertEquals(15363, jae.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo4.getPort()), jae.getTargetNode());
    //     }

    //     jc.set("e", "e");

    //     try {
    //         node4.get("e");
    //     } catch (RedisMovedDataException jme) {
    //         assertEquals(15363, jme.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo3.getPort()), jme.getTargetNode());
    //     }
    //     try {
    //         node3.get("e");
    //     } catch (RedisAskDataException jae) {
    //         assertEquals(15363, jae.getSlot());
    //         assertEquals(new HostAndPort(RedisServerHost, nodeInfo4.getPort()), jae.getTargetNode());
    //     }

    //     assertEquals("e", jc.get("e"));

    //     node4.clusterSetSlotNode(15363, node4Id);
    //     node3.clusterSetSlotNode(15363, node4Id);
    //     // assertEquals("e", jc.get("e"));
    //     assertEquals("e", node4.get("e"));

    //     // assertEquals("e", node3.get("e"));

    // }

    // @Test
    // void testRecalculateSlotsWhenMoved() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     int slot51 = RedisClusterCRC16.getSlot("51");
    //     node2.clusterDelSlots(slot51);
    //     node3.clusterDelSlots(slot51);
    //     node3.clusterAddSlots(slot51);

    //     RedisClusterTestUtil.waitForClusterReady(node1, node2, node3);
    //     jc.set("51", "foo");
    //     assertEquals("foo", jc.get("51"));
    // }

    // @Test
    // void testAskResponse() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     int slot51 = RedisClusterCRC16.getSlot("51");
    //     node3.clusterSetSlotImporting(slot51, RedisClusterTestUtil.getNodeId(node2.clusterNodes()));
    //     node2.clusterSetSlotMigrating(slot51, RedisClusterTestUtil.getNodeId(node3.clusterNodes()));
    //     jc.set("51", "foo");
    //     assertEquals("foo", jc.get("51"));
    // }

    // @Test(expected = RedisClusterMaxAttemptsException.class)
    // void testRedisClusterMaxRedirections() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     int slot51 = RedisClusterCRC16.getSlot("51");
    //     // This will cause an infinite redirection loop
    //     node2.clusterSetSlotMigrating(slot51, RedisClusterTestUtil.getNodeId(node3.clusterNodes()));
    //     jc.set("51", "foo");
    // }

    // @Test
    // void testClusterForgetNode() {
    //     // at first, join node4 to cluster
    //     node1.clusterMeet(RedisServerHost, nodeInfo4.getPort());

    //     string node7Id = RedisClusterTestUtil.getNodeId(node4.clusterNodes());

    //     RedisClusterTestUtil.assertNodeIsKnown(node3, node7Id, 1000);
    //     RedisClusterTestUtil.assertNodeIsKnown(node2, node7Id, 1000);
    //     RedisClusterTestUtil.assertNodeIsKnown(node1, node7Id, 1000);

    //     assertNodeHandshakeEnded(node3, 1000);
    //     assertNodeHandshakeEnded(node2, 1000);
    //     assertNodeHandshakeEnded(node1, 1000);

    //     assertEquals(4, node1.clusterNodes().split("\n").length);
    //     assertEquals(4, node2.clusterNodes().split("\n").length);
    //     assertEquals(4, node3.clusterNodes().split("\n").length);

    //     // do cluster forget
    //     node1.clusterForget(node7Id);
    //     node2.clusterForget(node7Id);
    //     node3.clusterForget(node7Id);

    //     RedisClusterTestUtil.assertNodeIsUnknown(node1, node7Id, 1000);
    //     RedisClusterTestUtil.assertNodeIsUnknown(node2, node7Id, 1000);
    //     RedisClusterTestUtil.assertNodeIsUnknown(node3, node7Id, 1000);

    //     assertEquals(3, node1.clusterNodes().split("\n").length);
    //     assertEquals(3, node2.clusterNodes().split("\n").length);
    //     assertEquals(3, node3.clusterNodes().split("\n").length);
    // }

    // @Test
    // void testClusterFlushSlots() {
    //     string slotRange = getNodeServingSlotRange(node1.clusterNodes());
    //     assertNotNull(slotRange);

    //     try {
    //         node1.clusterFlushSlots();
    //         assertNull(getNodeServingSlotRange(node1.clusterNodes()));
    //     } finally {
    //         // rollback
    //         string[] rangeInfo = slotRange.split("-");
    //         int lower = Integer.parseInt(rangeInfo[0]);
    //         int upper = Integer.parseInt(rangeInfo[1]);

    //         int[] node1Slots = new int[upper - lower + 1];
    //         for (int i = 0; lower <= upper;) {
    //             node1Slots[i++] = lower++;
    //         }
    //         node1.clusterAddSlots(node1Slots);
    //     }
    // }

    // @Test
    // void testClusterKeySlot() {
    //     // It assumes RedisClusterCRC16 is correctly implemented
    //     assertEquals(RedisClusterCRC16.getSlot("{user1000}.following"),
    //             node1.clusterKeySlot("{user1000}.following").intValue());
    //     assertEquals(RedisClusterCRC16.getSlot("foo{bar}{zap}"),
    //             node1.clusterKeySlot("foo{bar}{zap}").intValue());
    //     assertEquals(RedisClusterCRC16.getSlot("foo{}{bar}"),
    //             node1.clusterKeySlot("foo{}{bar}").intValue());
    //     assertEquals(RedisClusterCRC16.getSlot("foo{{bar}}zap"),
    //             node1.clusterKeySlot("foo{{bar}}zap").intValue());
    // }

    // @Test
    // void testClusterCountKeysInSlot() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(nodeInfo1.getHost(), nodeInfo1.getPort()));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);

    //     int count = 5;
    //     for (int index = 0; index < count; index++) {
    //         jc.set("foo{bar}" + index, "hello");
    //     }

    //     int slot = RedisClusterCRC16.getSlot("foo{bar}");
    //     assertEquals(count, node1.clusterCountKeysInSlot(slot).intValue());
    // }

    // @Test
    // void testStableSlotWhenMigratingNodeOrImportingNodeIsNotSpecified()
    //         {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(nodeInfo1.getHost(), nodeInfo1.getPort()));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);

    //     int slot51 = RedisClusterCRC16.getSlot("51");
    //     jc.set("51", "foo");
    //     // node2 is responsible of taking care of slot51 (7186)

    //     node3.clusterSetSlotImporting(slot51, RedisClusterTestUtil.getNodeId(node2.clusterNodes()));
    //     assertEquals("foo", jc.get("51"));
    //     node3.clusterSetSlotStable(slot51);
    //     assertEquals("foo", jc.get("51"));

    //     node2.clusterSetSlotMigrating(slot51, RedisClusterTestUtil.getNodeId(node3.clusterNodes()));
    //     // assertEquals("foo", jc.get("51")); // it leads Max Redirections
    //     node2.clusterSetSlotStable(slot51);
    //     assertEquals("foo", jc.get("51"));
    // }

    // @Test(expected = RedisExhaustedPoolException.class)
    // void testIfPoolConfigAppliesToClusterPools() {
    //     GenericObjectPoolConfig config = new GenericObjectPoolConfig();
    //     config.setMaxTotal(0);
    //     config.setMaxWaitMillis(DEFAULT_TIMEOUT);
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, config);
    //     jc.set("52", "poolTestValue");
    // }

    // @Test
    // void testCloseable() throws IOException {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(nodeInfo1.getHost(), nodeInfo1.getPort()));

    //     RedisCluster jc = null;
    //     try {
    //         jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //                 DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //         jc.set("51", "foo");
    //     } finally {
    //         if (jc != null) {
    //             jc.close();
    //         }
    //     }

    //     Iterator!(RedisPool) poolIterator = jc.getClusterNodes().values().iterator();
    //     while (poolIterator.hasNext()) {
    //         RedisPool pool = poolIterator.next();
    //         try {
    //             pool.getResource();
    //             fail("RedisCluster's internal pools should be already destroyed");
    //         } catch (RedisConnectionException e) {
    //             // ok to go...
    //         }
    //     }
    // }

    // @Test
    // void testRedisClusterTimeout() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(nodeInfo1.getHost(), nodeInfo1.getPort()));

    //     RedisCluster jc = new RedisCluster(jedisClusterNode, 4000, 4000, DEFAULT_REDIRECTIONS,
    //             RedisPassword, DEFAULT_CONFIG);

    //     for (RedisPool pool : jc.getClusterNodes().values()) {
    //         Redis jedis = pool.getResource();
    //         assertEquals(4000, jedis.getClient().getConnectionTimeout());
    //         assertEquals(4000, jedis.getClient().getSoTimeout());
    //         jedis.close();
    //     }
    // }

    // @Test
    // void testRedisClusterRunsWithMultithreaded() throws InterruptedException,
    //         ExecutionException, IOException {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     final RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);
    //     jc.set("foo", "bar");

    //     ThreadPoolExecutor executor = new ThreadPoolExecutor(10, 100, 0, TimeUnit.SECONDS,
    //             new ArrayBlockingQueue!(Runnable)(10));
    //     List!(Future!(string)) futures = new ArrayList!(Future!(string))();
    //     for (int i = 0; i < 50; i++) {
    //         executor.submit(new Callable!(string)() {
    //             override
    //             string call() throws Exception {
    //                 // FIXME : invalidate slot cache from RedisCluster to test
    //                 // random connection also does work
    //                 return jc.get("foo");
    //             }
    //         });
    //     }

    //     for (Future!(string) future : futures) {
    //         string value = future.get();
    //         assertEquals("bar", value);
    //     }

    //     jc.close();
    // }

    // @Test(timeout = DEFAULT_TIMEOUT)
    // void testReturnConnectionOnRedisConnectionException() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setMaxTotal(1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, config);

    //     Redis j = jc.getClusterNodes().get("127.0.0.1:7380").getResource();
    //     ClientKillerUtil.tagClient(j, "DEAD");
    //     ClientKillerUtil.killClient(j, "DEAD");
    //     j.close();

    //     jc.get("test");
    // }

    // @Test(expected = RedisClusterMaxAttemptsException.class, timeout = DEFAULT_TIMEOUT)
    // void testReturnConnectionOnRedirection() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setMaxTotal(1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, 0, 2, DEFAULT_REDIRECTIONS, RedisPassword,
    //             config);

    //     // This will cause an infinite redirection between node 2 and 3
    //     node3.clusterSetSlotMigrating(15363, RedisClusterTestUtil.getNodeId(node2.clusterNodes()));
    //     jc.get("e");
    // }

    // @Test
    // void testLocalhostNodeNotAddedWhen127Present() {
    //     HostAndPort localhost = new HostAndPort("localhost", RedisServerPort);
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     // cluster node is defined as 127.0.0.1; adding localhost should work,
    //     // but shouldn't show up.
    //     jedisClusterNode.add(localhost);
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setMaxTotal(1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, 0, 2, DEFAULT_REDIRECTIONS, RedisPassword,
    //             DEFAULT_CONFIG);
    //     Map!(string, RedisPool) clusterNodes = jc.getClusterNodes();
    //     assertEquals(3, clusterNodes.size());
    //     assertFalse(clusterNodes.containsKey(RedisClusterInfoCache.getNodeKey(localhost)));
    // }

    // @Test
    // void testInvalidStartNodeNotAdded() {
    //     HostAndPort invalidHost = new HostAndPort("not-a-real-host", RedisServerPort);
    //     Set!(HostAndPort) jedisClusterNode = new LinkedHashSet!(HostAndPort)();
    //     jedisClusterNode.add(invalidHost);
    //     jedisClusterNode.add(new HostAndPort(RedisServerHost, RedisServerPort));
    //     RedisPoolConfig config = new RedisPoolConfig();
    //     config.setMaxTotal(1);
    //     RedisCluster jc = new RedisCluster(jedisClusterNode, 0, 2, DEFAULT_REDIRECTIONS, RedisPassword,
    //             config);
    //     Map!(string, RedisPool) clusterNodes = jc.getClusterNodes();
    //     assertEquals(3, clusterNodes.size());
    //     assertFalse(clusterNodes.containsKey(RedisClusterInfoCache.getNodeKey(invalidHost)));
    // }

    // @Test
    // void nullKeys() {
    //     Set!(HostAndPort) jedisClusterNode = new HashSet!(HostAndPort)();
    //     jedisClusterNode.add(new HostAndPort(nodeInfo1.getHost(), nodeInfo1.getPort()));
    //     RedisCluster cluster = new RedisCluster(jedisClusterNode, DEFAULT_TIMEOUT, DEFAULT_TIMEOUT,
    //             DEFAULT_REDIRECTIONS, RedisPassword, DEFAULT_CONFIG);

    //     string foo = "foo";
    //     byte[] bfoo = new byte[]{0x0b, 0x0f, 0x00, 0x00};

    //     try {
    //         cluster.exists((string) null);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }

    //     try {
    //         cluster.exists(foo, null);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }

    //     try {
    //         cluster.exists(null, foo);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }

    //     try {
    //         cluster.exists((byte[]) null);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }

    //     try {
    //         cluster.exists(bfoo, null);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }

    //     try {
    //         cluster.exists(null, bfoo);
    //         fail();
    //     } catch (RedisClusterOperationException coe) {
    //         // expected
    //     }
    // }

    // private static string getNodeServingSlotRange(string infoOutput) {
    //     // f4f3dc4befda352a4e0beccf29f5e8828438705d 127.0.0.1:7380 master - 0
    //     // 1394372400827 0 connected 5461-10922
    //     for (string infoLine : infoOutput.split("\n")) {
    //         if (infoLine.contains("myself")) {
    //             try {
    //                 return infoLine.split(" ")[8];
    //             } catch (ArrayIndexOutOfBoundsException e) {
    //                 return null;
    //             }
    //         }
    //     }
    //     return null;
    // }

    // private void assertNodeHandshakeEnded(Redis node, int timeoutMs) {
    //     int sleepInterval = 100;
    //     for (int sleepTime = 0; sleepTime <= timeoutMs; sleepTime += sleepInterval) {
    //         bool isHandshaking = isAnyNodeHandshaking(node);
    //         if (!isHandshaking) return;

    //         try {
    //             Thread.sleep(sleepInterval);
    //         } catch (InterruptedException e) {
    //         }
    //     }

    //     throw new RedisException("Node handshaking is not ended");
    // }

    // private bool isAnyNodeHandshaking(Redis node) {
    //     string infoOutput = node.clusterNodes();
    //     for (string infoLine : infoOutput.split("\n")) {
    //         if (infoLine.contains("handshake")) {
    //             return true;
    //         }
    //     }
    //     return false;
    // }
}
