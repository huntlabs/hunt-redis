module hunt.redis.util.RedisURIHelper;

class RedisURIHelper {

  private enum int DEFAULT_DB = 0;

  private enum string REDIS = "redis";
  private enum string REDISS = "rediss";

  private RedisURIHelper(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static string getPassword(URI uri) {
    string userInfo = uri.getUserInfo();
    if (userInfo !is null) {
      return userInfo.split(":", 2)[1];
    }
    return null;
  }

  static int getDBIndex(URI uri) {
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

  static bool isValid(URI uri) {
    if (isEmpty(uri.getScheme()) || isEmpty(uri.getHost()) || uri.getPort() == -1) {
      return false;
    }

    return true;
  }

  private static bool isEmpty(string value) {
    return value is null || value.trim().length() == 0;
  }

  static bool isRedisScheme(URI uri) {
    return REDIS == uri.getScheme();
  }

  static bool isRedisSSLScheme(URI uri) {
    return REDISS == uri.getScheme();
  }

}
