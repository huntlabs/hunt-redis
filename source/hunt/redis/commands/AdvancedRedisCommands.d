module hunt.redis.commands.AdvancedRedisCommands;

import hunt.collection.List;

import hunt.redis.params.MigrateParams;
import hunt.redis.params.ClientKillParams;
import hunt.redis.util.Slowlog;

import hunt.Long;

interface AdvancedRedisCommands {
  List!(string) configGet(string pattern);

  string configSet(string parameter, string value);

  string slowlogReset();

  Long slowlogLen();

  List!(Slowlog) slowlogGet();

  List!(Slowlog) slowlogGet(long entries);

  Long objectRefcount(string key);

  string objectEncoding(string key);

  Long objectIdletime(string key);

  string migrate(string host, int port, string key, int destinationDB, int timeout);

  string migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, string[] keys...);

  string clientKill(string ipPort);

  string clientKill(string ip, int port);

  Long clientKill(ClientKillParams params);

  string clientGetname();

  string clientList();

  string clientSetname(string name);

  string memoryDoctor();
}
