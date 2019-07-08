module hunt.redis.commands.ModuleCommands;

import hunt.redis.Module;

import hunt.collection.List;

public interface ModuleCommands {
  String moduleLoad(String path);
  String moduleUnload(String name);
  List!(Module) moduleList();
}
