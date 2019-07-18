module hunt.redis.commands.SentinelCommands;

import hunt.collection.List;
import hunt.collection.Map;


interface SentinelCommands {
  List!(Map!(string, string)) sentinelMasters();

  List!(string) sentinelGetMasterAddrByName(string masterName);

  long sentinelReset(string pattern);

  List!(Map!(string, string)) sentinelSlaves(string masterName);

  string sentinelFailover(string masterName);

  string sentinelMonitor(string masterName, string ip, int port, int quorum);

  string sentinelRemove(string masterName);

  string sentinelSet(string masterName, Map!(string, string) parameterMap);
}
