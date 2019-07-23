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
 
module hunt.redis.commands.BinaryScriptingCommands;

import hunt.collection.List;

interface BinaryScriptingCommands {

  Object eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...);

  Object eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...);

  Object eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

  Object eval(const(ubyte)[] script);

  Object evalsha(const(ubyte)[] sha1);

  Object evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

  Object evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...);

  // TODO: should be Boolean, add singular version
  List!(long) scriptExists(const(ubyte)[][] sha1...);

  const(ubyte)[] scriptLoad(const(ubyte)[] script);

  string scriptFlush();

  string scriptKill();
}
