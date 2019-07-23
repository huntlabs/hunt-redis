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
 
module hunt.redis.commands.BasicRedisPipeline;

import hunt.redis.Module;
import hunt.redis.Response;

import hunt.collection.List;
import hunt.Long;

/**
 * Pipelined responses for all of the low level, non key related commands
 */
interface BasicRedisPipeline {

  Response!(string) bgrewriteaof();

  Response!(string) bgsave();

  Response!(List!(string)) configGet(string pattern);

  Response!(string) configSet(string parameter, string value);

  Response!(string) configResetStat();

  Response!(string) save();

  Response!(Long) lastsave();

  Response!(string) flushDB();

  Response!(string) flushAll();

  Response!(string) info();

  Response!(List!(string)) time();

  Response!(Long) dbSize();

  Response!(string) shutdown();

  Response!(string) ping();

  Response!(string) select(int index);

  Response!(string) swapDB(int index1, int index2);

  Response!(string) migrate(string host, int port, string key, int destinationDB, int timeout);

  Response!(string) moduleLoad(string path);

  Response!(List!(Module)) moduleList();

  Response!(string) moduleUnload(string name);

}
