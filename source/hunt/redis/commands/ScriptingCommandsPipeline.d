module hunt.redis.commands.ScriptingCommandsPipeline;

import hunt.redis.Response;

import hunt.collection.List;

interface ScriptingCommandsPipeline {
  Response!(Object) eval(string script, int keyCount, string[] params...);

  Response!(Object) eval(string script, List!(string) keys, List!(string) args);

  Response!(Object) eval(string script);

  Response!(Object) evalsha(string sha1);

  Response!(Object) evalsha(string sha1, List!(string) keys, List!(string) args);

  Response!(Object) evalsha(string sha1, int keyCount, string[] params...);
}
