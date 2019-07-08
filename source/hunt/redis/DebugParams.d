module hunt.redis.DebugParams;

class DebugParams {
  private String[] command;

  private DebugParams() {

  }

  String[] getCommand() {
    return command;
  }
  
  static DebugParams SEGFAULT() {
    DebugParams debugParams = new DebugParams();
    debugParams.command = new String[] { "SEGFAULT" };
    return debugParams;
  }

  static DebugParams OBJECT(String key) {
    DebugParams debugParams = new DebugParams();
    debugParams.command = new String[] { "OBJECT", key };
    return debugParams;
  }

  static DebugParams RELOAD() {
    DebugParams debugParams = new DebugParams();
    debugParams.command = new String[] { "RELOAD" };
    return debugParams;
  }
}
