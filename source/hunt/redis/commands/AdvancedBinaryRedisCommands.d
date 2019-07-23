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
 
module hunt.redis.commands.AdvancedBinaryRedisCommands;

import hunt.collection.List;

import hunt.redis.params.MigrateParams;
import hunt.redis.params.ClientKillParams;


interface AdvancedBinaryRedisCommands {

  List!(const(ubyte)[]) configGet(const(ubyte)[] pattern);

  const(ubyte)[] configSet(const(ubyte)[] parameter, const(ubyte)[] value);

  string slowlogReset();

  long slowlogLen();

  List!(const(ubyte)[]) slowlogGetBinary();

  List!(const(ubyte)[]) slowlogGetBinary(long entries);

  long objectRefcount(const(ubyte)[] key);

  const(ubyte)[] objectEncoding(const(ubyte)[] key);

  long objectIdletime(const(ubyte)[] key);

  string migrate(string host, int port, const(ubyte)[] key, int destinationDB, int timeout);

  string migrate(string host, int port, int destinationDB, int timeout, MigrateParams params, const(ubyte)[][] keys...);

  string clientKill(const(ubyte)[] ipPort);

  string clientKill(string ip, int port);

  long clientKill(ClientKillParams params);

  const(ubyte)[] clientGetnameBinary();

  const(ubyte)[] clientListBinary();

  string clientSetname(const(ubyte)[] name);

  const(ubyte)[] memoryDoctorBinary();
}
