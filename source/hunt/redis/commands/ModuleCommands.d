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
 
module hunt.redis.commands.ModuleCommands;

import hunt.redis.Module;

import hunt.collection.List;

interface ModuleCommands {
  string moduleLoad(string path);
  string moduleUnload(string name);
  List!(Module) moduleList();
}
