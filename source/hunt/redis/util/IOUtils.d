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
 
module hunt.redis.util.IOUtils;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import std.socket;

class IOUtils {
  private this() {
  }

  static void closeQuietly(Socket sock) {
    // It's same thing as Apache Commons - IOUtils.closeQuietly()
    if (sock !is null) {
      try {
        sock.close();
      } catch (IOException e) {
        version(HUNT_DEBUG) warning(e);
        // ignored
      }
    }
  }
}
