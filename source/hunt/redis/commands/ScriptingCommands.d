module hunt.redis.commands.ScriptingCommands;

import hunt.collection.List;

public interface ScriptingCommands {
  Object eval(string script, int keyCount, string[] params...);

  Object eval(string script, List!(string) keys, List!(string) args);

  Object eval(string script);

  Object evalsha(string sha1);

  Object evalsha(string sha1, List!(string) keys, List!(string) args);

  Object evalsha(string sha1, int keyCount, string[] params...);

  bool scriptExists(string sha1);

  List!(bool) scriptExists(string[] sha1...);

  string scriptLoad(string script);
}
