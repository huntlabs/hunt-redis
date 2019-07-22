module hunt.redis.commands.BinaryScriptingCommandsPipeline;

import hunt.redis.Response;

import hunt.collection.List;

interface BinaryScriptingCommandsPipeline {

  Response!(Object) eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...);

  Response!(Object) eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...);

  Response!(Object) eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

  Response!(Object) eval(const(ubyte)[] script);

  Response!(Object) evalsha(const(ubyte)[] sha1);

  Response!(Object) evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

  Response!(Object) evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...);
}
