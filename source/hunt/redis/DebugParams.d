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
