module hunt.redis.util.IOUtils;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
// import java.net.Socket;

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
