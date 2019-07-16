module hunt.redis.Module;

class Module {
  private string name;
  private int ver;

  this(string name, int ver) {
    this.name = name;
    this.ver = ver;
  }


  string getName() {
    return name;
  }

  int getVersion() {
    return ver;
  }

  override
  bool opEquals(Object o) {
    if (o is null) return false;
    if (o is this) return true;

    Module mod = cast(Module) o;
    if(mod is null) 
      return false;

    if (ver != mod.ver) return false;
    return name == mod.name;

  }

  override
  size_t toHash() @trusted nothrow {
    size_t result = name !is null ? name.hashOf() : 0;
    result = 31 * result + ver;
    return result;
  }


}
