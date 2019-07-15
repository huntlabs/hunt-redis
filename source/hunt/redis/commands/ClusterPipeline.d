module hunt.redis.commands.ClusterPipeline;

import hunt.redis.Response;

import hunt.collection.List;

interface ClusterPipeline {
  Response!(string) clusterNodes();

  Response!(string) clusterMeet(string ip, int port);

  Response!(string) clusterAddSlots(int[] slots...);

  Response!(string) clusterDelSlots(int[] slots...);

  Response!(string) clusterInfo();

  Response!(List!(string)) clusterGetKeysInSlot(int slot, int count);

  Response!(string) clusterSetSlotNode(int slot, string nodeId);

  Response!(string) clusterSetSlotMigrating(int slot, string nodeId);

  Response!(string) clusterSetSlotImporting(int slot, string nodeId);
}
