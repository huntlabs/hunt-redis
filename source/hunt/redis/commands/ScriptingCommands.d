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
 
module hunt.redis.commands.ScriptingCommands;

import hunt.collection.List;

interface ScriptingCommands {
  Object eval(string script, int keyCount, string[] params...);

  Object eval(string script, List!(string) keys, List!(string) args);

  Object eval(string script);

  Object evalsha(string sha1);

  Object evalsha(string sha1, List!(string) keys, List!(string) args);

  Object evalsha(string sha1, int keyCount, string[] params...);

  bool scriptExists(string sha1);

  bool[] scriptExists(string[] sha1...);

  string scriptLoad(string script);
}
