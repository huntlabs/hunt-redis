module hunt.redis.Module;

class Module {
  private String name;
  private int version;

  Module(String name, int version) {
    this.name = name;
    this.version = version;
  }


  String getName() {
    return name;
  }

  int getVersion() {
    return version;
  }

  override
  bool equals(Object o) {
    if (o == null) return false;
    if (o == this) return true;
    if (!(o instanceof Module)) return false;

    Module module = (Module) o;

    if (version != module.version) return false;
    return !(name != null ? !name == module.name : module.name != null);

  }

  override
  size_t toHash() @trusted nothrow() {
    int result = name != null ? name.hashCode() : 0;
    result = 31 * result + version;
    return result;
  }


}
