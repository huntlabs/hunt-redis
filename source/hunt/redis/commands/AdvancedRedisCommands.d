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
 
module hunt.redis.commands.AdvancedRedisCommands;

import hunt.collection.List;

import hunt.redis.params.MigrateParams;
import hunt.redis.params.ClientKillParams;
import hunt.redis.util.Slowlog;

interface AdvancedRedisCommands {
    List!(string) configGet(string pattern);

    string configSet(string parameter, string value);

    string slowlogReset();

    long slowlogLen();

    List!(Slowlog) slowlogGet();

    List!(Slowlog) slowlogGet(long entries);

    long objectRefcount(string key);

    string objectEncoding(string key);

    long objectIdletime(string key);

    string migrate(string host, int port, string key, int destinationDB, int timeout);

    string migrate(string host, int port, int destinationDB, int timeout,
            MigrateParams params, string[] keys...);

    string clientKill(string ipPort);

    string clientKill(string ip, int port);

    long clientKill(ClientKillParams params);

    string clientGetname();

    string clientList();

    string clientSetname(string name);

    string memoryDoctor();
}
