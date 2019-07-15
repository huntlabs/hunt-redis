module hunt.redis.commands.AdvancedBinaryRedisCommands;

import hunt.collection.List;

import hunt.redis.params.MigrateParams;
import hunt.redis.params.ClientKillParams;

import hunt.Long;

interface AdvancedBinaryRedisCommands {

  List!(byte[]) configGet(byte[] pattern);

  byte[] configSet(byte[] parameter, byte[] value);

  string slowlogReset();

  Long slowlogLen();

  List!(byte[]) slowlogGetBinary();

  List!(byte[]) slowlogGetBinary(long entries);

  Long objectRefcount(byte[] key);

  byte[] objectEncoding(byte[] key);

  Long objectIdletime(byte[] key);

  string migrate(string host, int port, byte[] key, int destinationDB, int timeout);

  string migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, byte[] keys...);

  string clientKill(byte[] ipPort);

  string clientKill(string ip, int port);

  Long clientKill(ClientKillParams params);

  byte[] clientGetnameBinary();

  byte[] clientListBinary();

  string clientSetname(byte[] name);

  byte[] memoryDoctorBinary();
}
