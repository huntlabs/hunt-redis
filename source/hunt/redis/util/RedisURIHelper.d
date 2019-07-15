module hunt.redis.util.RedisURIHelper;

import hunt.net.util.HttpURI;

class RedisURIHelper {

  private enum int DEFAULT_DB = 0;

  private enum string REDIS = "redis";
  private enum string REDISS = "rediss";

  private this(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static string getPassword(HttpURI uri) {
    string userInfo = uri.getUserInfo();
    if (userInfo !is null) {
      return userInfo.split(":", 2)[1];
    }
    return null;
  }

  static int getDBIndex(HttpURI uri) {
    string[] pathSplit = uri.getPath().split("/", 2);
    if (pathSplit.length > 1) {
      string dbIndexStr = pathSplit[1];
      if (dbIndexStr.isEmpty()) {
        return DEFAULT_DB;
      }
      return Integer.parseInt(dbIndexStr);
    } else {
      return DEFAULT_DB;
    }
  }

  static bool isValid(HttpURI uri) {
    if (isEmpty(uri.getScheme()) || isEmpty(uri.getHost()) || uri.getPort() == -1) {
      return false;
    }

    return true;
  }

  private static bool isEmpty(string value) {
    return value is null || value.trim().length() == 0;
  }

  static bool isRedisScheme(HttpURI uri) {
    return REDIS == uri.getScheme();
  }

  static bool isRedisSSLScheme(HttpURI uri) {
    return REDISS == uri.getScheme();
  }

}
