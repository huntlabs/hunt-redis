module hunt.redis.DebugParams;

class DebugParams {
  private string[] command;

  private this() {

  }

  string[] getCommand() {
    return command;
  }
  
  static DebugParams SEGFAULT() {
    DebugParams debugParams = new DebugParams();
    debugParams.command = ["SEGFAULT"];
    return debugParams;
  }

  static DebugParams OBJECT(string key) {
    DebugParams debugParams = new DebugParams();
    debugParams.command = ["OBJECT", key];
    return debugParams;
  }

  static DebugParams RELOAD() {
    DebugParams debugParams = new DebugParams();
    debugParams.command = ["RELOAD"];
    return debugParams;
  }
}
