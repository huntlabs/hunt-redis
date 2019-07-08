module hunt.redis.commands.ModuleCommands;

import hunt.redis.Module;

import hunt.collection.List;

public interface ModuleCommands {
  string moduleLoad(string path);
  string moduleUnload(string name);
  List!(Module) moduleList();
}
