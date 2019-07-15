module hunt.redis.commands.ClusterCommands;

import hunt.collection.List;
import hunt.Long;

import hunt.redis.ClusterReset;

public interface ClusterCommands {
  string clusterNodes();

  string clusterMeet(string ip, int port);

  string clusterAddSlots(int[] slots...);

  string clusterDelSlots(int[] slots...);

  string clusterInfo();

  List!(string) clusterGetKeysInSlot(int slot, int count);

  string clusterSetSlotNode(int slot, string nodeId);

  string clusterSetSlotMigrating(int slot, string nodeId);

  string clusterSetSlotImporting(int slot, string nodeId);

  string clusterSetSlotStable(int slot);

  string clusterForget(string nodeId);

  string clusterFlushSlots();

  Long clusterKeySlot(string key);

  Long clusterCountKeysInSlot(int slot);

  string clusterSaveConfig();

  string clusterReplicate(string nodeId);

  List!(string) clusterSlaves(string nodeId);

  string clusterFailover();

  List!(Object) clusterSlots();

  string clusterReset(ClusterReset resetType);

  string readonly();
}
